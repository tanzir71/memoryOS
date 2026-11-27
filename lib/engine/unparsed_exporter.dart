import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../data/database.dart';
import 'extractor.dart';
import 'rules_loader.dart';

class UnparsedExportResult {
  const UnparsedExportResult({
    required this.filePath,
    required this.sampleCount,
  });

  final String filePath;
  final int sampleCount;
}

/// Writes transactional signals that no sender pack matched to a JSON file in
/// app documents so real wording can be added to sender rule packs later.
Future<UnparsedExportResult> exportUnparsedTransactionalSamples({
  required MemoryDatabase db,
  required EngineRules rules,
  Directory? outputDir,
}) async {
  final extractor = ExtractionEngine(rules);
  final signals = await (db.select(db.signal)
        ..where(
          (t) =>
              t.deletedAt.isNull() &
              t.redacted.equals(false) &
              (t.signalClass.equals('transaction') |
                  t.signalClass.equals('order') |
                  t.source.equals('sms')),
        ))
      .get();

  final samples = <Map<String, dynamic>>[];
  for (final s in signals) {
    final res = extractor.extract(
      pkg: s.pkg,
      senderAddress: s.title,
      title: s.title,
      body: s.body,
      signalClass: s.signalClass,
    );
    if (res.unparsedTransactional) {
      samples.add({
        'id': s.id,
        'source': s.source,
        'pkg': s.pkg,
        'title': s.title,
        'body': s.body,
        'occurred_at': s.occurredAt,
        'fallback_fields': res.fields,
      });
    }
  }

  final dir = outputDir ?? await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'memoryos_unparsed_samples.json'));
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'exported_at': DateTime.now().toIso8601String(),
      'count': samples.length,
      'samples': samples,
    }),
  );

  return UnparsedExportResult(filePath: file.path, sampleCount: samples.length);
}
