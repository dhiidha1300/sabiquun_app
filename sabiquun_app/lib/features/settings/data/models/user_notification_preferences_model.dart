import 'package:sabiquun_app/features/settings/domain/entities/user_notification_preferences_entity.dart';

/// Data model for user notification preferences with JSON serialization
class UserNotificationPreferencesModel extends UserNotificationPreferencesEntity {
  const UserNotificationPreferencesModel({
    required super.id,
    required super.userId,
    required super.pushEnabled,
    required super.emailEnabled,
    required super.whatsappEnabled,
    super.whatsappPhone,
    required super.whatsappVerified,
    required super.sound,
    required super.quietHoursEnabled,
    super.quietHoursStart,
    super.quietHoursEnd,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from JSON
  factory UserNotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationPreferencesModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pushEnabled: json['push_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? true,
      whatsappEnabled: json['whatsapp_enabled'] as bool? ?? false,
      whatsappPhone: json['whatsapp_phone'] as String?,
      whatsappVerified: json['whatsapp_verified'] as bool? ?? false,
      sound: json['sound'] as String? ?? 'default',
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] != null
          ? parseTimeString(json['quiet_hours_start'] as String)
          : null,
      quietHoursEnd: json['quiet_hours_end'] != null
          ? parseTimeString(json['quiet_hours_end'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Parse time string (HH:mm:ss) to DateTime (uses today's date)
  static DateTime parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  /// Format DateTime to time string (HH:mm:ss)
  static String formatTimeString(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'whatsapp_enabled': whatsappEnabled,
      'whatsapp_phone': whatsappPhone,
      'whatsapp_verified': whatsappVerified,
      'sound': sound,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start':
          quietHoursStart != null ? formatTimeString(quietHoursStart!) : null,
      'quiet_hours_end':
          quietHoursEnd != null ? formatTimeString(quietHoursEnd!) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for update (excludes id and timestamps)
  Map<String, dynamic> toUpdateJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'whatsapp_enabled': whatsappEnabled,
      'whatsapp_phone': whatsappPhone,
      'sound': sound,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start':
          quietHoursStart != null ? formatTimeString(quietHoursStart!) : null,
      'quiet_hours_end':
          quietHoursEnd != null ? formatTimeString(quietHoursEnd!) : null,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create from entity
  factory UserNotificationPreferencesModel.fromEntity(
      UserNotificationPreferencesEntity entity) {
    return UserNotificationPreferencesModel(
      id: entity.id,
      userId: entity.userId,
      pushEnabled: entity.pushEnabled,
      emailEnabled: entity.emailEnabled,
      whatsappEnabled: entity.whatsappEnabled,
      whatsappPhone: entity.whatsappPhone,
      whatsappVerified: entity.whatsappVerified,
      sound: entity.sound,
      quietHoursEnabled: entity.quietHoursEnabled,
      quietHoursStart: entity.quietHoursStart,
      quietHoursEnd: entity.quietHoursEnd,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create default preferences for a user
  factory UserNotificationPreferencesModel.defaultFor(String userId) {
    final now = DateTime.now();
    return UserNotificationPreferencesModel(
      id: '',
      userId: userId,
      pushEnabled: true,
      emailEnabled: true,
      whatsappEnabled: false,
      whatsappPhone: null,
      whatsappVerified: false,
      sound: 'default',
      quietHoursEnabled: false,
      quietHoursStart: null,
      quietHoursEnd: null,
      createdAt: now,
      updatedAt: now,
    );
  }
}
