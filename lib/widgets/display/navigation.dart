import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Enum representing all possible navigation destinations across mobile and desktop.
enum NavigationTab {
  alerts,
  chats,
  contacts,
  groups,
  updates,
  settings,
  profile,
}

class AdaptiveNavigationShell extends StatelessWidget {
  final Widget child;
  final NavigationTab currentTab;
  final ValueChanged<NavigationTab> onTabSelected;

  const AdaptiveNavigationShell({
    super.key,
    required this.child,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600 ||
            MediaQuery.of(context).orientation == Orientation.landscape;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: themeExtension.background,
            body: Row(
              children: [
                _DesktopSideNav(
                  currentTab: currentTab,
                  onTabSelected: onTabSelected,
                  themeExtension: themeExtension,
                  isDark: isDark,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: themeExtension.background,
          body: child,
          bottomNavigationBar: _MobileBottomNav(
            currentTab: currentTab,
            onTabSelected: onTabSelected,
            themeExtension: themeExtension,
          ),
        );
      },
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final NavigationTab currentTab;
  final ValueChanged<NavigationTab> onTabSelected;
  final AppColorScheme themeExtension;

  const _MobileBottomNav({
    required this.currentTab,
    required this.onTabSelected,
    required this.themeExtension,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.0,
      decoration: BoxDecoration(
        color: themeExtension.background,
        border: Border(
          top: BorderSide(color: themeExtension.border, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            tab: NavigationTab.chats,
            icon: Icons.chat_bubble_outline,
            label: 'Chats',
          ),
          _buildNavItem(
            context,
            tab: NavigationTab.contacts,
            icon: Icons.person_outline,
            label: 'Contacts',
          ),
          _buildNavItem(
            context,
            tab: NavigationTab.updates,
            icon: Icons.campaign_outlined,
            label: 'Updates',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required NavigationTab tab,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentTab == tab;
    final color = isActive ? AppColors.haloRing : themeExtension.textInputColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.0),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: color,
              ).copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSideNav extends StatelessWidget {
  final NavigationTab currentTab;
  final ValueChanged<NavigationTab> onTabSelected;
  final AppColorScheme themeExtension;
  final bool isDark;

  const _DesktopSideNav({
    required this.currentTab,
    required this.onTabSelected,
    required this.themeExtension,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.0,
      decoration: BoxDecoration(
        color: themeExtension.background,
        border: Border(
          right: BorderSide(color: themeExtension.border, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24.0),
          _buildNavItem(context, tab: NavigationTab.alerts, icon: Icons.notifications_none, label: 'Alerts'),
          const SizedBox(height: 8.0),
          _buildNavItem(context, tab: NavigationTab.chats, icon: Icons.chat_bubble_outline, label: 'Chats'),
          const SizedBox(height: 8.0),
          _buildNavItem(context, tab: NavigationTab.contacts, icon: Icons.person_outline, label: 'Contacts'),
          const SizedBox(height: 8.0),
          _buildNavItem(context, tab: NavigationTab.groups, icon: Icons.people_outline, label: 'Groups'),
          
          const Spacer(),
          
          _buildNavItem(context, tab: NavigationTab.updates, icon: Icons.campaign_outlined, label: 'Updates'),
          const SizedBox(height: 8.0),
          _buildNavItem(context, tab: NavigationTab.settings, icon: Icons.settings_outlined, label: 'Settings'),
          const SizedBox(height: 16.0),
          _buildProfileAvatar(),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required NavigationTab tab,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentTab == tab;
    final color = isActive ? AppColors.haloRing : AppColors.mutedSlate;
    
    // Distinct background shape for active state on desktop
    final activeBgColor = isDark 
        ? const Color(0xFF2C3239) 
        : AppColors.neutralGray.withOpacity(0.5);

    return InkWell(
      onTap: () => onTabSelected(tab),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: 64.0,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.0),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: color,
              ).copyWith(fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return InkWell(
      onTap: () => onTabSelected(NavigationTab.profile),
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: themeExtension.border,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            'U',
            style: TextStyle(
              color: themeExtension.textInputColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}