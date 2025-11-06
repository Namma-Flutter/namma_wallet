import 'package:namma_wallet/src/features/tnstc/application/tnstc_ticket_parser.dart';

class TNSTCPDFParser {
  static TNSTCTicket parseTicket(String pdfText) {
    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true);
      final match = regex.firstMatch(input);

      if (match != null && groupIndex <= match.groupCount) {
        // Safely extract the matched group, or return empty string if null
        return match.group(groupIndex)?.trim() ?? '';
      }
      // Return empty string if the match or group is invalid
      return '';
    }

    DateTime parseDate(String date) {
      if (date.isEmpty) return DateTime.now();

      // Handle both '-' and '/' separators
      final parts = date.contains('/') ? date.split('/') : date.split('-');
      if (parts.length != 3) return DateTime.now();

      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day); // Construct the DateTime object
      } on FormatException {
        return DateTime.now();
      }
    }

    DateTime parseDateTime(String dateTime) {
      if (dateTime.isEmpty) return DateTime.now();

      final parts = dateTime.split(' '); // Split into date and time
      if (parts.length != 2) return DateTime.now();

      try {
        // Handle both '-' and '/' separators for date
        final dateParts = parts[0].contains('/')
            ? parts[0].split('/')
            : parts[0].split('-');
        if (dateParts.length != 3) return DateTime.now();

        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        final timeParts = parts[1].split(':'); // Split the time by ':'
        if (timeParts.length != 2) return DateTime.now();

        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        return DateTime(year, month, day, hour, minute);
      } on FormatException {
        return DateTime.now();
      }
    }

    int parseAge(String text) {
      final ageMatch = RegExp(r'Age\s+(\d+)').firstMatch(text);
      if (ageMatch == null) {
        return 1;
      }
      return int.parse(ageMatch.group(1)!);
    }

    // Extract all fields using PDF-specific patterns
    // The PDF shows patterns like "PNR $1: U68789437" due to text extraction issues
    final corporation = extractMatch(r'\$1\s*:\s*([A-Z\s]+)', pdfText);
    final pnrNumber = extractMatch(r'PNR\s+\$1\s*:\s*(\S+)', pdfText);
    final journeyDate = parseDate(
      extractMatch(r'Date of\s+\$1\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', pdfText),
    );
    final routeNo = extractMatch(r'Route\s+\$1\s*:\s*(\S+)', pdfText);
    final serviceStartPlace = extractMatch(
      r'Service Start\s+\$1\s*:\s*([A-Z\s]+)',
      pdfText,
    );
    final serviceEndPlace = extractMatch(
      r'Service End\s+\$1\s*:\s*([A-Z\s]+)',
      pdfText,
    );
    final serviceStartTime = extractMatch(
      r'Service Start\s+\$1\s*:\s*(\d{2}:\d{2})',
      pdfText,
    );
    final passengerStartPlace = extractMatch(
      r'Passenger Start\s+\$1\s*:\s*([A-Z\s]+)',
      pdfText,
    );
    final passengerEndPlace = extractMatch(
      r'Passenger End\s+\$1\s*:\s*([A-Z\s]+)',
      pdfText,
    );
    final passengerPickupPoint = extractMatch(
      r'Passenger Pickup\s+\$1\s*:\s*([A-Z\s]+)',
      pdfText,
    );
    final passengerPickupTime = parseDateTime(
      extractMatch(
        r'Passenger Pickup\s+\$1\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4} \d{2}:\d{2})',
        pdfText,
      ),
    );
    final platformNumber = extractMatch(r'Platform\s+\$1\s*:\s*(\S+)', pdfText);
    final classOfService = extractMatch(
      r'Class of\s+\$1\s*:\s*([A-Z0-9\s]+)',
      pdfText,
    );
    final tripCode = extractMatch(r'Trip\s+\$1\s*:\s*(\S+)', pdfText);
    final obReferenceNumber = extractMatch(
      r'OB Reference No\.\s*:\s*(\S+)',
      pdfText,
    );

    // Safe parsing for numbers
    final numberOfSeatsStr = extractMatch(
      r'No\. of\s+\$1\s*:\s*(\d+)',
      pdfText,
    );
    final numberOfSeats = numberOfSeatsStr.isNotEmpty
        ? int.tryParse(numberOfSeatsStr) ?? 1
        : 1;

    final bankTransactionNumber = extractMatch(
      r'Bank Txn\. No\.\s*:\s*(\S+)',
      pdfText,
    );
    final busIdNumber = extractMatch(r'Bus ID No\.\s*:\s*(\S+)', pdfText);
    final passengerCategory = extractMatch(
      r'Passenger\s+\$1\s*:\s*([A-Z\s]+)',
      pdfText,
    );

    // Extract passenger info from the table format
    // Looking for pattern: Name Age Adult/Child Gender Seat No.
    // Followed by: Maragatham 55 Adult F 14
    final passengerName = extractMatch(
      r'Seat No\.\s*\n\s*([A-Za-z\s]+)\s+\d+\s+(?:Adult|Child)',
      pdfText,
    );
    final passengerAgeStr = extractMatch(
      r'([A-Za-z\s]+)\s+(\d+)\s+(?:Adult|Child)',
      pdfText,
      groupIndex: 2,
    );
    final passengerAge = passengerAgeStr.isNotEmpty
        ? int.tryParse(passengerAgeStr) ?? 1
        : 1;
    final passengerType = extractMatch(
      r'[A-Za-z\s]+\s+\d+\s+(Adult|Child)',
      pdfText,
    );
    final passengerGender = extractMatch(
      r'[A-Za-z\s]+\s+\d+\s+(?:Adult|Child)\s+(M|F)',
      pdfText,
    );
    final passengerSeatNumber = extractMatch(
      r'[A-Za-z\s]+\s+\d+\s+(?:Adult|Child)\s+[MF]\s+(\d+)',
      pdfText,
    );

    final idCardType = extractMatch(
      r'ID Card\s+\$1\s*:\s*([A-Za-z\s]+)',
      pdfText,
    );
    final idCardNumber = extractMatch(r'ID Card\s+\$1\s*:\s*(\d+)', pdfText);

    // Safe parsing for total fare
    final totalFareStr = extractMatch(
      r'Total\s+\$1\s*:\s*(\d+\.?\d*)',
      pdfText,
    );
    final totalFare = totalFareStr.isNotEmpty
        ? double.tryParse(totalFareStr) ?? 0.0
        : 0.0;

    final passengerInfo = PassengerInfo(
      name: passengerName,
      age: passengerAge,
      type: passengerType,
      gender: passengerGender,
      seatNumber: passengerSeatNumber,
    );

    return TNSTCTicket(
      corporation: corporation,
      pnrNumber: pnrNumber,
      journeyDate: journeyDate,
      routeNo: routeNo,
      serviceStartPlace: serviceStartPlace,
      serviceEndPlace: serviceEndPlace,
      serviceStartTime: serviceStartTime,
      passengerStartPlace: passengerStartPlace,
      passengerEndPlace: passengerEndPlace,
      passengerPickupPoint: passengerPickupPoint,
      passengerPickupTime: passengerPickupTime,
      platformNumber: platformNumber,
      classOfService: classOfService,
      tripCode: tripCode,
      obReferenceNumber: obReferenceNumber,
      numberOfSeats: numberOfSeats,
      bankTransactionNumber: bankTransactionNumber,
      busIdNumber: busIdNumber,
      passengerCategory: passengerCategory,
      passengerInfo: passengerInfo,
      idCardType: idCardType,
      idCardNumber: idCardNumber,
      totalFare: totalFare,
    );
  }
}
