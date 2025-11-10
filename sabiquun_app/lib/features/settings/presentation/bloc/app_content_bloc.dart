import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/features/settings/domain/repositories/app_content_repository.dart';
import 'package:sabiquun_app/features/settings/presentation/bloc/app_content_event.dart';
import 'package:sabiquun_app/features/settings/presentation/bloc/app_content_state.dart';

/// BLoC for managing app content state
class AppContentBloc extends Bloc<AppContentEvent, AppContentState> {
  final AppContentRepository repository;

  AppContentBloc({required this.repository}) : super(const AppContentInitial()) {
    on<LoadAllPublishedContentRequested>(_onLoadAllPublishedContentRequested);
    on<LoadContentByKeyRequested>(_onLoadContentByKeyRequested);
    on<LoadContentByKeysRequested>(_onLoadContentByKeysRequested);
  }

  Future<void> _onLoadAllPublishedContentRequested(
    LoadAllPublishedContentRequested event,
    Emitter<AppContentState> emit,
  ) async {
    emit(const AppContentLoading());
    try {
      final contentList = await repository.getAllPublishedContent();
      emit(AllContentLoaded(contentList));
    } catch (e) {
      emit(AppContentError(e.toString()));
    }
  }

  Future<void> _onLoadContentByKeyRequested(
    LoadContentByKeyRequested event,
    Emitter<AppContentState> emit,
  ) async {
    emit(const AppContentLoading());
    try {
      final content = await repository.getContentByKey(event.contentKey);
      emit(ContentByKeyLoaded(content));
    } catch (e) {
      emit(AppContentError(e.toString()));
    }
  }

  Future<void> _onLoadContentByKeysRequested(
    LoadContentByKeysRequested event,
    Emitter<AppContentState> emit,
  ) async {
    emit(const AppContentLoading());
    try {
      final contentList = await repository.getContentByKeys(event.contentKeys);
      emit(ContentByKeysLoaded(contentList));
    } catch (e) {
      emit(AppContentError(e.toString()));
    }
  }
}
