import 'package:dart_mappable/dart_mappable.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

part 'ticket.mapper.dart';

@MappableClass()
class Ticket with TicketMappable {
  ///
  const Ticket({
    required this.primaryText,
    required this.secondaryText,
    required this.startTime,
    required this.location,
    this.type = TicketType.train,
    this.endTime,
    this.tags,
    this.extras,
    this.ticketId,
  });

  factory Ticket.fromIRCTC(IRCTCTicket model) {
    return Ticket(
      ticketId: int.tryParse(model.pnrNumber),
      primaryText: '${model.fromStation} → ${model.toStation}',
      secondaryText:
          'Train ${model.trainNumber} • ${model.travelClass} • '
          '${model.passengerName}',
      startTime: DateTime(
        model.dateOfJourney.year,
        model.dateOfJourney.month,
        model.dateOfJourney.day,
        model.scheduledDeparture.hour,
        model.scheduledDeparture.minute,
      ),
      location: model.boardingStation,
      tags: [
        TagModel(value: model.pnrNumber, icon: 'confirmation_number'),
        if (model.trainNumber.isNotEmpty)
          TagModel(value: model.trainNumber, icon: 'train'),
        if (model.travelClass.isNotEmpty)
          TagModel(value: model.travelClass, icon: 'event_seat'),
        if (model.status.isNotEmpty)
          TagModel(value: model.status, icon: 'info'),
        if (model.ticketFare > 0)
          TagModel(
            value: '₹${model.ticketFare.toStringAsFixed(2)}',
            icon: 'attach_money',
          ),
      ],
      extras: [
        ExtrasModel(title: 'Passenger', value: model.passengerName),
        ExtrasModel(title: 'Gender', value: model.gender),
        ExtrasModel(title: 'Age', value: model.age.toString()),
        ExtrasModel(title: 'Train Name', value: model.trainName),
        ExtrasModel(title: 'Quota', value: model.quota),
        ExtrasModel(title: 'From', value: model.fromStation),
        ExtrasModel(title: 'To', value: model.toStation),
        ExtrasModel(title: 'Boarding', value: model.boardingStation),
        ExtrasModel(
          title: 'Departure',
          value:
              '${model.scheduledDeparture.hour.toString().padLeft(2, '0')}'
              ':${model.scheduledDeparture.minute.toString().padLeft(2, '0')}',
        ),
        ExtrasModel(
          title: 'Date of Journey',
          value:
              '${model.dateOfJourney.year}-${model.dateOfJourney.month.toString().padLeft(2, '0')}-${model.dateOfJourney.day.toString().padLeft(2, '0')}',
        ),
        ExtrasModel(title: 'Fare', value: model.ticketFare.toStringAsFixed(2)),
        ExtrasModel(
          title: 'IRCTC Fee',
          value: model.irctcFee.toStringAsFixed(2),
        ),
        ExtrasModel(title: 'Transaction ID', value: model.transactionId),
      ],
    );
  }

  factory Ticket.fromTNSTC(TNSTCTicketModel model) {
    final primarySource =
        model.serviceStartPlace ?? model.passengerStartPlace ?? 'Unknown';
    final primaryDestination =
        model.serviceEndPlace ?? model.passengerEndPlace ?? 'Unknown';

    // Use first passenger for display if available
    final firstPassenger = model.passengers.isNotEmpty
        ? model.passengers.first
        : null;
    final seatNumber = firstPassenger?.seatNumber;
    final gender = firstPassenger?.gender;

    return Ticket(
      ticketId: int.tryParse(model.pnrNumber ?? ''),
      primaryText: '$primarySource → $primaryDestination',
      secondaryText:
          '${model.corporation ?? 'TNSTC'} - '
          '${model.tripCode ?? model.routeNo ?? 'Bus'}',
      startTime: model.journeyDate ?? DateTime.now(),
      location:
          model.passengerPickupPoint ??
          model.boardingPoint ??
          model.serviceStartPlace ??
          'Unknown',
      type: TicketType.bus,

      tags: [
        if (model.tripCode != null)
          TagModel(value: model.tripCode, icon: 'confirmation_number'),
        if (model.pnrNumber?.isNotEmpty ?? false)
          TagModel(value: model.pnrNumber, icon: 'qr_code'),
        if (model.serviceStartTime != null)
          TagModel(value: model.serviceStartTime, icon: 'access_time'),
        if (seatNumber != null && seatNumber.isNotEmpty)
          TagModel(value: seatNumber, icon: 'event_seat'),
        if (model.totalFare != null)
          TagModel(
            value: '₹${model.totalFare!.toStringAsFixed(2)}',
            icon: 'attach_money',
          ),
      ],

      extras: [
        if (firstPassenger != null)
          ExtrasModel(title: 'Passenger Name', value: firstPassenger.name),
        if (firstPassenger?.age != null)
          ExtrasModel(title: 'Age', value: firstPassenger!.age.toString()),
        if (gender != null && gender.isNotEmpty)
          ExtrasModel(title: 'Gender', value: gender),
        if (model.busIdNumber != null)
          ExtrasModel(title: 'Bus Number', value: model.busIdNumber!),
        if (model.vehicleNumber != null)
          ExtrasModel(title: 'Vehicle Number', value: model.vehicleNumber!),
        if (model.obReferenceNumber != null)
          ExtrasModel(title: 'Booking Ref', value: model.obReferenceNumber!),
        if (model.classOfService != null)
          ExtrasModel(title: 'Service Class', value: model.classOfService!),
        if (model.platformNumber != null)
          ExtrasModel(title: 'Platform', value: model.platformNumber!),
        if (model.passengerPickupTime != null)
          ExtrasModel(
            title: 'Pickup Time',
            value: model.passengerPickupTime.toString(),
          ),
        if (model.serviceStartTime != null)
          ExtrasModel(title: 'Departure Time', value: model.serviceStartTime!),
        if (model.numberOfSeats != null)
          ExtrasModel(
            title: 'Seats',
            value: model.numberOfSeats.toString(),
          ),
        if (model.idCardType != null && model.idCardNumber != null)
          ExtrasModel(
            title: 'ID',
            value: '${model.idCardType}: ${model.idCardNumber}',
          ),
        if (model.conductorMobileNo != null)
          ExtrasModel(
            title: 'Conductor Contact',
            value: model.conductorMobileNo!,
          ),
        if (model.totalFare != null)
          ExtrasModel(
            title: 'Fare',
            value: '₹${model.totalFare!.toStringAsFixed(2)}',
          ),
      ],
    );
  }

  @MappableField(key: 'id')
  final int? ticketId;
  @MappableField(key: 'primary_text')
  final String primaryText;
  @MappableField(key: 'secondary_text')
  final String secondaryText;
  @MappableField(key: 'type')
  final TicketType type;
  @MappableField(key: 'start_time')
  final DateTime startTime;
  @MappableField(key: 'end_time')
  final DateTime? endTime;
  @MappableField(key: 'location')
  final String location;
  @MappableField(key: 'tags')
  final List<TagModel>? tags;
  @MappableField(key: 'extras')
  final List<ExtrasModel>? extras;

  Map<String, Object?> toEntity() {
    final map = toMap()..removeWhere((key, value) => value == null);
    if (ticketId == null) map.remove('id');
    return map;
  }

  Ticket asExternalModel(Map<String, dynamic> json) {
    final ticket = TicketMapper.fromMap(json);
    return ticket;
  }
}
