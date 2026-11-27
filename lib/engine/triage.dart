import 'package:intl/intl.dart';
import '../services/capture_metadata.dart';
import 'rules_loader.dart';

const int flagOngoingEvent = 0x00000002;
const int flagGroupSummary = 0x00000200;
const int reasonClick = 1;
const int reasonCancel = 2;

class TriageInput {
  const TriageInput({
    required this.source,
    this.pkg = '',
    this.channel = '',
    this.category = '',
    this.flags = 0,
    this.importance = 3,
    this.title = '',
    this.body = '',
    required this.postedAt,
    this.removedAt,
    this.removalReason,
    this.redacted = false,
    this.isConversation = false,
    this.isProgressTick = false,
    this.userKeepOverride,
    this.channelScore = 0,
  });

  final String source;
  final String pkg;
  final String channel;
  final String category;
  final int flags;
  final int importance;
  final String title;
  final String body;
  final int postedAt;
  final int? removedAt;
  final int? removalReason;
  final bool redacted;
  final bool isConversation;
  final bool isProgressTick;
  final String? userKeepOverride; // 'keep' | 'set_aside' | null
  final int channelScore;
}

class TriageResult {
  const TriageResult({
    required this.signalClass,
    required this.kept,
    required this.redacted,
    required this.title,
    required this.body,
    required this.reason,
  });

  final String signalClass;
  final bool kept;
  final bool redacted;
  final String title;
  final String body;
  final String reason;
}

class TriageEngine {
  TriageEngine(this.rules);

  final EngineRules rules;

  static final _otpPattern = RegExp(
    r'(?:\b(?:otp|one[\s\-]?time\s+(?:password|code|pin)|verification\s+code|security\s+code|login\s+code|auth\s+code|2fa\s+code)\b|(?:code|pin)\s*(?:is|:)\s*\d{4,8}\b|\b\d{4,8}\s+is\s+your\s+(?:otp|code|verification|pin))',
    caseSensitive: false,
  );

  static final _transactionPattern = RegExp(
    r'\b(?:tk\.?\s*[\d,]+|bdt\s*[\d,]+|৳\s*[\d,]+|trxid|txnid|recharge|send money|cash out|bill\s+due|debited|credited|payment\s+of|balance:?)',
    caseSensitive: false,
  );

  static final _orderPattern = RegExp(
    r'\b(?:order\s+(?:placed|confirmed|shipped|delivered)|out for delivery|parcel|shipment|tracking\s*(?:#|id|no)|foodpanda|daraz)\b',
    caseSensitive: false,
  );

  static final _travelPattern = RegExp(
    r'\b(?:ride\s+(?:completed|ended|receipt)|trip\s+(?:completed|receipt)|pathao|uber|boarding pass|flight)\b',
    caseSensitive: false,
  );

  static int updateChannelScore({
    required int currentScore,
    required int postedAt,
    int? removedAt,
    int? removalReason,
  }) {
    if (removalReason == reasonClick) {
      return currentScore + 1;
    }
    if (removalReason == reasonCancel &&
        removedAt != null &&
        removedAt >= postedAt &&
        (removedAt - postedAt) <= 10 * 1000) {
      return currentScore - 1;
    }
    return currentScore;
  }

  TriageResult evaluate(TriageInput input) {
    final combined = '${input.title} ${input.body}';

    // Non-notification sources map directly (except SMS which goes through OTP/promo/tx/conversation).
    if (input.source == 'call') {
      return TriageResult(
        signalClass: 'call',
        kept: true,
        redacted: false,
        title: input.title,
        body: input.body,
        reason: 'call_log',
      );
    }
    if (input.source == 'calendar') {
      return TriageResult(
        signalClass: 'calendar',
        kept: true,
        redacted: false,
        title: input.title,
        body: input.body,
        reason: 'calendar_instance',
      );
    }
    if (input.source == 'voice' || input.source == 'note') {
      return TriageResult(
        signalClass: 'conversation',
        kept: true,
        redacted: false,
        title: input.title,
        body: input.body,
        reason: input.source,
      );
    }
    if (input.source == 'bluetooth') {
      return TriageResult(
        signalClass: 'system',
        kept: false,
        redacted: false,
        title: input.title,
        body: input.body,
        reason: 'bluetooth_background',
      );
    }

    // 1. Redacted or OTP: always redact body and set aside.
    if (input.redacted || _otpPattern.hasMatch(combined)) {
      final appLabel = _friendlyApp(input.pkg, input.source);
      final timeStr = DateFormat('h:mm a')
          .format(DateTime.fromMillisecondsSinceEpoch(input.postedAt))
          .toLowerCase();
      return TriageResult(
        signalClass: 'otp',
        kept: false,
        redacted: true,
        title: 'sensitive event from $appLabel at $timeStr',
        body: '',
        reason: input.redacted ? 'redacted' : 'otp',
      );
    }

    // 2. Classify signal.
    final signalClass = _classify(input, combined);

    // 3. User override in app_rule always wins (except OTP/redacted handled above).
    if (input.userKeepOverride == 'keep') {
      return TriageResult(
        signalClass: signalClass,
        kept: true,
        redacted: false,
        title: input.title,
        body: input.body,
        reason: 'user_keep',
      );
    }
    if (input.userKeepOverride == 'set_aside') {
      return TriageResult(
        signalClass: signalClass,
        kept: false,
        redacted: false,
        title: input.title,
        body: input.body,
        reason: 'user_set_aside',
      );
    }

    // 4. Hard set-aside rules for notifications.
    if (input.source == 'notification') {
      if ((input.flags & flagGroupSummary) != 0) {
        return _setAside(signalClass, input, 'group_summary');
      }
      if (isScreenshotCaptureNotification(
        packageName: input.pkg,
        channelId: input.channel,
        title: input.title,
        content: input.body,
      )) {
        return _setAside('system', input, 'screenshot_notification');
      }
      if (input.isProgressTick && signalClass != 'call') {
        return _setAside(signalClass, input, 'ongoing_progress_tick');
      }
      if (input.importance <= 2 && signalClass != 'call') {
        return _setAside(signalClass, input, 'low_importance');
      }
      if (input.channelScore < -5) {
        return _setAside(signalClass, input, 'learned_channel_noise');
      }
    }

    if (signalClass == 'promo' ||
        signalClass == 'media' ||
        signalClass == 'system') {
      return _setAside(signalClass, input, signalClass);
    }

    final appSpec = rules.apps[input.pkg];
    if (appSpec != null && appSpec.keepPolicy == 'set_aside') {
      return _setAside(signalClass, input, 'app_rule_set_aside');
    }

    return TriageResult(
      signalClass: signalClass,
      kept: true,
      redacted: false,
      title: input.title,
      body: input.body,
      reason: 'kept_$signalClass',
    );
  }

  TriageResult _setAside(String cls, TriageInput input, String reason) {
    return TriageResult(
      signalClass: cls,
      kept: false,
      redacted: false,
      title: input.title,
      body: input.body,
      reason: reason,
    );
  }

  String _classify(TriageInput input, String combined) {
    final cat = input.category.toLowerCase();

    if (cat == 'call' || cat == 'missed_call') return 'call';
    if (cat == 'email') return 'email';
    if (cat == 'event' || cat == 'reminder') return 'calendar';
    if (cat == 'transport') return 'media';
    if (cat == 'promo' || cat == 'recommendation') return 'promo';
    if (cat == 'status' ||
        cat == 'service' ||
        cat == 'progress' ||
        cat == 'sys' ||
        cat == 'system') {
      return 'system';
    }

    if (isMarketingNotification(
      packageName: input.pkg,
      channelId: input.channel,
      title: input.title,
      content: input.body,
    )) {
      return 'promo';
    }

    final appSpec = rules.apps[input.pkg];
    if (appSpec != null) {
      if (appSpec.appClass == 'media' || appSpec.appClass == 'system') {
        return appSpec.appClass;
      }
      if (appSpec.appClass == 'order' ||
          appSpec.appClass == 'transaction' ||
          appSpec.appClass == 'travel' ||
          appSpec.appClass == 'email' ||
          appSpec.appClass == 'calendar' ||
          appSpec.appClass == 'call') {
        return appSpec.appClass;
      }
      if (appSpec.appClass == 'conversation') {
        if (_orderPattern.hasMatch(combined) &&
            !input.isConversation &&
            input.source == 'sms') {
          return 'order';
        }
        if (_transactionPattern.hasMatch(combined) &&
            input.source == 'sms') {
          return 'transaction';
        }
        return 'conversation';
      }
      if (appSpec.appClass == 'promo') return 'promo';
    }

    if (_orderPattern.hasMatch(combined)) return 'order';
    if (_travelPattern.hasMatch(combined)) return 'travel';
    if (_transactionPattern.hasMatch(combined)) return 'transaction';
    if (cat == 'msg' || input.isConversation || input.source == 'sms') {
      return 'conversation';
    }
    return 'system';
  }

  String _friendlyApp(String pkg, String source) {
    if (pkg.isEmpty) return source == 'sms' ? 'SMS' : 'app';
    final parts = pkg.split('.');
    return parts.isNotEmpty ? parts.last : pkg;
  }
}
