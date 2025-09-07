import 'dart:convert';
import 'dart:io';

import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:card_stack_widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/models/tnstc_model.dart';
import 'package:namma_wallet/src/core/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/data/model/card_model.dart';
import 'package:namma_wallet/src/features/home/data/model/other_card_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widget/other_card_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widget/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/file_picker_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_service.dart';
import 'package:namma_wallet/src/features/sms_extract/application/sms_service.dart';
import 'package:namma_wallet/src/features/ticket_parser/application/tnstc_ticket_parser.dart';
import 'package:namma_wallet/src/features/ticket_view/ticket_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WalletCard> _walletCards = [];
  List<OtherCard> _otherCards = [];
  bool _isLoading = true;
  String extractedText = 'None';
  String? busTicket;

  @override
  void initState() {
    super.initState();
    _loadCardData();
    _loadOtherCardsData();
  }

  Map<String, dynamic> staticTnstcJson = {
    "corporation": "TNSTC",
    "service": "SETC",
    "pnr_no": "T63736642",
    "from": "CHENNAI-PT DR. M.G.R. BS",
    "to": "KUMBAKONAM",
    "trip_code": "2145CHEKUMAB",
    "journey_date": "11/02/2025",
    "time": "22:35",
    "seat_numbers": ["20", "21"],
    "class": "AC SLEEPER SEATER",
    "boarding_at": "KOTTIVAKKAM(RTO OFFICE)",
  };

  Future<void> onPDFExtractPressed() async {
    File? pdf = await FilePickerService().pickFile();
    if (pdf == null) {
      print('File not picked');
      return;
    }
    String text = PDFService().extractTextFrom(pdf);
    // extractedText = text;
    setState(() {});
    print(text);
    BusTicket ticket = parseTicket(text);
    print(ticket.toString());
  }

  Future<void> onSMSExtractPressed() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    String ticket = data?.text ??
        "TNSTC Corporation:SETC , PNR NO.:T60856763 , From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , Trip Code:2300CHEKUMLB , Journey Date:10/01/2025 , Time:23:55 , Seat No.:4 UB, .Class:NON AC LOWER BIRTH SEATER , Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com";

    busTicket = SMSService().parseTicket(ticket);
    debugPrint(busTicket);
    // extractedText = busTicket.toString();
    setState(() {});
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

  void _onError(BuildContext context, Object error) {
    print(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(error.toString()),
      ),
    );
  }

  void _onSuccess(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content:
              Text('Pass has been successfully added to the Google Wallet.'),
        ),
      );

  void _onCanceled(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.yellow,
          content: Text('Adding a pass has been canceled.'),
        ),
      );

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
              //* User info section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //* Date
                            Text(
                              getFormattedDate(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            //* User name
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
                        //* User avatar
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/150?img=32'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    //* Tickets section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //* Tickets heading
                        const Text(
                          'Your tickets',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        //* More button
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

              //* Top 3 card list
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
              //* Other Cards Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //* Card title
                        const Text(
                          'Other Cards',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        //* More button
                        TextButton(
                          onPressed: () {},
                          child: const Text('Show More',
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    //* More cards list view
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
              //* Action buttons section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(extractedText),
                    FloatingActionButton.extended(
                      onPressed: onSMSExtractPressed,
                      label: const Text('SMS'),
                    ),
                    FloatingActionButton.extended(
                      onPressed: onPDFExtractPressed,
                      label: const Text('PDF'),
                    ),
                    if (busTicket != null)
                      AddToGoogleWalletButton(
                        pass: busTicket!,
                        onError: (Object error) => _onError(context, error),
                        onSuccess: () => _onSuccess(context),
                        onCanceled: () => _onCanceled(context),
                      ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketView(
                                  ticket: TNSTCModel(
                                      corporation:
                                          staticTnstcJson['corporation']!,
                                      service: staticTnstcJson['service']!,
                                      pnrNo: staticTnstcJson['pnr_no']!,
                                      from: staticTnstcJson['from']!,
                                      to: staticTnstcJson['to']!,
                                      tripCode: staticTnstcJson['trip_code']!,
                                      journeyDate:
                                          staticTnstcJson['journey_date']!,
                                      time: staticTnstcJson['time']!,
                                      seatNumbers: List<String>.from(
                                          staticTnstcJson['seat_numbers']!),
                                      ticketClass: staticTnstcJson['class']!,
                                      boardingAt:
                                          staticTnstcJson['boarding_at']!)),
                            ),
                          );
                        },
                        child: const Text('TicketView'))
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
