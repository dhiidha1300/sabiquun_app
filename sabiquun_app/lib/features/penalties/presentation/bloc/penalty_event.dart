import 'package:equatable/equatable.dart';

abstract class PenaltyEvent extends Equatable {
  const PenaltyEvent();

  @override
  List<Object?> get props => [];
}

/// Load total outstanding balance across all users (Admin/Cashier dashboard)
class LoadTotalOutstandingBalanceRequested extends PenaltyEvent {
  const LoadTotalOutstandingBalanceRequested();
}

/// Load user's current penalty balance
class LoadPenaltyBalanceRequested extends PenaltyEvent {
  final String userId;

  const LoadPenaltyBalanceRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load list of penalties with optional filters
class LoadPenaltiesRequested extends PenaltyEvent {
  final String userId;
  final String? statusFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadPenaltiesRequested({
    required this.userId,
    this.statusFilter,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, statusFilter, startDate, endDate];
}

/// Load unpaid penalties for payment (FIFO)
class LoadUnpaidPenaltiesRequested extends PenaltyEvent {
  final String userId;

  const LoadUnpaidPenaltiesRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load a specific penalty by ID
class LoadPenaltyByIdRequested extends PenaltyEvent {
  final String penaltyId;

  const LoadPenaltyByIdRequested(this.penaltyId);

  @override
  List<Object?> get props => [penaltyId];
}

/// Waive a penalty (Admin/Cashier only)
class WaivePenaltyRequested extends PenaltyEvent {
  final String penaltyId;
  final String waivedBy;
  final String reason;

  const WaivePenaltyRequested({
    required this.penaltyId,
    required this.waivedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [penaltyId, waivedBy, reason];
}

/// Create manual penalty (Admin/Cashier only)
class CreateManualPenaltyRequested extends PenaltyEvent {
  final String userId;
  final double amount;
  final DateTime dateIncurred;
  final String reason;
  final String createdBy;

  const CreateManualPenaltyRequested({
    required this.userId,
    required this.amount,
    required this.dateIncurred,
    required this.reason,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [userId, amount, dateIncurred, reason, createdBy];
}

/// Update penalty amount (Admin/Cashier only)
class UpdatePenaltyAmountRequested extends PenaltyEvent {
  final String penaltyId;
  final double newAmount;
  final String reason;
  final String updatedBy;

  const UpdatePenaltyAmountRequested({
    required this.penaltyId,
    required this.newAmount,
    required this.reason,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [penaltyId, newAmount, reason, updatedBy];
}

/// Remove penalty (Admin/Cashier only)
class RemovePenaltyRequested extends PenaltyEvent {
  final String penaltyId;
  final String reason;
  final String removedBy;

  const RemovePenaltyRequested({
    required this.penaltyId,
    required this.reason,
    required this.removedBy,
  });

  @override
  List<Object?> get props => [penaltyId, reason, removedBy];
}

/// Reset penalty state
class ResetPenaltyStateRequested extends PenaltyEvent {
  const ResetPenaltyStateRequested();
}
