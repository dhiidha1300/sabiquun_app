import 'package:equatable/equatable.dart';

/// Base class for app content events
abstract class AppContentEvent extends Equatable {
  const AppContentEvent();

  @override
  List<Object?> get props => [];
}

/// Load all published content
class LoadAllPublishedContentRequested extends AppContentEvent {
  const LoadAllPublishedContentRequested();
}

/// Load content by specific key
class LoadContentByKeyRequested extends AppContentEvent {
  final String contentKey;

  const LoadContentByKeyRequested(this.contentKey);

  @override
  List<Object?> get props => [contentKey];
}

/// Load content by multiple keys
class LoadContentByKeysRequested extends AppContentEvent {
  final List<String> contentKeys;

  const LoadContentByKeysRequested(this.contentKeys);

  @override
  List<Object?> get props => [contentKeys];
}
