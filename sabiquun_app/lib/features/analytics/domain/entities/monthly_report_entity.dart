/// Entity representing monthly report statistics
class MonthlyReportEntity {
  final int year;
  final int month;
  final int reportsSubmitted;
  final int expectedReports;
  final double completionRate;
  final int penaltiesIncurred;
  final double penaltyAmount;

  const MonthlyReportEntity({
    required this.year,
    required this.month,
    required this.reportsSubmitted,
    required this.expectedReports,
    required this.completionRate,
    required this.penaltiesIncurred,
    required this.penaltyAmount,
  });

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String get monthYearLabel => '$monthName $year';

  bool get isComplete => completionRate >= 100.0;
  bool get hasGoodPerformance => completionRate >= 80.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MonthlyReportEntity &&
        other.year == year &&
        other.month == month &&
        other.reportsSubmitted == reportsSubmitted &&
        other.completionRate == completionRate;
  }

  @override
  int get hashCode {
    return year.hashCode ^
        month.hashCode ^
        reportsSubmitted.hashCode ^
        completionRate.hashCode;
  }
}
