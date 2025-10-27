import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(const PaymentInitial()) {
    on<LoadPaymentMethodsRequested>(_onLoadPaymentMethodsRequested);
    on<SubmitPaymentRequested>(_onSubmitPaymentRequested);
    on<LoadPaymentHistoryRequested>(_onLoadPaymentHistoryRequested);
    on<LoadPendingPaymentsRequested>(_onLoadPendingPaymentsRequested);
    on<ApprovePaymentRequested>(_onApprovePaymentRequested);
    on<RejectPaymentRequested>(_onRejectPaymentRequested);
    on<LoadPenaltyPaymentsRequested>(_onLoadPenaltyPaymentsRequested);
    on<ManualBalanceClearRequested>(_onManualBalanceClearRequested);
    on<ResetPaymentStateRequested>(_onResetPaymentStateRequested);
  }

  Future<void> _onLoadPaymentMethodsRequested(
    LoadPaymentMethodsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final methods = await _paymentRepository.getPaymentMethods();
      emit(PaymentMethodsLoaded(methods));
    } catch (e) {
      emit(PaymentError('Failed to load payment methods: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitPaymentRequested(
    SubmitPaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final payment = await _paymentRepository.submitPayment(
        userId: event.userId,
        amount: event.amount,
        paymentMethodId: event.paymentMethodId,
        referenceNumber: event.referenceNumber,
      );
      emit(PaymentSubmitted(payment));
    } catch (e) {
      emit(PaymentError('Failed to submit payment: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPaymentHistoryRequested(
    LoadPaymentHistoryRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final payments = await _paymentRepository.getPaymentHistory(
        userId: event.userId,
        status: event.statusFilter,
      );
      emit(PaymentHistoryLoaded(
        payments: payments,
        appliedFilter: event.statusFilter,
      ));
    } catch (e) {
      emit(PaymentError('Failed to load payment history: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPendingPaymentsRequested(
    LoadPendingPaymentsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final payments = await _paymentRepository.getPendingPayments();
      emit(PendingPaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentError('Failed to load pending payments: ${e.toString()}'));
    }
  }

  Future<void> _onApprovePaymentRequested(
    ApprovePaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      await _paymentRepository.approvePayment(
        paymentId: event.paymentId,
        reviewedBy: event.reviewedBy,
      );
      emit(PaymentApproved(event.paymentId));
    } catch (e) {
      emit(PaymentError('Failed to approve payment: ${e.toString()}'));
    }
  }

  Future<void> _onRejectPaymentRequested(
    RejectPaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      await _paymentRepository.rejectPayment(
        paymentId: event.paymentId,
        reviewedBy: event.reviewedBy,
        reason: event.reason,
      );
      emit(PaymentRejected(event.paymentId));
    } catch (e) {
      emit(PaymentError('Failed to reject payment: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPenaltyPaymentsRequested(
    LoadPenaltyPaymentsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final penaltyPayments = await _paymentRepository.getPenaltyPayments(
        event.paymentId,
      );
      emit(PenaltyPaymentsLoaded(penaltyPayments));
    } catch (e) {
      emit(PaymentError('Failed to load penalty payments: ${e.toString()}'));
    }
  }

  Future<void> _onManualBalanceClearRequested(
    ManualBalanceClearRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      await _paymentRepository.manualBalanceClear(
        userId: event.userId,
        amount: event.amount,
        reason: event.reason,
        clearedBy: event.clearedBy,
      );
      emit(BalanceCleared(userId: event.userId, amount: event.amount));
    } catch (e) {
      emit(PaymentError('Failed to clear balance: ${e.toString()}'));
    }
  }

  Future<void> _onResetPaymentStateRequested(
    ResetPaymentStateRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentInitial());
  }
}
