import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/date_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../features/calendar/presentation/bloc/calendar_state.dart';

/// A widget that displays dates according to user's calendar preference
/// Supports both single-line and multi-line layouts
class DualDateDisplay extends StatelessWidget {
  final DateTime date;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;
  final bool showTime;
  final bool fullFormat;
  final bool shortFormat;
  final bool multiLine;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const DualDateDisplay({
    super.key,
    required this.date,
    this.primaryStyle,
    this.secondaryStyle,
    this.showTime = false,
    this.fullFormat = false,
    this.shortFormat = false,
    this.multiLine = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final preference = state.preference;

        // For single display modes, just show the text
        if (preference == CalendarPreference.hijriOnly ||
            preference == CalendarPreference.gregorianOnly) {
          return Text(
            DateFormatter.format(
              date,
              preference: preference,
              showTime: showTime,
              fullFormat: fullFormat,
              shortFormat: shortFormat,
            ),
            style: primaryStyle ?? Theme.of(context).textTheme.bodyMedium,
          );
        }

        // For dual display modes
        if (multiLine) {
          return _buildMultiLineDisplay(context, preference);
        } else {
          return Text(
            DateFormatter.format(
              date,
              preference: preference,
              showTime: showTime,
              fullFormat: fullFormat,
              shortFormat: shortFormat,
            ),
            style: primaryStyle ?? Theme.of(context).textTheme.bodyMedium,
          );
        }
      },
    );
  }

  Widget _buildMultiLineDisplay(
      BuildContext context, CalendarPreference preference) {
    String primaryText;
    String secondaryText;

    if (preference == CalendarPreference.hijriPrimary) {
      primaryText = DateFormatter.formatHijri(date, shortFormat: shortFormat);
      secondaryText =
          DateFormatter.formatGregorian(date, shortFormat: shortFormat);
    } else {
      primaryText =
          DateFormatter.formatGregorian(date, shortFormat: shortFormat);
      secondaryText = DateFormatter.formatHijri(date, shortFormat: shortFormat);
    }

    if (showTime) {
      primaryText += ' ${_formatTime(date)}';
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          primaryText,
          style: primaryStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '($secondaryText)',
          style: secondaryStyle ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// A simple widget that displays only the Hijri date
class HijriDateText extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;
  final bool shortFormat;
  final bool fullFormat;

  const HijriDateText({
    super.key,
    required this.date,
    this.style,
    this.shortFormat = false,
    this.fullFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      fullFormat
          ? DateFormatter.format(
              date,
              preference: CalendarPreference.hijriOnly,
              fullFormat: true,
            )
          : DateFormatter.formatHijri(date, shortFormat: shortFormat),
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }
}

/// A widget that displays the formatted date with a label
class LabeledDateDisplay extends StatelessWidget {
  final String label;
  final DateTime date;
  final TextStyle? labelStyle;
  final TextStyle? dateStyle;
  final bool showTime;
  final bool shortFormat;

  const LabeledDateDisplay({
    super.key,
    required this.label,
    required this.date,
    this.labelStyle,
    this.dateStyle,
    this.showTime = false,
    this.shortFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: labelStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
            ),
            Expanded(
              child: Text(
                DateFormatter.format(
                  date,
                  preference: state.preference,
                  showTime: showTime,
                  shortFormat: shortFormat,
                ),
                style: dateStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A widget that displays date in a chip/badge format
class DateChip extends StatelessWidget {
  final DateTime date;
  final bool shortFormat;
  final Color? backgroundColor;
  final Color? textColor;

  const DateChip({
    super.key,
    required this.date,
    this.shortFormat = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor ??
                Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            DateFormatter.format(
              date,
              preference: state.preference,
              shortFormat: shortFormat,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor ??
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      },
    );
  }
}

/// A widget that displays the month and year header (for calendars)
class MonthYearHeader extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;

  const MonthYearHeader({
    super.key,
    required this.date,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Text(
          DateFormatter.formatMonthYear(date, preference: state.preference),
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}

/// A widget that displays relative time with Hijri support
class RelativeDateDisplay extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;

  const RelativeDateDisplay({
    super.key,
    required this.date,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Text(
          DateFormatter.formatRelative(date, preference: state.preference),
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        );
      },
    );
  }
}
