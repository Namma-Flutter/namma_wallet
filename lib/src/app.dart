import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/helper/check_pnr_id.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/services/sharing_intent_service.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class NammaWalletApp extends StatefulWidget {
  const NammaWalletApp({super.key});

  @override
  State<NammaWalletApp> createState() => _NammaWalletAppState();
}

class _NammaWalletAppState extends State<NammaWalletApp> {
  int currentPageIndex = 0;
  late final SharingIntentService _sharingService =
      getIt<SharingIntentService>();
  late final SMSService _smsService = getIt<SMSService>();
  late final TravelParserService _travelParserService =
      getIt<TravelParserService>();
  late final PDFService _pdfService = getIt<PDFService>();
  late final ILogger _logger = getIt<ILogger>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _logger.info('App initialized');

    // Initialize sharing intent service for file and text content
    _sharingService.initialize(
      onContentReceived: (content) async {
        try {
          _logger.info('Processing shared content: $content');

          String ticketContent;

          // Check if content is a file path or text content
          String? normalizedPath;
          if (content.startsWith('file://')) {
            try {
              normalizedPath = Uri.parse(content).toFilePath();
            } on Object catch (e, stackTrace) {
              _logger.error(
                'Failed to parse file URI: $content',
                e,
                stackTrace,
              );
            }
          } else if (content.contains('/')) {
            normalizedPath = content;
          }

          if (normalizedPath != null && File(normalizedPath).existsSync()) {
            // It's a file, read its content
            final file = File(normalizedPath);
            final fileExtension = path.extension(normalizedPath).toLowerCase();

            if (fileExtension == '.pdf') {
              // Extract text from PDF using PDFService
              _logger.info('Extracting text from PDF: $normalizedPath');
              ticketContent = await _pdfService.extractTextFrom(file);
              _logger.info('Successfully extracted text from PDF');
            } else {
              // Read as text file
              ticketContent = await file.readAsString();
              _logger.info('Read content from text file: $normalizedPath');
            }
          } else {
            // It's text content directly (SMS, etc.)
            ticketContent = content;
            _logger.info('Using content directly as text');
          }

          // First, check if this is an update SMS (e.g., conductor details)
          final updateInfo = _travelParserService.parseUpdateSMS(ticketContent);

          if (updateInfo != null) {
            // This is an update SMS. Attempt to apply the update.
            final db = getIt<ITicketDAO>();
            final count = await db.updateTicketById(
              updateInfo.pnrNumber,
              updateInfo.updates,
            );

            if (count > 0) {
              _logger.success(
                'Ticket updated successfully via shared content',
              );

              // Navigate to success screen with update message
              router.go(
                AppRoute.shareSuccess.path,
                extra: {
                  'pnrNumber': updateInfo.pnrNumber,
                  'from': 'Updated',
                  'to': 'Conductor Details',
                  'fare': 'Updated',
                  'date': 'Just Now',
                },
              );
              return;
            } else {
              _logger.warning(
                'Update SMS received via sharing, but no matching ticket found',
              );

              // Show error message
              _scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Update received, but the original ticket was not found.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 5),
                ),
              );

              // Navigate back to home on error
              router.go(AppRoute.home.path);
              return;
            }
          }

          // If it's not an update SMS, proceed with parsing as a new ticket.
          final ticket = _smsService.parseTicket(ticketContent);
          await checkAndUpdateTNSTCTicket(ticket);

          _logger.success(
            'Shared SMS processed successfully for PNR: ${ticket.ticketId}',
          );

          // Navigate to success screen
          router.go(
            AppRoute.shareSuccess.path,
            extra: {
              'pnrNumber': ticket.pnrOrId ?? 'Unknown',
              'from': ticket.fromLocation ?? 'Unknown',
              'to': ticket.toLocation ?? 'Unknown',
              'fare': ticket.fare ?? 'Unknown',
              'date': ticket.date,
            },
          );
        } on Object catch (e, stackTrace) {
          _logger.error(
            'Error processing shared content',
            e,
            stackTrace,
          );

          // Show error message
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Error processing shared content: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );

          // Navigate back to home on error
          router.go(AppRoute.home.path);
        }
      },
      onError: (error) {
        _logger.error('Sharing intent error: $error');

        // Show error message
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Sharing error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate back to home on error
        router.go(AppRoute.home.path);
      },
    );
  }

  @override
  void dispose() {
    _logger.info('App disposing');
    _sharingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'NammaWallet',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
    );
  }
}
