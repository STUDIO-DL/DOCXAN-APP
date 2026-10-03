import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/ads/ad_config.dart';
import 'package:docxan/core/ads/widgets/docxan_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _scanBranch = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showBanner =
        AdConfig.adsEnabled && navigationShell.currentIndex != _scanBranch;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBanner) const DocxanBannerAd(),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: DocxanColors.paper,
              border: Border(top: BorderSide(color: DocxanColors.hairline)),
            ),
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
                      selected: navigationShell.currentIndex == _scanBranch,
                      onTap: () => navigationShell.goBranch(_scanBranch),
                    ),
                    _NavItem(
                      icon: Icons.search,
                      selectedIcon: Icons.search_rounded,
                      label: l10n.searchTab,
                      selected: navigationShell.currentIndex == 3,
                      onTap: () => navigationShell.goBranch(3),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings_rounded,
                      label: l10n.settings,
                      selected: navigationShell.currentIndex == 4,
                      onTap: () => navigationShell.goBranch(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    final color = selected ? DocxanColors.accent : DocxanColors.inkMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: DocxanColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DocxanColors.accent.withValues(
                      alpha: selected ? 0.45 : 0.28,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                color: DocxanColors.paper,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? DocxanColors.accent : DocxanColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
