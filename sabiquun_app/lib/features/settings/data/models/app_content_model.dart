import 'package:sabiquun_app/features/settings/domain/entities/app_content_entity.dart';

/// Data model for app content with JSON serialization
class AppContentModel extends AppContentEntity {
  const AppContentModel({
    required super.id,
    required super.contentKey,
    required super.title,
    required super.content,
    required super.contentType,
    required super.isPublished,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from JSON
  factory AppContentModel.fromJson(Map<String, dynamic> json) {
    try {
      // print('Parsing app content JSON: ${json.keys}');
      return AppContentModel(
        id: json['id'] as String,
        contentKey: json['content_key'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        contentType: json['content_type'] as String? ?? 'html',
        isPublished: json['is_published'] as bool? ?? true,
        version: json['version'] as int? ?? 1,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (e) {
      // print('Error parsing AppContentModel: $e');
      // print('JSON keys: ${json.keys}');
      // print('JSON values: $json');
      rethrow;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_key': contentKey,
      'title': title,
      'content': content,
      'content_type': contentType,
      'is_published': isPublished,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory AppContentModel.fromEntity(AppContentEntity entity) {
    return AppContentModel(
      id: entity.id,
      contentKey: entity.contentKey,
      title: entity.title,
      content: entity.content,
      contentType: entity.contentType,
      isPublished: entity.isPublished,
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
