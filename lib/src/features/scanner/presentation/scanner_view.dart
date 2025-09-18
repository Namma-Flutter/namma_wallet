import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/core/routing/app_routes.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/common/generated/assets.gen.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';

class TicketScannerPage extends StatefulWidget {
  const TicketScannerPage({super.key});

  @override
  State<TicketScannerPage> createState() => _TicketScannerPageState();
}

class _TicketScannerPageState extends State<TicketScannerPage> {
  bool _isPasting = false;
  bool _isScanning = false;

  Future<void> _handleQRCodeScan(String qrData) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // Check if it's an IRCTC QR code
      if (IRCTCQRParser.isIRCTCQRCode(qrData)) {
        final irctcService = IRCTCScannerService();
        final result = await irctcService.parseAndSaveIRCTCTicket(qrData);

        if (!mounted) return;
        irctcService.showResultMessage(context, result);
      } else {
        // Handle other QR code types here if needed
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code format not supported'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _handleClipboardRead() async {
    if (_isPasting) return;

    setState(() {
      _isPasting = true;
    });

    try {
      final clipboardService = ClipboardService();
      final result = await clipboardService.readClipboard();

      if (!mounted) return;

      clipboardService.showResultMessage(context, result);
    } finally {
      if (mounted) {
        setState(() {
          _isPasting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromARGB(255, 231, 252, 85);
    const backgroundColor = Color.fromARGB(255, 33, 33, 35);
    final pickFileContainerWidth = MediaQuery.of(context).size.width > 500
        ? 400.0
        : MediaQuery.of(context).size.width - 80;
    return Material(
        color: backgroundColor,
        child: SafeArea(
          child: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 120
                              : 40,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await FilePicker.platform.pickFiles();
                          },
                          child: SizedBox(
                              height: pickFileContainerWidth,
                              width: pickFileContainerWidth,
                              child: DottedBorder(
                                options: const RoundedRectDottedBorderOptions(
                                  dashPattern: [5, 12],
                                  strokeWidth: 8,
                                  padding: EdgeInsets.all(16),
                                  radius: Radius.circular(24),
                                  color: borderColor,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_file,
                                        size: 90,
                                        color: Colors.white.withAlpha(145),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Upload Here',
                                        style: TextStyle(
                                            color: Colors.white.withAlpha(145),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 42,
                        ),
                        SizedBox(
                          width: 141,
                          height: 42,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  shape: const StadiumBorder()),
                              onPressed: () {
                                context.pushNamed(
                                  AppRoute.barcodeScanner.name,
                                  extra: (BarcodeCapture capture) async {
                                    // Handle the scanned barcode
                                    final qrData =
                                        capture.barcodes.first.rawValue;
                                    context.pop();
                                    if (qrData != null) {
                                      await _handleQRCodeScan(qrData);
                                    }
                                  },
                                );
                              },
                              child: const Text(
                                'Scan was better',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              )),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 141,
                          height: 42,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  shape: const StadiumBorder()),
                              onPressed:
                                  _isPasting ? null : _handleClipboardRead,
                              child: _isPasting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Read Clipboard',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(Assets.images.bottomCurve),
                ],
              ),
            ),
          ),
        ));
  }
}
