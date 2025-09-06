// Data model for our cards
import 'dart:ui';

class WalletCard {
  final String type;
  final String? name;
  final String? brand;
  final String? balance;
  final String? number;
  final Color color;

  WalletCard({
    required this.type,
    this.name,
    this.brand,
    this.balance,
    this.number,
    required this.color,
  });

  factory WalletCard.fromJson(Map<String, dynamic> json) {
    return WalletCard(
      type: json['type'],
      name: json['name'],
      brand: json['brand'],
      balance: json['balance'],
      number: json['number'],
      color: Color(int.parse(json['color'].replaceFirst('0x', ''), radix: 16)),
    );
  }
}
