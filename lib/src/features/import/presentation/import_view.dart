import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service_interface.dart';
import 'package:namma_wallet/src/features/clipboard/presentation/clipboard_result_handler.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
import 'package:namma_wallet/src/features/import/presentation/widgets/import_method_card_widget.dart';

class ImportView extends StatefulWidget {
  const ImportView({super.key});

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> {
  late final IImportService _importService = getIt<IImportService>();
  late final ILogger _logger = getIt<ILogger>();
  final TextEditingController _pnrController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isPasting = false;
  bool _isScanning = false;
  bool _isProcessingPDF = false;
  bool _isOpeningScanner = false;
  bool _isFetchingPNR = false;

  @override
  void dispose() {
    _pnrController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
        final id = ticket.ticketId;
        if (id != null) {
          context.go(AppRoute.home.path);
          await context.pushNamed(
            AppRoute.ticketView.name,
            pathParameters: {'id': id},
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
          final id = ticket.ticketId;
          if (id != null) {
            context.go(AppRoute.home.path);
            await context.pushNamed(
              AppRoute.ticketView.name,
              pathParameters: {'id': id},
            );
          }
        } else {
          showSnackbar(
            context,
            kIsWeb
                ? 'PDF import is not supported on web for scanned/image-only '
                      'tickets. Web currently supports SMS extraction only.'
                : 'Unable to read text from this PDF or content does'
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

        final ticketId = result.ticket?.ticketId;
        if (result.isSuccess && ticketId != null) {
          context.go(AppRoute.home.path);
          await context.pushNamed(
            AppRoute.ticketView.name,
            pathParameters: {'id': ticketId},
          );
        } else {
          ClipboardResultHandler.showResultMessage(context, result);
        }
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

  Future<void> _handlePNRFetch() async {
    if (_isFetchingPNR) return;

    final pnr = _pnrController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    if (pnr.isEmpty) {
      showSnackbar(
        context,
        'Please enter a PNR number',
        isError: true,
      );
      return;
    }
    if (phoneNumber.isEmpty) {
      showSnackbar(
        context,
        'Please enter your phone number',
        isError: true,
      );
      return;
    }

    setState(() {
      _isFetchingPNR = true;
    });

    getIt<IHapticService>().triggerHaptic(
      HapticType.selection,
    );

    try {
      final ticket = await _importService.importTNSTCByPNR(pnr, phoneNumber);

      if (!mounted) return;

      if (ticket != null) {
        _pnrController.clear();
        _phoneController.clear();
        final id = ticket.ticketId;
        if (id != null) {
          context.go(AppRoute.home.path);
          await context.pushNamed(
            AppRoute.ticketView.name,
            pathParameters: {'id': id},
          );
        } else {
          showSnackbar(
            context,
            'TNSTC ticket imported successfully!',
          );
        }
      } else {
        showSnackbar(
          context,
          'Unable to fetch ticket. Verify PNR and phone number.',
          isError: true,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        showSnackbar(
          context,
          'Error fetching ticket. Please try again.',
          isError: true,
        );
      }
      _logger.error('PNR fetch error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingPNR = false;
        });
      }
    }
  }

  Future<void> _openQRScanner() async {
    if (_isOpeningScanner) return;

    setState(() => _isOpeningScanner = true);
    try {
      await context.pushNamed(
        AppRoute.barcodeScanner.name,
        extra: _onBarcodeCaptured,
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningScanner = false);
      }
    }
  }

  Future<void> _showPNRDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter PNR and Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pnrController,
              decoration: const InputDecoration(
                labelText: 'PNR Number',
                hintText: 'e.g., T76296906',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g., 9876543210',
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) async {
                context.pop();
                await _handlePNRFetch();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              context.pop();
              await _handlePNRFetch();
            },
            child: _isFetchingPNR
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Fetch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Tickets'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              ImportMethodCardWidget(
                icon: Icons.upload_file,
                title: 'Upload PDF',
                subtitle: 'Import from file',
                onTap: _handlePDFPick,
                isLoading: _isProcessingPDF,
              ),
              ImportMethodCardWidget(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR',
                subtitle: 'IRCTC tickets',
                onTap: _openQRScanner,
                isLoading: _isOpeningScanner,
              ),
              ImportMethodCardWidget(
                icon: Icons.content_paste,
                title: 'Clipboard',
                subtitle: 'Parse SMS text',
                onTap: _handleClipboardRead,
                isLoading: _isPasting,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              ImportMethodCardWidget(
                icon: Icons.search,
                title: 'TNSTC PNR',
                subtitle: 'PNR + phone',
                onTap: _showPNRDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
