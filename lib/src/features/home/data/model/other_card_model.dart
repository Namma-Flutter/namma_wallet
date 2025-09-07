import 'package:flutter/material.dart';

class OtherCard {
  final String icon;
  final String title;
  final String subtitle;
  final String date;
  final String price;

  OtherCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.price,
  });

  factory OtherCard.fromJson(Map<String, dynamic> json) {
    return OtherCard(
      icon: json['icon'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      date: json['date'] as String,
      price: json['price'] as String,
    );
  }
}

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'local_activity':
      return Icons.local_activity;
    case 'code':
      return Icons.code;
    default:
      return Icons.help; // A default icon
  }
}
