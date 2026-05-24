String? extractScreenshotFileName(Map<String, dynamic> metadata) {
  final explicitName = metadata['fileName']?.toString().trim();
  if (explicitName != null && explicitName.isNotEmpty) {
    return explicitName;
  }

  for (final key in ['originalPath', 'filePath', 'cachedFilePath']) {
    final path = metadata[key]?.toString().trim();
    if (path == null || path.isEmpty) continue;
    final normalized = path.replaceAll('\\', '/');
    final name = normalized.split('/').last.trim();
    if (name.isNotEmpty) {
      return name;
    }
  }

  return null;
}

String buildScreenshotSummary(Map<String, dynamic> metadata) {
  return extractScreenshotFileName(metadata) ?? 'Screenshot file captured';
}

bool isNotificationRemovalRecord(String source) {
  return source == 'notification_removed';
}

bool isScreenshotFileRecord({
  required String source,
  required Map<String, dynamic> metadata,
}) {
  if (source != 'photo') {
    return false;
  }

  final isScreenshotFlag =
      metadata['isScreenshot'] == true ||
      metadata['isScreenshot']?.toString().toLowerCase() == 'true';
  final fileName = extractScreenshotFileName(metadata)?.toLowerCase() ?? '';

  return isScreenshotFlag || fileName.contains('screenshot');
}

Map<String, dynamic> visibleMetadataForNode({
  required String source,
  required Map<String, dynamic> metadata,
}) {
  if (isScreenshotFileRecord(source: source, metadata: metadata)) {
    final fileName = extractScreenshotFileName(metadata);
    return fileName == null ? const {} : {'fileName': fileName};
  }

  return metadata;
}

bool isScreenshotCaptureNotification({
  required String packageName,
  required String channelId,
  required String title,
  required String content,
}) {
  final packageLower = packageName.toLowerCase();
  final channelLower = channelId.toLowerCase();
  final titleLower = title.toLowerCase();
  final contentLower = content.toLowerCase();
  final haystack = '$packageLower $channelLower $titleLower $contentLower';

  final looksLikeCaptureSurface =
      packageLower.contains('systemui') ||
      packageLower.contains('smartcapture') ||
      packageLower.contains('screenshot') ||
      packageLower.contains('screenrecorder') ||
      channelLower.contains('capture') ||
      channelLower.contains('screenshot') ||
      titleLower.contains('samsung capture') ||
      titleLower.contains('screenshot');

  if (!looksLikeCaptureSurface) {
    return false;
  }

  return haystack.contains('screenshot') ||
      haystack.contains('screen shot') ||
      haystack.contains('screen capture');
}

bool isSystemScreenshotNotification({
  required String packageName,
  required String channelId,
  required String title,
  required String content,
}) {
  return isScreenshotCaptureNotification(
    packageName: packageName,
    channelId: channelId,
    title: title,
    content: content,
  );
}

bool isScreenshotCaptureNotificationRecord({
  required String source,
  required Map<String, dynamic> metadata,
  required String title,
  required String content,
}) {
  if (source != 'notification') {
    return false;
  }

  return isScreenshotCaptureNotification(
    packageName: metadata['packageName']?.toString() ?? '',
    channelId: metadata['channelId']?.toString() ?? '',
    title: title,
    content: content,
  );
}

String? ongoingNotificationDedupeKey({
  required String source,
  required String title,
  required Map<String, dynamic> metadata,
}) {
  if (source != 'notification') return null;

  final isOngoing =
      metadata['isOngoing'] == true ||
      metadata['isOngoing']?.toString().toLowerCase() == 'true';
  if (!isOngoing) return null;

  final notificationKey = metadata['notificationKey']?.toString().trim();
  if (notificationKey != null && notificationKey.isNotEmpty) {
    return 'ongoing-key:${notificationKey.toLowerCase()}';
  }

  final packageName = metadata['packageName']?.toString().trim().toLowerCase();
  final channelId = metadata['channelId']?.toString().trim().toLowerCase();
  final normalizedTitle = title.trim().toLowerCase();
  if (packageName == null ||
      packageName.isEmpty ||
      channelId == null ||
      channelId.isEmpty ||
      normalizedTitle.isEmpty) {
    return null;
  }

  return 'ongoing:$packageName:$channelId:$normalizedTitle';
}

bool isMarketingNotification({
  required String packageName,
  required String channelId,
  required String title,
  required String content,
}) {
  final haystack =
      '${packageName.toLowerCase()} ${channelId.toLowerCase()} '
      '${title.toLowerCase()} ${content.toLowerCase()}';

  final obviousPatterns = <RegExp>[
    RegExp(r'\b\d{1,3}\s*%\s*off\b'),
    RegExp(r'\b(use|apply)\s+(code|coupon|promo)\b'),
    RegExp(r'\b(code|coupon|promo)\s+[a-z0-9]{3,}\b'),
    RegExp(r'\b(flash|mega|summer|eid|holiday|clearance)\s+sale\b'),
    RegExp(r'\bsale\s+(ends|starts|is live|now|today|tonight)\b'),
    RegExp(r'\blimited\s+time\s+(offer|deal|discount)\b'),
    RegExp(r'\bfree\s+(delivery|shipping|trial|gift)\b'),
    RegExp(r'\b(shop|order|buy|subscribe|install|claim)\s+now\b'),
    RegExp(r'\bbuy\s+\d+\s+get\s+\d+\b'),
    RegExp(r'\b(cashback|voucher|reward points|deal of the day)\b'),
    RegExp(r'\b(ad|sponsored|promoted)\b.*\b(shop|buy|install|subscribe)\b'),
  ];

  if (obviousPatterns.any((pattern) => pattern.hasMatch(haystack))) {
    return true;
  }

  final promoChannel = RegExp(
    r'\b(promotions?|offers?|deals?|marketing|ads?|recommendations?)\b',
  ).hasMatch(channelId.toLowerCase());
  final promoTerms = RegExp(
    r'\b(discount|coupon|voucher|sale|cashback|deal|offer|shop now|buy now)\b',
  ).allMatches(haystack).length;

  return promoChannel && promoTerms >= 1;
}

bool isMarketingNotificationRecord({
  required String source,
  required Map<String, dynamic> metadata,
  required String title,
  required String content,
}) {
  if (source != 'notification') return false;

  return isMarketingNotification(
    packageName: metadata['packageName']?.toString() ?? '',
    channelId: metadata['channelId']?.toString() ?? '',
    title: title,
    content: content,
  );
}

String? shortWindowNotificationDedupeKey({
  required String source,
  required String title,
  required String content,
  required Map<String, dynamic> metadata,
}) {
  if (source != 'notification') return null;

  final packageName = metadata['packageName']?.toString().trim().toLowerCase();
  final channelId = metadata['channelId']?.toString().trim().toLowerCase();
  if (packageName == null ||
      packageName.isEmpty ||
      channelId == null ||
      channelId.isEmpty) {
    return null;
  }

  final combinedText = '$title $content';
  if (!_isShortWindowStatusLikeNotification(
    packageName: packageName,
    channelId: channelId,
    text: combinedText,
  )) {
    return null;
  }

  final normalized = _normalizeNotificationSimilarityText(combinedText);
  if (normalized.length < 8) return null;

  return 'short:$packageName:$channelId:$normalized';
}

bool _isShortWindowStatusLikeNotification({
  required String packageName,
  required String channelId,
  required String text,
}) {
  final haystack = '$packageName $channelId ${text.toLowerCase()}';
  return haystack.contains('bluetooth') ||
      haystack.contains('charging') ||
      haystack.contains('charger') ||
      haystack.contains('usb') ||
      haystack.contains('device connected') ||
      haystack.contains('device disconnected') ||
      haystack.contains('connected to') ||
      haystack.contains('disconnected from') ||
      haystack.contains('sync complete') ||
      haystack.contains('backup complete');
}

String _normalizeNotificationSimilarityText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'https?://\S+'), ' url ')
      .replaceAll(RegExp(r'\b[\w.\-]+@[\w.\-]+\.\w+\b'), ' email ')
      .replaceAll(RegExp(r'\b([0-9a-f]{2}:){5}[0-9a-f]{2}\b'), ' mac ')
      .replaceAll(RegExp(r'\b\d{1,2}:\d{2}\s*(am|pm)?\b'), ' time ')
      .replaceAll(
        RegExp(
          r'\b\d+\s*(%|kb|mb|gb|sec|secs|seconds?|mins?|minutes?|hours?)\b',
        ),
        ' number ',
      )
      .replaceAll(RegExp(r'\b\d+\b'), ' number ')
      .replaceAll(RegExp(r'\b(number|time|ago|just|now|at|on|the|a|an)\b'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
