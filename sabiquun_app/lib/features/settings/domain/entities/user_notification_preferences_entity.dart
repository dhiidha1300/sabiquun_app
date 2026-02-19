import 'package:equatable/equatable.dart';

/// Entity representing user notification preferences
class UserNotificationPreferencesEntity extends Equatable {
  final String id;
  final String userId;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final String? whatsappPhone;
  final bool whatsappVerified;
  final String sound;
  final bool quietHoursEnabled;
  final DateTime? quietHoursStart;
  final DateTime? quietHoursEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserNotificationPreferencesEntity({
    required this.id,
    required this.userId,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    this.whatsappPhone,
    required this.whatsappVerified,
    required this.sound,
    required this.quietHoursEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with optional new values
  UserNotificationPreferencesEntity copyWith({
    String? id,
    String? userId,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? whatsappEnabled,
    String? whatsappPhone,
    bool? whatsappVerified,
    String? sound,
    bool? quietHoursEnabled,
    DateTime? quietHoursStart,
    DateTime? quietHoursEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNotificationPreferencesEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      whatsappPhone: whatsappPhone ?? this.whatsappPhone,
      whatsappVerified: whatsappVerified ?? this.whatsappVerified,
      sound: sound ?? this.sound,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns default preferences for a new user
  factory UserNotificationPreferencesEntity.defaultPreferences(String userId) {
    final now = DateTime.now();
    return UserNotificationPreferencesEntity(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        pushEnabled,
        emailEnabled,
        whatsappEnabled,
        whatsappPhone,
        whatsappVerified,
        sound,
        quietHoursEnabled,
        quietHoursStart,
        quietHoursEnd,
        createdAt,
        updatedAt,
      ];
}
