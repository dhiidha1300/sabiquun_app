/// Date-related constants including Hijri calendar support
class DateConstants {
  DateConstants._();

  // Hijri month names in English
  static const List<String> hijriMonthsEnglish = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhul Qa\'dah',
    'Dhul Hijjah',
  ];

  // Hijri month names in Arabic
  static const List<String> hijriMonthsArabic = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  // Hijri month abbreviations in English
  static const List<String> hijriMonthsShortEnglish = [
    'Muh',
    'Saf',
    'Rab I',
    'Rab II',
    'Jum I',
    'Jum II',
    'Raj',
    'Sha',
    'Ram',
    'Shaw',
    'Dhul Q',
    'Dhul H',
  ];

  // Hijri day names in English
  static const List<String> hijriDaysEnglish = [
    'Al-Ahad', // Sunday
    'Al-Ithnayn', // Monday
    'Al-Thulatha', // Tuesday
    'Al-Arbia', // Wednesday
    'Al-Khamis', // Thursday
    'Al-Jumu\'ah', // Friday
    'Al-Sabt', // Saturday
  ];

  // Hijri day names in Arabic
  static const List<String> hijriDaysArabic = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  // Gregorian date format patterns
  static const String gregorianDateFormat = 'yyyy-MM-dd';
  static const String gregorianDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String gregorianDisplayFormat = 'MMM dd, yyyy';
  static const String gregorianDisplayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String gregorianFullDateFormat = 'EEEE, MMMM d, y';
  static const String gregorianShortDateFormat = 'MMM dd';

  // Hijri date format patterns
  static const String hijriDisplayFormat = 'd MMMM yyyy'; // 15 Ramadan 1446
  static const String hijriShortFormat = 'd MMM yyyy'; // 15 Ram 1446
  static const String hijriFullFormat = 'EEEE, d MMMM yyyy'; // Friday, 15 Ramadan 1446

  // Dual date format patterns
  static const String dualHijriPrimaryFormat = 'hijri (gregorian)';
  static const String dualGregorianPrimaryFormat = 'gregorian (hijri)';
}

/// Calendar display preference options
enum CalendarPreference {
  hijriPrimary('hijri_primary'),
  gregorianPrimary('gregorian_primary'),
  hijriOnly('hijri_only'),
  gregorianOnly('gregorian_only');

  const CalendarPreference(this.value);
  final String value;

  static CalendarPreference fromString(String? value) {
    return CalendarPreference.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CalendarPreference.hijriPrimary, // Default
    );
  }

  String get displayName {
    switch (this) {
      case CalendarPreference.hijriPrimary:
        return 'Hijri (Gregorian)';
      case CalendarPreference.gregorianPrimary:
        return 'Gregorian (Hijri)';
      case CalendarPreference.hijriOnly:
        return 'Hijri Only';
      case CalendarPreference.gregorianOnly:
        return 'Gregorian Only';
    }
  }

  String get description {
    switch (this) {
      case CalendarPreference.hijriPrimary:
        return '15 Ramadan 1446 (Mar 15, 2025)';
      case CalendarPreference.gregorianPrimary:
        return 'Mar 15, 2025 (15 Ramadan 1446)';
      case CalendarPreference.hijriOnly:
        return '15 Ramadan 1446';
      case CalendarPreference.gregorianOnly:
        return 'Mar 15, 2025';
    }
  }
}
