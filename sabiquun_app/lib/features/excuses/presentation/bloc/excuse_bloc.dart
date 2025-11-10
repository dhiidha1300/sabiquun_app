import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/features/excuses/domain/repositories/excuse_repository.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_event.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_state.dart';

class ExcuseBloc extends Bloc<ExcuseEvent, ExcuseState> {
  final ExcuseRepository repository;

  ExcuseBloc({required this.repository}) : super(const ExcuseInitial()) {
    on<CreateExcuseRequested>(_onCreateExcuseRequested);
    on<LoadMyExcusesRequested>(_onLoadMyExcusesRequested);
    on<LoadExcuseByIdRequested>(_onLoadExcuseByIdRequested);
    on<DeleteExcuseRequested>(_onDeleteExcuseRequested);
    on<CheckExcuseForDateRequested>(_onCheckExcuseForDateRequested);
  }

  Future<void> _onCreateExcuseRequested(
    CreateExcuseRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    emit(const ExcuseLoading());
    try {
      final excuse = await repository.createExcuse(
        userId: event.userId,
        excuseDate: event.excuseDate,
        excuseType: event.excuseType,
        affectedDeeds: event.affectedDeeds,
        description: event.description,
      );
      emit(ExcuseCreated(excuse));
    } catch (e) {
      emit(ExcuseError(e.toString()));
    }
  }

  Future<void> _onLoadMyExcusesRequested(
    LoadMyExcusesRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    emit(const ExcuseLoading());
    try {
      final excuses = await repository.getMyExcuses(
        userId: event.userId,
        status: event.status,
      );
      emit(ExcusesLoaded(excuses));
    } catch (e) {
      emit(ExcuseError(e.toString()));
    }
  }

  Future<void> _onLoadExcuseByIdRequested(
    LoadExcuseByIdRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    emit(const ExcuseLoading());
    try {
      final excuse = await repository.getExcuseById(event.excuseId);
      emit(ExcuseLoaded(excuse));
    } catch (e) {
      emit(ExcuseError(e.toString()));
    }
  }

  Future<void> _onDeleteExcuseRequested(
    DeleteExcuseRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    emit(const ExcuseLoading());
    try {
      await repository.deleteExcuse(event.excuseId);
      emit(const ExcuseDeleted());
    } catch (e) {
      emit(ExcuseError(e.toString()));
    }
  }

  Future<void> _onCheckExcuseForDateRequested(
    CheckExcuseForDateRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    try {
      final exists = await repository.hasExcuseForDate(
        userId: event.userId,
        date: event.date,
      );
      emit(ExcuseCheckResult(exists));
    } catch (e) {
      emit(ExcuseError(e.toString()));
    }
  }
}
