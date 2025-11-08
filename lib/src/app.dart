import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/helper/check_pnr_id.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/services/sharing_intent_service.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
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
  late final ILogger _logger = getIt<ILogger>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _logger.info('App initialized');

    // Initialize sharing intent service for file logging
    _sharingService.initialize(
      onFileReceived: (filePath) async {
        try {
          _logger.info('Processing shared file: $filePath');
          final file = File(filePath);
          final content = await file.readAsString();
          final ticket = _smsService.parseTicket(content);
          await checkAndUpdateTNSTCTicket(ticket);

          _logger.success(
            'Shared SMS processed successfully for PNR: ${ticket.pnrNumber}',
          );
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                'Shared SMS processed for PNR: ${ticket.pnrNumber}',
              ),
              backgroundColor: AppColor.primaryBlue,
              duration: const Duration(seconds: 3),
            ),
          );
        } on Object catch (e, stackTrace) {
          _logger.error(
            'Error processing shared SMS',
            e,
            stackTrace,
          );
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Error processing shared SMS: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      onError: (error) {
        _logger.error('Sharing intent error: $error');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Sharing error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
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
