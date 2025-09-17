import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/common/generated/assets.gen.dart';

class TicketScannerPage extends StatelessWidget {
  const TicketScannerPage({super.key});

  static Future<void> _handleClipboardRead(BuildContext context) async {
    final clipboardService = ClipboardService();
    final result = await clipboardService.readClipboard();

    if (result.isSuccess && result.content != null) {
      debugPrint('Clipboard content: ${result.content}');
    }

    if (context.mounted) {
      clipboardService.showResultMessage(context, result);
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
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AiBarcodeScanner(
                                      overlayConfig: const ScannerOverlayConfig(
                                          borderColor: borderColor,
                                          animationColor: borderColor,
                                          cornerRadius: 30,
                                          lineThickness: 10),
                                      onDetect: (BarcodeCapture capture) {
                                        // Handle the scanned barcode
                                        // debugPrint(
                                        //     'Barcode detected: ${capture.barcodes.first.rawValue}');
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
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
                              onPressed: () async {
                                await _handleClipboardRead(context);
                              },
                              child: const Text(
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
