import 'dart:async';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service_interface.dart';
import 'package:namma_wallet/src/features/clipboard/presentation/clipboard_result_handler.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';

class ImportView extends StatefulWidget {
  const ImportView({super.key});

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> {
  late final IImportService _importService = getIt<IImportService>();
  late final ILogger _logger = getIt<ILogger>();
  bool _isPasting = false;
  bool _isScanning = false;
  bool _isProcessingPDF = false;
  bool _isOpeningScanner = false;

  Future<void> _handleQRCodeScan(String qrData) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    getIt<IHapticService>().triggerHaptic(
      HapticType.selection,
    );

    try {
      // Use import service to handle QR code
      final ticket = await _importService.importQRCode(qrData);

      if (!mounted) return;

      if (ticket != null) {
        await NotificationService().scheduleTicketReminderFor(ticket);
        if (mounted) {
          showSnackbar(
            context,
            'QR ticket imported successfully!',
          );
        }
      } else {
        showSnackbar(
          context,
          'QR code format not supported',
          isError: true,
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

  Future<void> _onBarcodeCaptured(BarcodeCapture capture) async {
    // Check if barcodes list is not empty
    if (capture.barcodes.isEmpty) {
      if (!mounted) return;
      context.pop();
      return;
    }

    // Handle the scanned barcode
    final qrData = capture.barcodes.first.rawValue;

    // Check if rawValue is non-null
    if (qrData == null) {
      if (!mounted) return;
      context.pop();
      return;
    }

    if (!mounted) return;
    context.pop();
    await _handleQRCodeScan(qrData);
  }

  Future<void> _handlePDFPick() async {
    if (_isProcessingPDF) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Ensure bytes are loaded on web
      );

      XFile? xFile;
      if (result != null) {
        setState(() {
          _isProcessingPDF = true;
        });

        final platformFile = result.files.single;
        if (kIsWeb && platformFile.bytes != null) {
          xFile = XFile.fromData(
            platformFile.bytes!,
            name: platformFile.name,
          );
        } else if (platformFile.path != null) {
          xFile = XFile(platformFile.path!);
        } else {
          _logger.warning('File picked but no bytes or path available');
          if (mounted) {
            showSnackbar(
              context,
              'Could not read the selected file. Please try again.',
              isError: true,
            );
          }
          return;
        }
      }

      if (xFile != null) {
        getIt<IHapticService>().triggerHaptic(
          HapticType.selection,
        );

        // Use import service to handle PDF
        final ticket = await _importService.importAndSavePDFFile(xFile);

        if (!mounted) return;

        if (ticket != null) {
          await NotificationService().scheduleTicketReminderFor(ticket);
          if (mounted) {
            showSnackbar(context, 'PDF ticket imported successfully!');
          }
        } else {
          showSnackbar(
            context,
            'Unable to read text from this PDF or content does'
            ' not match any supported ticket format.',
            isError: true,
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        showSnackbar(
          context,
          'Error processing PDF. Please try again.',
          isError: true,
        );
      }
      _logger.error('PDF import error: $e');
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

    getIt<IHapticService>().triggerHaptic(
      HapticType.selection,
    );

    try {
      final clipboardService = getIt<IClipboardService>();

      try {
        final result = await clipboardService.readAndParseClipboard();

        if (!mounted) return;

        ClipboardResultHandler.showResultMessage(context, result);
      } on Exception catch (e) {
        if (mounted) {
          showSnackbar(
            context,
            'Failed to read clipboard',
            isError: true,
          );
        }
        _logger.error('Clipboard read error: $e');
      }
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
                      InkWell(
                        splashColor: Colors.transparent,
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
                          onPressed: _isOpeningScanner
                              ? null
                              : () async {
                                  setState(() {
                                    _isOpeningScanner = true;
                                  });
                                  try {
                                    await context.pushNamed(
                                      AppRoute.barcodeScanner.name,
                                      extra: _onBarcodeCaptured,
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isOpeningScanner = false;
                                      });
                                    }
                                  }
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
