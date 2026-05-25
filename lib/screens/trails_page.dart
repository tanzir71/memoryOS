import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/memory_node.dart';
import '../services/capture_interval_policy.dart';
import '../services/capture_metadata.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class TrailsPage extends StatefulWidget {
  const TrailsPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<TrailsPage> createState() => _TrailsPageState();
}

class _TrailsPageState extends State<TrailsPage> {
  String? _selectedThread;
  List<String> _dynamicThreads = [];
  List<MemoryNode> _nodes = [];
  bool _isLoading = true;
  bool _isThreadsLoading = true;
  Timer? _refreshTimer;
  StreamSubscription<void>? _databaseChangesSubscription;

  // Search/AI Q&A Controller
  final TextEditingController _queryController = TextEditingController();
  bool _isSearching = false;
  String? _searchAnswer;
  List<MemoryNode> _searchResults = [];

  Map<String, dynamic> _getThreadMetadata(String name) {
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final colors = [
      AppTheme.primary,
      AppTheme.error,
      AppTheme.contextAmber,
      AppTheme.contextGreen,
      Colors.blueAccent,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
    ];
    final Color color = colors[hash % colors.length];

    IconData icon = Icons.tag;
    final lower = name.toLowerCase();
    if (lower.contains('solar') ||
        lower.contains('battery') ||
        lower.contains('anode') ||
        lower.contains('efficiency') ||
        lower.contains('helios')) {
      icon = Icons.wb_sunny;
    } else if (lower.contains('inverter') ||
        lower.contains('breaker') ||
        lower.contains('cabling') ||
        lower.contains('voltage') ||
        lower.contains('power')) {
      icon = Icons.bolt;
    } else if (lower.contains('tax') ||
        lower.contains('premium') ||
        lower.contains('invoice') ||
        lower.contains('receipt') ||
        lower.contains('finance') ||
        lower.contains('depreciation')) {
      icon = Icons.receipt_long;
    } else if (lower.contains('health') ||
        lower.contains('medical') ||
        lower.contains('run') ||
        lower.contains('gym') ||
        lower.contains('workout') ||
        lower.contains('fitness') ||
        lower.contains('cardio')) {
      icon = Icons.favorite;
    } else if (lower.contains('brother') ||
        lower.contains('mom') ||
        lower.contains('dad') ||
        lower.contains('shared') ||
        lower.contains('whatsapp') ||
        lower.contains('quote')) {
      icon = Icons.people_outline;
    } else if (lower.contains('work') ||
        lower.contains('office') ||
        lower.contains('meeting') ||
        lower.contains('pitch') ||
        lower.contains('roadmap') ||
        lower.contains('client')) {
      icon = Icons.business_center;
    } else if (lower.contains('reading') ||
        lower.contains('article') ||
        lower.contains('news')) {
      icon = Icons.assignment;
    } else if (lower.contains('location') ||
        lower.contains('visited') ||
        lower.contains('market')) {
      icon = Icons.location_on;
    } else if (lower.contains('document') ||
        lower.contains('file') ||
        lower.contains('pdf')) {
      icon = Icons.description;
    } else if (lower.contains('voice') ||
        lower.contains('mic') ||
        lower.contains('audio') ||
        lower.contains('record')) {
      icon = Icons.mic;
    }

    String activeSince = 'Active in Feed';
    if (_nodes.isNotEmpty) {
      activeSince = DateFormat('MMM d').format(_nodes.last.timestamp);
    }

    return {
      'name': name,
      'icon': icon,
      'description':
          "Chronological context stream and synthesized intelligence matching logged references to '$name'.",
      'color': color,
      'activeSince': activeSince,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadDynamicThreads();
    _databaseChangesSubscription = DatabaseService.instance.changes.listen((_) {
      if (mounted && widget.isActive) {
        _loadDynamicThreads(isSilent: true);
      }
    });
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant TrailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadDynamicThreads(isSilent: true);
    }
    _syncRefreshTimer();
  }

  void _syncRefreshTimer() {
    if (!widget.isActive) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }
    if (_refreshTimer != null) return;

    _refreshTimer = Timer.periodic(uiRefreshInterval, (timer) {
      if (mounted && widget.isActive) {
        _loadDynamicThreads(isSilent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _databaseChangesSubscription?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadDynamicThreads({bool isSilent = false}) async {
    if (!isSilent) {
      setState(() => _isThreadsLoading = true);
    }
    try {
      final threads = await DatabaseService.instance.getDynamicThreads();
      if (mounted) {
        setState(() {
          _dynamicThreads = threads;
          _isThreadsLoading = false;
          if (threads.isNotEmpty) {
            if (_selectedThread == null ||
                !_dynamicThreads.contains(_selectedThread)) {
              _selectedThread = _dynamicThreads.first;
            }
          }
        });
        await _loadNodes(isSilent: isSilent);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isThreadsLoading = false;
        });
      }
    }
  }

  Future<void> _loadNodes({bool isSilent = false}) async {
    if (_selectedThread == null) return;
    if (!isSilent) {
      setState(() => _isLoading = true);
    }
    try {
      final nodes = await DatabaseService.instance.fetchNodesByDynamicThread(
        _selectedThread!,
      );
      if (mounted) {
        setState(() {
          _nodes = nodes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onThreadSelected(String thread) {
    setState(() {
      _selectedThread = thread;
      _searchAnswer = null;
      _searchResults.clear();
      _queryController.clear();
    });
    _loadNodes();
  }

  Future<void> _askLocalContext() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchAnswer = null;
      _searchResults.clear();
    });

    // Simple offline processing simulation (1.2 seconds)
    await Future.delayed(const Duration(milliseconds: 1200));

    final results = await DatabaseService.instance.searchNodes(query);
    String answer = '';

    if (results.isNotEmpty) {
      answer =
          'Found ${results.length} offline enclave match${results.length == 1 ? "" : "es"} in your secure database. Here is a synthesized summary:\n\n';
      for (int i = 0; i < results.length && i < 3; i++) {
        answer += '• ${results[i].title}: "${results[i].content}"\n';
      }
      if (results.length > 3) {
        answer +=
            '\n...and ${results.length - 3} more matching logs are available in this thread feed below.';
      }
    } else {
      answer =
          'No exact matches found in your secure offline enclave for "$query".\n\nTry enabling passive stream collectors in the "Sources" tab or manually ingesting nodes matching this context (e.g. "solar", "tax", "gym", "breaker").';
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchAnswer = answer;
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = _selectedThread != null
        ? _getThreadMetadata(_selectedThread!)
        : {
            'name': 'Dynamic Thread',
            'icon': Icons.topic,
            'description': 'Select a thread to view associated memories.',
            'color': AppTheme.primary,
            'activeSince': 'Today',
          };
    final Color activeColor = meta['color'];

    return Column(
      children: [
        // 1. Horizontal Scrollable Trail Selector
        Container(
          height: 60,
          color: Colors.white,
          child: _isThreadsLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  children: _dynamicThreads.map((threadName) {
                    final isSelected = _selectedThread == threadName;
                    final info = _getThreadMetadata(threadName);
                    final icon = info['icon'] as IconData;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        avatar: Icon(
                          icon,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.onSurfaceVariant,
                        ),
                        label: Text(
                          threadName,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.onSurface,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => _onThreadSelected(threadName),
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceDim,
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.outlineVariant.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
        ),

        // Divider
        Container(height: 1, color: Colors.black.withOpacity(0.04)),

        // Main content scroll area
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            children: [
              // 2. Trail Banner metadata bento box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              meta['icon'] as IconData,
                              color: activeColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              meta['name'] as String,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: activeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active: ${meta['activeSince']}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: activeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      meta['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 12,
                          color: AppTheme.contextGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_nodes.length} record nodes indexed offline',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.contextGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Offline Generative Query Bar "Ask context"
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ASK LOCAL CONTEXT',
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 0.8,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search through your private database using simple queries. Synthesized locally.',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 14),

                    // Input textfield
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText:
                                  'e.g., Why does the inverter breaker trip?',
                              hintStyle: TextStyle(
                                color: AppTheme.onSurfaceVariant.withOpacity(
                                  0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.outlineVariant,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.outlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _askLocalContext(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isSearching ? null : _askLocalContext,
                          child: _isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward, size: 16),
                        ),
                      ],
                    ),

                    // AI synthesized answer box
                    if (_searchAnswer != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDim,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.04),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ON-DEVICE COGNITIVE SYNTHESIS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchAnswer!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trail stream list header
              Row(
                children: [
                  const Icon(Icons.timeline, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'STREAM ARCHIVE FEED',
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (_nodes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 36,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No records match this trail category yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _nodes
                      .map((node) => _buildTrailItemCard(node))
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailItemCard(MemoryNode node) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('MMM d, yyyy • hh:mm a').format(node.timestamp);

    final visibleMetadata = visibleMetadataForNode(
      source: node.source,
      metadata: node.metadata,
    );

    IconData sourceIcon = Icons.article;
    switch (node.source) {
      case 'voice_note':
        sourceIcon = Icons.mic;
        break;
      case 'location':
        sourceIcon = Icons.location_on;
        break;
      case 'calendar':
        sourceIcon = Icons.calendar_today;
        break;
      case 'photo':
        sourceIcon = Icons.photo_library;
        break;
      case 'reading':
        sourceIcon = Icons.assignment;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with timestamp & source icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(sourceIcon, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      node.source.toUpperCase().replaceAll('_', ' '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  timeStr,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 8.5),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Card title
            Text(
              node.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 6),

            // Content snippet
            Text(
              node.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),

            // Optional Metadata tags
            if (visibleMetadata.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: visibleMetadata.entries.map((e) {
                  if (e.value is bool || e.value == null) {
                    return const SizedBox.shrink();
                  }
                  final valStr = e.value.toString();
                  if (valStr.length > 25) {
                    return const SizedBox.shrink(); // Skip very long fields
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      '${e.key}: $valStr',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8.5,
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
