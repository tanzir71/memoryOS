import '../models/memory_node.dart';
import 'capture_metadata.dart';

bool isIndividuallyVisibleMemoryNode(MemoryNode node) {
  if (node.deletedAt != null) return false;

  if (isMarketingNotificationRecord(
    source: node.source,
    metadata: node.metadata,
    title: node.title,
    content: node.content,
  )) {
    return false;
  }

  if (isSuppressedNotificationRecord(
    source: node.source,
    metadata: node.metadata,
  )) {
    return false;
  }

  if (isDeniedNotificationRecord(
    source: node.source,
    metadata: node.metadata,
  )) {
    return false;
  }

  if (isNotificationRemovalRecord(node.source)) return false;

  return !isScreenshotCaptureNotificationRecord(
    source: node.source,
    metadata: node.metadata,
    title: node.title,
    content: node.content,
  );
}

List<MemoryNode> filterVisibleMemoryNodes(Iterable<MemoryNode> nodes) {
  final seenScreenshotFiles = <String>{};
  final seenOngoingNotifications = <String>{};
  final recentSimilarNotifications = <String, DateTime>{};

  return nodes.where((node) {
    if (!isIndividuallyVisibleMemoryNode(node)) return false;

    if (isScreenshotFileRecord(source: node.source, metadata: node.metadata)) {
      final fileName = extractScreenshotFileName(node.metadata)?.toLowerCase();
      if (fileName != null && !seenScreenshotFiles.add(fileName)) {
        return false;
      }
    }

    final ongoingKey = ongoingNotificationDedupeKey(
      source: node.source,
      title: node.title,
      metadata: node.metadata,
    );
    if (ongoingKey != null && !seenOngoingNotifications.add(ongoingKey)) {
      return false;
    }

    final shortWindowKey = shortWindowNotificationDedupeKey(
      source: node.source,
      title: node.title,
      content: node.content,
      metadata: node.metadata,
    );
    if (shortWindowKey != null) {
      final latestSeen = recentSimilarNotifications[shortWindowKey];
      if (latestSeen != null &&
          latestSeen.difference(node.timestamp).abs() <=
              const Duration(minutes: 5)) {
        return false;
      }
      recentSimilarNotifications[shortWindowKey] = node.timestamp;
    }

    return true;
  }).toList();
}
