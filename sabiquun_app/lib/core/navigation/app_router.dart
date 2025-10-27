import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:sabiquun_app/features/auth/presentation/pages/login_page.dart';
import 'package:sabiquun_app/features/auth/presentation/pages/pending_approval_page.dart';
import 'package:sabiquun_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sabiquun_app/features/auth/presentation/pages/signup_page.dart';
import 'package:sabiquun_app/features/home/pages/home_page.dart';
import 'package:sabiquun_app/features/deeds/presentation/pages/today_deeds_page.dart';
import 'package:sabiquun_app/features/deeds/presentation/pages/my_reports_page.dart';
import 'package:sabiquun_app/features/deeds/presentation/pages/report_detail_page.dart';

/// Application router configuration
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is Authenticated;
      final isPendingApproval = authState is AccountPendingApproval;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isForgotPassword = state.matchedLocation == '/forgot-password';
      final isResetPassword = state.matchedLocation == '/reset-password';
      final isPendingPage = state.matchedLocation == '/pending-approval';

      // If authenticated, don't allow access to auth pages
      if (isAuthenticated) {
        if (isLoggingIn || isSigningUp || isPendingPage) {
          return '/home';
        }
      }

      // If pending approval, only allow pending approval page
      if (isPendingApproval) {
        if (!isPendingPage) {
          return '/pending-approval';
        }
      }

      // If not authenticated, redirect to login
      // Exception: allow signup, forgot password, reset password
      if (!isAuthenticated && !isPendingApproval) {
        if (!isLoggingIn &&
            !isSigningUp &&
            !isForgotPassword &&
            !isResetPassword &&
            !isPendingPage) {
          return '/login';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/pending-approval',
        name: 'pending-approval',
        builder: (context, state) {
          final email = state.extra as String?;
          return PendingApprovalPage(email: email);
        },
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Deed/Report Routes
      GoRoute(
        path: '/today-deeds',
        name: 'today-deeds',
        builder: (context, state) => const TodayDeedsPage(),
      ),
      GoRoute(
        path: '/my-reports',
        name: 'my-reports',
        builder: (context, state) => const MyReportsPage(),
      ),
      GoRoute(
        path: '/report-detail/:id',
        name: 'report-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportDetailPage(reportId: id);
        },
      ),

      // Add more routes as features are implemented
      // GoRoute(
      //   path: '/payments',
      //   name: 'payments',
      //   builder: (context, state) => const PaymentsPage(),
      // ),
      // etc...
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
