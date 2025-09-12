// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:namma_wallet/models/tnstc_model.dart' show TNSTCModel;

enum EntryType { event, busTicket, trainTicket, none }

class GenericDetailsModel {
  final String primaryText;
  final String secondaryText;
  final EntryType type;
  final DateTime startTime;
  final DateTime? endTime;
  final String location;
  final Extras? extras;
  final List<Tags>? tags;
  GenericDetailsModel(
      {required this.primaryText,
      required this.secondaryText,
      required this.startTime,
      required this.location,
      this.type = EntryType.none,
      this.endTime,
      this.tags,
      this.extras});

  GenericDetailsModel.fromTrainTicket(TNSTCModel ticket)
      : primaryText = 'ticket.pnrNo',
        secondaryText = '${ticket.from} → ${ticket.to}',
        startTime = DateTime.parse(ticket.journeyDate),
        endTime = DateTime.parse(ticket.journeyDate), //todo: + duration
        location = ticket.boardingAt,
        type = EntryType.trainTicket,
        tags=[  
          Tags(value: ticket.tripCode, icon: Icons.confirmation_number),
          Tags(value: ticket.pnrNo, icon: Icons.train),
          Tags(value: ticket.time, icon: Icons.access_time),
          Tags(value: ticket.seatNumbers.join(' | '), icon: Icons.event_seat),
        ],
        extras = null; // to be filled by all the other details

  GenericDetailsModel.fromJson(Map<String, dynamic> json)
      : primaryText = json['primaryText'] as String,
        secondaryText = json['secondaryText'] as String,
        startTime = DateTime.parse(json['startTime'] as String),
        endTime = json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        location = json['location'] as String,
        type = switch (json['type'] as String) {
          'event' => EntryType.event,
          'busTicket' => EntryType.busTicket,
          'trainTicket' => EntryType.trainTicket,
          _ => EntryType.none,
        },
        tags = json['tags'] != null
            ? (json['tags'] as List)
                .map((e) => Tags.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        extras = json['extras'] != null
            ? Extras.fromJson(json['extras'] as Map<String, dynamic>)
            : null;
}

class Tags {
  Tags({required this.value, this.icon});
  final IconData? icon; 
  final String value;

  Tags.fromJson(Map<String, dynamic> json)
      : icon = switch (json['icon']) {
          'location' => Icons.location_on,
          'duration' => Icons.access_time,
          // add here more icons as needed 
          // user IconData custom icons 
          _ => null,
        },
        value = json['value'] as String;
}

class Extras {
  final String? title;
  final String value;
  final List<Extras>? child;
  Extras({
    required this.value,
    this.child,
    this.title,
  });
  Extras.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String?,
        value = json['value'] as String,
        child = json['child'] != null
            ? (json['child'] as List)
                .map((e) => Extras.fromJson(e as Map<String, dynamic>))
                .toList()
            : null;
}
