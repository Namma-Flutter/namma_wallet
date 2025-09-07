// Data model for our cards
import 'dart:ui';

import 'package:uuid/uuid.dart';

class WalletCard {
  WalletCard({
    required this.type,
    required this.color,
    this.name,
    this.brand,
    this.balance,
    this.number,
  }) : id = const Uuid().v4();

  factory WalletCard.fromJson(Map<String, dynamic> json) {
    return WalletCard(
      type: json['type'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      balance: json['balance'] as String,
      number: json['number'] as String,
      color: Color(
          int.parse(json['color'].replaceFirst('0x', '') as String, radix: 16)),
    );
  }
  final String id;
  final String type;
  final String? name;
  final String? brand;
  final String? balance;
  final String? number;
  final Color color;
}
