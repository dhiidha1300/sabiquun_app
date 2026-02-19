import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/settings/data/models/user_notification_preferences_model.dart';

/// Remote data source for user notification preferences operations
class UserNotificationPreferencesRemoteDataSource {
  final SupabaseClient _supabase;

  UserNotificationPreferencesRemoteDataSource(this._supabase);

  /// Get notification preferences for a user
  Future<UserNotificationPreferencesModel?> getPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('user_notification_preferences')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserNotificationPreferencesModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch notification preferences: $e');
    }
  }

  /// Update notification preferences for a user
  Future<void> updatePreferences(UserNotificationPreferencesModel preferences) async {
    try {
      await _supabase
          .from('user_notification_preferences')
          .update(preferences.toUpdateJson())
          .eq('user_id', preferences.userId);
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// Create default notification preferences for a new user
  Future<UserNotificationPreferencesModel> createDefaultPreferences(String userId) async {
    try {
      final defaults = UserNotificationPreferencesModel.defaultFor(userId);

      final response = await _supabase
          .from('user_notification_preferences')
          .insert({
            'user_id': userId,
            'push_enabled': defaults.pushEnabled,
            'email_enabled': defaults.emailEnabled,
            'whatsapp_enabled': defaults.whatsappEnabled,
            'whatsapp_phone': defaults.whatsappPhone,
            'whatsapp_verified': defaults.whatsappVerified,
            'sound': defaults.sound,
            'quiet_hours_enabled': defaults.quietHoursEnabled,
            'quiet_hours_start': null,
            'quiet_hours_end': null,
          })
          .select()
          .single();

      return UserNotificationPreferencesModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create default notification preferences: $e');
    }
  }

  /// Update WhatsApp verification status (admin only)
  Future<void> updateWhatsAppVerification({
    required String userId,
    required String? whatsappPhone,
    required bool whatsappVerified,
  }) async {
    try {
      await _supabase
          .from('user_notification_preferences')
          .update({
            'whatsapp_phone': whatsappPhone,
            'whatsapp_verified': whatsappVerified,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update WhatsApp verification: $e');
    }
  }

  /// Upsert preferences (create if not exists, update if exists)
  Future<UserNotificationPreferencesModel> upsertPreferences(
      UserNotificationPreferencesModel preferences) async {
    try {
      final response = await _supabase
          .from('user_notification_preferences')
          .upsert({
            'user_id': preferences.userId,
            'push_enabled': preferences.pushEnabled,
            'email_enabled': preferences.emailEnabled,
            'whatsapp_enabled': preferences.whatsappEnabled,
            'whatsapp_phone': preferences.whatsappPhone,
            'whatsapp_verified': preferences.whatsappVerified,
            'sound': preferences.sound,
            'quiet_hours_enabled': preferences.quietHoursEnabled,
            'quiet_hours_start': preferences.quietHoursStart != null
                ? UserNotificationPreferencesModel.formatTimeString(
                    preferences.quietHoursStart!)
                : null,
            'quiet_hours_end': preferences.quietHoursEnd != null
                ? UserNotificationPreferencesModel.formatTimeString(
                    preferences.quietHoursEnd!)
                : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return UserNotificationPreferencesModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to upsert notification preferences: $e');
    }
  }
}
