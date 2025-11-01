import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/excuse_entity.dart';

part 'excuse_model.freezed.dart';
part 'excuse_model.g.dart';

@freezed
class ExcuseModel with _$ExcuseModel {
  const ExcuseModel._();

  const factory ExcuseModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'report_date') required DateTime reportDate,
    @JsonKey(name: 'excuse_type') required String excuseType,
    String? description,
    @JsonKey(name: 'affected_deeds') required Map<String, dynamic> affectedDeeds,
    required String status,
    @JsonKey(name: 'submitted_at') required DateTime submittedAt,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewer_name') String? reviewerName,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
  }) = _ExcuseModel;

  factory ExcuseModel.fromJson(Map<String, dynamic> json) =>
      _$ExcuseModelFromJson(json);

  /// Convert model to entity
  ExcuseEntity toEntity() {
    return ExcuseEntity(
      id: id,
      userId: userId,
      userName: userName ?? 'Unknown User',
      reportDate: reportDate,
      excuseType: excuseType,
      description: description,
      affectedDeeds: affectedDeeds,
      status: status,
      submittedAt: submittedAt,
      reviewedBy: reviewedBy,
      reviewerName: reviewerName,
      reviewedAt: reviewedAt,
      rejectionReason: rejectionReason,
    );
  }

  /// Convert entity to model
  factory ExcuseModel.fromEntity(ExcuseEntity entity) {
    return ExcuseModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      reportDate: entity.reportDate,
      excuseType: entity.excuseType,
      description: entity.description,
      affectedDeeds: entity.affectedDeeds,
      status: entity.status,
      submittedAt: entity.submittedAt,
      reviewedBy: entity.reviewedBy,
      reviewerName: entity.reviewerName,
      reviewedAt: entity.reviewedAt,
      rejectionReason: entity.rejectionReason,
    );
  }
}
