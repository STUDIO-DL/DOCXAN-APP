import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Material(
        color: DoxanColors.paper,
        elevation: 0,
        child: SafeArea(
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: l10n.home,
                  selected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _NavItem(
                  icon: Icons.folder_outlined,
                  selectedIcon: Icons.folder_rounded,
                  label: l10n.folders,
                  selected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _ScanItem(
                  label: l10n.scan,
                  selected: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: l10n.settings,
                  selected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? DoxanColors.ink : DoxanColors.inkMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanItem extends StatelessWidget {
  const _ScanItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DoxanColors.ink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                color: DoxanColors.paper,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: DoxanColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
