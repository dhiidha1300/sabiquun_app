import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';

abstract class ExcuseState extends Equatable {
  const ExcuseState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExcuseInitial extends ExcuseState {
  const ExcuseInitial();
}

/// Loading state
class ExcuseLoading extends ExcuseState {
  const ExcuseLoading();
}

/// Excuse created successfully
class ExcuseCreated extends ExcuseState {
  final ExcuseEntity excuse;

  const ExcuseCreated(this.excuse);

  @override
  List<Object?> get props => [excuse];
}

/// Excuses loaded
class ExcusesLoaded extends ExcuseState {
  final List<ExcuseEntity> excuses;

  const ExcusesLoaded(this.excuses);

  @override
  List<Object?> get props => [excuses];
}

/// Specific excuse loaded
class ExcuseLoaded extends ExcuseState {
  final ExcuseEntity excuse;

  const ExcuseLoaded(this.excuse);

  @override
  List<Object?> get props => [excuse];
}

/// Excuse deleted successfully
class ExcuseDeleted extends ExcuseState {
  const ExcuseDeleted();
}

/// Check result for excuse existence
class ExcuseCheckResult extends ExcuseState {
  final bool exists;

  const ExcuseCheckResult(this.exists);

  @override
  List<Object?> get props => [exists];
}

/// Error state
class ExcuseError extends ExcuseState {
  final String message;

  const ExcuseError(this.message);

  @override
  List<Object?> get props => [message];
}
