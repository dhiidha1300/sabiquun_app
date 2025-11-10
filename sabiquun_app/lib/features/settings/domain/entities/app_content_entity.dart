import 'package:equatable/equatable.dart';

/// Entity representing app content (rules, policies, about, etc.)
class AppContentEntity extends Equatable {
  final String id;
  final String contentKey;
  final String title;
  final String content;
  final String contentType; // 'html' or 'markdown'
  final bool isPublished;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppContentEntity({
    required this.id,
    required this.contentKey,
    required this.title,
    required this.content,
    required this.contentType,
    required this.isPublished,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        contentKey,
        title,
        content,
        contentType,
        isPublished,
        version,
        createdAt,
        updatedAt,
      ];
}
