import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/share/application/shared_content_processor.dart';
import 'package:namma_wallet/src/features/share/domain/sharing_intent_service_interface.dart';
import 'package:namma_wallet/src/features/share/presentation/share_handler.dart';
import 'package:provider/provider.dart';

class NammaWalletApp extends StatefulWidget {
  const NammaWalletApp({super.key});

  @override
  State<NammaWalletApp> createState() => _NammaWalletAppState();
}

class _NammaWalletAppState extends State<NammaWalletApp> {
  int currentPageIndex = 0;
  late final ISharingIntentService _sharingService =
      getIt<ISharingIntentService>();
  late final SharedContentProcessor _contentProcessor =
      getIt<SharedContentProcessor>();
  late final ILogger _logger = getIt<ILogger>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final ShareHandler _shareHandler = ShareHandler(
    router: router,
    scaffoldMessengerKey: _scaffoldMessengerKey,
  );

  @override
  void initState() {
    super.initState();
    _logger.info('App initialized');

    // Initialize sharing intent service for file and text content
    _sharingService.initialize(
      onContentReceived: (content, contentType) async {
        // Process the content using the processor service
        final result = await _contentProcessor.processContent(
          content,
          contentType,
        );

        // Handle the result using the share handler
        _shareHandler.handleResult(result);
      },
      onError: (error) {
        _logger.error('Sharing intent error: $error');

        // Handle the error using the share handler
        _shareHandler.handleError(error);
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
