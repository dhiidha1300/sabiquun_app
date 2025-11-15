import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/home/widgets/role_based_scaffold.dart';
import 'package:sabiquun_app/features/home/pages/admin_home_content.dart';
import 'package:sabiquun_app/features/home/pages/cashier_home_content.dart';
import 'package:sabiquun_app/features/home/pages/supervisor_home_content.dart';
import 'package:sabiquun_app/features/home/pages/user_home_content.dart';

/// Wrapper for cashier home that provides overlay to RoleBasedScaffold
class _CashierHomeWrapper extends StatefulWidget {
  final UserEntity user;

  const _CashierHomeWrapper({required this.user});

  @override
  State<_CashierHomeWrapper> createState() => _CashierHomeWrapperState();
}

class _CashierHomeWrapperState extends State<_CashierHomeWrapper> {
  final GlobalKey<CashierHomeContentState> _cashierKey = GlobalKey<CashierHomeContentState>();

  @override
  Widget build(BuildContext context) {
    return RoleBasedScaffold(
      currentIndex: 0,
      overlay: _CashierOverlayBuilder(
        cashierKey: _cashierKey,
        // Force rebuild when wrapper rebuilds
        key: ValueKey(_cashierKey),
      ),
      child: CashierHomeContent(key: _cashierKey, user: widget.user),
    );
  }
}

/// Builder for cashier overlay that listens to animation controllers
class _CashierOverlayBuilder extends StatefulWidget {
  final GlobalKey<CashierHomeContentState> cashierKey;

  const _CashierOverlayBuilder({super.key, required this.cashierKey});

  @override
  State<_CashierOverlayBuilder> createState() => _CashierOverlayBuilderState();
}

class _CashierOverlayBuilderState extends State<_CashierOverlayBuilder> {
  @override
  void initState() {
    super.initState();
    // Schedule a rebuild after the first frame to ensure state is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.cashierKey.currentState != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.cashierKey.currentState;
    if (state == null) {
      // Return empty widget but schedule rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return const SizedBox.shrink();
    }

    // Listen to animation controllers to rebuild when they change
    return AnimatedBuilder(
      animation: Listenable.merge([
        state.drawerAnimationController,
        state.fabAnimationController,
      ]),
      builder: (context, child) {
        return state.buildOverlay(context);
      },
    );
  }
}

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
        Widget? drawer;
        Widget? overlay;

        if (user.isAdmin) {
          homeContent = AdminHomeContent(key: ValueKey('admin-$_rebuildKey'), user: user);
        } else if (user.isCashier) {
          // Use wrapper to provide overlay to RoleBasedScaffold
          return _CashierHomeWrapper(user: user);
        } else if (user.isSupervisor) {
          homeContent = SupervisorHomeContent(key: ValueKey('supervisor-$_rebuildKey'), user: user);
        } else {
          homeContent = UserHomeContent(key: ValueKey('user-$_rebuildKey'), user: user);
          // Build drawer widget for users
          drawer = UserHomeContent.buildDrawer(user);
        }

        return RoleBasedScaffold(
          currentIndex: 0,
          drawer: drawer,
          overlay: overlay,
          child: homeContent,
        );
      },
    );
  }
}
