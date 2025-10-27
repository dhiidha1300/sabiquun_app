import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/penalty_entity.dart';
import '../../../../core/constants/penalty_status.dart';

part 'penalty_model.freezed.dart';
part 'penalty_model.g.dart';

@freezed
class PenaltyModel with _$PenaltyModel {
  const PenaltyModel._();

  const factory PenaltyModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'report_id') String? reportId,
    required double amount,
    @JsonKey(name: 'date_incurred') required DateTime dateIncurred,
    required String status,
    @JsonKey(name: 'paid_amount') required double paidAmount,
    @JsonKey(name: 'waived_by') String? waivedBy,
    @JsonKey(name: 'waived_reason') String? waivedReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'missed_deeds') double? missedDeeds,
  }) = _PenaltyModel;

  factory PenaltyModel.fromJson(Map<String, dynamic> json) =>
      _$PenaltyModelFromJson(json);

  PenaltyEntity toEntity() {
    return PenaltyEntity(
      id: id,
      userId: userId,
      reportId: reportId,
      amount: amount,
      dateIncurred: dateIncurred,
      status: PenaltyStatus.fromString(status),
      paidAmount: paidAmount,
      waivedBy: waivedBy,
      waivedReason: waivedReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      missedDeeds: missedDeeds,
    );
  }
}
