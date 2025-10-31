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

  const RoleBasedScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
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

        return Scaffold(
          body: child,
          extendBody: true,
          bottomNavigationBar: _buildFloatingBottomNav(context, navItems, user),
        );
      },
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context, List<BottomNavigationBarItem> items, user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, items.length - 1),
          onTap: (index) => _onItemTapped(context, index, user),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedFontSize: 12,
          unselectedFontSize: 11,
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
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet),
        label: 'Payments',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
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
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
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
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
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
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
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
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/my-reports');
        break;
      case 2:
        context.go('/payment-history', extra: user.id);
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _handleSupervisorNavigation(BuildContext context, int index, user) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/user-reports');
        break;
      case 2:
        context.go('/leaderboard');
        break;
      case 3:
        context.go('/send-notification');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  void _handleCashierNavigation(BuildContext context, int index, user) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/payment-review');
        break;
      case 2:
        context.go('/payment-history', extra: user.id);
        break;
      case 3:
        context.go('/user-balances');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  void _handleAdminNavigation(BuildContext context, int index, user) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/admin/user-management');
        break;
      case 2:
        context.go('/admin/analytics');
        break;
      case 3:
        context.go('/admin/system-settings');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
