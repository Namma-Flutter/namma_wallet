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

    test(
      'should parse IRCTC PDF file 4117608719 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4117608719.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // --- FIELD VALIDATIONS ---
        expect(ticket.ticketId, equals('4117608719'));

        /// Validates extracted route.
        expect(
          ticket.primaryText,
          equals('VALLIYUR (VLY) → CHENNAI EGMORE (MS)'),
        );

        /// Validates train number, class, and passenger text.
        expect(
          ticket.secondaryText,
          equals('Train 12634 • SL • SARAVANAKUMAR'),
        );

        /// Validate parsed departure date/time.
        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(4));
        expect(ticket.startTime?.day, equals(13));
        expect(ticket.startTime?.hour, equals(18));
        expect(ticket.startTime?.minute, equals(55));

        /// Origin station
        expect(ticket.location, equals('VALLIYUR (VLY)'));

        // TAG VALIDATION: PNR, Train, Class, Fare
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4117608719'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12634'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹549.95'),
        );

        // EXTRAS VALIDATION
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('SARAVANAKUMAR'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
          equals('13/04/2025'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('549.95'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('KANYAKUMARI EXP'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'IRCTC Fee').value,
          equals('17.70'),
        );
      },
    );

    test(
      'should parse IRCTC PDF file 4214465828 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4214465828.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // --- FIELD VALIDATIONS ---
        expect(ticket.ticketId, equals('4214465828'));

        /// Validates extracted route.
        expect(
          ticket.primaryText,
          equals('ARALVAYMOZHI (AAY) → CHENNAI EGMORE (MS)'),
        );

        /// Validates train number, class, and first passenger text.
        expect(
          ticket.secondaryText,
          equals('Train 20636 • SL • RAMKUMAR'),
        );

        /// Validate parsed departure date/time.
        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(2));
        expect(ticket.startTime?.day, equals(11));
        expect(ticket.startTime?.hour, equals(17));
        expect(ticket.startTime?.minute, equals(48));

        /// Origin station
        expect(ticket.location, equals('ARALVAYMOZHI (AAY)'));

        // TAG VALIDATION
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4214465828'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('20636'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹1905.85'),
        );

        // EXTRAS VALIDATION
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('RAMKUMAR'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
          equals('11/02/2025'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('1905.85'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('ANANTAPURI EXP'),
        );
      },
    );

    test(
      'should parse IRCTC PDF file 4249001496 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4249001496.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        expect(ticket.ticketId, equals('4249001496'));

        /// Validates extracted route [cite: 227, 237]
        expect(
          ticket.primaryText,
          equals('MGR CHENNAI CTL (MAS) → KOZHIKKODE (CLT)'),
        );

        /// Validates train number, class, and first passenger
        expect(
          ticket.secondaryText,
          equals('Train 12685 • SL • RAMKUMAR R'),
        );

        /// Validate parsed departure date/time [cite: 232]
        expect(ticket.startTime?.year, equals(2023));
        expect(ticket.startTime?.month, equals(8));
        expect(ticket.startTime?.day, equals(11));
        expect(ticket.startTime?.hour, equals(16));
        expect(ticket.startTime?.minute, equals(20));

        /// Origin station [cite: 231, 232]
        expect(ticket.location, equals('MGR CHENNAI CTL (MAS)'));
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4249001496'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12685'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹818.40'),
        );

        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('RAMKUMAR R'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
          equals('11/08/2023'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('818.40'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('MAS MAQ EXP'),
        );
      },
    );

    test(
      'should parse IRCTC PDF file 4417448343 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4417448343.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        expect(ticket.ticketId, equals('4417448343'));

        expect(
          ticket.primaryText,
          equals('CHENNAI EGMORE (MS) → TIRUNELVELI JN (TEN)'),
        );

        expect(
          ticket.secondaryText,
          equals('Train 12631 • SL • SARAVANAKUMAR'),
        );

        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(4));
        expect(ticket.startTime?.day, equals(10));
        expect(ticket.startTime?.hour, equals(20));
        expect(ticket.startTime?.minute, equals(40));

        expect(ticket.location, equals('CHENNAI EGMORE (MS)'));

        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4417448343'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12631'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹529.95'),
        );

        // EXTRAS VALIDATION [cite: 362, 357, 366, 382]
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('SARAVANAKUMAR'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
          equals('10/04/2025'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('529.95'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('NELLAI SF EXP'),
        );
      },
    );

    test(
      'should parse IRCTC PDF file 4222116599 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4222116599.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        expect(ticket.ticketId, equals('4222116599'));

        /// Validates extracted route [cite: 466, 481]
        expect(
          ticket.primaryText,
          equals('CHENNAI EGMORE (MS) → ARALVAYMOZHI (AAY)'),
        );

        /// Validates train number, class, and passenger [cite: 472, 476, 483]
        expect(
          ticket.secondaryText,
          equals('Train 16127 • 3A • MURUGESAN M'),
        );

        /// Validate parsed departure date/time [cite: 475]
        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(8));
        expect(ticket.startTime?.day, equals(27));
        expect(ticket.startTime?.hour, equals(10));
        expect(ticket.startTime?.minute, equals(20));

        /// Origin station [cite: 474, 475]
        expect(ticket.location, equals('CHENNAI EGMORE (MS)'));

        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4222116599'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('16127'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('3A'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹1112.20'),
        );

        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('MURUGESAN M'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
          equals('27/08/2025'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('MS GURUVAYUR EXP'),
        );
      },
    );

    test(
      'should parse IRCTC PDF file 4534937884 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4534937884.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // --- FIELD VALIDATIONS ---
        expect(ticket.ticketId, equals('4534937884'));

        /// Validates extracted route in CAPITAL LETTERS
        expect(
          ticket.primaryText,
          equals('MGR CHENNAI CTL (MAS) → KSR BENGALURU (SBC)'),
        );

        /// Validates train number, class, and passenger
        expect(
          ticket.secondaryText,
          equals('Train 12007 • CC'),
        );

        /// Validate parsed departure date/time
        expect(ticket.startTime?.year, equals(2025));
        expect(ticket.startTime?.month, equals(7));
        expect(ticket.startTime?.day, equals(28));
        expect(ticket.startTime?.hour, equals(6));
        expect(ticket.startTime?.minute, equals(0));

        /// Origin station
        expect(ticket.location, equals('MGR CHENNAI CTL (MAS)'));

        // TAG VALIDATION
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4534937884'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12007'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('CC'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹967.65'),
        );

        // EXTRAS VALIDATION
        // expect(
        //   ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
        //   equals('SARAVANAKUMAR RA'),
        // );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('MYS SHATABDI'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('967.65'),
        );
      },
    );

    test(
      'should parse IRCTC PDF 4565161618 correctly '
      'even with N.A. departure time',
      () async {
        /// Load the specific sample where departure is "N.A."
        final pdfFile = XFile('test/assets/irctc/4565161618.pdf');

        /// Extract text from the PDF
        final pdfText = await pdfService.extractTextFrom(pdfFile);

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
        expect(ticket.ticketId, equals('4565161618'));
        expect(ticket.journeyDate, isNotNull);

        /// Start time should be null because the PDF has "N.A."
        expect(ticket.startTime, isNull);
      },
    );

    test(
      'should parse IRCTC PDF file 4449000087 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/4449000087.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // --- FIELD VALIDATIONS ---
        expect(ticket.ticketId, equals('4449000087'));

        /// Validates extracted route in CAPITAL LETTERS
        expect(
          ticket.primaryText,
          equals('KOZHIKKODE (CLT) → MGR CHENNAI CTL (MAS)'),
        );

        /// Validates train number, class, and first passenger
        expect(
          ticket.secondaryText,
          equals('Train 12686 • 3A • RAMKUMAR'),
        );

        /// Validate parsed departure date/time
        expect(ticket.startTime?.year, equals(2023));
        expect(ticket.startTime?.month, equals(8));
        expect(ticket.startTime?.day, equals(15));
        expect(ticket.startTime?.hour, equals(20));
        expect(ticket.startTime?.minute, equals(30));

        /// Origin station
        expect(ticket.location, equals('KOZHIKKODE (CLT)'));

        // TAG VALIDATION
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4449000087'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('12686'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('3A'),
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹2126.10'),
        );

        // EXTRAS VALIDATION
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('RAMKUMAR'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('MAQ MAS EXP'),
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
          equals('2126.10'),
        );
      },
    );

    test(
      'should parse IRCTC PDF file 4328673018 to Ticket model correctly',
      () async {
        final pdfFile = XFile('test/assets/irctc/confirmTkt_ticket_2.pdf');
        final pdfText = await pdfService.extractTextFrom(pdfFile);
        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // --- FIELD VALIDATIONS ---
        expect(ticket.ticketId, equals('4328673018')); // [cite: 897]

        /// Validates extracted route in CAPITAL LETTERS
        expect(
          ticket.primaryText,
          equals(
            'KSR BENGALURU (SBC) → MGR CHENNAI CTL (MAS)',
          ), // [cite: 894, 908]
        );

        /// Validates train number, class, and passenger
        expect(
          ticket.secondaryText,
          equals('Train 16022 • SL • MAGESH K'), // [cite: 901, 911, 905]
        );

        /// Validate parsed departure date/time
        expect(ticket.startTime?.year, equals(2026)); // [cite: 895]
        expect(ticket.startTime?.month, equals(1)); // [cite: 895]
        expect(ticket.startTime?.day, equals(13)); // [cite: 895]
        expect(ticket.startTime?.hour, equals(23)); // [cite: 895]
        expect(ticket.startTime?.minute, equals(50)); // [cite: 895]

        /// Origin station
        expect(ticket.location, equals('KSR BENGALURU (SBC)')); // [cite: 894]

        // TAG VALIDATION
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'confirmation_number').value,
          equals('4328673018'), // [cite: 897]
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'train').value,
          equals('16022'), // [cite: 901]
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'event_seat').value,
          equals('SL'), // [cite: 911]
        );
        expect(
          ticket.tags?.firstWhere((t) => t.icon == 'attach_money').value,
          equals('₹240.00'), // [cite: 927]
        );

        // EXTRAS VALIDATION
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
          equals('MAGESH K'), // [cite: 905]
        );
        expect(
          ticket.extras?.firstWhere((e) => e.title == 'Train Name').value,
          equals('KAVERI EXPRESS'), // [cite: 901]
        );
      },
    );
  });
}
