// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:namma_wallet/models/travel_model.dart';
import 'package:namma_wallet/src/features/home/data/model/card_model.dart';

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
    required this.card,
    super.key,
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
    required this.card,
    super.key,
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
    required this.card,
    super.key,
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

class TravelTicketCard extends StatelessWidget {
  const TravelTicketCard({required this.ticket, super.key});
  final TravelModel ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
          color: const Color(0xffE7FC57)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              //* Service profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      //* Service logo
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Image.network(
                          'https://play-lh.googleusercontent.com/RgjEO8yvEEEU7xnUkTIsK6S5VJryL_C9uyuOswyx6yspFNsUGegPfVSO6LFnlTfdlg',
                        ),
                      ),

                      //* Serive name
                      Text(
                        ticket.service,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),

                  //* Passanger count
                  HighlightChipsWidget(
                    bgColor: const Color(0xffCADC56),
                    label: ticket.seatNumbers.length.toString(),
                    icon: Icons.people_outlined,
                  ),
                ],
              ),

              //* From and To - Trip
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  //* From
                  Text(
                    ticket.from,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),

                  //* Arrow Icon
                  const Icon(Icons.arrow_forward_outlined,
                      color: Colors.black54),

                  //* To
                  Text(
                    ticket.to,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                ],
              ),

              //* Highlights
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  //* PNR no.
                  HighlightChipsWidget(
                    bgColor: const Color(0xffCADC56),
                    label: ticket.pnrNo,
                    icon: Icons.train,
                  ),

                  //* Date
                  HighlightChipsWidget(
                    bgColor: const Color(0xffCADC56),
                    label: ticket.journeyDate,
                    icon: Icons.calendar_month_outlined,
                  ),

                  //* Time
                  HighlightChipsWidget(
                    bgColor: const Color(0xffCADC56),
                    label: ticket.time,
                    icon: Icons.access_time_outlined,
                  ),
                ],
              ),
            ],
          ),

          //*  See more action button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //* See more button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'See Details',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class HighlightChipsWidget extends StatelessWidget {
  const HighlightChipsWidget(
      {required this.label, required this.bgColor, super.key, this.icon});
  final Color bgColor;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: bgColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
            ),
            if (icon != null)
              const SizedBox(
                width: 5,
              ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
