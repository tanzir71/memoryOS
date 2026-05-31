import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_os_logo.dart';
import 'timeline_page.dart';
import 'summary_page.dart';
import 'sources_page.dart';
import 'trails_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;
  bool _isSyncing = false;

  void _triggerSync() {
    setState(() {
      _isSyncing = true;
    });
    // Simulate a local sync completion in 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Passive storage streams synchronized locally.',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12),
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomNavPadding = bottomInset > 12 ? bottomInset : 12.0;

    return Scaffold(
      // Global Sticky App Bar
      appBar: AppBar(
        title: Row(
          children: [
            const MemoryOSLogo(size: 24),
            const SizedBox(width: 8),
            Text(
              'MemoryOS',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isSyncing ? null : _triggerSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.sync, color: AppTheme.onSurfaceVariant),
            tooltip: 'Synchronize Local Streams',
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withOpacity(0.05), height: 1.0),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TimelinePage(
            key: const PageStorageKey('timeline'),
            isActive: _currentIndex == 0,
          ),
          SummaryPage(
            key: const PageStorageKey('summary'),
            isActive: _currentIndex == 1,
          ),
          SourcesPage(
            key: const PageStorageKey('sources'),
            isActive: _currentIndex == 2,
          ),
          TrailsPage(
            key: const PageStorageKey('trails'),
            isActive: _currentIndex == 3,
          ),
        ],
      ),
      // Stitch Custom Navigation Bar
      bottomNavigationBar: Container(
        key: const Key('shell-bottom-navigation-bar'),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomNavPadding),
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.timeline, 'Timeline'),
                _buildNavItem(1, Icons.auto_awesome, 'Insights'),
                _buildNavItem(2, Icons.settings_input_component, 'Sources'),
                _buildNavItem(3, Icons.account_tree, 'Threads'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isActive = _currentIndex == index;
    final activeColor = AppTheme.primary;
    final inactiveColor = AppTheme.onSurfaceVariant.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: 10,
                ),
              ),
              // Bottom small line matching the Stitch active nav line
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 16,
                  height: 2,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
