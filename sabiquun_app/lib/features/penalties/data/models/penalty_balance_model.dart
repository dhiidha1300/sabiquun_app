import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/penalty_balance_entity.dart';

part 'penalty_balance_model.freezed.dart';
part 'penalty_balance_model.g.dart';

@freezed
class PenaltyBalanceModel with _$PenaltyBalanceModel {
  const PenaltyBalanceModel._();

  const factory PenaltyBalanceModel({
    required double balance,
    @JsonKey(name: 'unpaid_penalties_count') required int unpaidPenaltiesCount,
    @JsonKey(name: 'oldest_penalty_date') DateTime? oldestPenaltyDate,
    @JsonKey(name: 'approaching_deactivation') required bool approachingDeactivation,
    @JsonKey(name: 'deactivation_threshold') required double deactivationThreshold,
    @JsonKey(name: 'first_warning_threshold') double? firstWarningThreshold,
    @JsonKey(name: 'final_warning_threshold') double? finalWarningThreshold,
  }) = _PenaltyBalanceModel;

  factory PenaltyBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$PenaltyBalanceModelFromJson(json);

  PenaltyBalanceEntity toEntity() {
    return PenaltyBalanceEntity(
      balance: balance,
      unpaidPenaltiesCount: unpaidPenaltiesCount,
      oldestPenaltyDate: oldestPenaltyDate,
      approachingDeactivation: approachingDeactivation,
      deactivationThreshold: deactivationThreshold,
      firstWarningThreshold: firstWarningThreshold,
      finalWarningThreshold: finalWarningThreshold,
    );
  }
}
