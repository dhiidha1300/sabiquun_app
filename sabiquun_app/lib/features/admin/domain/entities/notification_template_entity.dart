import 'package:equatable/equatable.dart';

/// Entity representing a notification template
class NotificationTemplateEntity extends Equatable {
  final String id;
  final String templateType; // 'report', 'payment', 'excuse', 'balance_warning', etc.
  final String templateName;
  final bool isActive;
  final bool isSystemDefault;

  // Email content
  final String? emailSubject;
  final String? emailBody;

  // Push notification content
  final String? pushTitle;
  final String? pushBody;

  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationTemplateEntity({
    required this.id,
    required this.templateType,
    required this.templateName,
    required this.isActive,
    required this.isSystemDefault,
    this.emailSubject,
    this.emailBody,
    this.pushTitle,
    this.pushBody,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get template type display name
  String get templateTypeDisplay {
    switch (templateType) {
      case 'report':
        return 'Report Notification';
      case 'payment':
        return 'Payment Notification';
      case 'excuse':
        return 'Excuse Notification';
      case 'balance_warning':
        return 'Balance Warning';
      case 'admin_action':
        return 'Admin Action';
      case 'system_announcement':
        return 'System Announcement';
      default:
        return templateType;
    }
  }

  /// Get email preview text (first 100 chars)
  String? get emailPreview {
    if (emailBody == null) return null;
    if (emailBody!.length <= 100) return emailBody;
    return '${emailBody!.substring(0, 100)}...';
  }

  /// Get push preview text (first 50 chars)
  String? get pushPreview {
    if (pushBody == null) return null;
    if (pushBody!.length <= 50) return pushBody;
    return '${pushBody!.substring(0, 50)}...';
  }

  @override
  List<Object?> get props => [
        id,
        templateType,
        templateName,
        isActive,
        isSystemDefault,
        emailSubject,
        emailBody,
        pushTitle,
        pushBody,
        createdAt,
        updatedAt,
      ];
}
