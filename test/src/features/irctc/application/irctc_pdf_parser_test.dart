import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_layout_parser.dart';

import '../../../../fixtures/irctc_layout_fixtures.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  setUp(() {
    final getIt = GetIt.instance;

    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('IRCTCLayoutParser with OCR Blocks', () {
    late IRCTCLayoutParser parser;
    late ILogger logger;

    setUp(() {
      logger = FakeLogger();
      parser = IRCTCLayoutParser(logger: logger);
    });

    test('should parse 4117608719 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4117608719;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4117608719'));
      // Title must include both train number and name
      expect(ticket.primaryText, equals('12634 - KANYAKUMARI EXP'));
      expect(ticket.secondaryText, equals('12634 - KANYAKUMARI EXP'));
      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(4));
      expect(ticket.startTime?.day, equals(13));
      expect(ticket.startTime?.hour, equals(18));
      expect(ticket.startTime?.minute, equals(55));

      // Check tags exist
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4117608719'));

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12634 - KANYAKUMARI EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹549.95'));

      // Check extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('SARAVANAKUMAR'));

      // Check quota
      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('PREMIUM TATKAL (PT)'));

      // Check status from tags (icon: 'info')
      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Check train name in extras
      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('KANYAKUMARI EXP'));

      // Check gender
      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      // Check age
      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('29'));

      // Check IRCTC Fee
      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      // Check Transaction ID
      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005723544746'));

      // Check From / To / Boarding stations
      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('VALLIYUR (VLY)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('CHENNAI EGMORE (MS)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('VALLIYUR (VLY)'));
    });

    test('should parse 4214465828 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4214465828;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4214465828'));
      expect(ticket.primaryText, equals('20636 - ANANTAPURI EXP'));
      expect(ticket.secondaryText, equals('20636 - ANANTAPURI EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(2));
      expect(ticket.startTime?.day, equals(11));
      expect(ticket.startTime?.hour, equals(17));
      expect(ticket.startTime?.minute, equals(48));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('20636 - ANANTAPURI EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹1905.85'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('PREMIUM TATKAL (PT)'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005583628004'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('ARALVAYMOZHI (AAY)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('CHENNAI EGMORE - MS'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('ARALVAYMOZHI (AAY)'));
    });

    test('should parse 4222116599 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4222116599;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4222116599'));
      expect(ticket.primaryText, equals('16127 - MS GURUVAYUR EXP'));
      expect(ticket.secondaryText, equals('16127 - MS GURUVAYUR EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(27));
      expect(ticket.startTime?.hour, equals(10));
      expect(ticket.startTime?.minute, equals(20));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('16127 - MS GURUVAYUR EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('3A'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹1112.20'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('WL'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('MURUGESAN M'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('63'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('35.40'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005916711382'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('CHENNAI EGMORE (MS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('ARALVAYMOZHI (AAY)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('CHENNAI EGMORE (MS)'));
    });

    test('should parse 4249001496 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4249001496;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4249001496'));
      expect(ticket.primaryText, equals('12685 - MAS MAQ EXP'));
      expect(ticket.secondaryText, equals('12685 - MAS MAQ EXP'));

      expect(ticket.startTime?.year, equals(2023));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(11));
      expect(ticket.startTime?.hour, equals(16));
      expect(ticket.startTime?.minute, equals(20));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12685 - MAS MAQ EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹818.40'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR R'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('28'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100004191377137'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('KOZHIKKODE (CLT)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('MGR CHENNAI CTL (MAS)'));
    });

    test('should parse 4417448343 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4417448343;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4417448343'));
      expect(ticket.primaryText, equals('12631 - NELLAI SF EXP'));
      expect(ticket.secondaryText, equals('12631 - NELLAI SF EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(4));
      expect(ticket.startTime?.day, equals(10));
      expect(ticket.startTime?.hour, equals(20));
      expect(ticket.startTime?.minute, equals(40));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12631 - NELLAI SF EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹529.95'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('SARAVANAKUMAR'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('29'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('TATKAL (TQ)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005716170167'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('CHENNAI EGMORE (MS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('TIRUNELVELI JN (TEN)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('CHENNAI EGMORE (MS)'));
    });

    test('should parse 4449000087 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4449000087;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4449000087'));
      expect(ticket.primaryText, equals('12686 - MAQ MAS EXP'));
      expect(ticket.secondaryText, equals('12686 - MAQ MAS EXP'));

      expect(ticket.startTime?.year, equals(2023));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(15));
      expect(ticket.startTime?.hour, equals(20));
      expect(ticket.startTime?.minute, equals(30));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12686 - MAQ MAS EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('3A'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹2126.10'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('28'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('35.40'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100004191230796'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('KOZHIKKODE (CLT)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('KOZHIKKODE (CLT)'));
    });

    test('should parse 4534937884 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4534937884;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4534937884'));
      expect(ticket.primaryText, equals('12007 - MYS SHATABDI'));
      expect(ticket.secondaryText, equals('12007 - MYS SHATABDI'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(7));
      expect(ticket.startTime?.day, equals(28));
      expect(ticket.startTime?.hour, equals(6));
      expect(ticket.startTime?.minute, equals(0));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12007 - MYS SHATABDI'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('CC'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹967.65'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('SARAVANAKUMAR RA'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('29'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('TATKAL (TQ)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('35.40'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005942292031'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('KSR BENGALURU (SBC)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('MGR CHENNAI CTL (MAS)'));
    });

    test('should parse 4565194077 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4565194077;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4565194077'));
      expect(ticket.primaryText, equals('12686 - MAQ MAS EXP'));
      expect(ticket.secondaryText, equals('12686 - MAQ MAS EXP'));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12686 - MAQ MAS EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹812.50'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('29'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('11.80'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100004363665728'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('KOZHIKKODE (CLT)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('MGR CHENNAI CTL - MAS'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('KOZHIKKODE (CLT)'));
    });

    test('should parse 4628586109 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4628586109;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4628586109'));
      expect(ticket.primaryText, equals('12631 - NELLAI SF EXP'));
      expect(ticket.secondaryText, equals('12631 - NELLAI SF EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(3));
      expect(ticket.startTime?.day, equals(10));
      expect(ticket.startTime?.hour, equals(20));
      expect(ticket.startTime?.minute, equals(40));

      // Tags
      expect(ticket.tags, isNotNull);
      expect(ticket.tags, isNotEmpty);

      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12631 - NELLAI SF EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹1030.40'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      expect(ticket.extras, isNotNull);

      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('R SENTHURKANI'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('F'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('59'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('PREMIUM TATKAL (PT)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005646919858'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('TIRUNELVELI JN (TEN)'));
    });

    test('should parse 4634845356 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4634845356;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4634845356'));
      expect(ticket.primaryText, equals('20635 - ANANTAPURI EXP'));
      expect(ticket.secondaryText, equals('20635 - ANANTAPURI EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(21));
      expect(ticket.startTime?.hour, equals(19));
      expect(ticket.startTime?.minute, equals(50));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('20635 - ANANTAPURI EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹454.95'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('PREMA M'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('F'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('50'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005916578569'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('CHENNAI EGMORE (MS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('ARALVAYMOZHI (AAY)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('CHENNAI EGMORE (MS)'));
    });

    test('should parse 4634847925 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4634847925;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4634847925'));
      expect(ticket.primaryText, equals('16127 - MS GURUVAYUR EXP'));
      expect(ticket.secondaryText, equals('16127 - MS GURUVAYUR EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(27));
      expect(ticket.startTime?.hour, equals(10));
      expect(ticket.startTime?.minute, equals(20));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('16127 - MS GURUVAYUR EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('3A'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹3242.20'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('WL'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR R'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('30'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('35.40'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005916757004'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('CHENNAI EGMORE (MS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('ARALVAYMOZHI (AAY)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('CHENNAI EGMORE (MS)'));
    });

    test('should parse 4740095793 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4740095793;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4740095793'));
      expect(ticket.primaryText, equals('20635 - ANANTAPURI EXP'));
      expect(ticket.secondaryText, equals('20635 - ANANTAPURI EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(6));
      expect(ticket.startTime?.day, equals(5));
      expect(ticket.startTime?.hour, equals(20));
      expect(ticket.startTime?.minute, equals(17));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('20635 - ANANTAPURI EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹1060.40'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('PREMA M'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('F'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('50'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('PREMIUM TATKAL (PT)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005832465483'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('TAMBARAM (TBM)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('ARALVAYMOZHI (AAY)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('TAMBARAM (TBM)'));
    });

    test('should parse 4842082738 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4842082738;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4842082738'));
      expect(ticket.primaryText, equals('20636 - ANANTAPURI EXP'));
      expect(ticket.secondaryText, equals('20636 - ANANTAPURI EXP'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(31));
      expect(ticket.startTime?.hour, equals(17));
      expect(ticket.startTime?.minute, equals(48));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('20636 - ANANTAPURI EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹2154.50'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('PQWL'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('PRIYANKA M'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('F'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('30'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005916605368'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('ARALVAYMOZHI (AAY)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('CHENNAI EGMORE (MS)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('ARALVAYMOZHI (AAY)'));
    });

    test('should parse 4928088531 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4928088531;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4928088531'));
      expect(ticket.primaryText, equals('16021 - KAVERI EXPRESS'));
      expect(ticket.secondaryText, equals('16021 - KAVERI EXPRESS'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(6));
      expect(ticket.startTime?.day, equals(21));
      expect(ticket.startTime?.hour, equals(21));
      expect(ticket.startTime?.minute, equals(15));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('16021 - KAVERI EXPRESS'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹552.25'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('SARAVANAKUMAR RA'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('29'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('PREMIUM TATKAL (PT)'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('11.80'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100005868403511'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('WHITEFIELD (WFD)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('MGR CHENNAI CTL (MAS)'));
    });

    test('should parse 4249001496_ecs from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc4249001496ECS;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4249001496'));
      expect(ticket.primaryText, equals('12685 - MAS MAQ EXP'));
      expect(ticket.secondaryText, equals('12685 - MAS MAQ EXP'));

      expect(ticket.startTime?.year, equals(2023));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(11));
      expect(ticket.startTime?.hour, equals(16));
      expect(ticket.startTime?.minute, equals(20));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12685 - MAS MAQ EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹560.56'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR R'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100004191377137'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('KOZHIKKODE (CLT)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('MGR CHENNAI CTL (MAS)'));
    });

    test('should parse 4449000087_ecs from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc4449000087ECS;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4449000087'));
      expect(ticket.primaryText, equals('12686 - MAQ MAS EXP'));
      expect(ticket.secondaryText, equals('12686 - MAQ MAS EXP'));

      expect(ticket.startTime?.year, equals(2023));
      expect(ticket.startTime?.month, equals(8));
      expect(ticket.startTime?.day, equals(15));
      expect(ticket.startTime?.hour, equals(20));
      expect(ticket.startTime?.minute, equals(30));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12686 - MAQ MAS EXP'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('3A'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹1710.56'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('RAMKUMAR'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100004191230796'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('KOZHIKKODE (CLT)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('KOZHIKKODE (CLT)'));
    });

    test('should parse 4537429538 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4537429538;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4537429538'));
      expect(ticket.primaryText, equals('12657 - MAS SBC SF MAIL'));
      expect(ticket.secondaryText, equals('12657 - MAS SBC SF MAIL'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(10));
      expect(ticket.startTime?.day, equals(26));
      expect(ticket.startTime?.hour, equals(22));
      expect(ticket.startTime?.minute, equals(50));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12657 - MAS SBC SF MAIL'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('WL'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('MAGESH K'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('25'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));
    });

    test('should parse 4328673018 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4328673018;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4328673018'));
      expect(ticket.primaryText, equals('16022 - KAVERI EXPRESS'));
      expect(ticket.secondaryText, equals('16022 - KAVERI EXPRESS'));

      expect(ticket.startTime?.year, equals(2026));
      expect(ticket.startTime?.month, equals(1));
      expect(ticket.startTime?.day, equals(13));
      expect(ticket.startTime?.hour, equals(23));
      expect(ticket.startTime?.minute, equals(50));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('16022 - KAVERI EXPRESS'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('RLWL'));

      // Extras
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtra?.value, equals('MAGESH K'));

      final genderExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtra?.value, equals('M'));

      final ageExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtra?.value, equals('25'));

      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('GENERAL (GN)'));
    });

    test('should parse 4937508934 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4937508934;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4937508934'));
      expect(ticket.primaryText, equals('12083 - Cbe Janshatabdi'));
      expect(ticket.secondaryText, equals('12083 - Cbe Janshatabdi'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(12));
      expect(ticket.startTime?.day, equals(22));
      expect(ticket.startTime?.hour, equals(15));
      expect(ticket.startTime?.minute, equals(38));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12083 - Cbe Janshatabdi'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('2S'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹387.70'));

      // Extras
      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('General (GN)'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100006249963507'));

      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('Kumbakonam (KMU)'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('Coimbatore Jn (CBE)'));

      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('Kumbakonam (KMU)'));
    });

    test('should parse 4846874185 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4846874185;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4846874185'));
      expect(ticket.primaryText, equals('12658 - Sbc Mas Sf Mail'));
      expect(ticket.secondaryText, equals('12658 - Sbc Mas Sf Mail'));

      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(12));
      expect(ticket.startTime?.day, equals(14));
      expect(ticket.startTime?.hour, equals(22));
      expect(ticket.startTime?.minute, equals(40));

      // Tags
      final trainTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'train',
        orElse: () => throw StateError('No train tag'),
      );
      expect(trainTag?.value, equals('12658 - Sbc Mas Sf Mail'));

      final classTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
        orElse: () => throw StateError('No event_seat tag'),
      );
      expect(classTag?.value, equals('SL'));

      final moneyTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'attach_money',
        orElse: () => throw StateError('No attach_money tag'),
      );
      expect(moneyTag?.value, equals('₹1367.70'));

      // Extras
      final quotaExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Quota',
        orElse: () => throw StateError('No Quota extra'),
      );
      expect(quotaExtra?.value, equals('General (GN)'));

      final transactionIdExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtra?.value, equals('100006112819561'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('Mgr Chennai Ctl (MAS)'));
    });
  });
}
