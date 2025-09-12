import 'package:namma_wallet/src/features/ticket_parser/tnstc/application/tnstc_ticket_parser.dart';

class TNSTCSMSParser {
  static TNSTCTicket parseTicket(String smsText) {
    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    DateTime parseDate(String date) {
      if (date.isEmpty) return DateTime.now();
      final parts = date.split('/');
      if (parts.length != 3) return DateTime.now();
      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } on FormatException {
        return DateTime.now();
      }
    }

    // Extract fields using SMS-specific patterns
    final corporation = extractMatch(r'Corporation\s*:\s*(.*?)(?=\s*,)', smsText);
    final pnrNumber = extractMatch(r'PNR NO\.\s*:\s*([^,\s]+)', smsText);
    final from = extractMatch(r'From\s*:\s*(.*?)(?=\s+To)', smsText);
    final to = extractMatch(r'To\s+([^,]+)', smsText);
    final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', smsText);
    final journeyDate = parseDate(
      extractMatch(r'Journey Date\s*:\s*(\d{2}/\d{2}/\d{4})', smsText),
    );
    final departureTime = extractMatch(r'Time\s*:\s*(?:\d{2}/\d{2}/\d{4},)?\s*,?\s*(\d{2}:\d{2})', smsText);
    final seatNumbers = extractMatch(r'Seat No\.\s*:\s*([0-9A-Z,\s\-#]+)', smsText)
        .replaceAll(RegExp(r'[,\s]+$'), '');
    final classOfService = extractMatch(r'Class\s*:\s*(.*?)(?=\s*[,\.]|\s*Boarding|\s*For\s+e-Ticket|$)', smsText);
    final passengerPickupPoint =
        extractMatch(r'Boarding at\s*:\s*(.*?)(?=\s*\.|$)', smsText);

    // Calculate number of seats from seat numbers
    final numberOfSeats = seatNumbers.isNotEmpty 
        ? seatNumbers.split(',').where((s) => s.trim().isNotEmpty).length 
        : 1;

    // Create passenger info with available data
    final passengerInfo = PassengerInfo(
      name: '', // Not available in SMS format
      age: 0, // Not available in SMS format
      type: 'Adult', // Default assumption
      gender: '', // Not available in SMS format
      seatNumber: seatNumbers,
    );

    return TNSTCTicket(
      corporation: corporation,
      pnrNumber: pnrNumber,
      serviceStartPlace: from,
      serviceEndPlace: to,
      tripCode: tripCode,
      journeyDate: journeyDate,
      serviceStartTime: departureTime,
      classOfService: classOfService,
      passengerPickupPoint: passengerPickupPoint,
      numberOfSeats: numberOfSeats,
      passengerInfo: passengerInfo,
    );
  }
}
