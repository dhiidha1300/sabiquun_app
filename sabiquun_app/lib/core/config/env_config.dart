/// Environment configuration for the application
///
/// This class holds all environment-specific configuration values
/// such as Supabase credentials, API keys, etc.
class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // App Configuration
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // Firebase Configuration (for FCM)
  static const String fcmServerKey = String.fromEnvironment(
    'FCM_SERVER_KEY',
    defaultValue: '',
  );

  // Mailgun Configuration (Admin configurable, stored in Supabase settings)
  // These are just defaults, actual values should be configured by admin
  static const String mailgunApiKey = String.fromEnvironment(
    'MAILGUN_API_KEY',
    defaultValue: '',
  );

  static const String mailgunDomain = String.fromEnvironment(
    'MAILGUN_DOMAIN',
    defaultValue: '',
  );

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
