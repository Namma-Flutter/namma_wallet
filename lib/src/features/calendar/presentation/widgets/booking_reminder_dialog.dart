import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service_interface.dart';
import 'package:namma_wallet/src/features/calendar/application/booking_reminder.dart';
import 'package:namma_wallet/src/features/calendar/application/booking_reminder_service.dart';

class BookingReminderDialog extends StatefulWidget {
  const BookingReminderDialog({required this.initialJourneyDate, super.key});

  final DateTime initialJourneyDate;

  @override
  State<BookingReminderDialog> createState() => _BookingReminderDialogState();
}

class _BookingReminderDialogState extends State<BookingReminderDialog> {
  late DateTime _journeyDate;
  TimeOfDay _departureTime = const TimeOfDay(hour: 8, minute: 0);
  String _provider = 'TNSTC';
  BookingWindow _window = BookingWindow.normal;
  TatkalClass _tatkalClass = TatkalClass.nonAc;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _journeyDate = DateUtils.dateOnly(widget.initialJourneyDate);
  }

  DateTime get _journeyDeparture => DateTime(
    _journeyDate.year,
    _journeyDate.month,
    _journeyDate.day,
    _departureTime.hour,
    _departureTime.minute,
  );

  DateTime get _remindAt => _window == BookingWindow.tatkal
      ? BookingReminderSchedule.tatkalBookingOpens(
          _journeyDate,
          _tatkalClass,
        )
      : BookingReminderSchedule.normalBookingOpens(_journeyDeparture);

  Future<void> _pickJourneyDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _journeyDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _journeyDate = picked);
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (picked != null) setState(() => _departureTime = picked);
  }

  Future<void> _save() async {
    final remindAt = _remindAt;
    if (!remindAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This booking window has already opened.'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    final notifications = getIt<INotificationService>();
    final permitted = await notifications.requestPermission();
    if (!mounted) return;
    if (!permitted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission is needed to set a reminder.'),
        ),
      );
      return;
    }
    final reminder = BookingReminder(
      id: '${_provider}_${_window.name}_${_journeyDeparture.millisecondsSinceEpoch}',
      provider: _provider,
      window: _window,
      journeyDeparture: _journeyDeparture,
      remindAt: remindAt,
    );
    try {
      await getIt<IBookingReminderService>().saveReminder(reminder);
    } on Object {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not set the reminder.')),
      );
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy');
    final isTatkal = _window == BookingWindow.tatkal;
    return AlertDialog(
      title: const Text('Booking reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<BookingWindow>(
              segments: const [
                ButtonSegment(
                  value: BookingWindow.normal,
                  label: Text('Normal'),
                ),
                ButtonSegment(
                  value: BookingWindow.tatkal,
                  label: Text('Tatkal'),
                ),
              ],
              selected: {_window},
              onSelectionChanged: (selection) => setState(() {
                _window = selection.first;
                if (_window == BookingWindow.tatkal) _provider = 'IRCTC';
              }),
            ),
            const SizedBox(height: 16),
            if (isTatkal)
              SegmentedButton<TatkalClass>(
                segments: const [
                  ButtonSegment(value: TatkalClass.ac, label: Text('AC')),
                  ButtonSegment(
                    value: TatkalClass.nonAc,
                    label: Text('Non-AC'),
                  ),
                ],
                selected: {_tatkalClass},
                onSelectionChanged: (selection) =>
                    setState(() => _tatkalClass = selection.first),
              ),
            if (!isTatkal)
              DropdownButtonFormField<String>(
                value: _provider,
                decoration: const InputDecoration(labelText: 'Provider'),
                items: const [
                  DropdownMenuItem(value: 'TNSTC', child: Text('TNSTC')),
                  DropdownMenuItem(value: 'IRCTC', child: Text('IRCTC')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _provider = value);
                },
              ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(isTatkal ? 'Origin departure date' : 'Journey date'),
              subtitle: Text(dateFormat.format(_journeyDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickJourneyDate,
            ),
            if (isTatkal)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Origin departure time'),
                subtitle: Text(_departureTime.format(context)),
                trailing: const Icon(Icons.access_time_outlined),
                onTap: _pickDepartureTime,
              ),
            const SizedBox(height: 8),
            Text(
              isTatkal
                  ? 'Tatkal reminder: ${DateFormat('EEE, dd MMM yyyy, h:mm a').format(_remindAt)}'
                  : 'Normal booking reminder: ${DateFormat('EEE, dd MMM yyyy, h:mm a').format(_remindAt)}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              isTatkal
                  ? 'Tatkal opens one day before the train departs from its originating station.'
                  : 'TNSTC and IRCTC normal booking opens 60 days before travel.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: const Text('Set reminder'),
        ),
      ],
    );
  }
}
