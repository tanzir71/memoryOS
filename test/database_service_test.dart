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
}
