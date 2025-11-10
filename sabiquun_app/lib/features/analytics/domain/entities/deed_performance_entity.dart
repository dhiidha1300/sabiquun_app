/// Entity representing performance statistics for a specific deed
class DeedPerformanceEntity {
  final String deedName;
  final int totalSubmitted;
  final int totalMissed;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;

  const DeedPerformanceEntity({
    required this.deedName,
    required this.totalSubmitted,
    required this.totalMissed,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
  });

  int get totalAttempts => totalSubmitted + totalMissed;

  bool get isPerfect => completionRate == 100.0 && totalAttempts > 0;
  bool get isExcellent => completionRate >= 90.0;
  bool get isGood => completionRate >= 70.0;
  bool get needsImprovement => completionRate < 50.0;

  String get performanceGrade {
    if (isPerfect) return 'Perfect';
    if (isExcellent) return 'Excellent';
    if (isGood) return 'Good';
    if (completionRate >= 50.0) return 'Fair';
    return 'Poor';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedPerformanceEntity &&
        other.deedName == deedName &&
        other.totalSubmitted == totalSubmitted &&
        other.totalMissed == totalMissed &&
        other.completionRate == completionRate;
  }

  @override
  int get hashCode {
    return deedName.hashCode ^
        totalSubmitted.hashCode ^
        totalMissed.hashCode ^
        completionRate.hashCode;
  }
}
