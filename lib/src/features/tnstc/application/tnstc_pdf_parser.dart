import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

class TNSTCPDFParser {
  TNSTCTicketModel parseTicket(String pdfText) {
    final passengers = <PassengerInfo>[];
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
      if (parts.length < 2) return DateTime.now();

      try {
        // Handle both '-' and '/' separators for date
        final dateParts = parts[0].contains('/')
            ? parts[0].split('/')
            : parts[0].split('-');
        if (dateParts.length != 3) return DateTime.now();

        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        // Extract time part (might have "Hrs." suffix)
        final timePart = parts[1].replaceAll(RegExp(r'\s*Hrs\.?'), '');
        final timeParts = timePart.split(':'); // Split the time by ':'
        if (timeParts.length != 2) return DateTime.now();

        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        return DateTime(year, month, day, hour, minute);
      } on FormatException {
        return DateTime.now();
      }
    }

    // Extract all fields using PDF-specific patterns
    // Use non-greedy matching and stop at newlines
    final corporation = extractMatch(
      r'Corporation\s*:\s*([A-Z\s]+?)(?:\n|$)',
      pdfText,
    );
    final pnrNumber = extractMatch(
      r'PNR Number\s*:\s*([A-Z0-9]+)',
      pdfText,
    );
    final journeyDate = parseDate(
      extractMatch(r'Date of Journey\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', pdfText),
    );
    final routeNo = extractMatch(r'Route No\s*:\s*(\S+)', pdfText);
    final serviceStartPlace = extractMatch(
      r'Service Start Place\s*:\s*([A-Z\s]+?)(?:\n|$)',
      pdfText,
    );
    final serviceEndPlace = extractMatch(
      r'Service End Place\s*:\s*([A-Z\s.,-]+?)(?:\n|$)',
      pdfText,
    );
    final serviceStartTime = extractMatch(
      r'Service Start Time\s*:\s*(\d{2}:\d{2})',
      pdfText,
    );
    final passengerStartPlace = extractMatch(
      r'Passenger Start Place\s*:\s*([A-Z\s]+?)(?:\n|$)',
      pdfText,
    );
    final passengerEndPlace = extractMatch(
      r'Passenger End Place\s*:\s*([A-Z\s.,-]+?)(?:\n|$)',
      pdfText,
    );
    final passengerPickupPoint = extractMatch(
      r'Passenger Pickup Point\s*:\s*([A-Z\s]+?)(?:\n|$)',
      pdfText,
    );
    final passengerPickupTime = parseDateTime(
      extractMatch(
        r'Passenger Pickup Time\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4}\s+\d{2}:\d{2}(?:\s*Hrs\.?)?)',
        pdfText,
      ),
    );
    final platformNumber = extractMatch(
      r'Platform Number\s*:\s*([^\n]*?)\n',
      pdfText,
    );
    final classOfService = extractMatch(
      r'Class of Service\s*:\s*([A-Z0-9\s]+?)(?:\n|$)',
      pdfText,
    );
    final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', pdfText);
    final obReferenceNumber = extractMatch(
      r'OB Reference No\.\s*:\s*([A-Z0-9]+)',
      pdfText,
    );

    // Safe parsing for numbers
    final numberOfSeatsStr = extractMatch(
      r'No\. of Seats\s*:\s*(\d+)',
      pdfText,
    );
    final numberOfSeats = numberOfSeatsStr.isNotEmpty
        ? int.tryParse(numberOfSeatsStr) ?? 1
        : 1;

    final bankTransactionNumber = extractMatch(
      r'Bank Txn\. No\.\s*:\s*([A-Z0-9]+)',
      pdfText,
    );
    final busIdNumber = extractMatch(r'Bus ID No\.\s*:\s*([A-Z0-9-]+)', pdfText);
    final passengerCategory = extractMatch(
      r'Passenger category\s*:\s*([A-Z\s]+?)(?:\n|$)',
      pdfText,
    );

    // Extract passenger info from the table format
    // Pattern: Name Age Adult/Child Gender Seat No.
    // Followed by: HarishAnbalagan 26 Adult M 4UB
    final passengerPattern = RegExp(
      r'Name\s+Age\s+Adult/Child\s+Gender\s+Seat No\.\s*\n\s*([A-Za-z]+)\s+(\d+)\s+(Adult|Child)\s+(M|F)\s+([A-Z0-9]+)',
      multiLine: true,
    );
    final passengerMatch = passengerPattern.firstMatch(pdfText);

    var passengerName = '';
    var passengerAge = 0;
    var passengerType = '';
    var passengerGender = '';
    var passengerSeatNumber = '';

    if (passengerMatch != null) {
      passengerName = passengerMatch.group(1) ?? '';
      passengerAge = int.tryParse(passengerMatch.group(2) ?? '0') ?? 0;
      passengerType = passengerMatch.group(3) ?? '';
      passengerGender = passengerMatch.group(4) ?? '';
      passengerSeatNumber = passengerMatch.group(5) ?? '';
    }

    final idCardType = extractMatch(
      r'ID Card Type\s*:\s*([A-Za-z\s]+?)(?=\s*ID Card Number)',
      pdfText,
    );
    final idCardNumber = extractMatch(
      r'ID Card Number\s*:\s*([0-9]+)',
      pdfText,
    );

    // Safe parsing for total fare
    final totalFareStr = extractMatch(
      r'Total Fare\s*:\s*(\d+\.?\d*)\s*Rs\.',
      pdfText,
    );
    final totalFare = totalFareStr.isNotEmpty
        ? double.tryParse(totalFareStr) ?? 0.0
        : 0.0;

    if (passengerName.isNotEmpty) {
      final passengerInfo = PassengerInfo(
        name: passengerName,
        age: passengerAge,
        type: passengerType,
        gender: passengerGender,
        seatNumber: passengerSeatNumber,
      );
      passengers.add(passengerInfo);
    }

    return TNSTCTicketModel(
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
      passengers: passengers,
      idCardType: idCardType,
      idCardNumber: idCardNumber,
      totalFare: totalFare,
    );
  }
}
