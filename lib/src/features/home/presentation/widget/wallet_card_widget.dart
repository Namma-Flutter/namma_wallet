// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/home/domain/card_model.dart';

class WalletCardWidget extends StatelessWidget {

  const WalletCardWidget({required this.card, super.key});
  final WalletCard card;

  @override
  Widget build(BuildContext context) {
    switch (card.type) {
      case 'PAY_CASH':
        return PayCashCard(card: card);
      case 'PASPOR_GOLD':
        return PasporCard(card: card);
      case 'AMEX_PLATINUM':
        return AmexCard(card: card);
      default:
        return Center(child: Text(card.name ?? 'Unknown Card'));
    }
  }
}

class PasporCard extends StatelessWidget {
  const PasporCard({
    required this.card, super.key,
  });

  final WalletCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  color: Colors.white.withAlpha(50),
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
}

class AmexCard extends StatelessWidget {
  const AmexCard({
    required this.card, super.key,
  });

  final WalletCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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

class PayCashCard extends StatelessWidget {
  const PayCashCard({
    required this.card, super.key,
  });

  final WalletCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
}
