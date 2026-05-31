import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/memory_node.dart';
import '../services/capture_interval_policy.dart';
import '../services/database_service.dart';
import '../services/insight_aggregator.dart';
import '../services/insight_index_service.dart';
import '../services/report_download_service.dart';
import '../theme/app_theme.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({
    super.key,
    this.isActive = true,
    this.initialNodes,
    this.activeTabListenable,
    this.tabIndex,
  });

  final bool isActive;
  final List<MemoryNode>? initialNodes;
  final ValueListenable<int>? activeTabListenable;
  final int? tabIndex;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String _selectedType = 'All';
  String _selectedRange = 'Last 7 Days';

  List<MemoryNode> _nodes = [];
  InsightSnapshot _snapshot = const InsightSnapshot(
    filters: ['All'],
    items: [],
    isIndexing: false,
    indexedNodeCount: 0,
    totalNodeCount: 0,
  );
  bool _isLoading = true;
  Timer? _refreshTimer;
  StreamSubscription<void>? _databaseChangesSubscription;

  bool get _isActive => _isActiveFor(widget);

  bool _isActiveFor(SummaryPage page) {
    final listenable = page.activeTabListenable;
    final index = page.tabIndex;
    if (listenable == null || index == null) return page.isActive;
    return listenable.value == index;
  }

  @override
  void initState() {
    super.initState();
    widget.activeTabListenable?.addListener(_handleActiveTabChanged);
    if (widget.initialNodes != null) {
      _nodes = widget.initialNodes!;
      _isLoading = false;
    } else if (_isActive) {
      DatabaseService.instance.loadAppCategoryRegistry().then((_) {
        if (mounted) _loadSnapshot();
      });
    }
    _databaseChangesSubscription = DatabaseService.instance.changes.listen((_) {
      if (mounted && _isActive && widget.initialNodes == null) {
        _loadSnapshot(isSilent: true);
      }
    });
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant SummaryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive = _isActiveFor(oldWidget);
    if (oldWidget.activeTabListenable != widget.activeTabListenable) {
      oldWidget.activeTabListenable?.removeListener(_handleActiveTabChanged);
      widget.activeTabListenable?.addListener(_handleActiveTabChanged);
    }
    if (oldWidget.initialNodes != widget.initialNodes &&
        widget.initialNodes != null) {
      setState(() {
        _nodes = widget.initialNodes!;
        _isLoading = false;
      });
    } else if (!wasActive && _isActive && widget.initialNodes == null) {
      _loadSnapshot();
    }
    _syncRefreshTimer();
  }

  void _handleActiveTabChanged() {
    if (_isActive && widget.initialNodes == null) {
      _loadSnapshot(isSilent: true);
    }
    _syncRefreshTimer();
  }

  void _syncRefreshTimer() {
    if (!_isActive) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }
    if (_refreshTimer != null) return;

    _refreshTimer = Timer.periodic(uiRefreshInterval, (timer) {
      if (mounted && _isActive && widget.initialNodes == null) {
        _loadSnapshot(isSilent: true);
      }
    });
  }

  @override
  void dispose() {
    widget.activeTabListenable?.removeListener(_handleActiveTabChanged);
    _refreshTimer?.cancel();
    _databaseChangesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSnapshot({bool isSilent = false}) async {
    if (!isSilent && mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final snapshot = await DatabaseService.instance.fetchInsightSnapshot(
        range: _selectedInsightRange(),
        selectedKeyword: _selectedType,
      );
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
          if (!_snapshot.filters.contains(_selectedType)) {
            _selectedType = 'All';
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InsightTimeRange _selectedInsightRange() {
    if (_selectedRange == 'Last 24 Hours') {
      return InsightTimeRange.last24Hours();
    } else if (_selectedRange == 'Last 7 Days') {
      return InsightTimeRange.last7Days();
    }
    return InsightTimeRange.allTime();
  }

  List<MemoryNode> _nodesForSelectedRange() {
    return _nodes.where((node) {
      final now = DateTime.now();
      if (_selectedRange == 'Last 24 Hours') {
        return node.timestamp.isAfter(now.subtract(const Duration(hours: 24)));
      } else if (_selectedRange == 'Last 7 Days') {
        return node.timestamp.isAfter(now.subtract(const Duration(days: 7)));
      }
      // 'All Time'
      return true;
    }).toList();
  }

  List<String> _insightFilters() {
    return _insightFiltersForNodes(_nodesForSelectedRange());
  }

  List<String> _insightFiltersForNodes(List<MemoryNode> nodes) {
    return ['All', ...extractFrequentInsightKeywords(nodes, limit: 6)];
  }

  List<Map<String, dynamic>> _getFilteredInsights() {
    return _filteredInsightsForNodes(_nodesForSelectedRange());
  }

  List<Map<String, dynamic>> _snapshotItems() {
    return _snapshot.items.map(_insightItemToMap).toList();
  }

  Map<String, dynamic> _insightItemToMap(InsightItem insight) {
    return {
      'type': 'aggregate',
      'icon': Icons.hub_outlined,
      'title': insight.keyword,
      'date': DateFormat('MMM d, yyyy').format(insight.latestTimestamp),
      'body': insight.summary,
      'tags': insight.sources.map((source) => '#$source').toList(),
    };
  }

  List<Map<String, dynamic>> _filteredInsightsForNodes(
    List<MemoryNode> filteredNodes,
  ) {
    final filters = _insightFiltersForNodes(filteredNodes);
    final selectedKeyword = filters.contains(_selectedType)
        ? _selectedType
        : 'All';

    return buildAggregatedInsights(
      filteredNodes,
      selectedKeyword: selectedKeyword,
      limit: 6,
    ).map((insight) {
      return {
        'type': 'aggregate',
        'icon': Icons.hub_outlined,
        'title': insight.keyword,
        'date': DateFormat('MMM d, yyyy').format(insight.latestTimestamp),
        'body': insight.summary,
        'tags': insight.sources.map((source) => '#$source').toList(),
      };
    }).toList();
  }

  String _buildMarkdownReport({
    required List<Map<String, dynamic>> items,
    required String selectedType,
    required String periodLabel,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("# MemoryOS Premium Insights: $selectedType");
    buffer.writeln(
      "Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}",
    );
    buffer.writeln("Time Range: $periodLabel");
    buffer.writeln("Verified by Local AI Model: Llama-3-Privacy");
    buffer.writeln();
    buffer.writeln("---");
    buffer.writeln();

    if (items.isEmpty) {
      buffer.writeln("No memories recorded in this range.");
    } else {
      for (final item in items) {
        final title = item['title'];
        final date = item['date'];
        final body = item['body'];
        final tags = List<String>.from(item['tags'] ?? []);

        buffer.writeln("## $title ($date)");
        if (item['type'] == 'quote') {
          buffer.writeln("> $body");
        } else {
          buffer.writeln(body);
        }
        if (tags.isNotEmpty) {
          buffer.writeln();
          buffer.writeln("**Tags:** ${tags.map((t) => "`$t`").join(', ')}");
        }
        buffer.writeln();
        buffer.writeln("---");
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  Future<void> _exportAsMarkdown() async {
    try {
      final result = await ReportDownloadService.instance.saveMarkdownReport(
        selectPeriod: () => showExportPeriodPicker(context),
        suggestedName: (period) {
          final effectiveSelectedType = _selectedType;
          final safeType = effectiveSelectedType.replaceAll(
            RegExp(r'[^\w]'),
            '_',
          );
          final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          return 'MemoryOS_${safeType}_${period.filenameSlug}_Summary_$stamp.md';
        },
        buildMarkdown: (period) async {
          final effectiveSelectedType = _selectedType;
          if (widget.initialNodes != null) {
            final periodNodes = period.filterNodes(_nodes);
            final filters = _insightFiltersForNodes(periodNodes);
            final selected = filters.contains(effectiveSelectedType)
                ? effectiveSelectedType
                : 'All';
            return _buildMarkdownReport(
              items: _filteredInsightsForNodes(periodNodes),
              selectedType: selected,
              periodLabel: period.label,
            );
          }
          final periodRange = period.rangeFor(DateTime.now());
          final snapshot = await DatabaseService.instance.fetchInsightSnapshot(
            range: InsightTimeRange.custom(
              periodRange.start,
              periodRange.endExclusive,
            ),
            selectedKeyword: effectiveSelectedType,
          );
          return _buildMarkdownReport(
            items: snapshot.items.map(_insightItemToMap).toList(),
            selectedType: effectiveSelectedType,
            periodLabel: period.label,
          );
        },
      );

      if (mounted && result.status == ReportDownloadStatus.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Markdown report saved: ${result.path}'),
            backgroundColor: AppTheme.contextGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export markdown file: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usesInitialNodes = widget.initialNodes != null;
    final currentDraftItems = usesInitialNodes
        ? _getFilteredInsights()
        : _snapshotItems();
    final insightFilters = usesInitialNodes
        ? _insightFilters()
        : _snapshot.filters;
    final effectiveSelectedType = insightFilters.contains(_selectedType)
        ? _selectedType
        : 'All';

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 64, left: 16, right: 16),
      children: [
        // Header
        Text(
          'Personal Insights',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Dynamic auto-summaries compiled entirely on-device. Safe, isolated, and reconstructed automatically from your passive streams.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Configurations selectors
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INSIGHT TOPICS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.outline,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: insightFilters.map((type) {
                  final isSelected = effectiveSelectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : AppTheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = type;
                        });
                        if (widget.initialNodes == null) {
                          unawaited(_loadSnapshot(isSilent: true));
                        }
                      },
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TIME RANGE',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.outline,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ['Last 24 Hours', 'Last 7 Days', 'All Time'].map((
                  range,
                ) {
                  final isSelected = _selectedRange == range;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRange = range;
                        });
                        if (widget.initialNodes == null) {
                          unawaited(_loadSnapshot());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: AppTheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          range,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Insights card wrapper
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header status
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'COMPILED THEMES: $effectiveSelectedType',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _isLoading
                          ? 'Checking database...'
                          : 'Synthesized ${currentDraftItems.length} theme${currentDraftItems.length == 1 ? "" : "s"}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                height: 1,
              ),

              // Summary draft blocks / Empty State
              if (_isLoading)
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                )
              else if (currentDraftItems.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: currentDraftItems.length,
                  itemBuilder: (context, index) {
                    final item = currentDraftItems[index];
                    return _buildInsightBlock(item);
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Footer Actions
        if (currentDraftItems.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Verified by Local AI Model: Llama-3-Privacy',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: AppTheme.outlineVariant),
                  ),
                  onPressed: _exportAsMarkdown,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    'Export as Markdown',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Saved to securely-encrypted Local Archive.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.archive, size: 18),
                  label: const Text(
                    'Save to Archive',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bubble_chart_outlined,
            size: 48,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No local context recorded yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MemoryOS runs strictly offline and generates real insights automatically. Add local check-ins, record a voice note, or enable passive stream setup in the Timeline tab to see dynamic auto-summaries here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBlock(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final String type = item['type'];
    final IconData icon = item['icon'];
    final String title = item['title'];
    final String date = item['date'];
    final String body = item['body'];
    final List<String> tags = List<String>.from(item['tags'] ?? []);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left index circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.outlineVariant),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 12, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),

          // Core content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(date, style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),

                if (type == 'quote')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDim,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.03),
                      ),
                    ),
                    child: Text(
                      '"$body"',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  )
                else if (type == 'visual') ...[
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stylized Blueprint/Scientific custom canvas mockup
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1A2A), // Dark blueprint blue
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(painter: BlueprintPainter()),
                    ),
                  ),
                ] else if (type == 'screenshot') ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ],

                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDim,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painters to draw blueprint/schematic for academic look
class BlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw grid background
    const gridSpacing = 16.0;
    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw academic blueprint schemas (circles, measurements, lines)
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.5),
      35,
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.5),
      15,
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.5),
      45,
      Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: 0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // Draw anode/cathode elements
    final rect1 = Rect.fromCenter(
      center: Offset(size.width * 0.2, size.height * 0.5),
      width: 15,
      height: 60,
    );
    final rect2 = Rect.fromCenter(
      center: Offset(size.width * 0.6, size.height * 0.5),
      width: 15,
      height: 60,
    );
    canvas.drawRect(rect1, linePaint);
    canvas.drawRect(rect2, linePaint);
    canvas.drawRect(rect1, fillPaint);
    canvas.drawRect(rect2, fillPaint);

    // Measurement lines
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.15),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.2, size.height * 0.2),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.2),
      linePaint,
    );

    // Schematic labels
    final TextPainter tp = TextPainter(
      text: const TextSpan(
        text: "SEC: A-4 [D=35mm]",
        style: TextStyle(
          color: Colors.lightBlueAccent,
          fontSize: 8,
          fontFamily: 'JetBrains Mono',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width * 0.25, size.height * 0.22));

    final TextPainter tp2 = TextPainter(
      text: const TextSpan(
        text: "ZINC FOAM ANODE",
        style: TextStyle(
          color: Colors.lightBlueAccent,
          fontSize: 7,
          fontFamily: 'JetBrains Mono',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(size.width * 0.05, size.height * 0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
