/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Sabiquun';
  static const String appVersion = '1.0.0';

  // Token Configuration
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const Duration accessTokenLifetime = Duration(hours: 24);
  static const Duration refreshTokenLifetime = Duration(days: 30);
  static const Duration tokenRefreshBuffer = Duration(hours: 1);

  // Session Configuration
  static const String rememberMeKey = 'remember_me';
  static const String lastLoginEmailKey = 'last_login_email';

  // Password Requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Phone Number
  static const String defaultCountryCode = '+252'; // Somalia

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration errorSnackBarDuration = Duration(seconds: 5);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Support
  static const String supportEmail = 'support@sabiquun.app';
  static const String privacyPolicyUrl = 'https://sabiquun.app/privacy';
  static const String termsOfServiceUrl = 'https://sabiquun.app/terms';
}
