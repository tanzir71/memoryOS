import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'export_period.dart';

typedef ExportPeriodSelector = Future<ExportPeriod?> Function();
typedef MarkdownSaveFile =
    Future<String?> Function({
      required String suggestedName,
      required String contents,
    });

enum ReportDownloadStatus { canceledPeriod, canceledSaveLocation, saved }

class ReportDownloadResult {
  const ReportDownloadResult._(this.status, {this.period, this.path});

  const ReportDownloadResult.canceledPeriod()
    : this._(ReportDownloadStatus.canceledPeriod);

  const ReportDownloadResult.canceledSaveLocation(ExportPeriod period)
    : this._(ReportDownloadStatus.canceledSaveLocation, period: period);

  const ReportDownloadResult.saved(ExportPeriod period, String path)
    : this._(ReportDownloadStatus.saved, period: period, path: path);

  final ReportDownloadStatus status;
  final ExportPeriod? period;
  final String? path;
}

class ReportDownloadService {
  ReportDownloadService({MarkdownSaveFile? saveMarkdownFile})
    : _saveMarkdownFile = saveMarkdownFile ?? _defaultSaveMarkdownFile;

  static final ReportDownloadService instance = ReportDownloadService();

  final MarkdownSaveFile _saveMarkdownFile;

  Future<ReportDownloadResult> saveMarkdownReport({
    required ExportPeriodSelector selectPeriod,
    required String Function(ExportPeriod period) suggestedName,
    required FutureOr<String> Function(ExportPeriod period) buildMarkdown,
  }) async {
    final period = await selectPeriod();
    if (period == null) {
      return const ReportDownloadResult.canceledPeriod();
    }

    final contents = await Future<String>.value(buildMarkdown(period));
    final path = await _saveMarkdownFile(
      suggestedName: suggestedName(period),
      contents: contents,
    );
    if (path == null) {
      return ReportDownloadResult.canceledSaveLocation(period);
    }

    return ReportDownloadResult.saved(period, path);
  }
}

Future<ExportPeriod?> showExportPeriodPicker(BuildContext context) {
  final theme = Theme.of(context);
  return showModalBottomSheet<ExportPeriod>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        top: false,
        child: Material(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Select export period',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose which memories should be included in this download.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final period in ExportPeriod.values)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.date_range, size: 20),
                      title: Text(period.label),
                      onTap: () => Navigator.pop(context, period),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<String?> _defaultSaveMarkdownFile({
  required String suggestedName,
  required String contents,
}) async {
  final bytes = Uint8List.fromList(utf8.encode(contents));
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save MemoryOS report',
    fileName: suggestedName,
    type: FileType.custom,
    allowedExtensions: const ['md'],
    bytes: bytes,
  );
  if (path == null) return null;

  if (!Platform.isAndroid && !Platform.isIOS) {
    await File(path).writeAsBytes(bytes, flush: true);
  }
  return path;
}
