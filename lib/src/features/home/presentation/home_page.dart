// Home page shows the tickets saved
// Top left has profile
import 'dart:convert';

import 'package:card_stack_widget/model/card_model.dart';
import 'package:card_stack_widget/model/card_orientation.dart';
import 'package:card_stack_widget/widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/models/travel_model.dart';
import 'package:namma_wallet/src/core/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/data/model/event_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widget/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widget/wallet_card_widget.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/file_picker_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_service.dart';
import 'package:namma_wallet/src/features/sms_extract/application/sms_service.dart';
import 'package:namma_wallet/src/features/ticket_parser/application/tnstc_ticket_parser.dart';
import 'package:namma_wallet/styles/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TravelModel> _travelTickets = [];
  List<EventModel> _eventTickets = [];
  bool _isLoading = true;
  String extractedText = 'None';
  String? busTicket;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
    _loadOtherCardsData();
  }

  Map<String, dynamic> staticTnstcJson = {
    'corporation': 'TNSTC',
    'service': 'SETC',
    'pnr_no': 'T63736642',
    'from': 'CHENNAI-PT DR. M.G.R. BS',
    'to': 'KUMBAKONAM',
    'trip_code': '2145CHEKUMAB',
    'journey_date': '11/02/2025',
    'time': '22:35',
    'seat_numbers': ['20', '21'],
    'class': 'AC SLEEPER SEATER',
    'boarding_at': 'KOTTIVAKKAM(RTO OFFICE)',
  };

  Future<void> onPDFExtractPressed() async {
    final pdf = await FilePickerService().pickFile();
    if (pdf == null) {
      debugPrint('File not picked');
      return;
    }
    final text = PDFService().extractTextFrom(pdf);
    // extractedText = text;
    setState(() {});
    debugPrint(text);
    final ticket = parseTicket(text);
    debugPrint(ticket.toString());
  }

  Future<void> onSMSExtractPressed() async {
    final data = await Clipboard.getData('text/plain');
    final ticket = data?.text ??
        'TNSTC Corporation:SETC , PNR NO.:T60856763 , From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , Trip Code:2300CHEKUMLB , Journey Date:10/01/2025 , Time:23:55 , Seat No.:4 UB, .Class:NON AC LOWER BIRTH SEATER , Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com';

    busTicket = SMSService().parseTicket(ticket);
    debugPrint(busTicket);
    // extractedText = busTicket.toString();
    setState(() {});
  }

  Future<void> _loadTicketData() async {
    try {
      final response =
          await rootBundle.loadString('assets/data/mocked_tickets.json');
      final data = await json.decode(response) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _travelTickets = data
            .map((ticket) =>
                TravelModelMapper.fromMap(ticket as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, 'Error loading card data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOtherCardsData() async {
    try {
      final response = await rootBundle
          .loadString('assets/data/event_tickets_mocked_data.json');
      final data = await json.decode(response) as List;
      if (!mounted) return;
      setState(() {
        _eventTickets = data
            .map((card) =>
                EventModelMapper.fromMap(card as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, 'Error loading other card data: $e');
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM, dd');
    return formatter.format(now);
  }

  void _onError(BuildContext context, Object error) {
    debugPrint(error.toString());
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
    final cardStackList = _travelTickets.map((card) {
      return CardModel(
        radius: const Radius.circular(30),
        shadowColor: Colors.transparent,
        child: TravelTicketCard(ticket: card),
      );
      // return const SizedBox.shrink();
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userProfileWidget(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tickets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              //* Top 3 card list
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _travelTickets.isEmpty
                    ? const Center(child: Text('No cards found.'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 500,
                          child: CardStackWidget(
                            cardList: cardStackList.take(3).toList(),
                            opacityChangeOnDrag: true,
                            swipeOrientation: CardOrientation.both,
                            cardDismissOrientation: CardOrientation.both,
                            positionFactor: 3,
                            scaleFactor: 1.5,
                            alignment: Alignment.center,
                            animateCardScale: true,
                            dismissedCardDuration:
                                const Duration(milliseconds: 150),
                          ),
                        ),
                      ),

              //* Other Cards Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Event heading
                    const Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    //* More cards list view
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _eventTickets.length,
                      itemBuilder: (context, index) {
                        final event = _eventTickets[index];
                        return EventCardWidget(
                          event: event,
                        );
                      },
                    ),
                  ],
                ),
              ),
              //* Action buttons section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(extractedText),
                    const FloatingActionButton.extended(
                      // onPressed: onSMSExtractPressed,
                      onPressed: null,
                      label: Text('SMS'),
                    ),
                    // FloatingActionButton.extended(
                    //   onPressed: onPDFExtractPressed,
                    //   label: const Text('PDF'),
                    // ),
                    // if (busTicket != null)
                    //   AddToGoogleWalletButton(
                    //     pass: busTicket!,
                    //     onError: (Object error) => _onError(context, error),
                    //     onSuccess: () => _onSuccess(context),
                    //     onCanceled: () => _onCanceled(context),
                    //   ),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => TicketView(
                    //               ticket: TNSTCModel(
                    //                   corporation:
                    //                       staticTnstcJson['corporation']!,
                    //                   service: staticTnstcJson['service']!,
                    //                   pnrNo: staticTnstcJson['pnr_no']!,
                    //                   from: staticTnstcJson['from']!,
                    //                   to: staticTnstcJson['to']!,
                    //                   tripCode: staticTnstcJson['trip_code']!,
                    //                   journeyDate:
                    //                       staticTnstcJson['journey_date']!,
                    //                   time: staticTnstcJson['time']!,
                    //                   seatNumbers: List<String>.from(
                    //                       staticTnstcJson['seat_numbers']!),
                    //                   ticketClass: staticTnstcJson['class']!,
                    //                   boardingAt:
                    //                       staticTnstcJson['boarding_at']!)),
                    //         ),
                    //       );
                    //     },
                    //     child: const Text('TicketView'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userProfileWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //* Name
          const Expanded(
            child: Text(
              'Namma Wallet',
              style: TextStyle(
                  color: AppColor.blackColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          //* Profile
          CircleAvatar(
            radius: 28,
            backgroundImage: const NetworkImage(
                'https://avatars.githubusercontent.com/u/583231?v=4'),
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
