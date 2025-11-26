import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'event_model.mapper.dart';

@MappableClass()
class Event with EventMappable {
  const Event({
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.price,
  });

  /// Icon name as string for serialization
  @MappableField(key: 'icon_name')
  final String iconName;

  @MappableField(key: 'title')
  final String title;

  @MappableField(key: 'subtitle')
  final String subtitle;

  @MappableField(key: 'date')
  final DateTime date;

  @MappableField(key: 'price')
  final String price;

  /// Get the IconData from the icon name
  IconData get icon => getIconData(iconName);

  /// Convert icon name to IconData
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'local_activity':
        return Icons.local_activity;
      case 'code':
        return Icons.code;
      case 'confirmation_number':
        return Icons.confirmation_number;
      default:
        return Icons.event;
    }
  }
}
