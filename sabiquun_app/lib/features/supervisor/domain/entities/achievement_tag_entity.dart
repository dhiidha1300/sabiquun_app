import 'package:equatable/equatable.dart';

/// Achievement tag entity
class AchievementTagEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final Map<String, dynamic>? criteria;
  final bool autoAssign;
  final int activeUserCount;
  final DateTime createdAt;

  const AchievementTagEntity({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    this.criteria,
    required this.autoAssign,
    required this.activeUserCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        criteria,
        autoAssign,
        activeUserCount,
        createdAt,
      ];
}
