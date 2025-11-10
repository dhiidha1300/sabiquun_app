import 'package:sabiquun_app/features/analytics/domain/entities/monthly_report_entity.dart';

class MonthlyReportModel extends MonthlyReportEntity {
  const MonthlyReportModel({
    required super.year,
    required super.month,
    required super.reportsSubmitted,
    required super.expectedReports,
    required super.completionRate,
    required super.penaltiesIncurred,
    required super.penaltyAmount,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      reportsSubmitted: (json['reports_submitted'] as num?)?.toInt() ?? 0,
      expectedReports: (json['expected_reports'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      penaltiesIncurred: (json['penalties_incurred'] as num?)?.toInt() ?? 0,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'reports_submitted': reportsSubmitted,
      'expected_reports': expectedReports,
      'completion_rate': completionRate,
      'penalties_incurred': penaltiesIncurred,
      'penalty_amount': penaltyAmount,
    };
  }

  MonthlyReportEntity toEntity() {
    return MonthlyReportEntity(
      year: year,
      month: month,
      reportsSubmitted: reportsSubmitted,
      expectedReports: expectedReports,
      completionRate: completionRate,
      penaltiesIncurred: penaltiesIncurred,
      penaltyAmount: penaltyAmount,
    );
  }
}
