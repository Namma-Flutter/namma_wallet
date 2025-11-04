import 'dart:core';

class TNSTCTicket {
  TNSTCTicket({
    this.corporation,
    this.pnrNumber,
    this.journeyDate,
    this.routeNo,
    this.serviceStartPlace,
    this.serviceEndPlace,
    this.serviceStartTime,
    this.passengerStartPlace,
    this.passengerEndPlace,
    this.passengerPickupPoint,
    this.passengerPickupTime,
    this.platformNumber,
    this.classOfService,
    this.tripCode,
    this.obReferenceNumber,
    this.numberOfSeats,
    this.bankTransactionNumber,
    this.busIdNumber,
    this.passengerCategory,
    this.passengerInfo,
    this.idCardType,
    this.idCardNumber,
    this.totalFare,
  });
  final String? corporation;
  final String? pnrNumber;
  final DateTime? journeyDate;
  final String? routeNo;
  final String? serviceStartPlace;
  final String? serviceEndPlace;
  final String? serviceStartTime;
  final String? passengerStartPlace;
  final String? passengerEndPlace;
  final String? passengerPickupPoint;
  final DateTime? passengerPickupTime;
  final String? platformNumber;
  final String? classOfService;
  final String? tripCode;
  final String? obReferenceNumber;
  final int? numberOfSeats;
  final String? bankTransactionNumber;
  final String? busIdNumber;
  final String? passengerCategory;
  final PassengerInfo? passengerInfo;
  final String? idCardType;
  final String? idCardNumber;
  final double? totalFare;

  @override
  String toString() => 'BusTicket(\n'
      'Corporation: $corporation,\n'
      'PNR Number: $pnrNumber,\n'
      'Journey Date: $journeyDate,\n'
      'Route No: $routeNo,\n'
      'Service Start Place: $serviceStartPlace,\n'
      'Service End Place: $serviceEndPlace,\n'
      'Service Start Time: $serviceStartTime,\n'
      'Passenger Start Place: $passengerStartPlace,\n'
      'Passenger End Place: $passengerEndPlace,\n'
      'Passenger Pickup Point: $passengerPickupPoint,\n'
      'Passenger Pickup Time: $passengerPickupTime,\n'
      'Platform Number: $platformNumber,\n'
      'Class of Service: $classOfService,\n'
      'Trip Code: $tripCode,\n'
      'OB Reference No: $obReferenceNumber,\n'
      'Number of Seats: $numberOfSeats,\n'
      'Bank Transaction No: $bankTransactionNumber,\n'
      'Bus ID No: $busIdNumber,\n'
      'Passenger Category: $passengerCategory,\n'
      'Passenger Info: $passengerInfo,\n'
      'ID Card Type: $idCardType,\n'
      'ID Card Number: $idCardNumber,\n'
      'Total Fare: $totalFare\n'
      ')';
}

class PassengerInfo {
  PassengerInfo({
    required this.name,
    required this.age,
    required this.type,
    required this.gender,
    required this.seatNumber,
  });
  final String name;
  final int age;
  final String type; // "Adult" or "Child"
  final String gender;
  final String seatNumber;

  @override
  String toString() => 'PassengerInfo(\n'
      'Name: $name,\n'
      'Age: $age,\n'
      'Type: $type,\n'
      'Gender: $gender,\n'
      'Seat Number: $seatNumber\n'
      ')';
}

TNSTCTicket parseTicket(String text) {
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
      final dateParts =
          parts[0].contains('/') ? parts[0].split('/') : parts[0].split('-');
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
  final serviceStartPlace =
      extractMatch(r'Service Start Place\s*:\s*(.*)', text);
  final serviceEndPlace = extractMatch(r'Service End Place\s*:\s*(.*)', text);
  final serviceStartTime =
      extractMatch(r'Service Start Time\s*:\s*(\d{2}:\d{2})', text);
  final passengerStartPlace =
      extractMatch(r'Passenger Start Place\s*:\s*(.*)', text);
  final passengerEndPlace =
      extractMatch(r'Passenger End Place\s*:\s*(.*)', text);
  final passengerPickupPoint =
      extractMatch(r'Passenger Pickup Point\s*:\s*(.*)', text);
  final passengerPickupTime = parseDateTime(
    extractMatch(
      r'Passenger Pickup Time\s*:\s*(\d{2}/\d{2}/\d{4} \d{2}:\d{2})',
      text,
    ),
  );
  final platformNumber = extractMatch(r'Platform Number\s*:\s*(\S+)', text);
  final classOfService = extractMatch(r'Class of Service\s*:\s*(.*)', text);
  final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', text);
  final obReferenceNumber =
      extractMatch(r'OB Reference No\.\s*:\s*(\S+)', text);
  final numberOfSeatsStr = extractMatch(r'No\. of Seats\s*:\s*(\d+)', text);
  final numberOfSeats =
      numberOfSeatsStr.isNotEmpty ? int.tryParse(numberOfSeatsStr) ?? 1 : 1;
  final bankTransactionNumber =
      extractMatch(r'Bank Txn\. No\.\s*:\s*(\S+)', text);
  final busIdNumber = extractMatch(r'Bus ID No\.\s*:\s*(\S+)', text);
  final passengerCategory =
      extractMatch(r'Passenger category\s*:\s*(.*)', text);
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
  final totalFare =
      totalFareStr.isNotEmpty ? double.tryParse(totalFareStr) ?? 0.0 : 0.0;

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

// void main() {
//   const ticketText = '''
// E-Ticket/Reservation Voucher-H

// Corporation :
// SETC
// PNR Number :
// T60856763
// Date of Journey :
// 10/01/2025
// Route No :
// 307ELB
// Service Start Place :
// CHENNAI-PT DR. M.G.R. BS
// Service End Place :
// KUMBAKONAM
// Service Start Time :
// 23:00
//  Hrs.
// ... (remaining text) ...
// ''';

//   final ticket = parseTicket(ticketText);
//   print('PNR Number: ${ticket.pnrNumber}');
//   print('Passenger Name: ${ticket.passengerInfo.name}');
//   print('Total Fare: ${ticket.totalFare}');
// }

// sample data
// TNSTC Corporation:SETC , PNR NO.:T63736642 , From:CHENNAI-PT DR. M.G.R.
// BS To KUMBAKONAM , Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 ,
// Time:22:35 , Seat No.:20,21, .Class:AC SLEEPER SEATER ,
// Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from
// View Ticket. Please carry your photo ID during journey. T&C apply.
