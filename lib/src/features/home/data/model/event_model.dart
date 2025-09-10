import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'event_model.mapper.dart';

@MappableClass()
class EventModel with EventModelMappable {
  EventModel({
    this.ticketId,
    this.eventName,
    this.eventDescription,
    this.venue,
    this.dateTime,
    this.organizerName,
    this.status,
    this.moreInfoURL,
    this.eventIcon = Icons.star_border_rounded,
  });
  @MappableField(key: 'ticket_id')
  final String? ticketId;
  @MappableField(key: 'event_name')
  final String? eventName;
  @MappableField(key: 'event_description')
  final String? eventDescription;
  @MappableField(key: 'venue')
  final String? venue;
  @MappableField(key: 'date_time')
  final DateTime? dateTime;
  @MappableField(key: 'organizer_name')
  final String? organizerName;
  @MappableField(key: 'status')
  final String? status;
  @MappableField(key: 'more_info_url')
  final String? moreInfoURL;
  @MappableField(key: 'event_icon')
  final IconData eventIcon;
}
