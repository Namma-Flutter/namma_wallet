import 'dart:convert';

import 'package:card_stack_widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/core/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/data/model/card_model.dart';
import 'package:namma_wallet/src/features/home/data/model/other_card_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widget/other_card_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widget/ticket_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WalletCard> _walletCards = [];
  List<OtherCard> _otherCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCardData();
    _loadOtherCardsData();
  }

  Future<void> _loadCardData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/cards.json');
      final data = await json.decode(response) as List;
      if (!mounted) return;
      setState(() {
        _walletCards = data.map((card) => WalletCard.fromJson(card)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, "Error loading card data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOtherCardsData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/other_cards.json');
      final data = await json.decode(response) as List;
      if (!mounted) return;
      setState(() {
        _otherCards = data.map((card) => OtherCard.fromJson(card)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, "Error loading other card data: $e");
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM, dd');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    final List<CardModel> cardStackList = _walletCards.map((card) {
      return CardModel(
        backgroundColor: card.color,
        radius: const Radius.circular(20),
        shadowColor: Colors.black.withAlpha(20),
        margin: EdgeInsets.zero,
        child: WalletCardWidget(card: card),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home > Cards',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getFormattedDate(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Hello, Justin',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/150?img=32'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your tickets',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Show More',
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _walletCards.isEmpty
                      ? const Center(child: Text('No cards found.'))
                      : SizedBox(
                          height: 350,
                          child: CardStackWidget(
                            cardList: cardStackList,
                            opacityChangeOnDrag: true,
                            swipeOrientation: CardOrientation.both,
                            cardDismissOrientation: CardOrientation.both,
                            positionFactor: 3,
                            scaleFactor: 1.5,
                            alignment: Alignment.center,
                            reverseOrder: false,
                            animateCardScale: true,
                            dismissedCardDuration:
                                const Duration(milliseconds: 150),
                          ),
                        ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Other Cards',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Show More',
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _otherCards.length,
                      itemBuilder: (context, index) {
                        final card = _otherCards[index];
                        return BuildOtherCardWidget(card: card);
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
