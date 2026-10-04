import 'package:dart_mappable/dart_mappable.dart';

part 'konfhub_ticket_model.mapper.dart';

@MappableClass()
class KonfHubTicketModel with KonfHubTicketModelMappable {
  const KonfHubTicketModel({
    this.bookingId,
    this.bookingDate,
    this.attendeeName,
    this.organization,
    this.eventName,
    this.eventDate,
    this.eventStartTime,
    this.eventEndTime,
    this.ticketName,
    this.location,
    this.additionalDetails,
    this.qrData,
  });

  final String? bookingId;
  final DateTime? bookingDate;
  final String? attendeeName;
  final String? organization;
  final String? eventName;
  final DateTime? eventDate;
  final DateTime? eventStartTime;
  final DateTime? eventEndTime;
  final String? ticketName;
  final String? location;
  final Map<String, String>? additionalDetails;
  final String? qrData;
}
