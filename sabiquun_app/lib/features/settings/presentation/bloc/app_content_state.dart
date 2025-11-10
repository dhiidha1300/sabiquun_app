import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/settings/domain/entities/app_content_entity.dart';

/// Base class for app content states
abstract class AppContentState extends Equatable {
  const AppContentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AppContentInitial extends AppContentState {
  const AppContentInitial();
}

/// Loading state
class AppContentLoading extends AppContentState {
  const AppContentLoading();
}

/// All content loaded
class AllContentLoaded extends AppContentState {
  final List<AppContentEntity> contentList;

  const AllContentLoaded(this.contentList);

  @override
  List<Object?> get props => [contentList];
}

/// Single content loaded
class ContentByKeyLoaded extends AppContentState {
  final AppContentEntity? content;

  const ContentByKeyLoaded(this.content);

  @override
  List<Object?> get props => [content];
}

/// Multiple content items loaded
class ContentByKeysLoaded extends AppContentState {
  final List<AppContentEntity> contentList;

  const ContentByKeysLoaded(this.contentList);

  @override
  List<Object?> get props => [contentList];
}

/// Error state
class AppContentError extends AppContentState {
  final String message;

  const AppContentError(this.message);

  @override
  List<Object?> get props => [message];
}
