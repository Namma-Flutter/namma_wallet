import 'dart:core';

import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

TNSTCTicketModel parseTicket(String text) {
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

  final corporation = extractMatch(r'Corporation\s*:\s*(.*)', text);
  final pnrNumber = extractMatch(r'PNR Number\s*:\s*(\S+)', text);
  final journeyDate = parseDate(
    extractMatch(r'Date of Journey\s*:\s*(\d{2}/\d{2}/\d{4})', text),
  );
  final routeNo = extractMatch(r'Route No\s*:\s*(\S+)', text);
  final serviceStartPlace = extractMatch(
    r'Service Start Place\s*:\s*(.*)',
    text,
  );
  final serviceEndPlace = extractMatch(r'Service End Place\s*:\s*(.*)', text);
  final serviceStartTime = extractMatch(
    r'Service Start Time\s*:\s*(\d{2}:\d{2})',
    text,
  );
  final passengerStartPlace = extractMatch(
    r'Passenger Start Place\s*:\s*(.*)',
    text,
  );
  final passengerEndPlace = extractMatch(
    r'Passenger End Place\s*:\s*(.*)',
    text,
  );
  final passengerPickupPoint = extractMatch(
    r'Passenger Pickup Point\s*:\s*(.*)',
    text,
  );
  final passengerPickupTime = parseDateTime(
    extractMatch(
      r'Passenger Pickup Time\s*:\s*(\d{2}/\d{2}/\d{4} \d{2}:\d{2})',
      text,
    ),
  );
  final platformNumber = extractMatch(r'Platform Number\s*:\s*(\S+)', text);
  final classOfService = extractMatch(r'Class of Service\s*:\s*(.*)', text);
  final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', text);
  final obReferenceNumber = extractMatch(
    r'OB Reference No\.\s*:\s*(\S+)',
    text,
  );
  final numberOfSeatsStr = extractMatch(r'No\. of Seats\s*:\s*(\d+)', text);
  final numberOfSeats = numberOfSeatsStr.isNotEmpty
      ? int.tryParse(numberOfSeatsStr) ?? 1
      : 1;
  final bankTransactionNumber = extractMatch(
    r'Bank Txn\. No\.\s*:\s*(\S+)',
    text,
  );
  final busIdNumber = extractMatch(r'Bus ID No\.\s*:\s*(\S+)', text);
  final passengerCategory = extractMatch(
    r'Passenger category\s*:\s*(.*)',
    text,
  );
  final passengerName = extractMatch(
    r'Name\s+Age\s+Adult/Child\s+Gender\s+Seat No\.\n(.*)\s+\d+',
    text,
  );
  final passengerAge = parseAge(text);
  final passengerType = extractMatch('Adult|Child', text);
  final passengerGender = extractMatch('(M|F)', text);
  final passengerSeatNumber = extractMatch(r'\d+[A-Z]+', text);
  final idCardType = extractMatch(r'ID Card Type\s*:\s*(.*)', text);
  final idCardNumber = extractMatch(r'ID Card Number\s*:\s*(.*)', text);
  final totalFareStr = extractMatch(r'Total Fare\s*:\s*(\d+\.\d+)', text);
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
  passengers.add(passengerInfo);

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
