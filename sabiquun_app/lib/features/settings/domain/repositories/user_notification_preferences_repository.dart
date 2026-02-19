import 'package:sabiquun_app/features/settings/domain/entities/user_notification_preferences_entity.dart';

/// Repository interface for user notification preferences operations
abstract class UserNotificationPreferencesRepository {
  /// Get notification preferences for a user
  Future<UserNotificationPreferencesEntity?> getPreferences(String userId);

  /// Update notification preferences for a user
  Future<void> updatePreferences(UserNotificationPreferencesEntity preferences);

  /// Create default notification preferences for a new user
  Future<UserNotificationPreferencesEntity> createDefaultPreferences(String userId);

  /// Update WhatsApp verification status (admin only)
  Future<void> updateWhatsAppVerification({
    required String userId,
    required String? whatsappPhone,
    required bool whatsappVerified,
  });
}
