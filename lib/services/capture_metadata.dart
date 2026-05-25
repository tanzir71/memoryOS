import 'app_category_registry.dart';

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

enum NotificationImportanceTier { high, medium, low, suppress }

class NotificationImportance {
  const NotificationImportance({
    required this.tier,
    required this.reason,
    required this.isPriorityEvent,
    this.registryCategory,
    this.conversationSender,
    this.conversationSnippet,
  });

  final NotificationImportanceTier tier;
  final String reason;
  final bool isPriorityEvent;
  final String? registryCategory;
  final String? conversationSender;
  final String? conversationSnippet;

  String get tierName => tier.name;
}

NotificationImportance classifyNotificationImportance({
  required String packageName,
  required String channelId,
  required String title,
  required String content,
  String category = '',
  bool isOngoing = false,
  String appName = '',
  AppCategoryRegistry? registry,
}) {
  final effectiveRegistry = registry ?? AppCategoryRegistry.active;
  final packageLower = packageName.toLowerCase();
  final channelLower = channelId.toLowerCase();
  final categoryLower = category.toLowerCase();
  final combinedLower =
      '$packageLower $channelLower $categoryLower '
      '${title.toLowerCase()} ${content.toLowerCase()}';

  if (effectiveRegistry.isUserDenied(
    packageName: packageName,
    appName: appName,
  )) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.suppress,
      reason: "Don't Log app registry match",
      isPriorityEvent: false,
    );
  }

  if (isMarketingNotification(
    packageName: packageName,
    channelId: channelId,
    title: title,
    content: content,
  )) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.suppress,
      reason: 'Promotional notification',
      isPriorityEvent: false,
    );
  }

  if (_isShortWindowStatusLikeNotification(
    packageName: packageLower,
    channelId: channelLower,
    text: '$title $content',
  )) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.low,
      reason: 'Device status update',
      isPriorityEvent: false,
    );
  }

  if (_looksLikeWeather(combinedLower)) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.high,
      reason: 'Weather summary',
      isPriorityEvent: true,
    );
  }

  if (_looksLikeSecurityAlert(combinedLower)) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.high,
      reason: 'Security or verification alert',
      isPriorityEvent: true,
    );
  }

  final isMessagingApp =
      effectiveRegistry.matches(
        AppCategory.messaging,
        packageName: packageName,
        appName: appName,
      ) ||
      categoryLower.contains('msg');
  final isEmailApp = effectiveRegistry.matches(
    AppCategory.email,
    packageName: packageName,
    appName: appName,
  );
  final appLabel = effectiveRegistry.displayNameFor(
    packageName: packageName,
    appName: appName,
  );

  if (isMessagingApp) {
    final sender = conversationSenderFromNotification(title: title);
    final snippet = conversationSnippetFromNotification(content);
    if (_looksLikeConversation(
      title: title,
      content: content,
      sender: sender,
    )) {
      return NotificationImportance(
        tier: NotificationImportanceTier.high,
        reason: 'Conversation from $appLabel',
        isPriorityEvent: true,
        registryCategory: AppCategory.messaging.storageKey,
        conversationSender: sender,
        conversationSnippet: snippet,
      );
    }
    return NotificationImportance(
      tier: NotificationImportanceTier.low,
      reason: 'Messaging status update',
      isPriorityEvent: false,
      registryCategory: AppCategory.messaging.storageKey,
    );
  }

  if (_looksLikeCalendarEvent(combinedLower)) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.high,
      reason: 'Calendar or event reminder',
      isPriorityEvent: true,
    );
  }

  if (isEmailApp || _isEmailPackage(packageLower)) {
    if (_looksLikeNewsletterOrDigest(combinedLower)) {
      return NotificationImportance(
        tier: NotificationImportanceTier.low,
        reason: 'Email newsletter or digest',
        isPriorityEvent: false,
        registryCategory: AppCategory.email.storageKey,
      );
    }
    final sender = conversationSenderFromNotification(title: title);
    final snippet = conversationSnippetFromNotification(content);
    final looksHumanOrProject =
        RegExp(
          r'\b(project|client|meeting|review|invoice|receipt|offer|deadline|call|'
          r'handoff|proposal|ready|question|follow up|follow-up|attached|'
          r'proposal|clinic|partnership|standup)\b',
        ).hasMatch(combinedLower) ||
        _looksLikeConversation(title: title, content: content, sender: sender);
    return NotificationImportance(
      tier: looksHumanOrProject
          ? NotificationImportanceTier.medium
          : NotificationImportanceTier.low,
      reason: looksHumanOrProject
          ? 'Email context from $appLabel'
          : 'Email notification',
      isPriorityEvent: looksHumanOrProject,
      registryCategory: AppCategory.email.storageKey,
      conversationSender: looksHumanOrProject ? sender : null,
      conversationSnippet: looksHumanOrProject ? snippet : null,
    );
  }

  if (isOngoing) {
    return const NotificationImportance(
      tier: NotificationImportanceTier.low,
      reason: 'Ongoing background status',
      isPriorityEvent: false,
    );
  }

  return const NotificationImportance(
    tier: NotificationImportanceTier.medium,
    reason: 'Unclassified notification',
    isPriorityEvent: false,
  );
}

String? conversationSenderFromNotification({required String title}) {
  final cleanTitle = title
      .replaceFirst(RegExp(r'^\[[^\]]+\]\s*'), '')
      .split(':')
      .last
      .trim();
  if (cleanTitle.isEmpty) return null;
  final sender = cleanTitle
      .split(RegExp(r'\s+'))
      .take(3)
      .join(' ')
      .replaceAll(RegExp(r'[^A-Za-z0-9 ._-]'), '')
      .trim();
  if (sender.isEmpty) return null;
  final lower = sender.toLowerCase();
  if (_conversationPlaceholderWords.contains(lower)) return null;
  if (RegExp(
    r'\b(sync|notification|message|messages|digest|newsletter)\b',
  ).hasMatch(lower)) {
    return null;
  }
  return sender;
}

String? conversationSnippetFromNotification(String content) {
  final lines = content
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.isEmpty) return null;
  final raw = lines.first.contains(':')
      ? lines.first.split(':').skip(1).join(':').trim()
      : lines.first;
  if (raw.isEmpty || _looksLikeStatusNoise(raw.toLowerCase())) return null;
  return raw.length <= 140 ? raw : '${raw.substring(0, 140).trim()}...';
}

bool _looksLikeConversation({
  required String title,
  required String content,
  required String? sender,
}) {
  final contentLower = content.toLowerCase().trim();
  if (contentLower.length < 8) return false;
  if (_looksLikeStatusNoise(contentLower)) return false;
  if (sender != null && sender.length >= 3 && contentLower.length >= 12) {
    return true;
  }
  return RegExp(
    r"(\?|can you|could you|please|review|call|meeting|send|sent|shared|"
    r"attached|thanks|thank you|where|when|today|tomorrow|before|after|"
    r"standup|proposal|client|project|deadline)",
  ).hasMatch(contentLower);
}

bool _looksLikeStatusNoise(String text) {
  return RegExp(
    r'\b(syncing|sync complete|checking|background|running|connected|'
    r'backup|updating|refreshing|waiting|no new|new messages|'
    r'notification activity|battery|charging|missed call|caller id)\b',
  ).hasMatch(text);
}

bool _looksLikeNewsletterOrDigest(String text) {
  return RegExp(
    r'\b(newsletter|digest|weekly roundup|unsubscribe|view in browser|'
    r'promotion|sponsored|recommended for you)\b',
  ).hasMatch(text);
}

const _conversationPlaceholderWords = {
  'user',
  'cache',
  'null',
  'unknown',
  'default',
  'slack',
  'gmail',
  'messages',
  'messenger',
  'notification',
};

bool _isEmailPackage(String packageName) {
  return packageName.contains('gmail') ||
      packageName.contains('google.android.gm') ||
      packageName.contains('email') ||
      packageName.contains('outlook') ||
      packageName.contains('mail');
}

bool _looksLikeWeather(String text) {
  return RegExp(
    r'\b(weather|forecast|rain|storm|thunder|temperature|humid|humidity|'
    r'wind|umbrella|heatwave|cyclone|flood|air quality|aqi)\b',
  ).hasMatch(text);
}

bool _looksLikeSecurityAlert(String text) {
  return RegExp(
    r'\b(otp|one time password|verification code|security alert|login|'
    r'sign-in|signin|password|2fa|two-factor|account alert)\b',
  ).hasMatch(text);
}

bool _looksLikeCalendarEvent(String text) {
  return RegExp(
    r'\b(calendar|meeting|event|appointment|starts in|call at|deadline|'
    r'due today|due tomorrow)\b',
  ).hasMatch(text);
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

bool isSuppressedNotificationRecord({
  required String source,
  required Map<String, dynamic> metadata,
}) {
  if (source != 'notification') return false;
  return metadata['importanceTier']?.toString().toLowerCase() == 'suppress';
}

bool isDeniedNotificationRecord({
  required String source,
  required Map<String, dynamic> metadata,
  AppCategoryRegistry? registry,
}) {
  if (source != 'notification') return false;
  final effectiveRegistry = registry ?? AppCategoryRegistry.active;
  return effectiveRegistry.isUserDenied(
    packageName: metadata['packageName']?.toString() ?? '',
    appName: metadata['appName']?.toString() ?? '',
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
