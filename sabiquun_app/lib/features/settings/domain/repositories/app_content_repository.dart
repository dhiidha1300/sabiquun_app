import 'package:sabiquun_app/features/settings/domain/entities/app_content_entity.dart';

/// Repository interface for app content operations
abstract class AppContentRepository {
  /// Get all published app content items
  Future<List<AppContentEntity>> getAllPublishedContent();

  /// Get app content by content key
  Future<AppContentEntity?> getContentByKey(String contentKey);

  /// Get specific content items by keys
  Future<List<AppContentEntity>> getContentByKeys(List<String> contentKeys);
}
