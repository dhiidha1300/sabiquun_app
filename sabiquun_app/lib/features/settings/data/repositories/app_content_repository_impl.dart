import 'package:sabiquun_app/features/settings/domain/entities/app_content_entity.dart';
import 'package:sabiquun_app/features/settings/domain/repositories/app_content_repository.dart';
import 'package:sabiquun_app/features/settings/data/datasources/app_content_remote_datasource.dart';

/// Implementation of AppContentRepository
class AppContentRepositoryImpl implements AppContentRepository {
  final AppContentRemoteDataSource remoteDataSource;

  AppContentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppContentEntity>> getAllPublishedContent() async {
    try {
      final models = await remoteDataSource.getAllPublishedContent();
      return models;
    } catch (e) {
      throw Exception('Failed to get published content: $e');
    }
  }

  @override
  Future<AppContentEntity?> getContentByKey(String contentKey) async {
    try {
      final model = await remoteDataSource.getContentByKey(contentKey);
      return model;
    } catch (e) {
      throw Exception('Failed to get content by key: $e');
    }
  }

  @override
  Future<List<AppContentEntity>> getContentByKeys(List<String> contentKeys) async {
    try {
      final models = await remoteDataSource.getContentByKeys(contentKeys);
      return models;
    } catch (e) {
      throw Exception('Failed to get content by keys: $e');
    }
  }
}
