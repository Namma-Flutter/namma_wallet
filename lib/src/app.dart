import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/services/sharing_intent_service.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class NammaWalletApp extends StatefulWidget {
  const NammaWalletApp({super.key});

  @override
  State<NammaWalletApp> createState() => _NammaWalletAppState();
}

class _NammaWalletAppState extends State<NammaWalletApp> {
  int currentPageIndex = 0;
  final SharingIntentService _sharingService = SharingIntentService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    // Initialize sharing intent service for file logging
    _sharingService.initialize(
      onFileReceived: (fileName) {
        // Show user that file was received
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('📄 Shared file received: $fileName'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      onError: (error) {
        //error message
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('❌ Sharing error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
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
