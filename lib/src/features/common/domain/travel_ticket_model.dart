import 'package:dart_mappable/dart_mappable.dart';

part 'travel_ticket_model.mapper.dart';

@MappableEnum()
enum TicketType {
  @MappableValue('BUS')
  bus,
  @MappableValue('TRAIN')
  train,
  @MappableValue('EVENT')
  event,
  @MappableValue('FLIGHT')
  flight,
  @MappableValue('METRO')
  metro,
}

@MappableEnum()
enum TicketStatus {
  @MappableValue('CONFIRMED')
  confirmed,
  @MappableValue('CANCELLED')
  cancelled,
  @MappableValue('PENDING')
  pending,
  @MappableValue('COMPLETED')
  completed,
}

@MappableEnum()
enum SourceType {
  @MappableValue('SMS')
  sms,
  @MappableValue('PDF')
  pdf,
  @MappableValue('MANUAL')
  manual,
  @MappableValue('CLIPBOARD')
  clipboard,
  @MappableValue('QR')
  qr,
  @MappableValue('SCANNER')
  scanner,
}

@MappableClass()
class TravelTicketModel with TravelTicketModelMappable {
  const TravelTicketModel({
    required this.ticketType,
    required this.providerName,
    this.id,
    this.userId = 1,
    this.bookingReference,
    this.pnrNumber,
    this.tripCode,
    this.sourceLocation,
    this.destinationLocation,
    this.journeyDate,
    this.journeyTime,
    this.departureTime,
    this.arrivalTime,
    this.passengerName,
    this.passengerAge,
    this.passengerGender,
    this.seatNumbers,
    this.coachNumber,
    this.classOfService,
    this.bookingDate,
    this.amount,
    this.currency = 'INR',
    this.status = TicketStatus.confirmed,
    this.boardingPoint,
    this.pickupLocation,
    this.eventName,
    this.venueName,
    this.contactMobile,
    this.sourceType = SourceType.manual,
    this.rawData,
    this.createdAt,
    this.updatedAt,
  });

  @MappableField(key: 'id')
  final int? id;

  @MappableField(key: 'user_id')
  final int userId;

  @MappableField(key: 'ticket_type')
  final TicketType ticketType;

  @MappableField(key: 'provider_name')
  final String providerName;

  @MappableField(key: 'booking_reference')
  final String? bookingReference;

  @MappableField(key: 'pnr_number')
  final String? pnrNumber;

  @MappableField(key: 'trip_code')
  final String? tripCode;

  @MappableField(key: 'source_location')
  final String? sourceLocation;

  @MappableField(key: 'destination_location')
  final String? destinationLocation;

  @MappableField(key: 'journey_date')
  final String? journeyDate;

  @MappableField(key: 'journey_time')
  final String? journeyTime;

  @MappableField(key: 'departure_time')
  final String? departureTime;

  @MappableField(key: 'arrival_time')
  final String? arrivalTime;

  @MappableField(key: 'passenger_name')
  final String? passengerName;

  @MappableField(key: 'passenger_age')
  final int? passengerAge;

  @MappableField(key: 'passenger_gender')
  final String? passengerGender;

  @MappableField(key: 'seat_numbers')
  final String? seatNumbers;

  @MappableField(key: 'coach_number')
  final String? coachNumber;

  @MappableField(key: 'class_of_service')
  final String? classOfService;

  @MappableField(key: 'booking_date')
  final String? bookingDate;

  @MappableField(key: 'amount')
  final double? amount;

  @MappableField(key: 'currency')
  final String currency;

  @MappableField(key: 'status')
  final TicketStatus status;

  @MappableField(key: 'boarding_point')
  final String? boardingPoint;

  @MappableField(key: 'pickup_location')
  final String? pickupLocation;

  @MappableField(key: 'event_name')
  final String? eventName;

  @MappableField(key: 'venue_name')
  final String? venueName;

  @MappableField(key: 'contact_mobile')
  final String? contactMobile;

  @MappableField(key: 'source_type')
  final SourceType sourceType;

  @MappableField(key: 'raw_data')
  final String? rawData;

  @MappableField(key: 'created_at')
  final String? createdAt;

  @MappableField(key: 'updated_at')
  final String? updatedAt;

  // Helper methods
  List<String> get seatNumbersList {
    if (seatNumbers == null || seatNumbers!.isEmpty) return [];
    return seatNumbers!.split(',').map((s) => s.trim()).toList();
  }

  String get displayName {
    if (ticketType == TicketType.event) {
      return eventName ?? 'Event Ticket';
    }
    if (sourceLocation != null && destinationLocation != null) {
      return '$sourceLocation → $destinationLocation';
    }
    return providerName;
  }

  String get displayDate {
    if (journeyDate != null) {
      try {
        final date = DateTime.parse(journeyDate!);
        return '${date.day}/${date.month}/${date.year}';
      } on Object catch (_) {
        return journeyDate!;
      }
    }
    return '';
  }

  String get displayTime {
    return departureTime ?? journeyTime ?? '';
  }

  bool get isPastTravel {
    if (journeyDate == null) return false;
    try {
      final date = DateTime.parse(journeyDate!);
      return date.isBefore(DateTime.now());
    } on Object catch (_) {
      return false;
    }
  }

  Map<String, Object?> toDatabase() {
    final map = toMap()
      // Remove null values and the id field for inserts
      ..removeWhere((key, value) => value == null);
    if (id == null) map.remove('id');
    return map;
  }
}
