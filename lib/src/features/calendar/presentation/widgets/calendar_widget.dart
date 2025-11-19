import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_view.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    required this.provider,
    required this.calendarFormat,
    required this.onDaySelected,
    super.key,
  });

  final CalendarProvider provider;
  final CalendarFormat calendarFormat;
  final void Function(DateTime, DateTime) onDaySelected;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.provider.selectedDay;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(widget.provider.selectedDay, oldWidget.provider.selectedDay)) {
      setState(() {
        _focusedMonth = widget.provider.selectedDay;
      });
    }
  }

  void _handlePrevMonth() {
    setState(() {
      final candidate = DateTime(
        _focusedMonth.year,
        _focusedMonth.month - 1,
      );
      final firstDay = DateTime.utc(2020, 1, 1);
      
      // Clamp to firstDay if candidate is before it
      if (candidate.isBefore(firstDay)) {
        _focusedMonth = DateTime(firstDay.year, firstDay.month);
      } else {
        _focusedMonth = candidate;
      }
    });
  }

  void _handleNextMonth() {
    setState(() {
      final candidate = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
      );
      final lastDay = DateTime.utc(2030, 12, 31);
      
      // Clamp to lastDay if candidate is after it
      if (candidate.isAfter(lastDay)) {
        _focusedMonth = DateTime(lastDay.year, lastDay.month);
      } else {
        _focusedMonth = candidate;
      }
    });
  }

  bool _isSelected(DateTime day) {
    return isSameDay(day, widget.provider.selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat.yMMMM().format(_focusedMonth);
    final weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.periwinkleBlue,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 19,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _handlePrevMonth,
                icon: const Icon(Icons.chevron_left, size: 18),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
              ),
              Text(
                monthName,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.42,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _handleNextMonth,
                icon: const Icon(Icons.chevron_right, size: 18),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Week Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.3,
                      color: index == 0
                          ? Colors.red.shade300
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Calendar Days
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedMonth,
            calendarFormat: widget.calendarFormat,
            selectedDayPredicate: _isSelected,
            onDaySelected: (selectedDay, focusedDay) {
              widget.onDaySelected(selectedDay, focusedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedMonth = focusedDay;
              });
            },
            headerVisible: false,
            daysOfWeekVisible: false,
            calendarStyle: const CalendarStyle(
              cellMargin: EdgeInsets.all(4),
              defaultTextStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              weekendTextStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              outsideTextStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.transparent,
              ),
            ),
            calendarBuilders: CalendarBuilders<dynamic>(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, true, false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, true);
              },
              outsideBuilder: (context, day, focusedDay) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isSelected, bool isToday) {
    final hasTickets = widget.provider.hasTicketsOnDay(day);
    final hasEvents = widget.provider.getEventsForDay(day).isNotEmpty;
    final hasContent = hasTickets || hasEvents;

    Color? backgroundColor;
    var textColor = Colors.white;
    if (isSelected) {
      backgroundColor = Colors.white;
      textColor = AppColor.periwinkleBlue;
    } else if (isToday) {
      backgroundColor = Colors.white.withValues(alpha: 0.3);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onDaySelected(day, day);
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: hasContent
                  ? Stack(
                      children: [
                        Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: textColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '${day.day}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

