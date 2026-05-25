import 'package:intl/intl.dart';

import '../models/memory_node.dart';
import 'app_category_registry.dart';

enum HealthTimelineCategory {
  food('Food'),
  grocery('Grocery'),
  fitness('Fitness');

  const HealthTimelineCategory(this.label);

  final String label;
}

final _foodOrderSignals = RegExp(
  r'\b(order|ordered|delivery|delivered|arriving|pickup|pick up|picked up|'
  r'restaurant|meal|lunch|dinner|breakfast|receipt|cart|checkout|paid|'
  r'payment|rider|driver|prepared|preparing|on the way)\b',
  caseSensitive: false,
);

final _fitnessActivitySignals = RegExp(
  r'\b(workout|exercise|fitness|gym|steps|heart rate|run|ran|walk|walking|'
  r'cycling|ride|sleep|activity|calories burned|active minutes|distance|km|'
  r'miles|pace|training|session)\b',
  caseSensitive: false,
);

List<MemoryNode> filterHealthTimelineEvents(
  List<MemoryNode> nodes, {
  AppCategoryRegistry? registry,
}) {
  final effectiveRegistry = registry ?? AppCategoryRegistry.active;
  return nodes
      .where(
        (node) =>
            healthTimelineCategory(node, registry: effectiveRegistry) != null,
      )
      .toList();
}

HealthTimelineCategory? healthTimelineCategory(
  MemoryNode node, {
  AppCategoryRegistry? registry,
}) {
  if (node.source != 'notification') return null;

  final effectiveRegistry = registry ?? AppCategoryRegistry.active;
  final packageName = node.metadata['packageName']?.toString() ?? '';
  final appName = node.metadata['appName']?.toString() ?? '';
  final channelId = node.metadata['channelId']?.toString() ?? '';
  final text = '$packageName $appName $channelId ${node.title} ${node.content}';

  if (effectiveRegistry.isDenied(packageName: packageName, appName: appName)) {
    return null;
  }

  if (effectiveRegistry.matches(
        AppCategory.fitness,
        packageName: packageName,
        appName: appName,
      ) &&
      _fitnessActivitySignals.hasMatch(text)) {
    return HealthTimelineCategory.fitness;
  }

  if (effectiveRegistry.matches(
        AppCategory.grocery,
        packageName: packageName,
        appName: appName,
      ) &&
      _foodOrderSignals.hasMatch(text)) {
    return HealthTimelineCategory.grocery;
  }

  if (effectiveRegistry.matches(
        AppCategory.food,
        packageName: packageName,
        appName: appName,
      ) &&
      _foodOrderSignals.hasMatch(text)) {
    return HealthTimelineCategory.food;
  }
  return null;
}

String buildHealthTimelineReport(
  List<MemoryNode> nodes, {
  DateTime? generatedAt,
  AppCategoryRegistry? registry,
}) {
  final effectiveRegistry = registry ?? AppCategoryRegistry.active;
  final events = filterHealthTimelineEvents(nodes, registry: effectiveRegistry);
  final generated = generatedAt ?? DateTime.now();
  final groups = <HealthTimelineCategory, List<MemoryNode>>{
    for (final category in HealthTimelineCategory.values) category: [],
  };

  for (final event in events) {
    final category = healthTimelineCategory(event, registry: effectiveRegistry);
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
