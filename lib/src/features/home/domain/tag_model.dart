import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'tag_model.mapper.dart';

@MappableClass()
class TagModel with TagModelMappable {
  TagModel({required this.icon, required this.value});
  final String? icon;
  final String? value;

  IconData get iconData {
    switch (icon) {
      case 'confirmation_number':
        return Icons.confirmation_number;
      case 'train':
        return Icons.train;
      case 'access_time':
        return Icons.access_time;
      case 'event_seat':
        return Icons.event_seat;
      default:
        return Icons.help_outline; // fallback icon
    }
  }
}
