import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase service wrapper for Crashlytics and Analytics
class FirebaseService {
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;

  FirebaseService({
    FirebaseCrashlytics? crashlytics,
    FirebaseAnalytics? analytics,
  })  : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  // ==================== Crashlytics Methods ====================

  /// Log a non-fatal error to Crashlytics
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );

    if (kDebugMode) {
      print('Error logged to Crashlytics: $exception');
    }
  }

  /// Log a message to Crashlytics
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// Set user identifier for crash reports
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// Set custom key-value pairs for crash reports
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Force a crash (for testing purposes only)
  void forceCrash() {
    if (kDebugMode) {
      print('Force crash called - only works in release mode');
    }
    _crashlytics.crash();
  }

  /// Check if Crashlytics collection is enabled
  bool get isCrashlyticsCollectionEnabled {
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }

  /// Set whether to collect crash reports
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  // ==================== Analytics Methods ====================

  /// Log an analytics event
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>(),
    );

    if (kDebugMode) {
      print('Analytics event logged: $name with params: $parameters');
    }
  }

  /// Log screen view event
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user property for analytics
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value ?? '');
  }

  /// Log user login event
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log user signup event
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'unknown');
  }

  // ==================== Custom Analytics Events ====================

  /// Log deed submission event
  Future<void> logDeedSubmission({
    required double deedTotal,
    required String membershipStatus,
  }) async {
    await logEvent(
      name: 'deed_submitted',
      parameters: {
        'deed_total': deedTotal,
        'membership_status': membershipStatus,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log payment submission event
  Future<void> logPaymentSubmission({
    required double amount,
    required String paymentMethod,
  }) async {
    await logEvent(
      name: 'payment_submitted',
      parameters: {
        'amount': amount,
        'payment_method': paymentMethod,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log excuse request event
  Future<void> logExcuseRequest({
    required String excuseType,
  }) async {
    await logEvent(
      name: 'excuse_requested',
      parameters: {
        'excuse_type': excuseType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log penalty incurred event
  Future<void> logPenaltyIncurred({
    required double penaltyAmount,
    required String reason,
  }) async {
    await logEvent(
      name: 'penalty_incurred',
      parameters: {
        'penalty_amount': penaltyAmount,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log offline sync event
  Future<void> logOfflineSync({
    required int itemsSynced,
    required bool success,
  }) async {
    await logEvent(
      name: 'offline_sync',
      parameters: {
        'items_synced': itemsSynced,
        'success': success,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== Get Analytics Instance ====================

  /// Get FirebaseAnalytics instance for advanced usage
  FirebaseAnalytics get analytics => _analytics;

  /// Get FirebaseCrashlytics instance for advanced usage
  FirebaseCrashlytics get crashlytics => _crashlytics;
}
