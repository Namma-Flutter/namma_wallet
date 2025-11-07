import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';

abstract class TravelTicketParser {
  bool canParse(String text);
  TravelTicketModel? parseTicket(String text);
  String get providerName;
  TicketType get ticketType;
}

class TNSTCBusParser implements TravelTicketParser {
  @override
  String get providerName => 'TNSTC';

  @override
  TicketType get ticketType => TicketType.bus;

  @override
  bool canParse(String text) {
    final patterns = [
      'TNSTC',
      'Tamil Nadu',
      'Corporation',
      'PNR NO.',
      'PNR Number',
      'Trip Code',
      'Service Start Place',
      'Date of Journey',
    ];
    return patterns.any(
      (pattern) => text.toLowerCase().contains(pattern.toLowerCase()),
    );
  }

  @override
  TravelTicketModel? parseTicket(String text) {
    if (!canParse(text)) return null;

    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    DateTime? parseDate(String date) {
      if (date.isEmpty) return null;

      // Handle both '/' and '-' separators
      final parts = date.contains('/') ? date.split('/') : date.split('-');
      if (parts.length != 3) return null;

      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } on FormatException {
        return null;
      }
    }

    // Try multiple PNR patterns (handles "PNR:", "PNR NO.", "PNR Number")
    var pnrNumber = extractMatch(
      r'PNR\s*(?:NO\.?|Number)?\s*:\s*([^,\s]+)',
      text,
    );

    // Try multiple date patterns (DOJ, Journey Date, Date of Journey)
    final journeyDateStr = extractMatch(
      r'(?:DOJ|Journey Date|Date of Journey)\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})',
      text,
    );
    var journeyDate = parseDate(journeyDateStr);

    // Try multiple patterns for route/vehicle information
    final vehicleNo = extractMatch(r'Vehicle No\s*:\s*([^,\s]+)', text);
    final routeNo = extractMatch(r'Route No\s*:\s*([^,.\s]+)', text);

    // Try SMS patterns with various formats
    var corporation = extractMatch(r'Corporation\s*:\s*(.*?)(?=\s*,)', text);
    var from = extractMatch(r'From\s*:\s*(.*?)(?=\s+To)', text);
    var to = extractMatch(r'To\s+([^,]+)', text);
    final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', text);
    var departureTime = extractMatch(
      r'Time\s*:\s*(?:\d{2}/\d{2}/\d{4},)?\s*,?\s*(\d{2}:\d{2})',
      text,
    );
    var seatNumbers = extractMatch(
      r'Seat No\.\s*:\s*([0-9A-Z,\s\-#]+)',
      text,
    ).replaceAll(RegExp(r'[,\s]+$'), '');
    var classOfService = extractMatch(
      r'Class\s*:\s*(.*?)(?=\s*[,\.]|\s*Boarding|\s*For\s+e-Ticket|$)',
      text,
    );
    var boardingPoint = extractMatch(
      r'Boarding at\s*:\s*(.*?)(?=\s*\.|$)',
      text,
    );

    // If SMS patterns failed, try PDF patterns
    if (corporation.isEmpty && pnrNumber.isEmpty) {
      corporation = extractMatch(r'Corporation\s*:\s*(.*)', text);
      pnrNumber = extractMatch(r'PNR Number\s*:\s*(\S+)', text);
    }

    if (from.isEmpty || to.isEmpty) {
      from = from.isNotEmpty
          ? from
          : extractMatch(r'Service Start Place\s*:\s*(.*)', text);
      to = to.isNotEmpty
          ? to
          : extractMatch(r'Service End Place\s*:\s*(.*)', text);
    }

    journeyDate ??= parseDate(
      extractMatch(r'Date of Journey\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', text),
    );

    if (departureTime.isEmpty) {
      departureTime = extractMatch(
        r'Service Start Time\s*:\s*(\d{2}:\d{2})',
        text,
      );
    }

    if (classOfService.isEmpty) {
      classOfService = extractMatch(r'Class of Service\s*:\s*(.*)', text);
    }

    if (boardingPoint.isEmpty) {
      boardingPoint = extractMatch(r'Passenger Pickup Point\s*:\s*(.*)', text);
    }

    // For PDF, try to extract seat number differently
    if (seatNumbers.isEmpty) {
      seatNumbers = extractMatch(r'\d+[A-Z]+', text);
    }

    // Use vehicle/route number as trip code if tripCode is empty
    final finalTripCode = tripCode.isNotEmpty
        ? tripCode
        : (vehicleNo.isNotEmpty ? vehicleNo : routeNo);

    return TravelTicketModel(
      ticketType: TicketType.bus,
      providerName: corporation.isNotEmpty ? corporation : 'TNSTC',
      pnrNumber: pnrNumber.isNotEmpty ? pnrNumber : null,
      tripCode: finalTripCode.isNotEmpty ? finalTripCode : null,
      sourceLocation: from.isNotEmpty ? from : null,
      destinationLocation: to.isNotEmpty ? to : null,
      journeyDate: journeyDate?.toIso8601String(),
      departureTime: departureTime.isNotEmpty ? departureTime : null,
      seatNumbers: seatNumbers.isNotEmpty ? seatNumbers : null,
      classOfService: classOfService.isNotEmpty ? classOfService : null,
      boardingPoint: boardingPoint.isNotEmpty ? boardingPoint : null,
      sourceType: SourceType.sms,
      rawData: text,
    );
  }
}

class IRCTCTrainParser implements TravelTicketParser {
  @override
  String get providerName => 'IRCTC';

  @override
  TicketType get ticketType => TicketType.train;

  @override
  bool canParse(String text) {
    final patterns = [
      'IRCTC',
      'Indian Railway',
      r'PNR\s*:',
      r'Train\s*No',
      'E-TICKET',
    ];
    return patterns.any(
      (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text),
    );
  }

  @override
  TravelTicketModel? parseTicket(String text) {
    if (!canParse(text)) return null;

    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    final pnrNumber = extractMatch(r'PNR\s*:\s*([A-Z0-9]+)', text);
    final trainNumber = extractMatch(r'Train\s*No\s*[:-]\s*(\d+)', text);
    final from = extractMatch(r'From\s*[:-]\s*([^-\n]+)', text);
    final to = extractMatch(r'To\s*[:-]\s*([^-\n]+)', text);
    final dateTime = extractMatch(r'Date\s*[:-]\s*([^-\n]+)', text);
    final coach = extractMatch(r'Coach\s*[:-]\s*([A-Z0-9]+)', text);
    final seat = extractMatch(r'Seat\s*[:-]\s*([A-Z0-9,\s]+)', text);
    final classService = extractMatch(r'Class\s*[:-]\s*([^-\n]+)', text);

    return TravelTicketModel(
      ticketType: TicketType.train,
      providerName: 'IRCTC',
      pnrNumber: pnrNumber.isNotEmpty ? pnrNumber : null,
      tripCode: trainNumber.isNotEmpty ? trainNumber : null,
      sourceLocation: from.isNotEmpty ? from : null,
      destinationLocation: to.isNotEmpty ? to : null,
      journeyDate: dateTime.isNotEmpty ? dateTime : null,
      seatNumbers: seat.isNotEmpty ? seat : null,
      coachNumber: coach.isNotEmpty ? coach : null,
      classOfService: classService.isNotEmpty ? classService : null,
      sourceType: SourceType.sms,
      rawData: text,
    );
  }
}

class SETCBusParser implements TravelTicketParser {
  @override
  String get providerName => 'SETC';

  @override
  TicketType get ticketType => TicketType.bus;

  @override
  bool canParse(String text) {
    final patterns = [
      'SETC',
      'State Express',
      'Booking ID',
      'Bus No',
    ];
    return patterns.any(
      (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text),
    );
  }

  @override
  TravelTicketModel? parseTicket(String text) {
    if (!canParse(text)) return null;

    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    final bookingId = extractMatch(r'Booking ID\s*[:-]\s*([A-Z0-9]+)', text);
    final busNumber = extractMatch(r'Bus No\s*[:-]\s*([A-Z0-9\s]+)', text);
    final from = extractMatch(r'From\s*[:-]\s*([^-\n]+)', text);
    final to = extractMatch(r'To\s*[:-]\s*([^-\n]+)', text);
    final dateTime = extractMatch(r'Date\s*[:-]\s*([^-\n]+)', text);
    final seat = extractMatch(r'Seat\s*[:-]\s*([A-Z0-9,\s]+)', text);

    return TravelTicketModel(
      ticketType: TicketType.bus,
      providerName: 'SETC',
      bookingReference: bookingId.isNotEmpty ? bookingId : null,
      tripCode: busNumber.isNotEmpty ? busNumber : null,
      sourceLocation: from.isNotEmpty ? from : null,
      destinationLocation: to.isNotEmpty ? to : null,
      journeyDate: dateTime.isNotEmpty ? dateTime : null,
      seatNumbers: seat.isNotEmpty ? seat : null,
      sourceType: SourceType.sms,
      rawData: text,
    );
  }
}

class TicketUpdateInfo {
  TicketUpdateInfo({
    required this.pnrNumber,
    required this.providerName,
    required this.updates,
  });

  final String pnrNumber;
  final String providerName;
  final Map<String, Object?> updates;
}

class TravelParserService {
  TravelParserService();

  final List<TravelTicketParser> _parsers = [
    TNSTCBusParser(),
    IRCTCTrainParser(),
    SETCBusParser(),
  ];

  /// Detects if this is an update SMS (e.g., conductor details for TNSTC)
  TicketUpdateInfo? parseUpdateSMS(String text) {
    // Check for TNSTC update SMS pattern
    if (text.toUpperCase().contains('TNSTC') &&
        (text.toLowerCase().contains('conductor mobile no') ||
            text.toLowerCase().contains('vehicle no'))) {
      final pnrMatch = RegExp(
        r'PNR\s*:\s*([^,\s]+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (pnrMatch == null) return null;

      final pnr = pnrMatch.group(1)!.trim();
      final updates = <String, Object?>{};

      // Extract conductor mobile number
      final mobileMatch = RegExp(
        r'Conductor Mobile No\s*:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (mobileMatch != null) {
        updates['contact_mobile'] = mobileMatch.group(1)!.trim();
      }

      // Extract vehicle number
      final vehicleMatch = RegExp(
        r'Vehicle No\s*:\s*([^,\s]+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (vehicleMatch != null) {
        updates['trip_code'] = vehicleMatch.group(1)!.trim();
      }

      if (updates.isNotEmpty) {
        getIt<ILogger>().info(
          '[TravelParserService] Detected TNSTC update SMS for '
          'PNR: $pnr with updates: $updates',
        );

        return TicketUpdateInfo(
          pnrNumber: pnr,
          providerName: 'TNSTC', // Default provider for these updates
          updates: updates,
        );
      }
    }

    return null;
  }

  TravelTicketModel? parseTicketFromText(
    String text, {
    SourceType? sourceType,
  }) {
    try {
      for (final parser in _parsers) {
        if (parser.canParse(text)) {
          getIt<ILogger>().debug('[TravelParserService] ticket text : $text');
          getIt<ILogger>().info(
            '[TravelParserService] Attempting to parse with '
            '${parser.providerName} parser',
          );

          final ticket = parser.parseTicket(text);
          if (ticket != null) {
            getIt<ILogger>().debug(
              '[TravelParserService] Parsed ticket: $ticket',
            );
            getIt<ILogger>().info(
              '[TravelParserService] Successfully parsed ticket with '
              '${parser.providerName}',
            );

            if (sourceType != null) {
              return ticket.copyWith(sourceType: sourceType);
            }
            return ticket;
          }
        }
      }

      getIt<ILogger>().warning(
        '[TravelParserService] No parser could handle the text',
      );
      return null;
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelParserService] Error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    }
  }

  List<String> getSupportedProviders() {
    return _parsers.map((parser) => parser.providerName).toList();
  }

  bool isTicketText(String text) {
    return _parsers.any((parser) => parser.canParse(text));
  }
}
