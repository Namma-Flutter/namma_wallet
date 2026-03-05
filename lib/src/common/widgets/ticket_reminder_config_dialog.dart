import 'dart:async';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/reminder_preferences.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/notification/reminder_preferences_service.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';

/// Dialog for configuring ticket-specific reminder settings
class TicketReminderConfigDialog extends StatefulWidget {
  const TicketReminderConfigDialog({
    required this.ticket,
    required this.context,
    super.key,
  });

  final Ticket ticket;
  final BuildContext context;

  @override
  State<TicketReminderConfigDialog> createState() =>
      _TicketReminderConfigDialogState();
}

class _TicketReminderConfigDialogState
    extends State<TicketReminderConfigDialog> {
  late IReminderPreferencesService _preferencesService;
  late ILogger _logger;

  List<int> _selectedIntervals = [];
  List<DateTime> _customDateTimes = [];
  bool _isEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;
  late ReminderPreferences _previousPreferences;

  // All available hour options
  static const List<int> _availableHours = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    12,
    24,
  ];

  @override
  void initState() {
    super.initState();
    _preferencesService = getIt<IReminderPreferencesService>();
    _logger = getIt<ILogger>();
    unawaited(_loadPreferences());
  }

  Future<void> _loadPreferences() async {
    try {
      // Load global default preferences first
      final globalDefaults = await _preferencesService
          .getDefaultRemainderPreferences();

      // Then try to load ticket-specific preferences
      final ticketPrefs = await _preferencesService.getRemainderPreferences(
        widget.ticket.ticketId ?? '',
      );

      // Store previous preferences for comparison when saving
      _previousPreferences = ticketPrefs;

      if (mounted) {
        setState(() {
          // Use ticket-specific intervals if they've been customized
          // Otherwise, use global default intervals from settings
          if (ticketPrefs.selectedIntervals.isNotEmpty) {
            // Check if custom vs using hardcoded defaults
            final hardcodedDefaults =
                ReminderPreferences.defaultPreferences.selectedIntervals;
            final isCustom = ticketPrefs.selectedIntervals != hardcodedDefaults;
            _selectedIntervals = isCustom
                ? ticketPrefs.selectedIntervals.toList()
                : globalDefaults.selectedIntervals.toList();
          } else {
            _selectedIntervals = globalDefaults.selectedIntervals.toList();
          }

          _customDateTimes = ticketPrefs.customDateTimes.toList();
          _isEnabled = ticketPrefs.isEnabled;
          _isLoading = false;
        });
      }
    } on Exception catch (e, st) {
      _logger.error(
        '[TicketReminderConfigDialog] Failed to load preferences',
        e,
        st,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addCustomDateTime() async {
    final journeyTime = widget.ticket.startTime;
    if (journeyTime == null) {
      showSnackbar(
        widget.context,
        'Cannot add custom reminder without journey time',
        isError: true,
      );
      return;
    }

    final now = DateTime.now();

    // Check if journey time is in the past
    if (journeyTime.isBefore(now)) {
      showSnackbar(
        widget.context,
        'Cannot add reminders for past journeys',
        isError: true,
      );
      return;
    }

    // Show date picker first
    final defaultReminderDate = journeyTime.subtract(const Duration(hours: 24));
    final initialDate = defaultReminderDate.isBefore(now)
        ? now
        : defaultReminderDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: journeyTime,
    );

    if (selectedDate == null) return;

    // Show time picker
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(journeyTime),
    );

    if (selectedTime == null) return;

    final customDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Validate that custom datetime is before journey time
    if (customDateTime.isAfter(journeyTime)) {
      if (mounted) {
        showSnackbar(
          widget.context,
          'Reminder time must be before journey start time',
          isError: true,
        );
      }
      return;
    }

    setState(() {
      _customDateTimes
        ..add(customDateTime)
        ..sort();
    });
  }

  Future<void> _removeCustomDateTime(int index) async {
    setState(() {
      _customDateTimes.removeAt(index);
    });
  }

  Future<void> _savePreferences() async {
    if (_isEnabled && _selectedIntervals.isEmpty && _customDateTimes.isEmpty) {
      showSnackbar(
        widget.context,
        'Please select at least one reminder interval',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Cancel existing notifications if reminders are being disabled
      if (_previousPreferences.isEnabled && !_isEnabled) {
        await _cancelAllReminders(_previousPreferences);
      }

      // Convert DateTime objects to milliseconds since epoch for storage
      final customDateTimeMillis = _customDateTimes
          .map((dt) => dt.millisecondsSinceEpoch)
          .toList();

      final preferences = ReminderPreferences(
        selectedIntervals: _selectedIntervals,
        customDateTimeMillis: customDateTimeMillis,
        isEnabled: _isEnabled,
      );

      await _preferencesService.saveRemainderPreferences(
        widget.ticket.ticketId ?? '',
        preferences,
      );

      // Schedule reminders only if enabled
      if (_isEnabled) {
        await _scheduleSelectedReminders();
      }

      _logger.info(
        '[TicketReminderConfigDialog] Saved ticket reminder preferences',
      );

      if (mounted) {
        showSnackbar(widget.context, 'Reminder preferences saved successfully');
        Navigator.pop(context, true);
      }
    } on Exception catch (e, st) {
      _logger.error(
        '[TicketReminderConfigDialog] Failed to save preferences',
        e,
        st,
      );
      if (mounted) {
        showSnackbar(
          widget.context,
          'Failed to save preferences: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _scheduleSelectedReminders() async {
    final journeyTime = widget.ticket.startTime;
    if (journeyTime == null) return;

    final title = widget.ticket.primaryText;
    final location = widget.ticket.location;

    if (title == null ||
        title.isEmpty ||
        location == null ||
        location.isEmpty) {
      return;
    }

    final now = DateTime.now();

    // Schedule standard interval reminders
    for (var i = 0; i < _selectedIntervals.length; i++) {
      final reminderTime = journeyTime.subtract(
        Duration(hours: _selectedIntervals[i]),
      );

      if (reminderTime.isBefore(now)) continue;

      final baseHash =
          widget.ticket.ticketId?.hashCode ??
          widget.ticket.primaryText.hashCode;
      const maxInt32 = 0x7FFFFFFF;
      const maxBase = maxInt32 ~/ 100;
      final safeBase = baseHash.abs() % maxBase;
      final notificationId = safeBase * 100 + i;

      final formattedDateTime = _formatDateTimeForNotification(journeyTime);
      final bodyText = formattedDateTime.isNotEmpty
          ? '$location • Starts - $formattedDateTime'
          : location;

      await NotificationService().scheduleTicketReminder(
        id: notificationId,
        dateTime: reminderTime,
        title: title,
        body: bodyText,
        payload: widget.ticket.ticketId ?? '',
      );
    }

    // Schedule custom datetime reminders
    for (var i = 0; i < _customDateTimes.length; i++) {
      final customDateTime = _customDateTimes[i];
      if (customDateTime.isBefore(now)) continue;

      final baseHash =
          widget.ticket.ticketId?.hashCode ??
          widget.ticket.primaryText.hashCode;
      const maxInt32 = 0x7FFFFFFF;
      const maxBase = maxInt32 ~/ 100;
      final safeBase = baseHash.abs() % maxBase;
      final notificationId = safeBase * 100 + _selectedIntervals.length + i;

      final formattedDateTime = _formatDateTimeForNotification(journeyTime);
      final bodyText = formattedDateTime.isNotEmpty
          ? '$location • Starts - $formattedDateTime'
          : location;

      await NotificationService().scheduleTicketReminder(
        id: notificationId,
        dateTime: customDateTime,
        title: title,
        body: bodyText,
        payload: widget.ticket.ticketId ?? '',
      );
    }
  }

  Future<void> _cancelAllReminders(
    ReminderPreferences previousPrefs,
  ) async {
    try {
      final baseHash =
          widget.ticket.ticketId?.hashCode ??
          widget.ticket.primaryText.hashCode;
      const maxInt32 = 0x7FFFFFFF;
      const maxBase = maxInt32 ~/ 100;
      final safeBase = baseHash.abs() % maxBase;

      // Cancel all standard interval reminders
      for (var i = 0; i < previousPrefs.selectedIntervals.length; i++) {
        final notificationId = safeBase * 100 + i;
        await NotificationService().cancelTicketReminder(notificationId);
      }

      // Cancel all custom datetime reminders
      for (var i = 0; i < previousPrefs.customDateTimeMillis.length; i++) {
        final notificationId =
            safeBase * 100 + previousPrefs.selectedIntervals.length + i;
        await NotificationService().cancelTicketReminder(notificationId);
      }

      _logger.info(
        '[TicketReminderConfigDialog] Cancelled all reminders for ticket',
      );
    } on Exception catch (e, st) {
      _logger.error(
        '[TicketReminderConfigDialog] Failed to cancel reminders',
        e,
        st,
      );
    }
  }

  String _formatTime12(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Converts UTC DateTime to local timezone
  DateTime _toLocalTime(DateTime dt) {
    if (dt.isUtc) {
      return dt.toLocal();
    }
    return dt;
  }

  String _formatDateTimeForNotification(DateTime dt) {
    // Convert to local timezone if it's in UTC
    final localDt = _toLocalTime(dt);

    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final dtDate = DateTime(localDt.year, localDt.month, localDt.day);
    final diffDays = dtDate.difference(nowDate).inDays;
    final time = _formatTime12(localDt);

    if (diffDays == 0) return time;
    if (diffDays == 1) return 'Tomorrow $time';

    return '${localDt.day}/${localDt.month}/${localDt.year} $time';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminder Configuration',
                                style: Paragraph01(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ).semiBold,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Customize when you want to be reminded',
                                style: Paragraph03(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ).regular,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Enable/Disable Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable Reminders',
                              style: Paragraph02(
                                color: Theme.of(context).colorScheme.onSurface,
                              ).semiBold,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEnabled
                                  ? 'Reminders are active'
                                  : 'Reminders are disabled',
                              style: Paragraph03(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ).regular,
                            ),
                          ],
                        ),
                        Switch(
                          value: _isEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Configuration section (only shown when enabled)
                    if (_isEnabled) ...[
                      // Hour Selection
                      Text(
                        'Select Intervals (Hours)',
                        style: Paragraph02(
                          color: Theme.of(context).colorScheme.onSurface,
                        ).semiBold,
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableHours.map((hour) {
                          final isSelected = _selectedIntervals.contains(hour);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIntervals.remove(hour);
                                } else {
                                  _selectedIntervals
                                    ..add(hour)
                                    ..sort();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withValues(
                                        alpha: 0.9,
                                      )
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '$hour hr',
                                style: Paragraph03(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                ).semiBold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Custom DateTime Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Custom Date & Time',
                            style: Paragraph02(
                              color: Theme.of(context).colorScheme.onSurface,
                            ).semiBold,
                          ),
                          TextButton.icon(
                            onPressed: _addCustomDateTime,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),

                      if (_customDateTimes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...List.generate(_customDateTimes.length, (index) {
                          final dt = _customDateTimes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${DateTimeConverter.instance.formatDate(dt)} '
                                      'at ${_formatTime12(dt)}',
                                      style: Paragraph02(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ).regular,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        _removeCustomDateTime(index),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Reminders are disabled. Toggle "Enable Reminders" to configure.',
                          style: Paragraph03(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ).regular,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSaving ? null : _savePreferences,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
