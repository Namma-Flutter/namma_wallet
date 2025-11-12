import 'dart:convert';

import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

Future<void> checkAndUpdateTNSTCTicket(TNSTCTicketModel ticket) async {
  final db = getIt<WalletDatabase>();

  if (ticket.pnrNumber == null) {
    return;
  }

  final existingTicket = await db.getTravelTicketByPNR(
    ticket.pnrNumber!,
  );

  if (existingTicket != null) {
    final updates = <String, Object?>{};
    if (ticket.busIdNumber?.isNotEmpty ?? false) {
      updates['trip_code'] = ticket.busIdNumber;
    }
    if (ticket.conductorMobileNo?.isNotEmpty ?? false) {
      updates['contact_mobile'] = ticket.conductorMobileNo;
    }

    if (updates.isNotEmpty) {
      await db.updateTravelTicketByPNR(ticket.pnrNumber!, updates);
    }
  } else {
    await db.insertTravelTicket(_mapTNSTCToTravelTicket(ticket));
  }
}

Map<String, Object?> _mapTNSTCToTravelTicket(TNSTCTicketModel ticket) {
  // Convert passengers list to JSON string and store in raw_data
  final passengersData = jsonEncode(
    ticket.passengers.map((p) => {
      'name': p.name,
      'age': p.age,
      'type': p.type,
      'gender': p.gender,
      'seatNumber': p.seatNumber,
    }).toList(),
  );

  return {
    'ticket_type': 'BUS',
    'provider_name': ticket.corporation ?? 'TNSTC',
    'booking_reference': ticket.obReferenceNumber,
    'pnr_number': ticket.pnrNumber,
    'trip_code': ticket.busIdNumber ?? ticket.tripCode,
    'source_location':
        ticket.serviceStartPlace ?? ticket.passengerStartPlace,
    'destination_location':
        ticket.serviceEndPlace ?? ticket.passengerEndPlace,
    'journey_date': ticket.journeyDate?.toIso8601String().split('T').first,
    'journey_time': ticket.serviceStartTime,
    'departure_time': ticket.serviceStartTime,
    'passenger_name':
        ticket.passengers.isNotEmpty ? ticket.passengers.first.name : null,
    'passenger_age':
        ticket.passengers.isNotEmpty ? ticket.passengers.first.age : null,
    'passenger_gender':
        ticket.passengers.isNotEmpty ? ticket.passengers.first.gender : null,
    'seat_numbers': ticket.passengers.map((p) => p.seatNumber).join(', '),
    'coach_number': ticket.platformNumber,
    'class_of_service': ticket.classOfService,
    'amount': ticket.totalFare,
    'currency': 'INR',
    'status': 'CONFIRMED',
    'boarding_point': ticket.boardingPoint ?? ticket.passengerPickupPoint,
    'pickup_location': ticket.passengerPickupPoint,
    'contact_mobile': ticket.conductorMobileNo,
    'source_type': 'SMS',
    'raw_data': jsonEncode({
      'corporation': ticket.corporation,
      'pnrNumber': ticket.pnrNumber,
      'journeyDate': ticket.journeyDate?.toIso8601String(),
      'routeNo': ticket.routeNo,
      'serviceStartPlace': ticket.serviceStartPlace,
      'serviceEndPlace': ticket.serviceEndPlace,
      'serviceStartTime': ticket.serviceStartTime,
      'passengerStartPlace': ticket.passengerStartPlace,
      'passengerEndPlace': ticket.passengerEndPlace,
      'passengerPickupPoint': ticket.passengerPickupPoint,
      'passengerPickupTime': ticket.passengerPickupTime?.toIso8601String(),
      'platformNumber': ticket.platformNumber,
      'classOfService': ticket.classOfService,
      'tripCode': ticket.tripCode,
      'obReferenceNumber': ticket.obReferenceNumber,
      'numberOfSeats': ticket.numberOfSeats,
      'bankTransactionNumber': ticket.bankTransactionNumber,
      'busIdNumber': ticket.busIdNumber,
      'passengerCategory': ticket.passengerCategory,
      'passengers_data': passengersData,
      'idCardType': ticket.idCardType,
      'idCardNumber': ticket.idCardNumber,
      'totalFare': ticket.totalFare,
      'boardingPoint': ticket.boardingPoint,
      'conductorMobileNo': ticket.conductorMobileNo,
      'vehicleNumber': ticket.vehicleNumber,
    }),
  };
}
