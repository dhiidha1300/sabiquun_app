import 'package:hijri/hijri_calendar.dart';

import '../constants/date_constants.dart';

/// Service for Hijri calendar conversions and formatting
/// Uses Umm al-Qura calendar (Saudi standard)
class HijriDateService {
  HijriDateService._();

  static final HijriDateService _instance = HijriDateService._();
  static HijriDateService get instance => _instance;

  // Cache for converted dates to improve performance
  final Map<String, HijriCalendar> _cache = {};

  /// Convert Gregorian DateTime to Hijri
  HijriCalendar toHijri(DateTime gregorian) {
    final key = '${gregorian.year}-${gregorian.month}-${gregorian.day}';

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final hijri = HijriCalendar.fromDate(gregorian);
    _cache[key] = hijri;

    // Limit cache size to prevent memory issues
    if (_cache.length > 1000) {
      final keysToRemove = _cache.keys.take(500).toList();
      for (final k in keysToRemove) {
        _cache.remove(k);
      }
    }

    return hijri;
  }

  /// Convert Hijri date to Gregorian DateTime
  DateTime toGregorian(int hYear, int hMonth, int hDay) {
    final hijri = HijriCalendar()
      ..hYear = hYear
      ..hMonth = hMonth
      ..hDay = hDay;

    return hijri.hijriToGregorian(hYear, hMonth, hDay);
  }

  /// Get Hijri month name in English
  String getMonthNameEnglish(int month) {
    if (month < 1 || month > 12) return '';
    return DateConstants.hijriMonthsEnglish[month - 1];
  }

  /// Get Hijri month name in Arabic
  String getMonthNameArabic(int month) {
    if (month < 1 || month > 12) return '';
    return DateConstants.hijriMonthsArabic[month - 1];
  }

  /// Get short Hijri month name in English
  String getMonthNameShortEnglish(int month) {
    if (month < 1 || month > 12) return '';
    return DateConstants.hijriMonthsShortEnglish[month - 1];
  }

  /// Format Hijri date as "d Month yyyy" (e.g., "15 Ramadan 1446")
  String formatHijri(DateTime gregorian, {bool useArabic = false}) {
    final hijri = toHijri(gregorian);
    final monthName = useArabic
        ? getMonthNameArabic(hijri.hMonth)
        : getMonthNameEnglish(hijri.hMonth);
    return '${hijri.hDay} $monthName ${hijri.hYear}';
  }

  /// Format Hijri date as short format "d Mon yyyy" (e.g., "15 Ram 1446")
  String formatHijriShort(DateTime gregorian) {
    final hijri = toHijri(gregorian);
    final monthName = getMonthNameShortEnglish(hijri.hMonth);
    return '${hijri.hDay} $monthName ${hijri.hYear}';
  }

  /// Format Hijri date with day name (e.g., "Al-Jumu'ah, 15 Ramadan 1446")
  String formatHijriFull(DateTime gregorian, {bool useArabic = false}) {
    final hijri = toHijri(gregorian);
    final dayIndex = gregorian.weekday % 7; // Sunday = 0
    final dayName = useArabic
        ? DateConstants.hijriDaysArabic[dayIndex]
        : DateConstants.hijriDaysEnglish[dayIndex];
    final monthName = useArabic
        ? getMonthNameArabic(hijri.hMonth)
        : getMonthNameEnglish(hijri.hMonth);
    return '$dayName, ${hijri.hDay} $monthName ${hijri.hYear}';
  }

  /// Get just the Hijri year
  int getHijriYear(DateTime gregorian) {
    return toHijri(gregorian).hYear;
  }

  /// Get just the Hijri month
  int getHijriMonth(DateTime gregorian) {
    return toHijri(gregorian).hMonth;
  }

  /// Get just the Hijri day
  int getHijriDay(DateTime gregorian) {
    return toHijri(gregorian).hDay;
  }

  /// Check if a date falls in Ramadan
  bool isRamadan(DateTime gregorian) {
    return getHijriMonth(gregorian) == 9;
  }

  /// Check if a date is Eid al-Fitr (1 Shawwal)
  bool isEidAlFitr(DateTime gregorian) {
    final hijri = toHijri(gregorian);
    return hijri.hMonth == 10 && hijri.hDay == 1;
  }

  /// Check if a date is Eid al-Adha (10 Dhul Hijjah)
  bool isEidAlAdha(DateTime gregorian) {
    final hijri = toHijri(gregorian);
    return hijri.hMonth == 12 && hijri.hDay == 10;
  }

  /// Get the Gregorian date for a specific Hijri date in a given Hijri year
  /// Useful for calculating recurring Islamic holidays
  DateTime getGregorianForHijriDate(int hYear, int hMonth, int hDay) {
    return toGregorian(hYear, hMonth, hDay);
  }

  /// Get next occurrence of a Hijri date (e.g., next Eid)
  /// If the date has passed this year, returns next year's date
  DateTime getNextOccurrence(int hMonth, int hDay) {
    final now = DateTime.now();
    final currentHijri = toHijri(now);

    int targetYear = currentHijri.hYear;
    final targetDate = toGregorian(targetYear, hMonth, hDay);

    if (targetDate.isBefore(now)) {
      targetYear++;
      return toGregorian(targetYear, hMonth, hDay);
    }

    return targetDate;
  }

  /// Get the current Hijri date
  HijriCalendar get today => toHijri(DateTime.now());

  /// Clear the cache (useful for testing or memory management)
  void clearCache() {
    _cache.clear();
  }
}
