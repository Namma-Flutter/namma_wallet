import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GemmaChatService().init();
  // Initialize local database (creates tables and seeds data on first run)
  await WalletDatabase.instance.database;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NammaWalletApp(),
    ),
  );
}
