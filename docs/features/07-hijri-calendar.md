# Phase 72: Hijri Calendar Support

## Overview

This phase adds Hijri (Islamic) calendar support to the Sabiquun app, allowing users to view dates in Hijri format alongside or instead of Gregorian dates. This is culturally significant for the Islamic deed tracking app targeting Somalia/Somaliland.

## Implementation Date
January 28, 2026

## Features Implemented

### 1. Core Hijri Services
- **HijriDateService** (`lib/core/services/hijri_date_service.dart`)
  - Gregorian to Hijri conversion using Umm al-Qura calendar
  - Hijri to Gregorian conversion
  - Month name formatting (English and Arabic)
  - Special date detection (Ramadan, Eid al-Fitr, Eid al-Adha)
  - Date caching for performance

- **DateFormatter** (`lib/core/utils/date_formatter.dart`)
  - Unified date formatting respecting user preference
  - Supports: Hijri Primary, Gregorian Primary, Hijri Only, Gregorian Only
  - Format variations: full, short, with time, relative

- **DateConstants** (`lib/core/constants/date_constants.dart`)
  - Hijri month names in English and Arabic
  - Hijri day names
  - Calendar preference enum

### 2. User Preference System
- **CalendarBloc** - State management for calendar preference
- **CalendarRepository** - Persistence layer for preferences
- **CalendarLocalDataSource** - SharedPreferences storage

**Default**: Hijri Primary (e.g., "15 Ramadan 1446 (Mar 15, 2025)")

### 3. UI Components

#### Reusable Widgets (`lib/shared/widgets/dual_date_display.dart`)
- `DualDateDisplay` - Shows date based on user preference
- `HijriDateText` - Shows only Hijri date
- `LabeledDateDisplay` - Date with label
- `DateChip` - Date in chip/badge format
- `MonthYearHeader` - Calendar header with Hijri month
- `RelativeDateDisplay` - Relative time with preference support

#### Calendar Settings Page
- New settings page at `/calendar-settings`
- Four display options with visual examples
- Hijri months reference

### 4. Updated Pages
- **Today's Deeds Page** - Date card shows Hijri date
- **Report Calendar Widget** - Header shows Hijri month name
- **My Reports Page** - Report dates show in user's preferred format
- **Rest Days Management** - Supports Hijri-based Islamic holidays

### 5. Rest Days Hijri Support
New database fields for Islamic holidays:
- `hijri_month` - Month in Hijri calendar (1-12)
- `hijri_day` - Day in Hijri calendar (1-30)
- `is_hijri_based` - Flag for Hijri-based recurring holidays

## Database Migration

```sql
-- supabase/migrations/20250128_hijri_rest_days.sql
ALTER TABLE rest_days ADD COLUMN hijri_month INTEGER;
ALTER TABLE rest_days ADD COLUMN hijri_day INTEGER;
ALTER TABLE rest_days ADD COLUMN is_hijri_based BOOLEAN DEFAULT FALSE;
```

## Package Dependencies

```yaml
hijri: ^3.0.0  # Umm al-Qura Hijri calendar
```

## File Structure

```
lib/
  core/
    constants/
      date_constants.dart          # NEW
    services/
      hijri_date_service.dart      # NEW
    utils/
      date_formatter.dart          # NEW
  features/
    calendar/                      # NEW FEATURE
      data/
        datasources/
          calendar_local_datasource.dart
        repositories/
          calendar_repository_impl.dart
      domain/
        repositories/
          calendar_repository.dart
      presentation/
        bloc/
          calendar_bloc.dart
          calendar_event.dart
          calendar_state.dart
  shared/
    widgets/
      dual_date_display.dart       # NEW
  settings/
    pages/
      calendar_settings_page.dart  # NEW
```

## Calendar Preference Options

| Option | Display Format | Example |
|--------|----------------|---------|
| Hijri Primary (default) | Hijri (Gregorian) | 15 Ramadan 1446 (Mar 15, 2025) |
| Gregorian Primary | Gregorian (Hijri) | Mar 15, 2025 (15 Ramadan 1446) |
| Hijri Only | Hijri only | 15 Ramadan 1446 |
| Gregorian Only | Gregorian only | Mar 15, 2025 |

## Hijri Months Reference

| # | English | Arabic |
|---|---------|--------|
| 1 | Muharram | محرم |
| 2 | Safar | صفر |
| 3 | Rabi' al-Awwal | ربيع الأول |
| 4 | Rabi' al-Thani | ربيع الثاني |
| 5 | Jumada al-Awwal | جمادى الأولى |
| 6 | Jumada al-Thani | جمادى الآخرة |
| 7 | Rajab | رجب |
| 8 | Sha'ban | شعبان |
| 9 | Ramadan | رمضان |
| 10 | Shawwal | شوال |
| 11 | Dhul Qa'dah | ذو القعدة |
| 12 | Dhul Hijjah | ذو الحجة |

## Usage Examples

### Display a date with user preference
```dart
BlocBuilder<CalendarBloc, CalendarState>(
  builder: (context, state) {
    return Text(
      DateFormatter.format(
        date,
        preference: state.preference,
      ),
    );
  },
)
```

### Use DualDateDisplay widget
```dart
DualDateDisplay(
  date: DateTime.now(),
  showTime: true,
  multiLine: true,
)
```

### Get Hijri date directly
```dart
final hijri = HijriDateService.instance.toHijri(DateTime.now());
print('${hijri.hDay} ${hijri.hMonth} ${hijri.hYear}');
```

## Testing Checklist

- [ ] Calendar settings page displays correctly
- [ ] Preference persists after app restart
- [ ] Today's Deeds shows Hijri date
- [ ] Report Calendar header shows Hijri month
- [ ] Rest days can be created with Hijri dates
- [ ] Eid dates calculated correctly for next year
- [ ] All four preference modes work correctly

## Future Enhancements

1. **Prayer Times Integration** - Link Hijri dates with prayer times
2. **Ramadan Mode** - Special tracking during Ramadan
3. **Islamic Events Calendar** - Highlight important Islamic dates
4. **Hijri Date Picker Widget** - Full Hijri calendar selection
