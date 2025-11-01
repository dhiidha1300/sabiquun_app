import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/audit_log_entity.dart';

part 'audit_log_model.freezed.dart';

/// Data model for audit logs with JSON serialization
@freezed
class AuditLogModel with _$AuditLogModel {
  const factory AuditLogModel({
    required String id,
    required String action,
    required String performedBy,
    required String performedByName,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? reason,
    required DateTime timestamp,
  }) = _AuditLogModel;

  const AuditLogModel._();

  /// Create from JSON (Supabase response with joined user name)
  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      action: json['action_type'] as String,
      performedBy: json['performed_by'] as String,
      performedByName: json['performed_by_name'] as String? ?? 'Unknown',
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String? ?? '',
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      reason: json['reason'] as String?,
      timestamp: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to domain entity
  AuditLogEntity toEntity() {
    return AuditLogEntity(
      id: id,
      action: action,
      performedBy: performedBy,
      performedByName: performedByName,
      entityType: entityType,
      entityId: entityId,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
      timestamp: timestamp,
    );
  }

  /// Create from domain entity
  factory AuditLogModel.fromEntity(AuditLogEntity entity) {
    return AuditLogModel(
      id: entity.id,
      action: entity.action,
      performedBy: entity.performedBy,
      performedByName: entity.performedByName,
      entityType: entity.entityType,
      entityId: entity.entityId,
      oldValue: entity.oldValue,
      newValue: entity.newValue,
      reason: entity.reason,
      timestamp: entity.timestamp,
    );
  }
}
