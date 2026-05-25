import 'package:intl/intl.dart';

import '../models/memory_node.dart';

enum HealthTimelineCategory {
  food('Food'),
  grocery('Grocery'),
  fitness('Fitness');

  const HealthTimelineCategory(this.label);

  final String label;
}

final _foodSignals = RegExp(
  r'\b(foodpanda|uber eats|ubereats|doordash|door dash|grubhub|zomato|'
  r'swiggy|deliveroo|restaurant|meal|lunch|dinner|breakfast|salad|'
  r'protein|calories|order delivered|food order)\b',
  caseSensitive: false,
);

final _grocerySignals = RegExp(
  r'\b(instacart|grocery|groceries|whole foods|wholefoods|kroger|aldi|'
  r'walmart grocery|target grocery|market|supermarket|milk|eggs|spinach|'
  r'oats|produce|receipt)\b',
  caseSensitive: false,
);

final _fitnessSignals = RegExp(
  r'\b(samsung health|shealth|google fit|fitbit|strava|garmin|nike run|'
  r'workout|exercise|fitness|gym|steps|heart rate|run|walk|cycling|'
  r'calories burned|activity)\b',
  caseSensitive: false,
);

List<MemoryNode> filterHealthTimelineEvents(List<MemoryNode> nodes) {
  return nodes.where((node) => healthTimelineCategory(node) != null).toList();
}

HealthTimelineCategory? healthTimelineCategory(MemoryNode node) {
  if (node.source != 'notification') return null;

  final packageName = node.metadata['packageName']?.toString() ?? '';
  final appName = node.metadata['appName']?.toString() ?? '';
  final channelId = node.metadata['channelId']?.toString() ?? '';
  final text = '$packageName $appName $channelId ${node.title} ${node.content}';

  if (_fitnessSignals.hasMatch(text)) return HealthTimelineCategory.fitness;
  if (_grocerySignals.hasMatch(text)) return HealthTimelineCategory.grocery;
  if (_foodSignals.hasMatch(text)) return HealthTimelineCategory.food;
  return null;
}

String buildHealthTimelineReport(
  List<MemoryNode> nodes, {
  DateTime? generatedAt,
}) {
  final events = filterHealthTimelineEvents(nodes);
  final generated = generatedAt ?? DateTime.now();
  final groups = <HealthTimelineCategory, List<MemoryNode>>{
    for (final category in HealthTimelineCategory.values) category: [],
  };

  for (final event in events) {
    final category = healthTimelineCategory(event);
    if (category != null) {
      groups[category]!.add(event);
    }
  }

  final buffer = StringBuffer()
    ..writeln('# Health Timeline Report')
    ..writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(generated)}')
    ..writeln('Total events: ${events.length}')
    ..writeln();

  if (events.isEmpty) {
    buffer.writeln('No health-related notifications found.');
    return buffer.toString();
  }

  for (final category in HealthTimelineCategory.values) {
    final categoryEvents = groups[category]!;
    if (categoryEvents.isEmpty) continue;

    buffer
      ..writeln('## ${category.label}')
      ..writeln();

    for (final event in categoryEvents) {
      final time = DateFormat('yyyy-MM-dd HH:mm').format(event.timestamp);
      final content = event.content.trim().isEmpty
          ? 'No details recorded.'
          : event.content.trim();
      buffer.writeln('- $time - ${event.title}: $content');
    }
    buffer.writeln();
  }

  return buffer.toString();
}
