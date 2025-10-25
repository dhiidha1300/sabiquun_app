import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the application
///
/// This class holds all environment-specific configuration values
/// such as Supabase credentials, API keys, etc.
class EnvConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // App Configuration
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  // Firebase Configuration (for FCM)
  static String get fcmServerKey => dotenv.env['FCM_SERVER_KEY'] ?? '';

  // Mailgun Configuration (Admin configurable, stored in Supabase settings)
  // These are just defaults, actual values should be configured by admin
  static String get mailgunApiKey => dotenv.env['MAILGUN_API_KEY'] ?? '';

  static String get mailgunDomain => dotenv.env['MAILGUN_DOMAIN'] ?? '';

  // Validation
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';

  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  static void validateConfig() {
    if (!isConfigured) {
      throw Exception(
        'Environment not configured properly. '
        'Please set SUPABASE_URL and SUPABASE_ANON_KEY',
      );
    }
  }
}
