import 'package:equatable/equatable.dart';

import '../../../../core/services/hijri_date_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/constants/date_constants.dart';

/// Entity representing a rest day (penalty-free day)
class RestDayEntity extends Equatable {
  final String id;
  final DateTime date;
  final DateTime? endDate; // For date ranges
  final String description;
  final bool isRecurring; // Recurring annually
  final DateTime createdAt;

  // Hijri-based fields for Islamic holidays
  final int? hijriMonth; // 1-12 (Muharram to Dhul Hijjah)
  final int? hijriDay; // 1-30
  final bool isHijriBased; // True if this is a Hijri-based recurring holiday

  const RestDayEntity({
    required this.id,
    required this.date,
    this.endDate,
    required this.description,
    required this.isRecurring,
    required this.createdAt,
    this.hijriMonth,
    this.hijriDay,
    this.isHijriBased = false,
  });

  /// Check if this is a single day or date range
  bool get isDateRange => endDate != null;

  /// Get formatted date display
  String get formattedDate {
    if (endDate == null) {
      return _formatDate(date);
    }
    return '${_formatDate(date)} - ${_formatDate(endDate!)}';
  }

  /// Get day count
  int get dayCount {
    if (endDate == null) return 1;
    return endDate!.difference(date).inDays + 1;
  }

  /// Check if a specific date falls within this rest day
  bool containsDate(DateTime checkDate) {
    final check = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final start = DateTime(date.year, date.month, date.day);

    if (endDate == null) {
      return check.isAtSameMomentAs(start);
    }

    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return (check.isAtSameMomentAs(start) ||
            check.isAfter(start)) &&
        (check.isAtSameMomentAs(end) || check.isBefore(end));
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get Hijri date display for Hijri-based holidays
  String? get hijriDateDisplay {
    if (!isHijriBased || hijriMonth == null || hijriDay == null) return null;
    final monthName = DateConstants.hijriMonthsEnglish[hijriMonth! - 1];
    return '$hijriDay $monthName';
  }

  /// Get formatted date with Hijri support
  String getFormattedDate(CalendarPreference preference) {
    return DateFormatter.format(date, preference: preference);
  }

  /// Calculate next occurrence for Hijri-based holidays
  DateTime? getNextHijriOccurrence() {
    if (!isHijriBased || hijriMonth == null || hijriDay == null) return null;
    return HijriDateService.instance.getNextOccurrence(hijriMonth!, hijriDay!);
  }

  @override
  List<Object?> get props => [
        id,
        date,
        endDate,
        description,
        isRecurring,
        createdAt,
        hijriMonth,
        hijriDay,
        isHijriBased,
      ];
}
