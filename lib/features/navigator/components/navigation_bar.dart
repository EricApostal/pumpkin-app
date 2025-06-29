import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalNavigationBar extends ConsumerStatefulWidget {
  const GlobalNavigationBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GlobalNavigationBarState();
}

class _GlobalNavigationBarState extends ConsumerState<GlobalNavigationBar>
    with TickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<NavItem> navItems = [
    NavItem(Icons.terminal_rounded, 'Console'),
    NavItem(Icons.folder_rounded, 'Files'),
    NavItem(Icons.settings_rounded, 'Config'),
    NavItem(Icons.star_rounded, 'Features'),
  ];

  @override
  void initState() {
    super.initState();
    currentPage = 0;

    tabController = TabController(
      length: navItems.length,
      vsync: this,
      initialIndex: currentPage,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });

    _animationController.forward();
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(NavItem item, int index) {
    final isSelected = currentPage == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        changePage(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              // const SizedBox(height: 4),
              // AnimatedDefaultTextStyle(
              //   duration: const Duration(milliseconds: 200),
              //   style: TextStyle(
              //     fontSize: 12,
              //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              //     color: isSelected
              //         ? Theme.of(context).colorScheme.primary
              //         : Theme.of(context).colorScheme.onSurfaceVariant,
              //   ),
              //   child: Text(item.label),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: navItems
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                            Expanded(child: _buildTab(entry.value, entry.key)),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}
