import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';

class CalendarUtils {
  static Color getTicketTypeColor(TicketType type) {
    switch (type) {
      case TicketType.bus:
        return Colors.green;
      case TicketType.train:
        return Colors.blue;
      case TicketType.flight:
        return Colors.red;
      case TicketType.event:
        return Colors.purple;
      case TicketType.metro:
        return Colors.orange;
    }
  }

  static IconData getTicketTypeIcon(TicketType type) {
    switch (type) {
      case TicketType.bus:
        return Icons.directions_bus;
      case TicketType.train:
        return Icons.train;
      case TicketType.flight:
        return Icons.flight;
      case TicketType.event:
        return Icons.event;
      case TicketType.metro:
        return Icons.subway;
    }
  }
}
