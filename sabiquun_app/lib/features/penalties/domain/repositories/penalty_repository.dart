import '../entities/penalty_entity.dart';
import '../entities/penalty_balance_entity.dart';

abstract class PenaltyRepository {
  /// Get user's current penalty balance
  Future<PenaltyBalanceEntity> getUserBalance(String userId);

  /// Get list of penalties for a user with optional status filter
  Future<List<PenaltyEntity>> getUserPenalties({
    required String userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get a specific penalty by ID
  Future<PenaltyEntity> getPenaltyById(String penaltyId);

  /// Get unpaid penalties ordered by date (FIFO - for payment application)
  Future<List<PenaltyEntity>> getUnpaidPenaltiesForPayment(String userId);

  /// Waive a penalty (Admin/Cashier only)
  Future<void> waivePenalty({
    required String penaltyId,
    required String waivedBy,
    required String reason,
  });

  /// Create manual penalty (Admin/Cashier only)
  Future<PenaltyEntity> createManualPenalty({
    required String userId,
    required double amount,
    required DateTime dateIncurred,
    required String reason,
    required String createdBy,
  });

  /// Update penalty amount (Admin/Cashier only)
  Future<void> updatePenaltyAmount({
    required String penaltyId,
    required double newAmount,
    required String reason,
    required String updatedBy,
  });

  /// Remove penalty (Admin/Cashier only)
  Future<void> removePenalty({
    required String penaltyId,
    required String reason,
    required String removedBy,
  });
}
