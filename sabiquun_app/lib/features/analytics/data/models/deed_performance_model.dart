import 'package:sabiquun_app/features/analytics/domain/entities/deed_performance_entity.dart';

class DeedPerformanceModel extends DeedPerformanceEntity {
  const DeedPerformanceModel({
    required super.deedName,
    required super.totalSubmitted,
    required super.totalMissed,
    required super.completionRate,
    required super.currentStreak,
    required super.longestStreak,
  });

  factory DeedPerformanceModel.fromJson(Map<String, dynamic> json) {
    return DeedPerformanceModel(
      deedName: json['deed_name'] as String,
      totalSubmitted: (json['total_submitted'] as num?)?.toInt() ?? 0,
      totalMissed: (json['total_missed'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deed_name': deedName,
      'total_submitted': totalSubmitted,
      'total_missed': totalMissed,
      'completion_rate': completionRate,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  DeedPerformanceEntity toEntity() {
    return DeedPerformanceEntity(
      deedName: deedName,
      totalSubmitted: totalSubmitted,
      totalMissed: totalMissed,
      completionRate: completionRate,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }
}
