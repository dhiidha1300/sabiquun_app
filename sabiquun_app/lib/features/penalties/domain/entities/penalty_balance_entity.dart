import 'package:equatable/equatable.dart';

class PenaltyBalanceEntity extends Equatable {
  final double balance;
  final int unpaidPenaltiesCount;
  final DateTime? oldestPenaltyDate;
  final bool approachingDeactivation;
  final double deactivationThreshold;
  final double? firstWarningThreshold;
  final double? finalWarningThreshold;

  const PenaltyBalanceEntity({
    required this.balance,
    required this.unpaidPenaltiesCount,
    this.oldestPenaltyDate,
    required this.approachingDeactivation,
    required this.deactivationThreshold,
    this.firstWarningThreshold,
    this.finalWarningThreshold,
  });

  /// Get total balance (alias for balance field for consistency)
  double get totalBalance => balance;

  /// Get balance color indicator level
  /// green: 0-100,000
  /// yellow: 100,001-300,000
  /// red: 300,000+
  BalanceColorLevel get colorLevel {
    if (balance <= 100000) return BalanceColorLevel.green;
    if (balance <= 300000) return BalanceColorLevel.yellow;
    return BalanceColorLevel.red;
  }

  /// Check if balance is at or above first warning threshold
  bool get isAtFirstWarning {
    return firstWarningThreshold != null && balance >= firstWarningThreshold!;
  }

  /// Check if balance is at or above final warning threshold
  bool get isAtFinalWarning {
    return finalWarningThreshold != null && balance >= finalWarningThreshold!;
  }

  /// Check if balance has reached deactivation threshold
  bool get isAtDeactivationThreshold => balance >= deactivationThreshold;

  /// Get distance to deactivation threshold
  double get distanceToDeactivation => deactivationThreshold - balance;

  /// Get formatted balance string
  String get formattedBalance => '${balance.toStringAsFixed(0)} Shillings';

  /// Get formatted distance to deactivation
  String get formattedDistanceToDeactivation =>
      '${distanceToDeactivation.toStringAsFixed(0)} Shillings';

  @override
  List<Object?> get props => [
        balance,
        unpaidPenaltiesCount,
        oldestPenaltyDate,
        approachingDeactivation,
        deactivationThreshold,
        firstWarningThreshold,
        finalWarningThreshold,
      ];
}

enum BalanceColorLevel {
  green,
  yellow,
  red;

  bool get isGreen => this == BalanceColorLevel.green;
  bool get isYellow => this == BalanceColorLevel.yellow;
  bool get isRed => this == BalanceColorLevel.red;
}
