import 'dart:convert';

class SmsRecord {
  const SmsRecord({
    required this.address,
    required this.body,
    required this.occurredAt,
  });

  final String address;
  final String body;
  final int occurredAt;
}

class CallLogRecord {
  const CallLogRecord({
    required this.number,
    required this.cachedName,
    required this.callType,
    required this.startedAt,
    required this.durationSec,
  });

  final String number;
  final String cachedName;
  final String callType;
  final int startedAt;
  final int durationSec;

  int get endedAt => startedAt + durationSec * 1000;
}

class NotificationRecord {
  const NotificationRecord({
    required this.pkg,
    required this.category,
    required this.title,
    required this.text,
    required this.postedAt,
    this.removedAt,
    this.extrasJson = '{}',
  });

  final String pkg;
  final String category;
  final String title;
  final String text;
  final int postedAt;
  final int? removedAt;
  final String extrasJson;
}

class ParsedChatMessage {
  const ParsedChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isSelf,
  });

  final String sender;
  final String text;
  final int time;
  final bool isSelf;
}

/// Normalises phone numbers with +880 (Bangladesh) as the default country code.
String normalizePhoneNumber(String raw, {String defaultCountryCode = '+880'}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final hasPlus = trimmed.startsWith('+');
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return trimmed.toLowerCase();

  if (hasPlus) {
    return '+$digits';
  }
  if (digits.startsWith('00') && digits.length > 4) {
    return '+${digits.substring(2)}';
  }
  if (digits.startsWith('880') && digits.length >= 13) {
    return '+$digits';
  }
  if (digits.startsWith('0') && digits.length == 11) {
    return '$defaultCountryCode${digits.substring(1)}';
  }
  if (digits.length == 10 && digits.startsWith('1')) {
    return '$defaultCountryCode$digits';
  }
  return digits;
}

String normalizeBodyForHash(String body) {
  return body
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');
}

int smsBodyHash(String body) {
  final norm = normalizeBodyForHash(body);
  // Deterministic 32-bit FNV-1a hash.
  var hash = 0x811c9dc5;
  for (final unit in norm.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

bool isSmsAppPackage(String pkg) {
  final lower = pkg.toLowerCase();
  return lower.contains('messaging') ||
      lower.contains('mms') ||
      lower.contains('sms');
}

/// Dedupe an SMS inbox row against an SMS notification by normalised address,
/// timestamp within 60 seconds, and deterministic body hash.
bool isDuplicateSmsNotification({
  required SmsRecord sms,
  required NotificationRecord notification,
}) {
  if (!isSmsAppPackage(notification.pkg) &&
      notification.category != 'msg') {
    return false;
  }
  final deltaMs = (sms.occurredAt - notification.postedAt).abs();
  if (deltaMs > 60 * 1000) return false;

  final smsNormAddr = normalizePhoneNumber(sms.address);
  final notifNormAddr = normalizePhoneNumber(notification.title);
  final addrMatch = smsNormAddr.isNotEmpty &&
      (smsNormAddr == notifNormAddr ||
          notification.title.toLowerCase().contains(sms.address.toLowerCase()) ||
          sms.address.toLowerCase().contains(notification.title.toLowerCase()));
  if (!addrMatch) return false;

  return smsBodyHash(sms.body) == smsBodyHash(notification.text);
}

bool isCallNotificationCategory(String category) {
  return category == 'call' || category == 'missed_call';
}

/// Drops a notification call when a call-log row overlaps it in time (tolerates
/// missing `removedAt` on the notification by using a 90-second window).
bool isOverlappingCallNotification({
  required CallLogRecord call,
  required NotificationRecord notification,
}) {
  if (!isCallNotificationCategory(notification.category)) return false;

  const toleranceMs = 90 * 1000;
  final callStart = call.startedAt - toleranceMs;
  final callEnd = call.endedAt + toleranceMs;
  final notifStart = notification.postedAt;
  final notifEnd = notification.removedAt ?? notification.postedAt;

  final overlapsTime = notifStart <= callEnd && notifEnd >= callStart;
  if (!overlapsTime) return false;

  final notifTitleLower = notification.title.trim().toLowerCase();
  final cachedLower = call.cachedName.trim().toLowerCase();
  final callNorm = normalizePhoneNumber(call.number);
  final notifNorm = normalizePhoneNumber(notification.title);

  if (callNorm.isNotEmpty && notifNorm.isNotEmpty && callNorm == notifNorm) {
    return true;
  }
  if (cachedLower.isNotEmpty &&
      notifTitleLower.isNotEmpty &&
      (notifTitleLower.contains(cachedLower) ||
          cachedLower.contains(notifTitleLower))) {
    return true;
  }
  // If the notification is from the native phone/dialer app and overlaps in time,
  // treat it as the same call even if contact formatting differs.
  final pkgLower = notification.pkg.toLowerCase();
  return pkgLower.contains('dialer') ||
      pkgLower.contains('telecom') ||
      pkgLower.contains('incallui');
}

/// Computes call length in seconds from notification lifetime when available,
/// returning null gracefully if `removedAt` is missing or invalid.
int? callDurationSecondsFromNotification(NotificationRecord notification) {
  final removed = notification.removedAt;
  if (removed == null || removed <= notification.postedAt) return null;
  return ((removed - notification.postedAt) / 1000).round();
}

/// Extracts chat messages and inline replies from notification `extrasJson`,
/// tolerating missing `messages` or missing `remoteInputHistory`.
List<ParsedChatMessage> extractChatMessagesFromExtras(
  String extrasJson, {
  required String fallbackSender,
  required String fallbackText,
  required int fallbackTime,
}) {
  final result = <ParsedChatMessage>[];
  final seenSelfTexts = <String>{};

  try {
    final decoded = jsonDecode(extrasJson);
    if (decoded is Map<String, dynamic>) {
      final rawMsgs = decoded['messages'];
      if (rawMsgs is List) {
        for (final entry in rawMsgs) {
          if (entry is Map) {
            final sender = entry['sender']?.toString().trim() ?? '';
            final text = entry['text']?.toString().trim() ?? '';
            final time = (entry['time'] as num?)?.toInt() ?? fallbackTime;
            final isSelf = entry['isSelf'] == true || sender.isEmpty;
            if (text.isNotEmpty) {
              if (isSelf) seenSelfTexts.add(text);
              result.add(
                ParsedChatMessage(
                  sender: sender,
                  text: text,
                  time: time,
                  isSelf: isSelf,
                ),
              );
            }
          }
        }
      }

      final rawReplies = decoded['remoteInputHistory'];
      if (rawReplies is List) {
        for (final reply in rawReplies) {
          final text = reply?.toString().trim() ?? '';
          if (text.isNotEmpty && !seenSelfTexts.contains(text)) {
            seenSelfTexts.add(text);
            result.add(
              ParsedChatMessage(
                sender: '',
                text: text,
                time: fallbackTime,
                isSelf: true,
              ),
            );
          }
        }
      }
    }
  } catch (_) {
    // Malformed extras fall back cleanly below.
  }

  if (result.isEmpty && fallbackText.trim().isNotEmpty) {
    result.add(
      ParsedChatMessage(
        sender: fallbackSender.trim(),
        text: fallbackText.trim(),
        time: fallbackTime,
        isSelf: false,
      ),
    );
  }
  return result;
}
