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
import 'package:namma_wallet/src/features/ai/fallback-parser/application/ai_service_interface.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service_interface.dart';
import 'package:namma_wallet/src/features/clipboard/data/clipboard_repository.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_repository_interface.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_parser_service.dart';
import 'package:namma_wallet/src/features/receive/application/shared_content_processor.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_service.dart';
import 'package:namma_wallet/src/features/receive/domain/sharing_intent_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';
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
    // Database - Initialize before DAOs
    ..registerSingleton<IWalletDatabase>(WalletDatabase())
    // DAOs
    ..registerLazySingleton<ITicketDAO>(TicketDao.new)
    ..registerLazySingleton<IUserDAO>(UserDao.new)
    // Core services
    ..registerLazySingleton<IOCRService>(
      () => OCRService(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<IPDFService>(
      () => PDFService(
        ocrService: getIt<IOCRService>(),
        logger: getIt<ILogger>(),
      ),
    )
    ..registerLazySingleton<IAIService>(
      () => GemmaChatService(logger: getIt<ILogger>()),
    )
    // Parsers
    ..registerLazySingleton<TNSTCSMSParser>(TNSTCSMSParser.new)
    ..registerLazySingleton<ITicketParser>(
      () => TNSTCPDFParser(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<ISMSService>(
      () => SMSService(
        logger: getIt<ILogger>(),
        smsParser: getIt<TNSTCSMSParser>(),
      ),
    )
    ..registerLazySingleton<ITravelParserService>(
      () => TravelParserService(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<PDFParserService>(
      () => PDFParserService(
        logger: getIt<ILogger>(),
        pdfParser: getIt<ITicketParser>(),
        pdfService: getIt<IPDFService>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    )
    ..registerLazySingleton<ISharingIntentService>(
      () => SharingIntentService(
        logger: getIt<ILogger>(),
        pdfService: getIt<IPDFService>(),
      ),
    )
    ..registerLazySingleton<SharedContentProcessor>(
      () => SharedContentProcessor(
        logger: getIt<ILogger>(),
        travelParser: getIt<ITravelParserService>(),
        smsService: getIt<ISMSService>(),
        pdfParser: getIt<ITicketParser>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    )
    // Feature services
    ..registerLazySingleton<IRCTCQRParser>(IRCTCQRParser.new)
    ..registerLazySingleton<IRCTCScannerService>(
      () => IRCTCScannerService(
        logger: getIt<ILogger>(),
        qrParser: getIt<IRCTCQRParser>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    )
    // Clipboard - Repository and Service
    ..registerLazySingleton<IClipboardRepository>(ClipboardRepository.new)
    ..registerLazySingleton<IClipboardService>(
      () => ClipboardService(
        repository: getIt<IClipboardRepository>(),
        logger: getIt<ILogger>(),
        parserService: getIt<ITravelParserService>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    );
}
