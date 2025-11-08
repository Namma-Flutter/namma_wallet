import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';

class CalendarUtils {
  static Color getTicketTypeColor(TicketType type) {
    switch (type) {
      case TicketType.bus:
        return AppColor.busTicketColor;
      case TicketType.train:
        return AppColor.trainTicketColor;
      case TicketType.flight:
        return AppColor.flightTicketColor;
      case TicketType.event:
        return AppColor.eventTicketColor;
      case TicketType.metro:
        return AppColor.metroTicketColor;
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
