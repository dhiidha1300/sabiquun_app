import 'package:equatable/equatable.dart';

/// Entity representing an audit log entry for admin actions
class AuditLogEntity extends Equatable {
  final String id;
  final String action;
  final String performedBy;
  final String performedByName; // Joined from users table
  final String entityType; // 'user', 'penalty', 'report', 'payment', 'system'
  final String entityId;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? reason;
  final DateTime timestamp;

  const AuditLogEntity({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.performedByName,
    required this.entityType,
    required this.entityId,
    this.oldValue,
    this.newValue,
    this.reason,
    required this.timestamp,
  });

  /// Get formatted action name for display
  String get formattedAction {
    return action
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Get action icon based on type
  String get actionIcon {
    if (action.contains('penalty')) return '💰';
    if (action.contains('report')) return '📋';
    if (action.contains('user')) return '👤';
    if (action.contains('payment')) return '💳';
    if (action.contains('settings')) return '⚙️';
    if (action.contains('deed')) return '📖';
    return '📝';
  }

  /// Check if action has changes (old/new values)
  bool get hasChanges => oldValue != null || newValue != null;

  @override
  List<Object?> get props => [
        id,
        action,
        performedBy,
        performedByName,
        entityType,
        entityId,
        oldValue,
        newValue,
        reason,
        timestamp,
      ];
}
