import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:provider/provider.dart';
import 'package:namma_wallet/src/common/di/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await getIt<GemmaChatService>().init();
  // Initialize local database (creates tables and seeds data on first run)
  await getIt<WalletDatabase>().database;

  runApp(
    ChangeNotifierProvider.value(
      value: getIt<ThemeProvider>(),
      child: const NammaWalletApp(),
    ),
  );
}
