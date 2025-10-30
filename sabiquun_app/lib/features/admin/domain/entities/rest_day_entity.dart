import 'package:equatable/equatable.dart';

/// Entity representing a rest day (penalty-free day)
class RestDayEntity extends Equatable {
  final String id;
  final DateTime date;
  final DateTime? endDate; // For date ranges
  final String description;
  final bool isRecurring; // Recurring annually
  final DateTime createdAt;

  const RestDayEntity({
    required this.id,
    required this.date,
    this.endDate,
    required this.description,
    required this.isRecurring,
    required this.createdAt,
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

  @override
  List<Object?> get props => [
        id,
        date,
        endDate,
        description,
        isRecurring,
        createdAt,
      ];
}
