import 'dart:convert';

class MemoryNode {
  final int? id;
  final DateTime timestamp;
  final String title;
  final String content;
  final String
  source; // voice_note, location, calendar, notification, bluetooth, photo, reading
  final Map<String, dynamic> metadata;
  final String
  trail; // work, tax, health, project_memory, relationship_memory, none
  final bool isStarred;
  final DateTime? deletedAt;

  MemoryNode({
    this.id,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.source,
    required this.metadata,
    required this.trail,
    this.isStarred = false,
    this.deletedAt,
  });

  // Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'content': content,
      'source': source,
      'metadata': jsonEncode(metadata),
      'trail': trail,
      'is_starred': isStarred ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Convert from Database Map
  factory MemoryNode.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> meta;
    try {
      meta = map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : {};
    } catch (_) {
      meta = {};
    }

    return MemoryNode(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      title: map['title'] as String,
      content: map['content'] as String,
      source: map['source'] as String,
      metadata: meta,
      trail: map['trail'] as String,
      isStarred: (map['is_starred'] as int) == 1,
      deletedAt: _parseOptionalDate(map['deleted_at']),
    );
  }

  MemoryNode copyWith({
    int? id,
    DateTime? timestamp,
    String? title,
    String? content,
    String? source,
    Map<String, dynamic>? metadata,
    String? trail,
    bool? isStarred,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return MemoryNode(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      content: content ?? this.content,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
      trail: trail ?? this.trail,
      isStarred: isStarred ?? this.isStarred,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
