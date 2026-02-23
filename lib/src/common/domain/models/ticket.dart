import 'package:dart_mappable/dart_mappable.dart';
import 'package:namma_wallet/src/common/constants/string_extension.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/tag_model.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

part 'ticket.mapper.dart';

@MappableClass()
class Ticket with TicketMappable {
  ///
  const Ticket({
    this.primaryText,
    this.secondaryText,
    this.location,
    this.startTime,
    this.type,
    this.endTime,
    this.tags,
    this.extras,
    this.ticketId,
    this.imagePath,
    this.directionsUrl,
  });

  factory Ticket.fromIRCTC(
    IRCTCTicket model, {
    bool isUpdate = false,
  }) {
    // If dateOfJourney or scheduledDeparture are null,startTime will be null
    final hasValidDateTime =
        model.dateOfJourney != null && model.scheduledDeparture != null;

    final journeyDate = model.dateOfJourney;
    final departure = model.scheduledDeparture;

    /// the constants [_primaryTextConstant] used for primaryText
    /// and [__secondaryTextConstant] used for secondary
    /// are used here only for merging logic, it won't affect the user data.

    return Ticket(
      ticketId: model.pnrNumber,
      primaryText:
          (model.trainNumber.isNotNullOrEmpty &&
              model.trainName.isNotNullOrEmpty)
          ? '${model.trainNumber} - ${model.trainName}'
          : (model.trainName.isNotNullOrEmpty
                ? model.trainName
                : (model.fromStation.isNotNullOrEmpty &&
                          model.toStation.isNotNullOrEmpty
                      ? '${model.fromStation} → ${model.toStation}'
                      : _primaryTextConstant)),
      secondaryText: (() {
        if (model.trainNumber.isNotNullOrEmpty &&
            model.trainName.isNotNullOrEmpty) {
          return '${model.trainNumber} - ${model.trainName}';
        }
        if (model.trainName.isNotNullOrEmpty) return model.trainName;
        if (model.fromStation.isNotNullOrEmpty &&
            model.toStation.isNotNullOrEmpty) {
          return '${model.fromStation} → ${model.toStation}';
        }
        return _secondaryTextConstant;
      })(),
      startTime: !isUpdate && hasValidDateTime
          ? DateTime.utc(
              journeyDate!.year,
              journeyDate.month,
              journeyDate.day,
              departure!.hour,
              departure.minute,
            )
          : null,
      location: model.boardingStation,
      tags: [
        TagModel(value: model.pnrNumber, icon: 'confirmation_number'),
        if (model.trainNumber.isNotNullOrEmpty)
          TagModel(
            value: model.trainName.isNotNullOrEmpty
                ? '${model.trainNumber} - ${model.trainName}'
                : model.trainNumber,
            icon: 'train',
          ),
        if (model.travelClass != null && model.travelClass!.isNotNullOrEmpty)
          TagModel(value: model.travelClass, icon: 'event_seat'),
        if (model.status.isNotNullOrEmpty)
          TagModel(value: model.status, icon: 'info'),
        if ((model.ticketFare ?? 0) > 0)
          TagModel(
            value: '₹${model.ticketFare?.toStringAsFixed(2)}',
            icon: 'attach_money',
          ),
      ],
      type: TicketType.train,
      extras: [
        ExtrasModel(title: 'PNR Number', value: model.pnrNumber),
        ExtrasModel(title: 'Passenger', value: model.passengerName),
        ExtrasModel(title: 'Gender', value: model.gender),
        ExtrasModel(title: 'Age', value: model.age.toString()),
        ExtrasModel(title: 'Berth', value: model.seatNumber),
        ExtrasModel(title: 'Train Name', value: model.trainName),
        ExtrasModel(title: 'Quota', value: model.quota),
        ExtrasModel(
          title: 'Distance',
          value: model.distance != null ? '${model.distance} KM' : null,
        ),
        ExtrasModel(title: 'From', value: model.fromStation),
        ExtrasModel(title: 'To', value: model.toStation),
        ExtrasModel(title: 'Boarding', value: model.boardingStation),
        ExtrasModel(
          title: 'Departure',
          value: !isUpdate && departure != null
              ? DateTimeConverter.instance.formatTime(departure)
              : null,
        ),
        ExtrasModel(
          title: 'Date of Journey',
          value: !isUpdate && journeyDate != null
              ? DateTimeConverter.instance.formatDate(journeyDate)
              : null,
        ),
        ExtrasModel(title: 'Fare', value: model.ticketFare?.toStringAsFixed(2)),
        ExtrasModel(
          title: 'IRCTC Fee',
          value: model.irctcFee?.toStringAsFixed(2),
        ),
        ExtrasModel(title: 'Transaction ID', value: model.transactionId),
      ],
    );
  }

  factory Ticket.fromTNSTC(
    TNSTCTicketModel model, {
    String sourceType = 'PDF',
  }) {
    final primarySource = model.serviceStartPlace ?? model.passengerStartPlace;
    final primaryDestination = model.serviceEndPlace ?? model.passengerEndPlace;

    // Get seat numbers from either SMS field or first passenger
    final seatNumber = model.seatNumbers.isNotNullOrEmpty
        ? model.seatNumbers
        : null;

    var startTime = model.passengerPickupTime;

    // If pickup time is missing, derive from journeyDate + serviceStartTime
    if (startTime == null &&
        model.journeyDate != null &&
        model.serviceStartTime != null &&
        model.serviceStartTime!.isNotNullOrEmpty) {
      try {
        // serviceStartTime format is HH:mm or HH:mm AM/PM
        final timeParts = model.serviceStartTime!.trim().split(':');
        if (timeParts.length == 2) {
          final hourPart = timeParts[0];
          final minuteAndPeriod = timeParts[1].toLowerCase();

          var hour = int.tryParse(hourPart);
          // minuteAndPeriod might be "15 pm" or "15"
          final minuteMatch = RegExp(r'^(\d{2})').firstMatch(minuteAndPeriod);
          final minute = minuteMatch != null
              ? int.tryParse(minuteMatch.group(1)!)
              : null;

          if (hour != null && minute != null) {
            final isPm = minuteAndPeriod.contains('pm');
            final isAm = minuteAndPeriod.contains('am');

            // Validate 12-hour format: if AM/PM is present,
            // hour must be 1-12
            final isValid12HourFormat =
                !(isPm || isAm) || (hour >= 1 && hour <= 12);

            if (isValid12HourFormat) {
              if (isPm && hour < 12) {
                hour += 12;
              } else if (isAm && hour == 12) {
                hour = 0;
              }

              // Validate hour and minute ranges
              if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
                startTime = DateTime(
                  model.journeyDate!.year,
                  model.journeyDate!.month,
                  model.journeyDate!.day,
                  hour,
                  minute,
                );
              }
            }
          }
        }
      } on FormatException catch (e) {
        // Log parse failure for debugging (no PII)
        getIt<ILogger>().warning(
          '[Ticket.fromTNSTC] Failed to parse serviceStartTime: $e',
        );
      } on Exception catch (e) {
        // Log any other parsing errors (no PII)
        getIt<ILogger>().warning(
          '[Ticket.fromTNSTC] Error parsing serviceStartTime: $e',
        );
      }
    }

    startTime ??= model.journeyDate;

    /// the constants [_primaryTextConstant] used for primaryText
    /// and [__secondaryTextConstant] used for secondary
    /// are used here only for merging logic, it won't affect the user data.

    return Ticket(
      ticketId: model.pnrNumber,
      primaryText:
          primarySource.isNotNullOrEmpty && primaryDestination.isNotNullOrEmpty
          ? '$primarySource → $primaryDestination'
          : _primaryTextConstant,
      secondaryText:
          model.tripCode.isNotNullOrEmpty || model.routeNo.isNotNullOrEmpty
          ? [
              if (model.corporation.isNotNullOrEmpty) model.corporation,
              if (model.tripCode.isNotNullOrEmpty)
                model.tripCode
              else
                model.routeNo ?? 'Bus',
            ].where((s) => s != null && s.isNotEmpty).join(' - ')
          : _secondaryTextConstant,
      startTime: startTime,
      location:
          model.passengerPickupPoint ??
          model.boardingPoint ??
          model.serviceStartPlace ??
          'Unknown',
      type: TicketType.bus,

      tags: [
        if (model.tripCode != null)
          TagModel(value: model.tripCode, icon: 'confirmation_number'),
        if (model.pnrNumber.isNotNullOrEmpty)
          TagModel(value: model.pnrNumber, icon: 'qr_code'),
        if (model.serviceStartTime != null)
          TagModel(value: model.serviceStartTime, icon: 'access_time'),
        if (seatNumber != null && seatNumber.isNotNullOrEmpty)
          TagModel(value: seatNumber, icon: 'event_seat'),
        if (model.totalFare != null)
          TagModel(
            value: '₹${model.totalFare!.toStringAsFixed(2)}',
            icon: 'attach_money',
          ),
      ],

      extras: [
        if (model.pnrNumber.isNotNullOrEmpty)
          ExtrasModel(title: 'PNR Number', value: model.pnrNumber),
        if (model.passengers.isNotEmpty)
          ExtrasModel(
            title: 'Passenger',
            value: model.passengers.map((p) => p.name).join(', '),
            child: model.passengers.length == 1
                ? [
                    // Single passenger: show individual details
                    if (model.passengers.first.seatNumber != null)
                      ExtrasModel(
                        title: 'Seat',
                        value: model.passengers.first.seatNumber,
                      ),
                    if (model.passengers.first.age != null)
                      ExtrasModel(
                        title: 'Age',
                        value: model.passengers.first.age.toString(),
                      ),
                    if (model.passengers.first.gender != null)
                      ExtrasModel(
                        title: 'Gender',
                        value: model.passengers.first.gender,
                      ),
                  ]
                : [
                    // Multiple passengers: show combined details
                    ExtrasModel(
                      title: 'Ages',
                      value: model.passengers
                          .map((p) => p.age?.toString() ?? 'N/A')
                          .join(', '),
                    ),
                    ExtrasModel(
                      title: 'Genders',
                      value: model.passengers
                          .map((p) => p.gender ?? 'N/A')
                          .join(', '),
                    ),
                    ExtrasModel(
                      title: 'Seat Numbers',
                      value: model.passengers
                          .map((p) => p.seatNumber ?? 'N/A')
                          .join(', '),
                    ),
                  ],
          ),
        if (model.busIdNumber?.trim().isNotNullOrEmpty ?? false)
          ExtrasModel(title: 'Bus ID', value: model.busIdNumber!.trim()),
        if (model.vehicleNumber?.trim().isNotNullOrEmpty ?? false)
          ExtrasModel(
            title: 'Bus Number',
            value: model.vehicleNumber!.trim(),
          ),
        if (model.obReferenceNumber != null &&
            model.obReferenceNumber!.trim().isNotNullOrEmpty)
          ExtrasModel(
            title: 'Booking Ref',
            value: model.obReferenceNumber!.trim(),
          ),

        if (model.serviceStartPlace.isNotNullOrEmpty)
          ExtrasModel(title: 'From Place', value: model.serviceStartPlace),
        if (model.serviceEndPlace.isNotNullOrEmpty)
          ExtrasModel(title: 'To Place', value: model.serviceEndPlace),
        if (model.passengerStartPlace.isNotNullOrEmpty &&
            model.passengerStartPlace != model.serviceStartPlace)
          ExtrasModel(
            title: 'Passenger From',
            value: model.passengerStartPlace,
          ),
        if (model.passengerEndPlace.isNotNullOrEmpty &&
            model.passengerEndPlace != model.serviceEndPlace)
          ExtrasModel(title: 'Passenger To', value: model.passengerEndPlace),
        if (model.passengerPickupPoint.isNotNullOrEmpty)
          ExtrasModel(title: 'Pickup Point', value: model.passengerPickupPoint),

        if (model.classOfService != null &&
            model.classOfService!.trim().isNotNullOrEmpty)
          ExtrasModel(
            title: 'Service Class',
            value: model.classOfService!.trim(),
          ),
        if (model.platformNumber != null &&
            model.platformNumber!.trim().isNotNullOrEmpty)
          ExtrasModel(title: 'Platform', value: model.platformNumber!.trim()),
        if (model.passengerPickupTime != null)
          ExtrasModel(
            title: 'Pickup Time',
            value: DateTimeConverter.instance.formatTime(
              model.passengerPickupTime!,
            ),
          ),
        if (model.serviceStartTime != null &&
            model.serviceStartTime!.isNotNullOrEmpty)
          ExtrasModel(
            title: 'Departure',
            value: DateTimeConverter.instance.formatTimeString(
              model.serviceStartTime!,
            ),
          ),
        if (seatNumber != null && seatNumber.isNotNullOrEmpty)
          ExtrasModel(title: 'Seat Number', value: seatNumber),
        if (model.numberOfSeats != null)
          ExtrasModel(
            title: 'Seats',
            value: model.numberOfSeats.toString(),
          ),
        if (model.conductorMobileNo != null &&
            model.conductorMobileNo!.isNotNullOrEmpty)
          ExtrasModel(
            title: 'Conductor Contact',
            value: model.conductorMobileNo,
          ),
        if (model.totalFare != null)
          ExtrasModel(
            title: 'Fare',
            value: '₹${model.totalFare!.toStringAsFixed(2)}',
          ),
        if (model.corporation != null && model.corporation!.isNotNullOrEmpty)
          ExtrasModel(
            title: 'Provider',
            value: model.corporation,
          ),
        if (model.tripCode != null && model.tripCode!.isNotNullOrEmpty)
          ExtrasModel(title: 'Trip Code', value: model.tripCode),
        if (model.routeNo != null && model.routeNo!.trim().isNotNullOrEmpty)
          ExtrasModel(title: 'Route No', value: model.routeNo!.trim()),
        if (model.serviceStartPlace != null &&
            model.serviceStartPlace!.isNotNullOrEmpty)
          ExtrasModel(title: 'From', value: model.serviceStartPlace)
        else if (model.passengerStartPlace != null &&
            model.passengerStartPlace!.isNotNullOrEmpty)
          ExtrasModel(title: 'From', value: model.passengerStartPlace),
        if (model.serviceEndPlace != null &&
            model.serviceEndPlace!.isNotNullOrEmpty)
          ExtrasModel(title: 'To', value: model.serviceEndPlace)
        else if (model.passengerEndPlace != null &&
            model.passengerEndPlace!.isNotNullOrEmpty)
          ExtrasModel(title: 'To', value: model.passengerEndPlace),
        ExtrasModel(title: 'Source Type', value: sourceType),
      ],
    );
  }

  factory Ticket.mergeTickets(Ticket existing, Ticket incoming) {
    return Ticket(
      ticketId: existing.ticketId,

      primaryText:
          (!incoming.primaryText.isNotNullOrEmpty ||
              incoming.primaryText == _primaryTextConstant)
          ? existing.primaryText
          : incoming.primaryText,

      secondaryText:
          (!incoming.secondaryText.isNotNullOrEmpty ||
              incoming.secondaryText == _secondaryTextConstant)
          ? existing.secondaryText
          : incoming.secondaryText,

      location: (incoming.location?.trim().isNotNullOrEmpty ?? false)
          ? incoming.location
          : existing.location,

      startTime: (incoming.startTime == null)
          ? existing.startTime
          : incoming.startTime,

      endTime: (incoming.endTime == null) ? existing.endTime : incoming.endTime,

      type: incoming.type,

      tags: _mergeTags(existing.tags, incoming.tags),
      extras: _mergeExtras(existing.extras, incoming.extras),
      imagePath: incoming.imagePath ?? existing.imagePath,
      directionsUrl: incoming.directionsUrl ?? existing.directionsUrl,
    );
  }

  /// Sentinel value for merge logic only. Never use as a parsing fallback.
  static const _primaryTextConstant = 'Unknown → Unknown';

  /// Sentinel value for merge logic only. Never use as a parsing fallback.
  static const _secondaryTextConstant = 'N/A';

  /// Merges Extras (Key-Value pairs).
  /// Strategy: Convert old list to Map. Overwrite only if new value is valid.
  static List<ExtrasModel>? _mergeExtras(
    List<ExtrasModel>? current,
    List<ExtrasModel>? incoming,
  ) {
    if (current == null && incoming == null) return null;
    if (incoming == null || incoming.isEmpty) return current;
    if (current == null || current.isEmpty) return incoming;

    final mergedMap = <String, ExtrasModel>{
      for (final item in current)
        if ((item.title ?? '').trim().isNotNullOrEmpty)
          item.title!.trim(): item,
    };

    for (final newItem in incoming) {
      final title = (newItem.title ?? '').trim();
      if (title.isEmpty) continue;

      final value = newItem.value?.trim();
      final hasValue = value != null && value.isNotNullOrEmpty;

      if (hasValue) {
        mergedMap[title] = newItem;
      }
    }

    return mergedMap.values.toList();
  }

  /// Merges Tags (Icons/Chips).
  /// Strategy: Update tags with same Icon, Add new tags, Keep old unique tags.
  static List<TagModel>? _mergeTags(
    List<TagModel>? current,
    List<TagModel>? incoming,
  ) {
    if (current == null && incoming == null) return null;
    if (incoming == null || incoming.isEmpty) return current;
    if (current == null || current.isEmpty) return incoming;

    final result = List<TagModel>.from(current);

    for (final newTag in incoming) {
      if (newTag.value == null || newTag.value!.trim().isEmpty) continue;
      final existingIndex = result.indexWhere((t) => t.icon == newTag.icon);

      if (existingIndex != -1) {
        result[existingIndex] = newTag;
      } else {
        result.add(newTag);
      }
    }

    return result;
  }

  @MappableField(key: 'ticket_id')
  final String? ticketId;
  @MappableField(key: 'primary_text')
  final String? primaryText;
  @MappableField(key: 'secondary_text')
  final String? secondaryText;
  @MappableField(key: 'type')
  final TicketType? type;
  @MappableField(key: 'start_time')
  final DateTime? startTime;
  @MappableField(key: 'end_time')
  final DateTime? endTime;
  @MappableField(key: 'location')
  final String? location;
  @MappableField(key: 'tags')
  final List<TagModel>? tags;
  @MappableField(key: 'extras')
  final List<ExtrasModel>? extras;
  @MappableField(key: 'image_path')
  final String? imagePath;
  @MappableField(key: 'directions_url')
  final String? directionsUrl;

  Map<String, Object?> toEntity() {
    final map = toMap()..removeWhere((key, value) => value == null);
    if (ticketId == null) map.remove('id');
    return map;
  }

  static Ticket asExternalModel(Map<String, dynamic> json) {
    return TicketMapper.fromMap(json);
  }
}
