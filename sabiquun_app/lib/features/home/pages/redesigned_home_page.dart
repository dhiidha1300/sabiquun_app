import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/home/widgets/role_based_scaffold.dart';
import 'package:sabiquun_app/features/home/pages/admin_home_content.dart';
import 'package:sabiquun_app/features/home/pages/cashier_home_content.dart';
import 'package:sabiquun_app/features/home/pages/supervisor_home_content.dart';
import 'package:sabiquun_app/features/home/pages/user_home_content.dart';

/// Redesigned Modern Home Page with Role-Based Content
class RedesignedHomePage extends StatefulWidget {
  const RedesignedHomePage({super.key});

  @override
  State<RedesignedHomePage> createState() => _RedesignedHomePageState();
}

class _RedesignedHomePageState extends State<RedesignedHomePage> {
  int _rebuildKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force rebuild with new key every time dependencies change (e.g., when navigating back)
    setState(() {
      _rebuildKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authState.user;

        // Route to appropriate home content based on user role
        // Use rebuild key to force complete widget recreation
        Widget homeContent;
        if (user.isAdmin) {
          homeContent = AdminHomeContent(key: ValueKey('admin-$_rebuildKey'), user: user);
        } else if (user.isCashier) {
          homeContent = CashierHomeContent(key: ValueKey('cashier-$_rebuildKey'), user: user);
        } else if (user.isSupervisor) {
          homeContent = SupervisorHomeContent(key: ValueKey('supervisor-$_rebuildKey'), user: user);
        } else {
          homeContent = UserHomeContent(key: ValueKey('user-$_rebuildKey'), user: user);
        }

        return RoleBasedScaffold(
          currentIndex: 0,
          child: homeContent,
        );
      },
    );
  }
}
