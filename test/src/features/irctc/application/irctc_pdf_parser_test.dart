import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
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

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S2/34/MIDDLE'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('695 KM'));

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('VALLIYUR (VLY)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4117608719'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('549.95'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4214465828'));

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

      final statusTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(statusTag?.value, equals('CNF'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('ANANTAPURI EXP'));

      final irctcFeeExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtra?.value, equals('17.70'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('ARALVAYMOZHI (AAY)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4214465828'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S1/50/MIDDLE'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('714 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('1905.85'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4222116599'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MS GURUVAYUR EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('CHENNAI EGMORE (MS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4222116599'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('WL/26'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('714 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('1112.20'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4249001496'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('MGR CHENNAI CTL (MAS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4249001496'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S8/56/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('668 KM'));

      // Check Train Name
      final trainNameExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtraCheck?.value, equals('MAS MAQ EXP'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('818.40'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4417448343'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('NELLAI SF EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('CHENNAI EGMORE (MS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4417448343'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S2/32/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('653 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('529.95'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4449000087'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MAQ MAS EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('KOZHIKKODE (CLT)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4449000087'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('B3/16/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('668 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('2126.10'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4534937884'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MYS SHATABDI'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('MGR CHENNAI CTL (MAS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4534937884'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('C7/35/WINDOW SIDE'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('362 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('967.65'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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

      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4565194077'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MAQ MAS EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('KOZHIKKODE (CLT)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4565194077'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S6/80/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('668 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('812.50'));
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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('CHENNAI EGMORE - MS'));

      // Check From
      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('CHENNAI EGMORE - MS'));

      // Check Boarding
      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('CHENNAI EGMORE - MS'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4628586109'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S1/25/LOWER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('653 KM'));

      // Check Train Name
      final trainNameExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtraCheck?.value, equals('NELLAI SF EXP'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('1030.40'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4634845356'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('ANANTAPURI EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('CHENNAI EGMORE (MS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4634845356'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S4/57/LOWER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('714 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('454.95'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4634847925'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MS GURUVAYUR EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('CHENNAI EGMORE (MS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4634847925'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('WL/23'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('714 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('3242.20'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4740095793'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('ANANTAPURI EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('TAMBARAM (TBM)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4740095793'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S5/57/LOWER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('689 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('1060.40'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4842082738'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('ANANTAPURI EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('ARALVAYMOZHI (AAY)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4842082738'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('PQWL/38'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('714 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('2154.50'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4928088531'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('KAVERI EXPRESS'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('MGR CHENNAI CTL (MAS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4928088531'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S1/16/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('338 KM'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('552.25'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4249001496'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MAS MAQ EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('MGR CHENNAI CTL (MAS)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4249001496'));

      // Check Gender
      final genderExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtraCheck?.value, equals('M'));

      // Check Age
      final ageExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtraCheck?.value, equals('28'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S8/56/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('668 KM'));

      // Check IRCTC Fee
      final irctcFeeExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtraCheck?.value, equals('240.00'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('560.56'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4449000087'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MAQ MAS EXP'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('KOZHIKKODE (CLT)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4449000087'));

      // Check Gender
      final genderExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtraCheck?.value, equals('M'));

      // Check Age
      final ageExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtraCheck?.value, equals('28'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('B3/16/SIDE UPPER'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('668 KM'));

      // Check IRCTC Fee
      final irctcFeeExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtraCheck?.value, equals('380.00'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('1710.56'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4537429538'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('MAS SBC SF MAIL'));

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4537429538'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('WL/111'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('362 KM'));

      // Check IRCTC Fee
      final irctcFeeExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtraCheck?.value, equals('17.70'));

      // Check Transaction ID (not available in this ticket)
      final transactionIdExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtraCheck?.value, isNull);

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('308.00'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);

      // Check From
      final fromExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtra?.value, equals('MGR CHENNAI CTL (MAS)'));

      // Check To
      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('KSR BENGALURU (SBC)'));

      // Check Boarding
      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('MGR CHENNAI CTL (MAS)'));
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4328673018'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('KAVERI EXPRESS'));

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4328673018'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('RLWL/20'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('362 KM'));

      // Check IRCTC Fee
      final irctcFeeExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtraCheck?.value, equals('17.70'));

      // Check Transaction ID (not available in this ticket)
      final transactionIdExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Transaction ID',
        orElse: () => throw StateError('No Transaction ID extra'),
      );
      expect(transactionIdExtraCheck?.value, isNull);

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('278.00'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4937508934'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('Cbe Janshatabdi'));

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

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check location
      expect(ticket.location, equals('Kumbakonam (KMU)'));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4937508934'));

      // Check Passenger
      final passengerExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtraCheck?.value, equals('Maragatham'));

      // Check Gender
      final genderExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtraCheck?.value, equals('F'));

      // Check Age
      final ageExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtraCheck?.value, equals('57'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('D6/33/NC'));

      // Check info tag (status)
      final infoTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(infoTag?.value, equals('CNF'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('331 KM'));

      // Check IRCTC Fee
      final irctcFeeExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtraCheck?.value, equals('17.70'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('387.70'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
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
      final confirmationTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
        orElse: () => throw StateError('No confirmation_number tag'),
      );
      expect(confirmationTag?.value, equals('4846874185'));

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

      final trainNameExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Train Name',
        orElse: () => throw StateError('No Train Name extra'),
      );
      expect(trainNameExtra?.value, equals('Sbc Mas Sf Mail'));

      final toExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'To',
        orElse: () => throw StateError('No To extra'),
      );
      expect(toExtra?.value, equals('Mgr Chennai Ctl (MAS)'));

      // Check type
      expect(ticket.type, equals(TicketType.train));

      // Check PNR Number extra
      final pnrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'PNR Number',
        orElse: () => throw StateError('No PNR Number extra'),
      );
      expect(pnrExtra?.value, equals('4846874185'));

      // Check location
      expect(ticket.location, equals('Ksr Bengaluru'));

      // Check Boarding
      final boardingExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Boarding',
        orElse: () => throw StateError('No Boarding extra'),
      );
      expect(boardingExtra?.value, equals('Ksr Bengaluru'));

      // Check Passenger
      final passengerExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
        orElse: () => throw StateError('No Passenger extra'),
      );
      expect(passengerExtraCheck?.value, equals('Justin Benito'));

      // Check Gender
      final genderExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Gender',
        orElse: () => throw StateError('No Gender extra'),
      );
      expect(genderExtraCheck?.value, equals('M'));

      // Check Age
      final ageExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'Age',
        orElse: () => throw StateError('No Age extra'),
      );
      expect(ageExtraCheck?.value, equals('19'));

      // Check Berth
      final berthExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Berth',
        orElse: () => throw StateError('No Berth extra'),
      );
      expect(berthExtra?.value, equals('S4/26/MB'));

      // Check info tag (status)
      final infoTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'info',
        orElse: () => throw StateError('No info tag'),
      );
      expect(infoTag?.value, equals('CNF'));

      // Check From
      final fromExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'From',
        orElse: () => throw StateError('No From extra'),
      );
      expect(fromExtraCheck?.value, equals('Ksr Bengaluru (SBC)'));

      // Check Distance
      final distanceExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Distance',
        orElse: () => throw StateError('No Distance extra'),
      );
      expect(distanceExtra?.value, equals('362 KM'));

      // Check IRCTC Fee
      final irctcFeeExtraCheck = ticket.extras?.firstWhere(
        (e) => e.title == 'IRCTC Fee',
        orElse: () => throw StateError('No IRCTC Fee extra'),
      );
      expect(irctcFeeExtraCheck?.value, equals('17.70'));

      // Check Fare
      final fareExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Fare',
        orElse: () => throw StateError('No Fare extra'),
      );
      expect(fareExtra?.value, equals('1367.70'));

      // Check Departure extra exists (timezone-dependent value)
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure',
        orElse: () => throw StateError('No Departure extra'),
      );
      expect(departureExtra?.value, isNotNull);

      // Check Date of Journey extra exists (timezone-dependent value)
      final dojExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Date of Journey',
        orElse: () => throw StateError('No Date of Journey extra'),
      );
      expect(dojExtra?.value, isNotNull);
    });

    test('should parse 4565161618 from OCR blocks', () {
      final blocks = IrctcLayoutFixtures.irctc_4565161618;
      final ticket = parser.parseTicketFromBlocks(blocks);

      expect(ticket, isNotNull);
      expect(ticket.ticketId, equals('4565161618'));

      final departureExtra = ticket.extras
          ?.where((e) => e.title == 'Departure')
          .firstOrNull;

      expect(departureExtra, isNotNull);
      expect(departureExtra?.value, isNull);
    });
  });
}
