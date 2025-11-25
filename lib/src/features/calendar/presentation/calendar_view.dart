import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/features/calendar/application/calendar_provider.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_list.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_toggle_buttons.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = CalendarProvider();
        unawaited(provider.loadEvents());
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('Calendar'),
          ),
          centerTitle: false,
        ),
        body: const CalendarContent(),
      ),
    );
  }
}

class CalendarContent extends StatefulWidget {
  const CalendarContent({super.key});

  @override
  State<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<CalendarContent> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _selectedFilter = 1;

  Future<void> _showDateRangePicker(CalendarProvider provider) async {
    final now = DateTime.timestamp();
    final today = DateTime(now.year, now.month, now.day);

    final initialRange =
        provider.selectedRange ??
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
      provider.setSelectedRange(pickedRange);
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
    final provider = Provider.of<CalendarProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarToggleButtons(
            selectedFilter: _selectedFilter,
            onFilterChanged: (index) async {
              setState(() {
                if (index != 2) {
                  _selectedFilter = index;
                }
                if (index == 0) {
                  _calendarFormat = CalendarFormat.week;
                  provider.setSelectedRange(null);
                } else if (index == 1) {
                  _calendarFormat = CalendarFormat.month;
                  provider.setSelectedRange(null);
                }
              });

              if (index == 2) {
                // Handle Date Range
                await _showDateRangePicker(provider);
              }
            },
          ),
          if (provider.selectedRange case final range?)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: InkWell(
                onTap: () async {
                  await _showDateRangePicker(provider);
                },
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
                          provider.setSelectedRange(null);
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
          if (provider.selectedRange == null)
            CalendarWidget(
              provider: provider,
              calendarFormat: _calendarFormat,
              onDaySelected: (day, focusedDay) {
                provider.setSelectedDay(day);
              },
            ),
          const SizedBox(height: 8),
          CalendarList(provider: provider),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
