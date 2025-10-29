import '../../domain/entities/penalty_entity.dart';
import '../../domain/entities/penalty_balance_entity.dart';
import '../../domain/repositories/penalty_repository.dart';
import '../datasources/penalty_remote_datasource.dart';

class PenaltyRepositoryImpl implements PenaltyRepository {
  final PenaltyRemoteDataSource _remoteDataSource;

  PenaltyRepositoryImpl(this._remoteDataSource);

  @override
  Future<PenaltyBalanceEntity> getUserBalance(String userId) async {
    try {
      final model = await _remoteDataSource.getUserBalance(userId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get user balance: $e');
    }
  }

  @override
  Future<List<PenaltyEntity>> getUserPenalties({
    required String userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _remoteDataSource.getUserPenalties(
        userId: userId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get penalties: $e');
    }
  }

  @override
  Future<PenaltyEntity> getPenaltyById(String penaltyId) async {
    try {
      final model = await _remoteDataSource.getPenaltyById(penaltyId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get penalty: $e');
    }
  }

  @override
  Future<List<PenaltyEntity>> getUnpaidPenaltiesForPayment(String userId) async {
    try {
      final models = await _remoteDataSource.getUnpaidPenaltiesForPayment(userId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get unpaid penalties: $e');
    }
  }

  @override
  Future<void> waivePenalty({
    required String penaltyId,
    required String waivedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.waivePenalty(
        penaltyId: penaltyId,
        waivedBy: waivedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to waive penalty: $e');
    }
  }

  @override
  Future<PenaltyEntity> createManualPenalty({
    required String userId,
    required double amount,
    required DateTime dateIncurred,
    required String reason,
    required String createdBy,
  }) async {
    try {
      final model = await _remoteDataSource.createManualPenalty(
        userId: userId,
        amount: amount,
        dateIncurred: dateIncurred,
        reason: reason,
        createdBy: createdBy,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to create manual penalty: $e');
    }
  }

  @override
  Future<void> updatePenaltyAmount({
    required String penaltyId,
    required double newAmount,
    required String reason,
    required String updatedBy,
  }) async {
    try {
      await _remoteDataSource.updatePenaltyAmount(
        penaltyId: penaltyId,
        newAmount: newAmount,
        reason: reason,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw Exception('Failed to update penalty amount: $e');
    }
  }

  @override
  Future<void> removePenalty({
    required String penaltyId,
    required String reason,
    required String removedBy,
  }) async {
    try {
      await _remoteDataSource.removePenalty(
        penaltyId: penaltyId,
        reason: reason,
        removedBy: removedBy,
      );
    } catch (e) {
      throw Exception('Failed to remove penalty: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateDailyPenalties() async {
    try {
      return await _remoteDataSource.calculateDailyPenaltiesWithLogging();
    } catch (e) {
      throw Exception('Failed to calculate daily penalties: $e');
    }
  }
}
