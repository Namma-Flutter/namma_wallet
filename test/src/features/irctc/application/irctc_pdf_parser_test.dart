import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_pdf_parser.dart';

import '../../../../helpers/fake_logger.dart';
import '../../../../helpers/mock_ocr_service.dart';

void main() {
  /// Set up GetIt dependency injection before each test run.
  setUp(() {
    final getIt = GetIt.instance;

    /// Register a FakeLogger only if not already registered.
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }

    /// Register mock OCR service for PDF parsing.
    if (!getIt.isRegistered<IOCRService>()) {
      getIt.registerSingleton<IOCRService>(MockOCRService());
    }
  });

  /// Reset GetIt after each test to avoid pollution between tests.
  tearDown(() async {
    await GetIt.instance.reset();
  });

  /// Test group validating various IRCTC PDF layouts.
  group('IRCTCPDFParser Tests', () {
    /// Parser instance used for each test.
    late IRCTCPDFParser parser;

    /// PDFService used to extract text from files.
    late PDFService pdfService;

    /// Initialize parser + PDF service with dependency-injected logger/OCR.
    setUp(() {
      final logger = GetIt.instance<ILogger>();
      final ocrService = GetIt.instance<IOCRService>();

      pdfService = PDFService(
        ocrService: ocrService,
        logger: logger,
      );

      parser = IRCTCPDFParser(logger: logger);
    });

    // -------------------------------------------------------------------------
    // TEST CASE 1: Amazon Pay Layout (Vertical/Columnar)
    // -------------------------------------------------------------------------
    /// Validates parsing of the Amazon Pay IRCTC ticket PDF layout.
    test(
      'should parse Amazon Pay PDF file to Ticket model correctly',
      () async {
        /// Load Amazon Pay sample PDF.
        final pdfFile = XFile('test/assets/irctc/amazonPay_ticket.pdf');

        /// Extract text and parse into ticket.
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // --- FIELD VALIDATIONS ---

        /// PNR / Ticket ID must match.
        expect(ticket.ticketId, equals('4846874185'));

        /// Validates extracted route.
        expect(
          ticket.primaryText,
          equals('Ksr Bengaluru (SBC) → Mgr Chennai Ctl (MAS)'),
        );

        /// Validates train number, class, and passenger text.
        expect(
          ticket.secondaryText,
          equals('Train 12658 • SL • Justin Benito'),
        );

        /// Validate parsed departure date/time.
        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(12));
        expect(ticket.startTime?.day, equals(14));
        expect(ticket.startTime?.hour, equals(22));
        expect(ticket.startTime?.minute, equals(40));

        /// Origin station
        expect(ticket.location, equals('Ksr Bengaluru (SBC)'));

        // TAG VALIDATION: PNR, Train, Class, Fare
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4846874185'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12658'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹1350.00'),
        );

        // EXTRAS VALIDATION
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('Justin Benito'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
          equals('14/12/2025'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('1350.00'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('Sbc Mas Sf Mail'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'IRCTC Fee').value,
          equals('17.70'),
        );
      },
    );

    // -------------------------------------------------------------------------
    // TEST CASE 2: ConfirmTkt Layout (Format Variations)
    // -------------------------------------------------------------------------
    /// Validates parsing of ConfirmTkt-style PDF ticket.
    test(
      'should parse ConfirmTkt PDF file to Ticket model correctly',
      () async {
        /// Load ConfirmTkt sample PDF.
        final pdfFile = XFile('test/assets/irctc/confirmTkt_ticket.pdf');

        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // PRIMARY FIELDS
        expect(ticket.ticketId, equals('4641404389'));
        expect(
          ticket.primaryText,
          equals('TIRUVALLUR (TRL) → KSR BENGALURU (SBC)'),
        );
        expect(ticket.secondaryText, equals('Train 16021 • SL • MAGESH K'));

        // START TIME VALIDATION
        expect(ticket.startTime?.year, equals(2026));
        expect(ticket.startTime?.month, equals(1));
        expect(ticket.startTime?.day, equals(11));
        expect(ticket.startTime?.hour, equals(21));
        expect(ticket.startTime?.minute, equals(55));

        // TAGS
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('16021'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹240.00'),
        );

        // EXTRAS
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('MAGESH K'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('240.00'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('KAVERI EXPRESS'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'IRCTC Fee').value,
          equals('17.70'),
        );
      },
    );

    // -------------------------------------------------------------------------
    // TEST CASE 3: Standard Email/HTML Copy Layout
    // -------------------------------------------------------------------------
    /// Validates parsing of IRCTC email-style printable PDF layout.
    test(
      'should parse IRCTC Email PDF file to Ticket model correctly',
      () async {
        /// Load email-format PDF.
        final pdfFile = XFile('test/assets/irctc/email_ticket.pdf');

        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // PRIMARY FIELDS
        expect(ticket.ticketId, equals('4639188602'));
        expect(
          ticket.primaryText,
          equals('KSR BENGALURU (SBC) → MGR CHENNAI CTL (MAS)'),
        );

        // Note: Parser now prioritizes Train No. from email body.
        expect(
          ticket.secondaryText,
          equals('Train 12658 • SL • HARISH ANBALAGAN'),
        );

        // START TIME (Email Body: 06-Dec-2025 22:40)
        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(12));
        expect(ticket.startTime?.day, equals(6));
        expect(ticket.startTime?.hour, equals(22));
        expect(ticket.startTime?.minute, equals(40));

        // TAGS
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12658'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹1080.00'),
        );

        // EXTRAS
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('HARISH ANBALAGAN'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('1080.00'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('SBC MAS SF MAIL'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'IRCTC Fee').value,
          equals('17.70'),
        );
      },
    );
  });
}
