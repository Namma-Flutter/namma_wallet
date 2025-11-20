import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

/// Parses TNSTC SMS messages into structured [Ticket] data.
///
/// Handles both conductor SMS and booking confirmation SMS formats.
/// Falls back to default values if parsing fails for individual fields.
///
/// **Error Handling:**
/// - Never throws exceptions
/// - Returns a [Ticket] with partial data on parsing errors
/// - Missing/invalid fields use fallbacks: 'Unknown', DateTime.now(), etc.
/// - Conversion via [Ticket.fromTNSTC] is guaranteed not to throw
class TNSTCSMSParser implements ITicketParser {
  @override
  Ticket parseTicket(String smsText) {
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

    // Extract common fields present in both SMS formats.
    // Falls back to empty string if pattern doesn't match.
    final pnrNumber = extractMatch(
      r'(?:PNR NO\.\s*|PNR)\s*:\s*([^,\s]+)',
      smsText,
    );
    // Falls back to DateTime.now() if date is missing or malformed.
    final journeyDate = parseDate(
      extractMatch(
        r'(?:Journey Date|DOJ)\s*:\s*(\d{2}/\d{2}/\d{4})',
        smsText,
      ),
    );

    // Check if it's a conductor SMS (vs booking confirmation SMS)
    final isConductorSMS = smsText.contains('Conductor Mobile No');

    if (isConductorSMS) {
      // Parse conductor SMS format (typically sent during journey).
      // Missing fields result in empty strings or null values.
      final conductorMobileNo = extractMatch(
        r'Conductor Mobile No:\s*(\d+)',
        smsText,
      );
      final vehicleNumber = extractMatch('Vehicle No:([A-Z0-9]+)', smsText);

      final tnstcModel = TNSTCTicketModel(
        pnrNumber: pnrNumber,
        journeyDate: journeyDate,
        conductorMobileNo: conductorMobileNo,
        vehicleNumber: vehicleNumber,
        corporation: 'TNSTC', // Assuming TNSTC for conductor SMS
      );
      // Convert to Ticket (guaranteed not to throw,
      // uses fallbacks for missing data)
      return Ticket.fromTNSTC(tnstcModel, sourceType: 'SMS');
    } else {
      // Parse booking confirmation SMS format (sent at time of booking).
      // All fields use fallbacks if extraction fails.
      final corporation = extractMatch(
        r'Corporation\s*:\s*(.*?)(?=\s*,)',
        smsText,
      );
      final from = extractMatch(r'From\s*:\s*(.*?)(?=\s+To)', smsText);
      final to = extractMatch(r'To\s+([^,]+)', smsText);
      final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', smsText);
      final departureTime = extractMatch(
        r'Time\s*:\s*(?:\d{2}/\d{2}/\d{4},)?\s*,?\s*(\d{2}:\d{2})',
        smsText,
      );
      final seatNumbers = extractMatch(
        r'Seat No\.\s*:\s*([0-9A-Z,\-#]+(?:,\s*[0-9A-Z,\-#]+)*)',
        smsText,
      ).replaceAll(RegExp(r'[,\s]+$'), '');
      final classOfService = extractMatch(
        r'Class\s*:\s*(.*?)(?=\s*[,\.]|\s*Boarding|\s*For\s+e-Ticket|$)',
        smsText,
      );
      final passengerPickupPoint = extractMatch(
        r'Boarding at\s*:\s*(.*?)(?=\s*\.|$)',
        smsText,
      );

      final numberOfSeats = seatNumbers.isNotEmpty
          ? seatNumbers.split(',').where((s) => s.trim().isNotEmpty).length
          : 1;

      final tnstcModel = TNSTCTicketModel(
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
        smsSeatNumbers: seatNumbers.isNotEmpty ? seatNumbers : null,
      );
      // Convert to Ticket (guaranteed not to throw,
      // uses fallbacks: 'Unknown', DateTime.now(), etc. for missing data)
      return Ticket.fromTNSTC(tnstcModel, sourceType: 'SMS');
    }
  }
}
