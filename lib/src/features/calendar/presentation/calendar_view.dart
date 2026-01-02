import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/features/calendar/application/calendar_notifier.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_list.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_toggle_buttons.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  @override
  void initState() {
    super.initState();
    // Load events when the view is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(calendarProvider.notifier).loadEvents());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text('Calendar'),
        ),
        centerTitle: false,
      ),
      body: const CalendarContent(),
    );
  }
}

class CalendarContent extends ConsumerStatefulWidget {
  const CalendarContent({super.key});

  @override
  ConsumerState<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends ConsumerState<CalendarContent> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _selectedFilter = 1;

  Future<void> _showDateRangePicker() async {
    final calendarState = ref.read(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final initialRange =
        calendarState.selectedRange ??
        DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 7)),
        );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: AppTheme.getDateRangePickerTheme(context),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      notifier.setSelectedRange(pickedRange);
      setState(() {
        _selectedFilter = 2;
      });
    } else {
      setState(() {
        _selectedFilter = 1;
        _calendarFormat = CalendarFormat.month;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final hapticService = getIt<IHapticService>();

    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarToggleButtons(
            selectedFilter: _selectedFilter,
            onFilterChanged: (index) async {
              hapticService.triggerHaptic(HapticType.selection);
              setState(() {
                if (index != 2) {
                  _selectedFilter = index;
                }
                if (index == 0) {
                  _calendarFormat = CalendarFormat.week;
                  notifier.setSelectedRange(null);
                } else if (index == 1) {
                  _calendarFormat = CalendarFormat.month;
                  notifier.setSelectedRange(null);
                }
              });

              if (index == 2) {
                // Handle Date Range
                await _showDateRangePicker();
              }
            },
          ),
          if (calendarState.selectedRange case final range?)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: InkWell(
                onTap: _showDateRangePicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected: '
                          '${DateFormat('MMM dd, yyyy').format(range.start)} - '
                          '${DateFormat('MMM dd, yyyy').format(range.end)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          notifier.setSelectedRange(null);
                          setState(() {
                            _selectedFilter = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (calendarState.selectedRange == null)
            CalendarWidget(
              calendarState: calendarState,
              calendarNotifier: notifier,
              calendarFormat: _calendarFormat,
              onDaySelected: (day, focusedDay) {
                notifier.setSelectedDay(day);
              },
            ),
          const SizedBox(height: 8),
          CalendarList(
            calendarState: calendarState,
            calendarNotifier: notifier,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
