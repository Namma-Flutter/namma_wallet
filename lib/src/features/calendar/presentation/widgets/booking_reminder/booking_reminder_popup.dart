import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/booking_reminder/booking_reminder_service.dart';

class BookingReminderPopup extends StatefulWidget {
  const BookingReminderPopup({
    required this.tickets,
    required this.dateLabel,
    super.key,
  });

  final List<Ticket> tickets;
  final String dateLabel;

  static Future<void> show({
    required BuildContext context,
    required List<Ticket> tickets,
    required DateTime date,
  }) {
    final dateLabel = '${date.day}/${date.month}/${date.year}';
    return showModalBottomSheet(
      context: context,
      builder: (_) => BookingReminderPopup(
        tickets: tickets,
        dateLabel: dateLabel,
      ),
    );
  }

  @override
  State<BookingReminderPopup> createState() => _BookingReminderPopupState();
}

class _BookingReminderPopupState extends State<BookingReminderPopup> {
  final _service = getIt<BookingReminderService>();
  final Map<String, bool> _normalEnabled = {};
  final Map<String, bool> _tatkalEnabled = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    for (final ticket in widget.tickets) {
      if (ticket.ticketId == null) continue;
      final normal = await _service.hasActiveReminder(ticket.ticketId!);
      final tatkal = await _service.hasActiveTatkalReminder(ticket.ticketId!);
      _normalEnabled[ticket.ticketId!] = normal;
      _tatkalEnabled[ticket.ticketId!] = tatkal;
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Reminders - ${widget.dateLabel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ...widget.tickets.map((ticket) => _buildTicketTile(ticket)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTicketTile(Ticket ticket) {
    final route = ticket.primaryText ?? 'Unknown route';
    final typeLabel = ticket.type?.name ?? 'ticket';
    final dates = getIt<BookingReminderService>().computeBookingOpenDates(
      ticket,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              typeLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (dates != null) ...[
              const SizedBox(height: 8),
              if (!dates.$1.isBefore(DateTime.now()))
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Normal booking opens ${_formatDate(dates.$1)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Switch(
                      value: _normalEnabled[ticket.ticketId!] ?? false,
                      onChanged: (v) => _toggleNormal(ticket, v),
                    ),
                  ],
                ),
              if (dates.$2 != null && !dates.$2!.isBefore(DateTime.now()))
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tatkal opens ${_formatDate(dates.$2!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Switch(
                      value: _tatkalEnabled[ticket.ticketId!] ?? false,
                      onChanged: (v) => _toggleTatkal(ticket, v),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _toggleNormal(Ticket ticket, bool enabled) async {
    if (ticket.ticketId == null) return;
    if (enabled) {
      await _service.scheduleBookingReminder(ticket);
    } else {
      await _service.cancelBookingReminder(ticket.ticketId!);
    }
    setState(() => _normalEnabled[ticket.ticketId!] = enabled);
  }

  Future<void> _toggleTatkal(Ticket ticket, bool enabled) async {
    if (ticket.ticketId == null) return;
    if (enabled) {
      await _service.scheduleBookingReminder(ticket);
    } else {
      await _service.cancelBookingReminder(ticket.ticketId!);
    }
    setState(() => _tatkalEnabled[ticket.ticketId!] = enabled);
  }
}
