import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('memory_nodes has indexes for visible feed queries', () async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery("PRAGMA index_list('memory_nodes')");
    final names = rows.map((row) => row['name']).toSet();

    expect(
      names,
      containsAll({
        'idx_memory_nodes_timestamp',
        'idx_memory_nodes_trail_timestamp',
        'idx_memory_nodes_source_timestamp',
        'idx_memory_nodes_deleted_at',
      }),
    );
  });

  test('insight index tables and lookup indexes are created', () async {
    final db = await DatabaseService.instance.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final tableNames = tables.map((row) => row['name']).toSet();

    expect(
      tableNames,
      containsAll({
        'insight_index_meta',
        'insight_node_index',
        'insight_term_index',
        'insight_bucket_rollups',
      }),
    );

    final termIndexes = await db.rawQuery(
      "PRAGMA index_list('insight_term_index')",
    );
    expect(
      termIndexes.map((row) => row['name']).toSet(),
      containsAll({
        'idx_insight_term_node',
        'idx_insight_term_lookup',
        'idx_insight_term_bucket',
        'idx_insight_term_registry_version',
      }),
    );
  });
}
