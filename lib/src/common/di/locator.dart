import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/services/namma_logger.dart';
import 'package:namma_wallet/src/common/services/sharing_intent_service.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_parser_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt
    // Logger - Initialize first
    ..registerSingleton<ILogger>(NammaLogger())
    // Providers
    ..registerSingleton<ThemeProvider>(ThemeProvider())
    // Core services
    ..registerLazySingleton<SharingIntentService>(SharingIntentService.new)
    ..registerLazySingleton<SMSService>(SMSService.new)
    ..registerLazySingleton<GemmaChatService>(GemmaChatService.new)
    // Feature services
    ..registerLazySingleton<IRCTCScannerService>(IRCTCScannerService.new)
    ..registerLazySingleton<PDFParserService>(PDFParserService.new)
    ..registerLazySingleton<ClipboardService>(ClipboardService.new)
    ..registerLazySingleton<TravelParserService>(TravelParserService.new)
    // Database
    ..registerSingleton<WalletDatabase>(WalletDatabase());
}
