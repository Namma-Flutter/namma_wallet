import 'dart:developer' as developer;
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
    return patterns
        .any((pattern) => text.toLowerCase().contains(pattern.toLowerCase()));
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
      var parts = date.contains('/') ? date.split('/') : date.split('-');
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

    // Try SMS patterns first
    var corporation = extractMatch(r'Corporation\s*:\s*(.*?)(?=\s*,)', text);
    var pnrNumber = extractMatch(r'PNR NO\.\s*:\s*([^,\s]+)', text);
    var from = extractMatch(r'From\s*:\s*(.*?)(?=\s+To)', text);
    var to = extractMatch(r'To\s+([^,]+)', text);
    var tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', text);
    var journeyDate = parseDate(
      extractMatch(r'Journey Date\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', text),
    );
    var departureTime = extractMatch(
        r'Time\s*:\s*(?:\d{2}/\d{2}/\d{4},)?\s*,?\s*(\d{2}:\d{2})', text);
    var seatNumbers = extractMatch(r'Seat No\.\s*:\s*([0-9A-Z,\s\-#]+)', text)
        .replaceAll(RegExp(r'[,\s]+$'), '');
    var classOfService = extractMatch(
        r'Class\s*:\s*(.*?)(?=\s*[,\.]|\s*Boarding|\s*For\s+e-Ticket|$)', text);
    var boardingPoint =
        extractMatch(r'Boarding at\s*:\s*(.*?)(?=\s*\.|$)', text);

    // If SMS patterns failed, try PDF patterns
    if (corporation.isEmpty || pnrNumber.isEmpty) {
      corporation = corporation.isNotEmpty
          ? corporation
          : extractMatch(r'Corporation\s*:\s*(.*)', text);
      pnrNumber = pnrNumber.isNotEmpty
          ? pnrNumber
          : extractMatch(r'PNR Number\s*:\s*(\S+)', text);
      from = from.isNotEmpty
          ? from
          : extractMatch(r'Service Start Place\s*:\s*(.*)', text);
      to = to.isNotEmpty
          ? to
          : extractMatch(r'Service End Place\s*:\s*(.*)', text);
      journeyDate = journeyDate ??
          parseDate(
            extractMatch(
                r'Date of Journey\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', text),
          );
      departureTime = departureTime.isNotEmpty
          ? departureTime
          : extractMatch(r'Service Start Time\s*:\s*(\d{2}:\d{2})', text);
      classOfService = classOfService.isNotEmpty
          ? classOfService
          : extractMatch(r'Class of Service\s*:\s*(.*)', text);
      boardingPoint = boardingPoint.isNotEmpty
          ? boardingPoint
          : extractMatch(r'Passenger Pickup Point\s*:\s*(.*)', text);

      // For PDF, try to extract seat number differently
      if (seatNumbers.isEmpty) {
        seatNumbers = extractMatch(r'\d+[A-Z]+', text);
      }
    }

    return TravelTicketModel(
      ticketType: TicketType.bus,
      providerName: corporation.isNotEmpty ? corporation : 'TNSTC',
      pnrNumber: pnrNumber.isNotEmpty ? pnrNumber : null,
      tripCode: tripCode.isNotEmpty ? tripCode : null,
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
      r'IRCTC',
      r'Indian Railway',
      r'PNR\s*:',
      r'Train\s*No',
      r'E-TICKET',
    ];
    return patterns
        .any((pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text));
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
      r'SETC',
      r'State Express',
      r'Booking ID',
      r'Bus No',
    ];
    return patterns
        .any((pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text));
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

class TravelParserService {
  static final List<TravelTicketParser> _parsers = [
    TNSTCBusParser(),
    IRCTCTrainParser(),
    SETCBusParser(),
  ];

  static TravelTicketModel? parseTicketFromText(String text,
      {SourceType? sourceType}) {
    try {
      for (final parser in _parsers) {
        if (parser.canParse(text)) {
          developer.log(
              'Attempting to parse with ${parser.providerName} parser',
              name: 'TravelParserService');
          print('🔍 PARSING: Trying ${parser.providerName} parser');

          final ticket = parser.parseTicket(text);
          if (ticket != null) {
            developer.log(
                'Successfully parsed ticket with ${parser.providerName}',
                name: 'TravelParserService');
            print(
                '✅ PARSED: Successfully parsed ${parser.providerName} ticket');

            if (sourceType != null) {
              return ticket.copyWith(sourceType: sourceType);
            }
            return ticket;
          }
        }
      }

      developer.log('No parser could handle the text',
          name: 'TravelParserService');
      print('❌ PARSING: No parser could handle the text');
      return null;
    } catch (e) {
      developer.log('Error during ticket parsing',
          name: 'TravelParserService', error: e);
      print('🔴 PARSING ERROR: $e');
      return null;
    }
  }

  static List<String> getSupportedProviders() {
    return _parsers.map((parser) => parser.providerName).toList();
  }

  static bool isTicketText(String text) {
    return _parsers.any((parser) => parser.canParse(text));
  }
}
