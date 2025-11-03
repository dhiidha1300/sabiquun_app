class NotificationScheduleEntity {
  final String id;
  final String notificationTemplateId;
  final String scheduledTime; // HH:mm:ss format
  final String frequency; // 'daily', 'weekly', 'monthly', 'once'
  final List<int>? daysOfWeek; // For weekly: [0,1,2,3,4,5,6] where 0=Sunday
  final Map<String, dynamic>? conditions; // JSON conditions
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationScheduleEntity({
    required this.id,
    required this.notificationTemplateId,
    required this.scheduledTime,
    required this.frequency,
    this.daysOfWeek,
    this.conditions,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
