class NotificationTemplateEntity {
  final String id;
  final String templateKey;
  final String title;
  final String body;
  final String? emailSubject;
  final String? emailBody;
  final String notificationType;
  final bool isEnabled;
  final bool isSystemDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationTemplateEntity({
    required this.id,
    required this.templateKey,
    required this.title,
    required this.body,
    this.emailSubject,
    this.emailBody,
    required this.notificationType,
    required this.isEnabled,
    required this.isSystemDefault,
    required this.createdAt,
    required this.updatedAt,
  });
}
