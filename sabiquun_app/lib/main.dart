import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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

  // Initialize Firebase
  try {
    await Firebase.initializeApp();

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    if (kDebugMode) {
      // Disable Crashlytics collection in debug mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      print('Firebase initialized successfully (Crashlytics disabled in debug mode)');
    } else {
      // Enable Crashlytics collection in release mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      print('Firebase initialized successfully (Crashlytics enabled)');
    }
  } catch (e) {
    // If Firebase initialization fails, show error
    if (kDebugMode) {
      print('Failed to initialize Firebase: ${e.toString()}');
    }
    runApp(ErrorApp(error: 'Failed to initialize Firebase: ${e.toString()}'));
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
        BlocProvider.value(value: Injection.supervisorBloc),
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
