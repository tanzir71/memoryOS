import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables_core.dart';
import 'tables_engine.dart';

part 'database.g.dart';

class SearchHit {
  const SearchHit({
    required this.targetType,
    required this.targetId,
    required this.title,
    required this.body,
    required this.people,
    required this.entities,
  });

  final String targetType;
  final int targetId;
  final String title;
  final String body;
  final String people;
  final String entities;
}

@DriftDatabase(
  tables: [
    Signal,
    Person,
    PersonHandle,
    Entity,
    SignalEntity,
    SignalIntent,
    MemoryThread,
    ThreadSignal,
    SignalLink,
    OpenLoop,
    Series,
    SeriesSignal,
    Feedback,
    SuppressRule,
    AppRule,
    ChannelScore,
    Setting,
    DaySummary,
  ],
)
class MemoryDatabase extends _$MemoryDatabase {
  MemoryDatabase(super.e);

  factory MemoryDatabase.inMemory() {
    return MemoryDatabase(NativeDatabase.memory());
  }

  static Future<MemoryDatabase> openDefault() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'memory.db'));
    return MemoryDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
          target_type UNINDEXED,
          target_id UNINDEXED,
          title,
          body,
          people,
          entities
        );
      ''');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> upsertSearchEntry({
    required String targetType,
    required int targetId,
    required String title,
    required String body,
    String people = '',
    String entities = '',
  }) async {
    await customStatement(
      'DELETE FROM search_index WHERE target_type = ? AND target_id = ?',
      [targetType, targetId],
    );
    await customStatement(
      'INSERT INTO search_index(target_type, target_id, title, body, people, entities) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [targetType, targetId, title, body, people, entities],
    );
  }

  Future<List<SearchHit>> searchFts(String rawQuery, {int limit = 30}) async {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) return const [];
    final tokens = trimmed
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'[^\w\u0980-\u09FF]'), ''))
        .where((t) => t.isNotEmpty)
        .map((t) => '"$t"*')
        .toList();
    if (tokens.isEmpty) return const [];
    final matchExpr = tokens.join(' ');
    final rows = await customSelect(
      'SELECT target_type, target_id, title, body, people, entities '
      'FROM search_index WHERE search_index MATCH ? LIMIT ?',
      variables: [Variable<String>(matchExpr), Variable<int>(limit)],
    ).get();
    return rows
        .map(
          (r) => SearchHit(
            targetType: r.read<String>('target_type'),
            targetId: r.read<int>('target_id'),
            title: r.read<String>('title'),
            body: r.read<String>('body'),
            people: r.read<String>('people'),
            entities: r.read<String>('entities'),
          ),
        )
        .toList();
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(setting)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(setting).insertOnConflictUpdate(
      SettingCompanion.insert(key: key, value: value),
    );
  }

  Stream<List<SignalRow>> watchKeptSignals({int limit = 200}) {
    return (select(signal)
          ..where((t) => t.kept.equals(true) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> purgeExpiredDeleted({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    return (delete(signal)
          ..where(
            (t) =>
                t.deletedAt.isNotNull() &
                t.deletedAt.isSmallerOrEqualValue(cutoff),
          ))
        .go();
  }
}
