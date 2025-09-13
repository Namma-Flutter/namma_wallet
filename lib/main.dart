import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/core/llm_service/llm_service.dart';
import 'package:namma_wallet/src/core/services/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local database (creates tables and seeds data on first run)
  await DatabaseHelper.instance.database;
  LLMService().init(); // Initialize LLM service
  runApp(const NammaWalletApp());
}
