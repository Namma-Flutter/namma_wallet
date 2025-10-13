import 'package:flutter/material.dart';

class Event {
  Event({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.price,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime date;
  final String price;

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'local_activity':
        return Icons.local_activity;
      case 'code':
        return Icons.code;
      default:
        return Icons.event;
    }
  }
}