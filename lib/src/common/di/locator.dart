import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/ticket_dao.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/database/user_dao.dart';
import 'package:namma_wallet/src/common/database/user_dao_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_services.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/logger/namma_logger.dart';
import 'package:namma_wallet/src/common/services/ocr/google_mlkit_ocr.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/web_ocr_service.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/common/services/ticket_change_notifier.dart';
import 'package:namma_wallet/src/common/services/widget/home_widget_service.dart';
import 'package:namma_wallet/src/common/services/widget/web_widget_service.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/ai_service_interface.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/web_gemma_service.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service_interface.dart';
import 'package:namma_wallet/src/features/clipboard/data/clipboard_repository.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_repository_interface.dart';
import 'package:namma_wallet/src/features/import/application/deep_link_service.dart';
import 'package:namma_wallet/src/features/import/application/deep_link_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/web_deep_link_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/receive/application/shared_content_processor.dart';
import 'package:namma_wallet/src/features/receive/application/shared_content_processor_interface.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_service.dart';
import 'package:namma_wallet/src/features/receive/application/web_sharing_intent_service.dart';
import 'package:namma_wallet/src/features/receive/domain/sharing_intent_service_interface.dart';
import 'package:namma_wallet/src/features/settings/application/ai_service_status.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_api_ticket_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/data/remote/tnstc_pnr_fetcher.dart';
import 'package:namma_wallet/src/features/tnstc/data/remote/tnstc_pnr_fetcher_interface.dart';
import 'package:namma_wallet/src/features/travel/application/pkpass_parser.dart';
import 'package:namma_wallet/src/features/travel/application/pkpass_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_service.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt
    // Logger - Initialize first
    ..registerSingleton<ILogger>(NammaLogger())
    // Notifiers
    ..registerSingleton<TicketChangeNotifier>(TicketChangeNotifier())
    // Providers
    ..registerSingleton<ThemeProvider>(ThemeProvider())
    ..registerSingleton<AIServiceStatus>(AIServiceStatus())
    // Database - Initialize before DAOs
    ..registerSingleton<IWalletDatabase>(WalletDatabase())
    // DAOs
    ..registerLazySingleton<ITicketDAO>(TicketDao.new)
    ..registerLazySingleton<IUserDAO>(UserDao.new)
    // Core services
    ..registerLazySingleton<IOCRService>(
      () => kIsWeb ? WebOCRService() : GoogleMLKitOCR(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<IPDFService>(
      () => PDFService(
        ocrService: getIt<IOCRService>(),
        logger: getIt<ILogger>(),
      ),
    )
    ..registerLazySingleton<IAIService>(
      () => kIsWeb ? WebGemmaService() : GemmaService(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<IWidgetService>(
      () => kIsWeb
          ? WebWidgetService(logger: getIt<ILogger>())
          : HomeWidgetService(logger: getIt<ILogger>()),
    )
    // Parsers
    ..registerLazySingleton<TNSTCSMSParser>(TNSTCSMSParser.new)
    ..registerLazySingleton<ITravelParser>(
      () => TravelParserService(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<ISharingIntentService>(
      () => kIsWeb
          ? WebSharingIntentService()
          : SharingIntentService(
              logger: getIt<ILogger>(),
              pdfService: getIt<IPDFService>(),
            ),
    )
    ..registerLazySingleton<ISharedContentProcessor>(
      () => SharedContentProcessor(
        logger: getIt<ILogger>(),
        travelParser: getIt<ITravelParser>(),
        ticketDao: getIt<ITicketDAO>(),
        importService: getIt<IImportService>(),
      ),
    )
    ..registerLazySingleton<IHapticService>(HapticService.new)
    // Feature services
    ..registerLazySingleton<IPKPassParser>(
      () => PKPassParser(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<IIRCTCQRParser>(IRCTCQRParser.new)
    ..registerLazySingleton<IIRCTCScannerService>(
      () => IRCTCScannerService(
        logger: getIt<ILogger>(),
        qrParser: getIt<IIRCTCQRParser>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    )
    ..registerLazySingleton<ITNSTCPNRFetcher>(
      () => TNSTCPNRFetcher(logger: getIt<ILogger>()),
    )
    ..registerLazySingleton<TNSTCApiTicketParser>(TNSTCApiTicketParser.new)
    ..registerLazySingleton<IImportService>(
      () => ImportService(
        logger: getIt<ILogger>(),
        pdfService: getIt<IPDFService>(),
        travelParser: getIt<ITravelParser>(),
        qrParser: getIt<IIRCTCQRParser>(),
        irctcScannerService: getIt<IIRCTCScannerService>(),
        pkpassParser: getIt<IPKPassParser>(),
        tnstcPnrFetcher: getIt<ITNSTCPNRFetcher>(),
        tnstcApiTicketParser: getIt<TNSTCApiTicketParser>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    )
    ..registerLazySingleton<IDeepLinkService>(
      () => kIsWeb
          ? WebDeepLinkService(logger: getIt<ILogger>())
          : DeepLinkService(
              importService: getIt<IImportService>(),
              logger: getIt<ILogger>(),
            ),
    )
    // Clipboard - Repository and Service
    ..registerLazySingleton<IClipboardRepository>(ClipboardRepository.new)
    ..registerLazySingleton<IClipboardService>(
      () => ClipboardService(
        repository: getIt<IClipboardRepository>(),
        logger: getIt<ILogger>(),
        parserService: getIt<ITravelParser>(),
        ticketDao: getIt<ITicketDAO>(),
      ),
    );
}
