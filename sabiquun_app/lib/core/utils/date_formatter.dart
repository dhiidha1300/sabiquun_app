import 'package:intl/intl.dart';

import '../constants/date_constants.dart';
import '../services/hijri_date_service.dart';

/// Unified date formatting utility that supports both Gregorian and Hijri calendars
/// Respects user's calendar preference for consistent date display across the app
class DateFormatter {
  DateFormatter._();

  static final HijriDateService _hijriService = HijriDateService.instance;

  /// Format a date based on the user's calendar preference
  static String format(
    DateTime? date, {
    CalendarPreference preference = CalendarPreference.hijriPrimary,
    bool showTime = false,
    bool fullFormat = false,
    bool shortFormat = false,
  }) {
    if (date == null) return '';

    switch (preference) {
      case CalendarPreference.hijriPrimary:
        return _formatHijriPrimary(date,
            showTime: showTime, fullFormat: fullFormat, shortFormat: shortFormat);
      case CalendarPreference.gregorianPrimary:
        return _formatGregorianPrimary(date,
            showTime: showTime, fullFormat: fullFormat, shortFormat: shortFormat);
      case CalendarPreference.hijriOnly:
        return _formatHijriOnly(date,
            showTime: showTime, fullFormat: fullFormat, shortFormat: shortFormat);
      case CalendarPreference.gregorianOnly:
        return _formatGregorianOnly(date,
            showTime: showTime, fullFormat: fullFormat, shortFormat: shortFormat);
    }
  }

  /// Format with Hijri as primary, Gregorian in parentheses
  /// Example: "15 Ramadan 1446 (Mar 15, 2025)"
  static String _formatHijriPrimary(
    DateTime date, {
    bool showTime = false,
    bool fullFormat = false,
    bool shortFormat = false,
  }) {
    final hijriPart = shortFormat
        ? _hijriService.formatHijriShort(date)
        : fullFormat
            ? _hijriService.formatHijriFull(date)
            : _hijriService.formatHijri(date);

    final gregorianPart = shortFormat
        ? DateFormat(DateConstants.gregorianShortDateFormat).format(date)
        : DateFormat(DateConstants.gregorianDisplayFormat).format(date);

    String result = '$hijriPart ($gregorianPart)';

    if (showTime) {
      result += ' ${DateFormat('HH:mm').format(date)}';
    }

    return result;
  }

  /// Format with Gregorian as primary, Hijri in parentheses
  /// Example: "Mar 15, 2025 (15 Ramadan 1446)"
  static String _formatGregorianPrimary(
    DateTime date, {
    bool showTime = false,
    bool fullFormat = false,
    bool shortFormat = false,
  }) {
    final gregorianPart = fullFormat
        ? DateFormat(DateConstants.gregorianFullDateFormat).format(date)
        : shortFormat
            ? DateFormat(DateConstants.gregorianShortDateFormat).format(date)
            : DateFormat(DateConstants.gregorianDisplayFormat).format(date);

    final hijriPart = shortFormat
        ? _hijriService.formatHijriShort(date)
        : _hijriService.formatHijri(date);

    String result = '$gregorianPart ($hijriPart)';

    if (showTime) {
      result += ' ${DateFormat('HH:mm').format(date)}';
    }

    return result;
  }

  /// Format Hijri only
  /// Example: "15 Ramadan 1446"
  static String _formatHijriOnly(
    DateTime date, {
    bool showTime = false,
    bool fullFormat = false,
    bool shortFormat = false,
  }) {
    String result = shortFormat
        ? _hijriService.formatHijriShort(date)
        : fullFormat
            ? _hijriService.formatHijriFull(date)
            : _hijriService.formatHijri(date);

    if (showTime) {
      result += ' ${DateFormat('HH:mm').format(date)}';
    }

    return result;
  }

  /// Format Gregorian only
  /// Example: "Mar 15, 2025"
  static String _formatGregorianOnly(
    DateTime date, {
    bool showTime = false,
    bool fullFormat = false,
    bool shortFormat = false,
  }) {
    String pattern;
    if (fullFormat) {
      pattern = showTime
          ? '${DateConstants.gregorianFullDateFormat} HH:mm'
          : DateConstants.gregorianFullDateFormat;
    } else if (shortFormat) {
      pattern = showTime
          ? '${DateConstants.gregorianShortDateFormat} HH:mm'
          : DateConstants.gregorianShortDateFormat;
    } else {
      pattern = showTime
          ? DateConstants.gregorianDisplayDateTimeFormat
          : DateConstants.gregorianDisplayFormat;
    }

    return DateFormat(pattern).format(date);
  }

  /// Format just the Hijri part
  static String formatHijri(DateTime? date, {bool shortFormat = false}) {
    if (date == null) return '';
    return shortFormat
        ? _hijriService.formatHijriShort(date)
        : _hijriService.formatHijri(date);
  }

  /// Format just the Gregorian part
  static String formatGregorian(DateTime? date, {bool shortFormat = false}) {
    if (date == null) return '';
    return shortFormat
        ? DateFormat(DateConstants.gregorianShortDateFormat).format(date)
        : DateFormat(DateConstants.gregorianDisplayFormat).format(date);
  }

  /// Format for ISO storage (always Gregorian)
  static String formatForStorage(DateTime date) {
    return DateFormat(DateConstants.gregorianDateFormat).format(date);
  }

  /// Format with relative time (e.g., "Today", "Yesterday", "2 days ago")
  static String formatRelative(
    DateTime date, {
    CalendarPreference preference = CalendarPreference.hijriPrimary,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference <= 7) {
      return '$difference days ago';
    } else if (difference < -1 && difference >= -7) {
      return 'In ${-difference} days';
    } else {
      return format(date, preference: preference, shortFormat: true);
    }
  }

  /// Get the Hijri month name for a date
  static String getHijriMonthName(DateTime date, {bool useArabic = false}) {
    final month = _hijriService.getHijriMonth(date);
    return useArabic
        ? _hijriService.getMonthNameArabic(month)
        : _hijriService.getMonthNameEnglish(month);
  }

  /// Get the Hijri year for a date
  static int getHijriYear(DateTime date) {
    return _hijriService.getHijriYear(date);
  }

  /// Format a date range
  static String formatDateRange(
    DateTime start,
    DateTime end, {
    CalendarPreference preference = CalendarPreference.hijriPrimary,
  }) {
    final startFormatted = format(start, preference: preference, shortFormat: true);
    final endFormatted = format(end, preference: preference, shortFormat: true);
    return '$startFormatted - $endFormatted';
  }

  /// Format month and year header (for calendars)
  static String formatMonthYear(
    DateTime date, {
    CalendarPreference preference = CalendarPreference.hijriPrimary,
  }) {
    switch (preference) {
      case CalendarPreference.hijriPrimary:
      case CalendarPreference.hijriOnly:
        final hijriMonth = _hijriService.getMonthNameEnglish(
            _hijriService.getHijriMonth(date));
        final hijriYear = _hijriService.getHijriYear(date);
        if (preference == CalendarPreference.hijriOnly) {
          return '$hijriMonth $hijriYear';
        }
        final gregorian = DateFormat('MMMM yyyy').format(date);
        return '$hijriMonth $hijriYear ($gregorian)';

      case CalendarPreference.gregorianPrimary:
        final gregorian = DateFormat('MMMM yyyy').format(date);
        final hijriMonth = _hijriService.getMonthNameEnglish(
            _hijriService.getHijriMonth(date));
        final hijriYear = _hijriService.getHijriYear(date);
        return '$gregorian ($hijriMonth $hijriYear)';

      case CalendarPreference.gregorianOnly:
        return DateFormat('MMMM yyyy').format(date);
    }
  }
}
