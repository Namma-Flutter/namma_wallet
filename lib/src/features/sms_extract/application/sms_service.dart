import 'package:namma_wallet/src/features/ticket_parser/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/ticket_parser/tnstc/application/tnstc_ticket_parser.dart' as old_parser;
import 'package:namma_wallet/src/features/ticket_parser/tnstc/domain/tnstc_model.dart';

class SMSService {
  TNSTCTicketModel parseTicket(String text) {
    // Use the dedicated SMS parser and convert to new model
    final oldTicket = TNSTCSMSParser.parseTicket(text);
    return _convertToNewModel(oldTicket);
  }

  TNSTCTicketModel _convertToNewModel(old_parser.TNSTCTicket oldTicket) {
    // Convert old TNSTCTicket to new TNSTCTicketModel
    final passengers = <PassengerInfo>[];
    if (oldTicket.passengerInfo != null) {
      passengers.add(PassengerInfo(
        name: oldTicket.passengerInfo!.name,
        age: oldTicket.passengerInfo!.age,
        type: oldTicket.passengerInfo!.type,
        gender: oldTicket.passengerInfo!.gender,
        seatNumber: oldTicket.passengerInfo!.seatNumber,
      ));
    }

    return TNSTCTicketModel(
      corporation: oldTicket.corporation,
      pnrNumber: oldTicket.pnrNumber,
      journeyDate: oldTicket.journeyDate,
      routeNo: oldTicket.routeNo,
      serviceStartPlace: oldTicket.serviceStartPlace,
      serviceEndPlace: oldTicket.serviceEndPlace,
      serviceStartTime: oldTicket.serviceStartTime,
      passengerStartPlace: oldTicket.passengerStartPlace,
      passengerEndPlace: oldTicket.passengerEndPlace,
      passengerPickupPoint: oldTicket.passengerPickupPoint,
      passengerPickupTime: oldTicket.passengerPickupTime,
      platformNumber: oldTicket.platformNumber,
      classOfService: oldTicket.classOfService,
      tripCode: oldTicket.tripCode,
      obReferenceNumber: oldTicket.obReferenceNumber,
      numberOfSeats: oldTicket.numberOfSeats,
      bankTransactionNumber: oldTicket.bankTransactionNumber,
      busIdNumber: oldTicket.busIdNumber,
      passengerCategory: oldTicket.passengerCategory,
      passengers: passengers,
      idCardType: oldTicket.idCardType,
      idCardNumber: oldTicket.idCardNumber,
      totalFare: oldTicket.totalFare,
    );
  }
}
