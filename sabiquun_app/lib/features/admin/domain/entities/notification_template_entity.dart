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
  // WhatsApp template fields
  final String? whatsappTemplateName;
  final String? whatsappTemplateLanguage;
  final bool whatsappEnabled;
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
    this.whatsappTemplateName,
    this.whatsappTemplateLanguage,
    this.whatsappEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with optional new values
  NotificationTemplateEntity copyWith({
    String? id,
    String? templateKey,
    String? title,
    String? body,
    String? emailSubject,
    String? emailBody,
    String? notificationType,
    bool? isEnabled,
    bool? isSystemDefault,
    String? whatsappTemplateName,
    String? whatsappTemplateLanguage,
    bool? whatsappEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTemplateEntity(
      id: id ?? this.id,
      templateKey: templateKey ?? this.templateKey,
      title: title ?? this.title,
      body: body ?? this.body,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
      notificationType: notificationType ?? this.notificationType,
      isEnabled: isEnabled ?? this.isEnabled,
      isSystemDefault: isSystemDefault ?? this.isSystemDefault,
      whatsappTemplateName: whatsappTemplateName ?? this.whatsappTemplateName,
      whatsappTemplateLanguage: whatsappTemplateLanguage ?? this.whatsappTemplateLanguage,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
