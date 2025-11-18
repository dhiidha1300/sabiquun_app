import 'package:equatable/equatable.dart';
import '../../domain/entities/penalty_entity.dart';
import '../../domain/entities/penalty_balance_entity.dart';

abstract class PenaltyState extends Equatable {
  const PenaltyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PenaltyInitial extends PenaltyState {
  const PenaltyInitial();
}

/// Loading state
class PenaltyLoading extends PenaltyState {
  const PenaltyLoading();
}

/// Total outstanding balance loaded (all users)
class TotalOutstandingBalanceLoaded extends PenaltyState {
  final double totalBalance;

  const TotalOutstandingBalanceLoaded(this.totalBalance);

  @override
  List<Object?> get props => [totalBalance];
}

/// Penalty balance loaded successfully
class PenaltyBalanceLoaded extends PenaltyState {
  final PenaltyBalanceEntity balance;

  const PenaltyBalanceLoaded(this.balance);

  @override
  List<Object?> get props => [balance];
}

/// Penalties list loaded successfully
class PenaltiesLoaded extends PenaltyState {
  final List<PenaltyEntity> penalties;
  final String? appliedFilter;

  const PenaltiesLoaded({
    required this.penalties,
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [penalties, appliedFilter];
}

/// Unpaid penalties loaded (for payment)
class UnpaidPenaltiesLoaded extends PenaltyState {
  final List<PenaltyEntity> penalties;
  final PenaltyBalanceEntity balance;

  const UnpaidPenaltiesLoaded({
    required this.penalties,
    required this.balance,
  });

  double get totalBalance => balance.totalBalance;
  double get formattedTotalBalance => totalBalance;

  @override
  List<Object?> get props => [penalties, balance];
}

/// Single penalty loaded
class PenaltyDetailLoaded extends PenaltyState {
  final PenaltyEntity penalty;

  const PenaltyDetailLoaded(this.penalty);

  @override
  List<Object?> get props => [penalty];
}

/// Penalty waived successfully
class PenaltyWaived extends PenaltyState {
  final String penaltyId;

  const PenaltyWaived(this.penaltyId);

  @override
  List<Object?> get props => [penaltyId];
}

/// Manual penalty created successfully
class ManualPenaltyCreated extends PenaltyState {
  final PenaltyEntity penalty;

  const ManualPenaltyCreated(this.penalty);

  @override
  List<Object?> get props => [penalty];
}

/// Penalty amount updated successfully
class PenaltyAmountUpdated extends PenaltyState {
  final String penaltyId;

  const PenaltyAmountUpdated(this.penaltyId);

  @override
  List<Object?> get props => [penaltyId];
}

/// Penalty removed successfully
class PenaltyRemoved extends PenaltyState {
  final String penaltyId;

  const PenaltyRemoved(this.penaltyId);

  @override
  List<Object?> get props => [penaltyId];
}

/// Error state
class PenaltyError extends PenaltyState {
  final String message;

  const PenaltyError(this.message);

  @override
  List<Object?> get props => [message];
}
