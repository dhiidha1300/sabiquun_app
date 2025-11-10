import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';

abstract class ExcuseEvent extends Equatable {
  const ExcuseEvent();

  @override
  List<Object?> get props => [];
}

/// Create a new excuse
class CreateExcuseRequested extends ExcuseEvent {
  final String userId;
  final DateTime excuseDate;
  final ExcuseType excuseType;
  final List<String> affectedDeeds;
  final String? description;

  const CreateExcuseRequested({
    required this.userId,
    required this.excuseDate,
    required this.excuseType,
    required this.affectedDeeds,
    this.description,
  });

  @override
  List<Object?> get props => [userId, excuseDate, excuseType, affectedDeeds, description];
}

/// Load user's excuses
class LoadMyExcusesRequested extends ExcuseEvent {
  final String userId;
  final ExcuseStatus? status;

  const LoadMyExcusesRequested({
    required this.userId,
    this.status,
  });

  @override
  List<Object?> get props => [userId, status];
}

/// Load a specific excuse by ID
class LoadExcuseByIdRequested extends ExcuseEvent {
  final String excuseId;

  const LoadExcuseByIdRequested(this.excuseId);

  @override
  List<Object?> get props => [excuseId];
}

/// Delete an excuse
class DeleteExcuseRequested extends ExcuseEvent {
  final String excuseId;

  const DeleteExcuseRequested(this.excuseId);

  @override
  List<Object?> get props => [excuseId];
}

/// Check if excuse exists for date
class CheckExcuseForDateRequested extends ExcuseEvent {
  final String userId;
  final DateTime date;

  const CheckExcuseForDateRequested({
    required this.userId,
    required this.date,
  });

  @override
  List<Object?> get props => [userId, date];
}
