import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/penalty_payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    try {
      final models = await _remoteDataSource.getPaymentMethods();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  @override
  Future<PaymentEntity> submitPayment({
    required String userId,
    required double amount,
    required String paymentMethodId,
    String? referenceNumber,
  }) async {
    try {
      final model = await _remoteDataSource.submitPayment(
        userId: userId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        referenceNumber: referenceNumber,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to submit payment: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentHistory({
    required String userId,
    String? status,
  }) async {
    try {
      final models = await _remoteDataSource.getPaymentHistory(
        userId: userId,
        status: status,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  @override
  Future<PaymentEntity> getPaymentById(String paymentId) async {
    try {
      final model = await _remoteDataSource.getPaymentById(paymentId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getPendingPayments() async {
    try {
      final models = await _remoteDataSource.getPendingPayments();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pending payments: $e');
    }
  }

  @override
  Future<void> approvePayment({
    required String paymentId,
    required String reviewedBy,
  }) async {
    try {
      await _remoteDataSource.approvePayment(
        paymentId: paymentId,
        reviewedBy: reviewedBy,
      );
    } catch (e) {
      throw Exception('Failed to approve payment: $e');
    }
  }

  @override
  Future<void> rejectPayment({
    required String paymentId,
    required String reviewedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.rejectPayment(
        paymentId: paymentId,
        reviewedBy: reviewedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to reject payment: $e');
    }
  }

  @override
  Future<List<PenaltyPaymentEntity>> getPenaltyPayments(String paymentId) async {
    try {
      final models = await _remoteDataSource.getPenaltyPayments(paymentId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get penalty payments: $e');
    }
  }

  @override
  Future<void> manualBalanceClear({
    required String userId,
    required double amount,
    required String reason,
    required String clearedBy,
  }) async {
    try {
      await _remoteDataSource.manualBalanceClear(
        userId: userId,
        amount: amount,
        reason: reason,
        clearedBy: clearedBy,
      );
    } catch (e) {
      throw Exception('Failed to clear balance: $e');
    }
  }

  @override
  Future<PaymentMethodEntity> createPaymentMethod({
    required String name,
    required String displayName,
    required int sortOrder,
  }) async {
    try {
      final model = await _remoteDataSource.createPaymentMethod(
        name: name,
        displayName: displayName,
        sortOrder: sortOrder,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to create payment method: $e');
    }
  }

  @override
  Future<void> updatePaymentMethod({
    required String methodId,
    required String displayName,
    required bool isActive,
    required int sortOrder,
  }) async {
    try {
      await _remoteDataSource.updatePaymentMethod(
        methodId: methodId,
        displayName: displayName,
        isActive: isActive,
        sortOrder: sortOrder,
      );
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String methodId) async {
    try {
      await _remoteDataSource.deletePaymentMethod(methodId);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }
}
