import 'package:dart_mappable/dart_mappable.dart';

part 'tnstc_model.mapper.dart';

@MappableClass()
class TNSTCTicketModel with TNSTCTicketModelMappable {
  const TNSTCTicketModel({
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
    this.passengers = const [],
    this.idCardType,
    this.idCardNumber,
    this.totalFare,
    this.boardingPoint,
    this.conductorMobileNo,
    this.vehicleNumber,
    this.smsSeatNumbers,
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
  final List<PassengerInfo> passengers;
  final String? idCardType;
  final String? idCardNumber;
  final double? totalFare;
  final String? boardingPoint;
  final String? conductorMobileNo;
  final String? vehicleNumber;
  final String? smsSeatNumbers;

  @override
  String toString() {
    return '''
TNSTCTicketModel(
Corporation: $corporation,
PNR Number: $pnrNumber,
Journey Date: ${journeyDate?.toString().split(' ')[0]},
Route No: $routeNo,
Service Start Place: $serviceStartPlace,
Service End Place: $serviceEndPlace,
Service Start Time: $serviceStartTime,
Passenger Start Place: $passengerStartPlace,
Passenger End Place: $passengerEndPlace,
Passenger Pickup Point: $passengerPickupPoint,
Passenger Pickup Time: $passengerPickupTime,
Platform Number: $platformNumber,
Class of Service: $classOfService,
Trip Code: $tripCode,
OB Reference No: $obReferenceNumber,
Number of Seats: $numberOfSeats,
Bank Transaction No: $bankTransactionNumber,
Bus ID No: $busIdNumber,
Passenger Category: $passengerCategory,
Passengers: ${passengers.map((p) => p.toString()).join(', ')},
ID Card Type: $idCardType,
ID Card Number: $idCardNumber,
Total Fare: ₹$totalFare,
Boarding Point: $boardingPoint
)''';
  }

  // Convenience getters
  String get displayPnr =>
      (pnrNumber?.isNotEmpty ?? false) ? pnrNumber! : 'Unknown';
  String get displayFrom => (serviceStartPlace?.isNotEmpty ?? false)
      ? serviceStartPlace!
      : (passengerStartPlace?.isNotEmpty ?? false)
      ? passengerStartPlace!
      : 'Unknown';
  String get displayTo => (serviceEndPlace?.isNotEmpty ?? false)
      ? serviceEndPlace!
      : (passengerEndPlace?.isNotEmpty ?? false)
      ? passengerEndPlace!
      : 'Unknown';
  String get displayClass =>
      (classOfService?.isNotEmpty ?? false) ? classOfService! : 'Unknown';
  String get displayFare =>
      totalFare != null ? '₹${totalFare!.toStringAsFixed(2)}' : '₹0.00';
  String get displayDate => journeyDate != null
      ? '${journeyDate!.day.toString().padLeft(2, '0')}/${journeyDate!.month.toString().padLeft(2, '0')}/${journeyDate!.year}'
      : 'Unknown';
  String get seatNumbers {
    // If we have SMS seat numbers (from SMS parsing), use those
    if (smsSeatNumbers != null && smsSeatNumbers!.isNotEmpty) {
      return smsSeatNumbers!;
    }
    // Otherwise, extract from passenger info (from PDF parsing)
    return passengers
        .map((p) => p.seatNumber)
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}

@MappableClass()
class PassengerInfo with PassengerInfoMappable {
  const PassengerInfo({
    required this.name,
    required this.age,
    required this.type,
    required this.gender,
    required this.seatNumber,
  });
  final String name;
  final int age;
  final String type; // "Adult" or "Child"
  final String gender; // "M" or "F"
  final String seatNumber;

  @override
  String toString() {
    return 'PassengerInfo(Name: $name, Age: $age, Type: $type, '
        'Gender: $gender, Seat: $seatNumber)';
  }
}
