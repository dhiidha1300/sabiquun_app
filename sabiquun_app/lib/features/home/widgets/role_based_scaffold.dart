import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';

/// Role-Based Scaffold with different bottom navigation per role
class RoleBasedScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Widget? drawer;
  final Widget? overlay; // Overlay widget (e.g., drawer, dialogs) that appears above bottom nav

  const RoleBasedScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.drawer,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return Scaffold(body: child);
        }

        final user = state.user;

        // Get navigation items based on user role
        List<BottomNavigationBarItem> navItems;
        if (user.isAdmin) {
          navItems = _getAdminNavItems();
        } else if (user.isSupervisor) {
          navItems = _getSupervisorNavItems();
        } else if (user.isCashier) {
          navItems = _getCashierNavItems();
        } else {
          navItems = _getUserNavItems();
        }

        return Stack(
          children: [
            Scaffold(
              body: child,
              drawer: drawer,
              extendBody: false,
              bottomNavigationBar: _buildModernBottomNav(context, navItems, user),
            ),
            // Render overlay on top of everything (including bottom nav)
            if (overlay != null) overlay!,
          ],
        );
      },
    );
  }

  Widget _buildModernBottomNav(BuildContext context, List<BottomNavigationBarItem> items, user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, items.length - 1),
          onTap: (index) => _onItemTapped(context, index, user),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          items: items,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _getUserNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.description_outlined),
        activeIcon: Icon(Icons.description),
        label: 'Reports',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events_outlined),
        activeIcon: Icon(Icons.emoji_events),
        label: 'Leaderboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet),
        label: 'Payments',
      ),
    ];
  }

  List<BottomNavigationBarItem> _getSupervisorNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Users',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard_outlined),
        activeIcon: Icon(Icons.leaderboard),
        label: 'Leaderboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        activeIcon: Icon(Icons.notifications),
        label: 'Notify',
      ),
    ];
  }

  List<BottomNavigationBarItem> _getCashierNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.pending_actions_outlined),
        activeIcon: Icon(Icons.pending_actions),
        label: 'Pending',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet),
        label: 'Payments',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Balances',
      ),
    ];
  }

  List<BottomNavigationBarItem> _getAdminNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Users',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Analytics',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }

  void _onItemTapped(BuildContext context, int index, user) {
    if (user.isAdmin) {
      _handleAdminNavigation(context, index, user);
    } else if (user.isSupervisor) {
      _handleSupervisorNavigation(context, index, user);
    } else if (user.isCashier) {
      _handleCashierNavigation(context, index, user);
    } else {
      _handleUserNavigation(context, index, user);
    }
  }

  void _handleUserNavigation(BuildContext context, int index, user) {
    // Don't navigate if already on the target page
    final currentRoute = GoRouterState.of(context).uri.toString();

    switch (index) {
      case 0:
        if (!currentRoute.startsWith('/home')) context.go('/home');
        break;
      case 1:
        if (!currentRoute.startsWith('/my-reports')) context.go('/my-reports');
        break;
      case 2:
        if (!currentRoute.startsWith('/user-leaderboard')) context.go('/user-leaderboard');
        break;
      case 3:
        if (!currentRoute.startsWith('/payment-history')) {
          context.go('/payment-history', extra: user.id);
        }
        break;
    }
  }

  void _handleSupervisorNavigation(BuildContext context, int index, user) {
    // Don't navigate if already on the target page
    final currentRoute = GoRouterState.of(context).uri.toString();

    switch (index) {
      case 0:
        if (!currentRoute.startsWith('/home')) context.go('/home');
        break;
      case 1:
        if (!currentRoute.startsWith('/user-reports')) context.go('/user-reports');
        break;
      case 2:
        if (!currentRoute.startsWith('/leaderboard')) context.go('/leaderboard');
        break;
      case 3:
        if (!currentRoute.startsWith('/send-notification')) context.go('/send-notification');
        break;
    }
  }

  void _handleCashierNavigation(BuildContext context, int index, user) {
    // Don't navigate if already on the target page
    final currentRoute = GoRouterState.of(context).uri.toString();

    switch (index) {
      case 0:
        if (!currentRoute.startsWith('/home')) context.go('/home');
        break;
      case 1:
        if (!currentRoute.startsWith('/payment-review')) context.go('/payment-review');
        break;
      case 2:
        if (!currentRoute.startsWith('/payment-history')) {
          context.go('/payment-history', extra: user.id);
        }
        break;
      case 3:
        if (!currentRoute.startsWith('/user-balances')) context.go('/user-balances');
        break;
    }
  }

  void _handleAdminNavigation(BuildContext context, int index, user) {
    // Don't navigate if already on the target page
    final currentRoute = GoRouterState.of(context).uri.toString();

    switch (index) {
      case 0:
        if (!currentRoute.startsWith('/home')) context.go('/home');
        break;
      case 1:
        if (!currentRoute.startsWith('/admin/user-management')) {
          context.go('/admin/user-management');
        }
        break;
      case 2:
        if (!currentRoute.startsWith('/admin/analytics')) context.go('/admin/analytics');
        break;
      case 3:
        if (!currentRoute.startsWith('/admin/system-settings')) {
          context.go('/admin/system-settings');
        }
        break;
    }
  }
}
