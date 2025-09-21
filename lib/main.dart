import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/services/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local database (creates tables and seeds data on first run)
  await DatabaseHelper.instance.database;
  runApp(const NammaWalletApp());
}
