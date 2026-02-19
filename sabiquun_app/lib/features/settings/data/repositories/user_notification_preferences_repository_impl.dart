import 'package:sabiquun_app/features/settings/domain/entities/user_notification_preferences_entity.dart';
import 'package:sabiquun_app/features/settings/domain/repositories/user_notification_preferences_repository.dart';
import 'package:sabiquun_app/features/settings/data/datasources/user_notification_preferences_remote_datasource.dart';
import 'package:sabiquun_app/features/settings/data/models/user_notification_preferences_model.dart';

/// Implementation of UserNotificationPreferencesRepository
class UserNotificationPreferencesRepositoryImpl
    implements UserNotificationPreferencesRepository {
  final UserNotificationPreferencesRemoteDataSource remoteDataSource;

  UserNotificationPreferencesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserNotificationPreferencesEntity?> getPreferences(String userId) async {
    try {
      final model = await remoteDataSource.getPreferences(userId);
      return model;
    } catch (e) {
      throw Exception('Failed to get notification preferences: $e');
    }
  }

  @override
  Future<void> updatePreferences(
      UserNotificationPreferencesEntity preferences) async {
    try {
      final model = UserNotificationPreferencesModel.fromEntity(preferences);
      await remoteDataSource.updatePreferences(model);
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  @override
  Future<UserNotificationPreferencesEntity> createDefaultPreferences(
      String userId) async {
    try {
      final model = await remoteDataSource.createDefaultPreferences(userId);
      return model;
    } catch (e) {
      throw Exception('Failed to create default notification preferences: $e');
    }
  }

  @override
  Future<void> updateWhatsAppVerification({
    required String userId,
    required String? whatsappPhone,
    required bool whatsappVerified,
  }) async {
    try {
      await remoteDataSource.updateWhatsAppVerification(
        userId: userId,
        whatsappPhone: whatsappPhone,
        whatsappVerified: whatsappVerified,
      );
    } catch (e) {
      throw Exception('Failed to update WhatsApp verification: $e');
    }
  }
}
