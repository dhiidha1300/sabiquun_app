import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sabiquun_app/core/di/injection.dart';
import 'package:sabiquun_app/core/navigation/app_router.dart';
import 'package:sabiquun_app/core/theme/app_theme.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
// import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
// import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
// import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env file fails to load, show error
    runApp(ErrorApp(error: 'Failed to load .env file: ${e.toString()}'));
    return;
  }

  // Initialize dependencies (Supabase, services, etc.)
  try {
    await Injection.init();
  } catch (e) {
    // If initialization fails, show error
    runApp(ErrorApp(error: e.toString()));
    return;
  }

  // Check if user is already authenticated
  Injection.authBloc.add(const AuthCheckRequested());

  // Run the app
  runApp(const SabiquunApp());
}

/// Main application widget
class SabiquunApp extends StatelessWidget {
  const SabiquunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: Injection.authBloc),
        BlocProvider.value(value: Injection.deedBloc),
        BlocProvider.value(value: Injection.penaltyBloc),
        BlocProvider.value(value: Injection.paymentBloc),
        BlocProvider.value(value: Injection.adminBloc),
        BlocProvider.value(value: Injection.notificationBloc),
        BlocProvider.value(value: Injection.excuseBloc),
        BlocProvider.value(value: Injection.analyticsBloc),
        BlocProvider.value(value: Injection.appContentBloc),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter(context.read<AuthBloc>()).router;

          return MaterialApp.router(
            title: 'Sabiquun',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

/// Error app shown when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabiquun - Error',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your environment configuration (.env file)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
