import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/date_constants.dart';
import '../../calendar/presentation/bloc/calendar_bloc.dart';
import '../../calendar/presentation/bloc/calendar_event.dart';
import '../../calendar/presentation/bloc/calendar_state.dart';

/// Full-page calendar settings screen
/// Allows users to choose between different calendar display preferences
class CalendarSettingsPage extends StatelessWidget {
  const CalendarSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Settings'),
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Calendar',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select how dates should be displayed throughout the app',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),

              // Hijri Primary option (default)
              _buildCalendarCard(
                context: context,
                title: 'Hijri (Gregorian)',
                subtitle: 'Show Hijri dates with Gregorian in parentheses',
                example: '15 Ramadan 1446 (Mar 15, 2025)',
                icon: Icons.calendar_month,
                preference: CalendarPreference.hijriPrimary,
                isSelected: state.preference == CalendarPreference.hijriPrimary,
              ),

              const SizedBox(height: 16),

              // Gregorian Primary option
              _buildCalendarCard(
                context: context,
                title: 'Gregorian (Hijri)',
                subtitle: 'Show Gregorian dates with Hijri in parentheses',
                example: 'Mar 15, 2025 (15 Ramadan 1446)',
                icon: Icons.calendar_today,
                preference: CalendarPreference.gregorianPrimary,
                isSelected:
                    state.preference == CalendarPreference.gregorianPrimary,
              ),

              const SizedBox(height: 16),

              // Hijri Only option
              _buildCalendarCard(
                context: context,
                title: 'Hijri Only',
                subtitle: 'Show only Hijri (Islamic) dates',
                example: '15 Ramadan 1446',
                icon: Icons.mosque,
                preference: CalendarPreference.hijriOnly,
                isSelected: state.preference == CalendarPreference.hijriOnly,
              ),

              const SizedBox(height: 16),

              // Gregorian Only option
              _buildCalendarCard(
                context: context,
                title: 'Gregorian Only',
                subtitle: 'Show only Gregorian dates',
                example: 'Mar 15, 2025',
                icon: Icons.today,
                preference: CalendarPreference.gregorianOnly,
                isSelected:
                    state.preference == CalendarPreference.gregorianOnly,
              ),

              const SizedBox(height: 24),

              // Info card about Hijri calendar
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About the Hijri Calendar',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The Hijri (Islamic) calendar is a lunar calendar used to determine Islamic holidays and events. It has 12 months and approximately 354 days per year.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hijri months reference
              _buildHijriMonthsCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String example,
    required IconData icon,
    required CalendarPreference preference,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<CalendarBloc>().add(CalendarPreferenceChanged(preference));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Title, subtitle, and example
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        example,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHijriMonthsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hijri Months',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(12, (index) {
                final monthName = DateConstants.hijriMonthsEnglish[index];
                final monthNumber = index + 1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$monthNumber. $monthName',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
