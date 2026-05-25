import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/export_period.dart';
import 'package:memoryos/services/report_download_service.dart';

void main() {
  group('ReportDownloadService', () {
    test('canceling period selection writes nothing', () async {
      var writeCount = 0;
      final service = ReportDownloadService(
        saveMarkdownFile: ({required suggestedName, required contents}) async {
          writeCount += 1;
          return 'unused';
        },
      );

      final result = await service.saveMarkdownReport(
        selectPeriod: () async => null,
        suggestedName: (_) => 'report.md',
        buildMarkdown: (_) => 'body',
      );

      expect(result.status, ReportDownloadStatus.canceledPeriod);
      expect(writeCount, 0);
    });

    test('canceling save picker writes nothing', () async {
      var capturedContents = '';
      final service = ReportDownloadService(
        saveMarkdownFile: ({required suggestedName, required contents}) async {
          capturedContents = contents;
          return null;
        },
      );

      final result = await service.saveMarkdownReport(
        selectPeriod: () async => ExportPeriod.thisMonth,
        suggestedName: (_) => 'report.md',
        buildMarkdown: (_) => 'body',
      );

      expect(result.status, ReportDownloadStatus.canceledSaveLocation);
      expect(capturedContents, 'body');
    });

    test(
      'successful save writes generated markdown to selected path',
      () async {
        final writes = <String, String>{};
        final service = ReportDownloadService(
          saveMarkdownFile:
              ({required suggestedName, required contents}) async {
                writes[suggestedName] = contents;
                return '/downloads/$suggestedName';
              },
        );

        final result = await service.saveMarkdownReport(
          selectPeriod: () async => ExportPeriod.lastMonth,
          suggestedName: (period) => 'memoryos-${period.filenameSlug}.md',
          buildMarkdown: (period) => '# ${period.label}',
        );

        expect(result.status, ReportDownloadStatus.saved);
        expect(result.path, '/downloads/memoryos-last-month.md');
        expect(writes, {'memoryos-last-month.md': '# Last month'});
      },
    );
  });
}
