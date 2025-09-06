
// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/home/data/model/card_model.dart';

class WalletCardWidget extends StatelessWidget {
  final WalletCard card;

  const WalletCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    switch (card.type) {
      case 'PAY_CASH':
        return _buildPayCashCard();
      case 'PASPOR_GOLD':
        return _buildPasporCard();
      case 'AMEX_PLATINUM':
        return _buildAmexCard();
      default:
        return Center(child: Text(card.name ?? 'Unknown Card'));
    }
  }

  Widget _buildPayCashCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: 400,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.apple, color: Colors.white, size: 28),
                  const SizedBox(width: 20),
                  Text(card.name!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              Text(
                card.balance!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            card.number!,
            style: const TextStyle(
                color: Colors.white70, fontSize: 18, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPasporCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: 400,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.name!,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.brand!,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          // Empty row to push content to top and bottom
          const Row(),
        ],
      ),
    );
  }

  Widget _buildAmexCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: 400,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.name!,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              Text(
                card.brand!,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // Empty row to push content to top and bottom
          const Row(),
        ],
      ),
    );
  }
}
