// ignore_for_file: public_member_api_docs


import 'package:namma_wallet/models/tnstc_model.dart' show TNSTCModel;

enum Type { event, busTicket, trainTicket, generic,none}

class GenericDetailsModel {
 final String primaryText;
 final String secondaryText;
 final DateTime startTime;
 final DateTime? endTime;
 final String location;
 final Type type;
 final Map<String,dynamic>?extras;
   GenericDetailsModel({
    required this.primaryText,
    required this.secondaryText,
    required this.startTime,
    required this.location,
     this.type=Type.none,
    this.endTime,
    this.extras
  });

  GenericDetailsModel.fromTrainTicket(TNSTCModel ticket):
    primaryText='${ticket.from} → ${ticket.to}',
    secondaryText='${ticket.corporation} → ${ticket.service}',
    startTime=DateTime.parse(ticket.journeyDate),
    endTime=DateTime.parse(ticket.journeyDate),  // + duration
    location=ticket.boardingAt,
    type=Type.trainTicket,
    extras={}; // to be fixed
}
