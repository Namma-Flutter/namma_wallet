import 'dart:io';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_parser_service.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  bool _isPasting = false;
  bool _isScanning = false;
  bool _isProcessingPDF = false;

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

  Future<void> _handlePDFPick() async {
    if (_isProcessingPDF) return;

    setState(() {
      _isProcessingPDF = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final pdfParserService = PDFParserService();
        final parseResult = await pdfParserService.parseAndSavePDFTicket(file);

        if (!mounted) return;
        pdfParserService.showResultMessage(context, parseResult);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPDF = false;
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
    final borderColor = Theme.of(context).colorScheme.primary;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final pickFileContainerWidth = MediaQuery.of(context).size.width > 500
        ? 400.0
        : MediaQuery.of(context).size.width - 80;
    return Scaffold(
      body: SafeArea(
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
                        height:
                            MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 120
                            : 40,
                      ),
                      GestureDetector(
                        onTap: _isProcessingPDF ? null : _handlePDFPick,
                        child: SizedBox(
                          height: pickFileContainerWidth,
                          width: pickFileContainerWidth,
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: const [5, 12],
                              strokeWidth: 8,
                              padding: const EdgeInsets.all(16),
                              radius: const Radius.circular(24),
                              color: borderColor,
                            ),
                            child: Center(
                              child: _isProcessingPDF
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: borderColor,
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Processing PDF...',
                                          style: TextStyle(
                                            color: textColor.withAlpha(180),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          size: 90,
                                          color: textColor.withAlpha(180),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Upload PDF Here',
                                          style: TextStyle(
                                            color: textColor.withAlpha(180),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 42,
                      ),
                      SizedBox(
                        width: 141,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () {
                            context.pushNamed(
                              AppRoute.barcodeScanner.name,
                              extra: (BarcodeCapture capture) async {
                                // Check if barcodes list is not empty
                                if (capture.barcodes.isEmpty) {
                                  context.pop();
                                  return;
                                }

                                // Handle the scanned barcode
                                final qrData = capture.barcodes.first.rawValue;

                                // Check if rawValue is non-null
                                if (qrData == null) {
                                  context.pop();
                                  return;
                                }

                                context.pop();
                                await _handleQRCodeScan(qrData);
                              },
                            );
                          },
                          child: const Text(
                            'Scan QR Code',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 141,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _isPasting ? null : _handleClipboardRead,
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
