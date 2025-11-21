import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/ticket_dao.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/database/user_dao.dart';
import 'package:namma_wallet/src/common/database/user_dao_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/services/namma_logger.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/clipboard/data/clipboard_repository.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_repository_interface.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_parser_service.dart';
import 'package:namma_wallet/src/features/share/application/shared_content_processor.dart';
import 'package:namma_wallet/src/features/share/application/sharing_intent_service.dart';
import 'package:namma_wallet/src/features/share/domain/sharing_intent_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/ocr_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/pdf_service_interface.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt
    // Logger - Initialize first
    ..registerSingleton<ILogger>(NammaLogger())
    // Providers
    ..registerSingleton<ThemeProvider>(ThemeProvider())
    // Core services
    ..registerLazySingleton<ISharingIntentService>(SharingIntentService.new)
    ..registerLazySingleton<SharedContentProcessor>(
      SharedContentProcessor.new,
    )
    ..registerLazySingleton<SMSService>(SMSService.new)
    ..registerLazySingleton<GemmaChatService>(GemmaChatService.new)
    // Feature services
    ..registerLazySingleton<IRCTCQRParser>(IRCTCQRParser.new)
    ..registerLazySingleton<IRCTCScannerService>(IRCTCScannerService.new)
    ..registerLazySingleton<IOCRService>(OCRService.new)
    ..registerLazySingleton<IPDFService>(PDFService.new)
    ..registerLazySingleton<PDFParserService>(PDFParserService.new)
    // Clipboard - Repository and Service
    ..registerLazySingleton<IClipboardRepository>(ClipboardRepository.new)
    ..registerLazySingleton<ClipboardService>(ClipboardService.new)
    ..registerLazySingleton<TravelParserService>(TravelParserService.new)
    // Parsers
    ..registerLazySingleton<TNSTCSMSParser>(TNSTCSMSParser.new)
    ..registerLazySingleton<TNSTCPDFParser>(TNSTCPDFParser.new)
    // Database
    ..registerSingleton<IWalletDatabase>(WalletDatabase())
    // DAOs
    ..registerLazySingleton<ITicketDAO>(TicketDao.new)
    ..registerLazySingleton<IUserDAO>(UserDao.new);
}
