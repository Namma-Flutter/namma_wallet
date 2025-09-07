import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/home/data/model/other_card_model.dart';

class BuildTicketCardWidget extends StatelessWidget {
  const BuildTicketCardWidget({
    super.key,
    required this.card,
  });

  final OtherCard card;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(getIconData(card.icon), color: Colors.blue),
      title: Text(card.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.subtitle),
          const SizedBox(height: 4),
          Text(card.date, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(card.price, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      onTap: () {},
    );
  }
}
