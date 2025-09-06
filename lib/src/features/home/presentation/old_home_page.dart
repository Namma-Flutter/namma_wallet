// Home page shows the tickets saved
// Top left has profile
import 'dart:io';

import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/file_picker_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_service.dart';
import 'package:namma_wallet/src/features/sms_extract/application/sms_service.dart';
import 'package:namma_wallet/src/features/ticket_parser/application/tnstc_ticket_parser.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String extractedText = 'None';
  String? busTicket;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
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
}
