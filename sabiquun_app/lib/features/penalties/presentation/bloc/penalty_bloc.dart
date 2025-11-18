import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/penalty_repository.dart';
import 'penalty_event.dart';
import 'penalty_state.dart';

class PenaltyBloc extends Bloc<PenaltyEvent, PenaltyState> {
  final PenaltyRepository _penaltyRepository;

  PenaltyBloc(this._penaltyRepository) : super(const PenaltyInitial()) {
    on<LoadTotalOutstandingBalanceRequested>(_onLoadTotalOutstandingBalanceRequested);
    on<LoadPenaltyBalanceRequested>(_onLoadPenaltyBalanceRequested);
    on<LoadPenaltiesRequested>(_onLoadPenaltiesRequested);
    on<LoadUnpaidPenaltiesRequested>(_onLoadUnpaidPenaltiesRequested);
    on<LoadPenaltyByIdRequested>(_onLoadPenaltyByIdRequested);
    on<WaivePenaltyRequested>(_onWaivePenaltyRequested);
    on<CreateManualPenaltyRequested>(_onCreateManualPenaltyRequested);
    on<UpdatePenaltyAmountRequested>(_onUpdatePenaltyAmountRequested);
    on<RemovePenaltyRequested>(_onRemovePenaltyRequested);
    on<ResetPenaltyStateRequested>(_onResetPenaltyStateRequested);
  }

  Future<void> _onLoadTotalOutstandingBalanceRequested(
    LoadTotalOutstandingBalanceRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    try {
      final totalBalance = await _penaltyRepository.getTotalOutstandingBalance();
      emit(TotalOutstandingBalanceLoaded(totalBalance));
    } catch (e) {
      emit(PenaltyError('Failed to load total outstanding balance: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPenaltyBalanceRequested(
    LoadPenaltyBalanceRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      final balance = await _penaltyRepository.getUserBalance(event.userId);
      emit(PenaltyBalanceLoaded(balance));
    } catch (e) {
      emit(PenaltyError('Failed to load penalty balance: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPenaltiesRequested(
    LoadPenaltiesRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      final penalties = await _penaltyRepository.getUserPenalties(
        userId: event.userId,
        status: event.statusFilter,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PenaltiesLoaded(
        penalties: penalties,
        appliedFilter: event.statusFilter,
      ));
    } catch (e) {
      emit(PenaltyError('Failed to load penalties: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUnpaidPenaltiesRequested(
    LoadUnpaidPenaltiesRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      final penalties = await _penaltyRepository.getUnpaidPenaltiesForPayment(
        event.userId,
      );

      // Get user balance
      final balance = await _penaltyRepository.getUserBalance(event.userId);

      emit(UnpaidPenaltiesLoaded(
        penalties: penalties,
        balance: balance,
      ));
    } catch (e) {
      emit(PenaltyError('Failed to load unpaid penalties: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPenaltyByIdRequested(
    LoadPenaltyByIdRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      final penalty = await _penaltyRepository.getPenaltyById(event.penaltyId);
      emit(PenaltyDetailLoaded(penalty));
    } catch (e) {
      emit(PenaltyError('Failed to load penalty details: ${e.toString()}'));
    }
  }

  Future<void> _onWaivePenaltyRequested(
    WaivePenaltyRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      await _penaltyRepository.waivePenalty(
        penaltyId: event.penaltyId,
        waivedBy: event.waivedBy,
        reason: event.reason,
      );
      emit(PenaltyWaived(event.penaltyId));
    } catch (e) {
      emit(PenaltyError('Failed to waive penalty: ${e.toString()}'));
    }
  }

  Future<void> _onCreateManualPenaltyRequested(
    CreateManualPenaltyRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      final penalty = await _penaltyRepository.createManualPenalty(
        userId: event.userId,
        amount: event.amount,
        dateIncurred: event.dateIncurred,
        reason: event.reason,
        createdBy: event.createdBy,
      );
      emit(ManualPenaltyCreated(penalty));
    } catch (e) {
      emit(PenaltyError('Failed to create manual penalty: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePenaltyAmountRequested(
    UpdatePenaltyAmountRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      await _penaltyRepository.updatePenaltyAmount(
        penaltyId: event.penaltyId,
        newAmount: event.newAmount,
        reason: event.reason,
        updatedBy: event.updatedBy,
      );
      emit(PenaltyAmountUpdated(event.penaltyId));
    } catch (e) {
      emit(PenaltyError('Failed to update penalty amount: ${e.toString()}'));
    }
  }

  Future<void> _onRemovePenaltyRequested(
    RemovePenaltyRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyLoading());
    try {
      await _penaltyRepository.removePenalty(
        penaltyId: event.penaltyId,
        reason: event.reason,
        removedBy: event.removedBy,
      );
      emit(PenaltyRemoved(event.penaltyId));
    } catch (e) {
      emit(PenaltyError('Failed to remove penalty: ${e.toString()}'));
    }
  }

  Future<void> _onResetPenaltyStateRequested(
    ResetPenaltyStateRequested event,
    Emitter<PenaltyState> emit,
  ) async {
    emit(const PenaltyInitial());
  }
}
