import 'dart:ui';

import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

/// OCR block fixtures for layout-based TNSTC parsing tests.
///
/// These fixtures contain OCR blocks extracted from real TNSTC PDF tickets.
/// Use these to test the layout-based parser with realistic data.
class TnstcLayoutFixtures {
  /// SETC ticket: Chennai to Kumbakonam (14/01/2026)
  /// PNR: T73266848
  /// Route: 307AB
  /// Class: AC SLEEPER SEATER
  ///
  /// Note: This fixture uses pseudo-blocks (extracted as plain text).
  /// For testing with real OCR layout data, use actual PDF OCR extraction.
  static final t73266848 = <OCRBlock>[
    OCRBlock(
      text: 'E-Ticket/Reservation Voucher',
      boundingBox: const Rect.fromLTRB(0, 0, 100, 20),
      page: 0,
    ),
    OCRBlock(
      text: 'Corporation :',
      boundingBox: const Rect.fromLTRB(0, 40, 100, 60),
      page: 0,
    ),
    OCRBlock(
      text: 'SETC',
      boundingBox: const Rect.fromLTRB(0, 60, 100, 80),
      page: 0,
    ),
    OCRBlock(
      text: 'PNR Number :',
      boundingBox: const Rect.fromLTRB(0, 80, 100, 100),
      page: 0,
    ),
    OCRBlock(
      text: 'T73266848',
      boundingBox: const Rect.fromLTRB(0, 100, 100, 120),
      page: 0,
    ),
    OCRBlock(
      text: 'Date of Journey :',
      boundingBox: const Rect.fromLTRB(0, 120, 100, 140),
      page: 0,
    ),
    OCRBlock(
      text: '14/01/2026',
      boundingBox: const Rect.fromLTRB(0, 140, 100, 160),
      page: 0,
    ),
    OCRBlock(
      text: 'Route No :',
      boundingBox: const Rect.fromLTRB(0, 160, 100, 180),
      page: 0,
    ),
    OCRBlock(
      text: '307AB',
      boundingBox: const Rect.fromLTRB(0, 180, 100, 200),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Place :',
      boundingBox: const Rect.fromLTRB(0, 200, 100, 220),
      page: 0,
    ),
    OCRBlock(
      text: 'CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(0, 220, 100, 240),
      page: 0,
    ),
    OCRBlock(
      text: 'Service End Place :',
      boundingBox: const Rect.fromLTRB(0, 240, 100, 260),
      page: 0,
    ),
    OCRBlock(
      text: 'KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(0, 260, 100, 280),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Time :',
      boundingBox: const Rect.fromLTRB(0, 280, 100, 300),
      page: 0,
    ),
    OCRBlock(
      text: '23:30',
      boundingBox: const Rect.fromLTRB(0, 300, 100, 320),
      page: 0,
    ),
    OCRBlock(
      text: 'Hrs.',
      boundingBox: const Rect.fromLTRB(0, 320, 100, 340),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Start Place :',
      boundingBox: const Rect.fromLTRB(0, 380, 100, 400),
      page: 0,
    ),
    OCRBlock(
      text: 'CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(0, 400, 100, 420),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger End Place :',
      boundingBox: const Rect.fromLTRB(0, 420, 100, 440),
      page: 0,
    ),
    OCRBlock(
      text: 'KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(0, 440, 100, 460),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Pickup Point :',
      boundingBox: const Rect.fromLTRB(0, 460, 100, 480),
      page: 0,
    ),
    OCRBlock(
      text: 'CHENNAI-PT Dr.M.G.R. BS',
      boundingBox: const Rect.fromLTRB(0, 480, 100, 500),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Pickup Time :',
      boundingBox: const Rect.fromLTRB(0, 500, 100, 520),
      page: 0,
    ),
    OCRBlock(
      text: '14/01/2026 23:30',
      boundingBox: const Rect.fromLTRB(0, 520, 100, 540),
      page: 0,
    ),
    OCRBlock(
      text: 'Hrs.',
      boundingBox: const Rect.fromLTRB(0, 540, 100, 560),
      page: 0,
    ),
    OCRBlock(
      text: 'Platform Number :',
      boundingBox: const Rect.fromLTRB(0, 560, 100, 580),
      page: 0,
    ),
    OCRBlock(
      text: '2',
      boundingBox: const Rect.fromLTRB(0, 580, 100, 600),
      page: 0,
    ),
    OCRBlock(
      text: 'Class of Service :',
      boundingBox: const Rect.fromLTRB(0, 600, 100, 620),
      page: 0,
    ),
    OCRBlock(
      text: 'AC SLEEPER SEATER',
      boundingBox: const Rect.fromLTRB(0, 620, 100, 640),
      page: 0,
    ),
    OCRBlock(
      text: 'Trip Code :',
      boundingBox: const Rect.fromLTRB(0, 640, 100, 660),
      page: 0,
    ),
    OCRBlock(
      text: '2330CHEKUMAB',
      boundingBox: const Rect.fromLTRB(0, 660, 100, 680),
      page: 0,
    ),
    OCRBlock(
      text: 'OB Reference No. :',
      boundingBox: const Rect.fromLTRB(0, 680, 100, 700),
      page: 0,
    ),
    OCRBlock(
      text: 'OB31464175',
      boundingBox: const Rect.fromLTRB(0, 700, 100, 720),
      page: 0,
    ),
    OCRBlock(
      text: 'No. of Seats :',
      boundingBox: const Rect.fromLTRB(0, 720, 100, 740),
      page: 0,
    ),
    OCRBlock(
      text: '1 (Adults=1 ; Children=0)',
      boundingBox: const Rect.fromLTRB(0, 740, 100, 760),
      page: 0,
    ),
    OCRBlock(
      text: 'Bank Txn. No. :',
      boundingBox: const Rect.fromLTRB(0, 760, 100, 780),
      page: 0,
    ),
    OCRBlock(
      text: 'BAX6AHY12IIXAW',
      boundingBox: const Rect.fromLTRB(0, 780, 100, 800),
      page: 0,
    ),
    OCRBlock(
      text: 'Bus ID No. :',
      boundingBox: const Rect.fromLTRB(0, 800, 100, 820),
      page: 0,
    ),
    OCRBlock(
      text: 'E-3269',
      boundingBox: const Rect.fromLTRB(0, 820, 100, 840),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger category :',
      boundingBox: const Rect.fromLTRB(0, 840, 100, 860),
      page: 0,
    ),
    OCRBlock(
      text: 'GENERAL PUBLIC',
      boundingBox: const Rect.fromLTRB(0, 860, 100, 880),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Information',
      boundingBox: const Rect.fromLTRB(0, 880, 100, 900),
      page: 0,
    ),
    OCRBlock(
      text: 'Name',
      boundingBox: const Rect.fromLTRB(0, 900, 100, 920),
      page: 0,
    ),
    OCRBlock(
      text: 'Age',
      boundingBox: const Rect.fromLTRB(0, 920, 100, 940),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult/Child',
      boundingBox: const Rect.fromLTRB(0, 940, 100, 960),
      page: 0,
    ),
    OCRBlock(
      text: 'Gender',
      boundingBox: const Rect.fromLTRB(0, 960, 100, 980),
      page: 0,
    ),
    OCRBlock(
      text: 'Seat No.',
      boundingBox: const Rect.fromLTRB(0, 980, 100, 1000),
      page: 0,
    ),
    OCRBlock(
      text: 'HarishAnbalagan',
      boundingBox: const Rect.fromLTRB(0, 1000, 100, 1020),
      page: 0,
    ),
    OCRBlock(
      text: '26',
      boundingBox: const Rect.fromLTRB(0, 1020, 100, 1040),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult',
      boundingBox: const Rect.fromLTRB(0, 1040, 100, 1060),
      page: 0,
    ),
    OCRBlock(
      text: 'M',
      boundingBox: const Rect.fromLTRB(0, 1060, 100, 1080),
      page: 0,
    ),
    OCRBlock(
      text: '10UB',
      boundingBox: const Rect.fromLTRB(0, 1080, 100, 1100),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Type :',
      boundingBox: const Rect.fromLTRB(0, 1100, 100, 1120),
      page: 0,
    ),
    OCRBlock(
      text: 'Government Issued Photo',
      boundingBox: const Rect.fromLTRB(0, 1140, 100, 1160),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card',
      boundingBox: const Rect.fromLTRB(0, 1160, 100, 1180),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Number :',
      boundingBox: const Rect.fromLTRB(0, 1180, 100, 1200),
      page: 0,
    ),
    OCRBlock(
      text: '736960775578',
      boundingBox: const Rect.fromLTRB(0, 1220, 100, 1240),
      page: 0,
    ),
    OCRBlock(
      text: 'Total Fare : 740.00 Rs.',
      boundingBox: const Rect.fromLTRB(0, 1240, 100, 1260),
      page: 0,
    ),
  ];

  /// Expected parsed values for t73266848 fixture
  static const Map<String, Object?> t73266848Expected = {
    'pnrNumber': 'T73266848',
    'corporation': 'SETC',
    'journeyDate': '14/01/2026',
    'routeNo': '307AB',
    'serviceStartPlace': 'CHENNAI-PT DR. M.G.R. BS',
    'serviceEndPlace': 'KUMBAKONAM',
    'serviceStartTime': '23:30',
    'passengerPickupPoint': 'CHENNAI-PT Dr.M.G.R. BS',
    'platformNumber': '2',
    'classOfService': 'AC SLEEPER SEATER',
    'tripCode': '2330CHEKUMAB',
    'busIdNumber': 'E-3269',
    'totalFare': 740.00,
    // Passenger details can't be extracted from pseudo-blocks without labels
    'passengerName': null,
    'passengerAge': null,
    'passengerGender': null,
    'seatNumber': '10UB',
  };

  /// SETC ticket 2: Chennai to Kumbakonam (28/11/2025)
  /// PNR: T73289588
  /// Route: 307ELB
  /// Class: NON AC LOWER BERTH SEATER
  ///
  /// Note: This fixture uses pseudo-blocks (extracted as plain text).
  static final t73289588 = <OCRBlock>[
    OCRBlock(
      text: 'E-Ticket/Reservation Voucher',
      boundingBox: const Rect.fromLTRB(0, 0, 100, 20),
      page: 0,
    ),
    OCRBlock(
      text: 'Corporation :',
      boundingBox: const Rect.fromLTRB(0, 40, 100, 60),
      page: 0,
    ),
    OCRBlock(
      text: 'SETC',
      boundingBox: const Rect.fromLTRB(0, 60, 100, 80),
      page: 0,
    ),
    OCRBlock(
      text: 'PNR Number :',
      boundingBox: const Rect.fromLTRB(0, 80, 100, 100),
      page: 0,
    ),
    OCRBlock(
      text: 'T73289588',
      boundingBox: const Rect.fromLTRB(0, 100, 100, 120),
      page: 0,
    ),
    OCRBlock(
      text: 'Date of Journey :',
      boundingBox: const Rect.fromLTRB(0, 120, 100, 140),
      page: 0,
    ),
    OCRBlock(
      text: '28/11/2025',
      boundingBox: const Rect.fromLTRB(0, 140, 100, 160),
      page: 0,
    ),
    OCRBlock(
      text: 'Route No :',
      boundingBox: const Rect.fromLTRB(0, 160, 100, 180),
      page: 0,
    ),
    OCRBlock(
      text: '307ELB',
      boundingBox: const Rect.fromLTRB(0, 180, 100, 200),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Place :',
      boundingBox: const Rect.fromLTRB(0, 200, 100, 220),
      page: 0,
    ),
    OCRBlock(
      text: 'CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(0, 220, 100, 240),
      page: 0,
    ),
    OCRBlock(
      text: 'Service End Place :',
      boundingBox: const Rect.fromLTRB(0, 240, 100, 260),
      page: 0,
    ),
    OCRBlock(
      text: 'KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(0, 260, 100, 280),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Time :',
      boundingBox: const Rect.fromLTRB(0, 280, 100, 300),
      page: 0,
    ),
    OCRBlock(
      text: '22:00',
      boundingBox: const Rect.fromLTRB(0, 300, 100, 320),
      page: 0,
    ),
    OCRBlock(
      text: 'Hrs.',
      boundingBox: const Rect.fromLTRB(0, 320, 100, 340),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Start Place :',
      boundingBox: const Rect.fromLTRB(0, 380, 100, 400),
      page: 0,
    ),
    OCRBlock(
      text: 'CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(0, 400, 100, 420),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger End Place :',
      boundingBox: const Rect.fromLTRB(0, 420, 100, 440),
      page: 0,
    ),
    OCRBlock(
      text: 'KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(0, 440, 100, 460),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Pickup Point :',
      boundingBox: const Rect.fromLTRB(0, 460, 100, 480),
      page: 0,
    ),
    OCRBlock(
      text: 'KOTTIVAKKAM(RTO',
      boundingBox: const Rect.fromLTRB(0, 480, 100, 500),
      page: 0,
    ),
    OCRBlock(
      text: 'OFFICE)',
      boundingBox: const Rect.fromLTRB(0, 500, 100, 520),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Pickup Time :',
      boundingBox: const Rect.fromLTRB(0, 520, 100, 540),
      page: 0,
    ),
    OCRBlock(
      text: '28/11/2025 22:55',
      boundingBox: const Rect.fromLTRB(0, 540, 100, 560),
      page: 0,
    ),
    OCRBlock(
      text: 'Hrs.',
      boundingBox: const Rect.fromLTRB(0, 560, 100, 580),
      page: 0,
    ),
    OCRBlock(
      text: 'Platform Number :',
      boundingBox: const Rect.fromLTRB(0, 580, 100, 600),
      page: 0,
    ),
    OCRBlock(
      text: '2',
      boundingBox: const Rect.fromLTRB(0, 600, 100, 620),
      page: 0,
    ),
    OCRBlock(
      text: 'Class of Service :',
      boundingBox: const Rect.fromLTRB(0, 620, 100, 640),
      page: 0,
    ),
    OCRBlock(
      text: 'NON AC LOWER BERTH',
      boundingBox: const Rect.fromLTRB(0, 640, 100, 660),
      page: 0,
    ),
    OCRBlock(
      text: 'SEATER',
      boundingBox: const Rect.fromLTRB(0, 660, 100, 680),
      page: 0,
    ),
    OCRBlock(
      text: 'Trip Code :',
      boundingBox: const Rect.fromLTRB(0, 680, 100, 700),
      page: 0,
    ),
    OCRBlock(
      text: '2200CHEKUMLB',
      boundingBox: const Rect.fromLTRB(0, 700, 100, 720),
      page: 0,
    ),
    OCRBlock(
      text: 'OB Reference No. :',
      boundingBox: const Rect.fromLTRB(0, 720, 100, 740),
      page: 0,
    ),
    OCRBlock(
      text: 'OB31470112',
      boundingBox: const Rect.fromLTRB(0, 740, 100, 760),
      page: 0,
    ),
    OCRBlock(
      text: 'No. of Seats :',
      boundingBox: const Rect.fromLTRB(0, 760, 100, 780),
      page: 0,
    ),
    OCRBlock(
      text: '1 (Adults=1 ; Children=0)',
      boundingBox: const Rect.fromLTRB(0, 780, 100, 800),
      page: 0,
    ),
    OCRBlock(
      text: 'Bank Txn. No. :',
      boundingBox: const Rect.fromLTRB(0, 800, 100, 820),
      page: 0,
    ),
    OCRBlock(
      text: 'BAX6T2M12LV5QL',
      boundingBox: const Rect.fromLTRB(0, 820, 100, 840),
      page: 0,
    ),
    OCRBlock(
      text: 'Bus ID No. :',
      boundingBox: const Rect.fromLTRB(0, 840, 100, 860),
      page: 0,
    ),
    OCRBlock(
      text: 'E-4950',
      boundingBox: const Rect.fromLTRB(0, 860, 100, 880),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger category :',
      boundingBox: const Rect.fromLTRB(0, 880, 100, 900),
      page: 0,
    ),
    OCRBlock(
      text: 'GENERAL PUBLIC',
      boundingBox: const Rect.fromLTRB(0, 900, 100, 920),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Information',
      boundingBox: const Rect.fromLTRB(0, 920, 100, 940),
      page: 0,
    ),
    OCRBlock(
      text: 'Name',
      boundingBox: const Rect.fromLTRB(0, 940, 100, 960),
      page: 0,
    ),
    OCRBlock(
      text: 'Age',
      boundingBox: const Rect.fromLTRB(0, 960, 100, 980),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult/Child',
      boundingBox: const Rect.fromLTRB(0, 980, 100, 1000),
      page: 0,
    ),
    OCRBlock(
      text: 'Gender',
      boundingBox: const Rect.fromLTRB(0, 1000, 100, 1020),
      page: 0,
    ),
    OCRBlock(
      text: 'Seat No.',
      boundingBox: const Rect.fromLTRB(0, 1020, 100, 1040),
      page: 0,
    ),
    OCRBlock(
      text: 'HarishAnbalagan',
      boundingBox: const Rect.fromLTRB(0, 1040, 100, 1060),
      page: 0,
    ),
    OCRBlock(
      text: '26',
      boundingBox: const Rect.fromLTRB(0, 1060, 100, 1080),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult',
      boundingBox: const Rect.fromLTRB(0, 1080, 100, 1100),
      page: 0,
    ),
    OCRBlock(
      text: 'M',
      boundingBox: const Rect.fromLTRB(0, 1100, 100, 1120),
      page: 0,
    ),
    OCRBlock(
      text: '2LB',
      boundingBox: const Rect.fromLTRB(0, 1120, 100, 1140),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Type :',
      boundingBox: const Rect.fromLTRB(0, 1140, 100, 1160),
      page: 0,
    ),
    OCRBlock(
      text: 'Government Issued Photo',
      boundingBox: const Rect.fromLTRB(0, 1180, 100, 1200),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card',
      boundingBox: const Rect.fromLTRB(0, 1200, 100, 1220),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Number :',
      boundingBox: const Rect.fromLTRB(0, 1220, 100, 1240),
      page: 0,
    ),
    OCRBlock(
      text: '736960775578',
      boundingBox: const Rect.fromLTRB(0, 1260, 100, 1280),
      page: 0,
    ),
    OCRBlock(
      text: 'Total Fare : 555.00 Rs.',
      boundingBox: const Rect.fromLTRB(0, 1280, 100, 1300),
      page: 0,
    ),
  ];

  /// Expected parsed values for t73289588 fixture
  static const Map<String, Object?> t73289588Expected = {
    'pnrNumber': 'T73289588',
    'corporation': 'SETC',
    'journeyDate': '28/11/2025',
    'routeNo': '307ELB',
    'serviceStartPlace': 'CHENNAI-PT DR. M.G.R. BS',
    'serviceEndPlace': 'KUMBAKONAM',
    'serviceStartTime': '22:00',
    'passengerPickupPoint': 'KOTTIVAKKAM(RTO OFFICE)',
    'platformNumber': '2',
    'classOfService': 'NON AC LOWER BERTH',
    'tripCode': '2200CHEKUMLB',
    'busIdNumber': 'E-4950',
    'totalFare': 555.00,
    // Passenger details can't be extracted from pseudo-blocks without labels
    'passengerName': null,
    'passengerAge': null,
    'passengerGender': null,
    'seatNumber': '2LB',
  };

  /// SETC ticket 3: Kumbakonam to Chennai (18/01/2026)
  /// PNR: T73309927
  /// Route: 307AB
  /// Class: AC SLEEPER SEATER
  ///
  /// Note: This fixture uses REAL OCR blocks with actual bounding boxes
  /// from PDF extraction (not pseudo-blocks).
  static final t73309927 = <OCRBlock>[
    OCRBlock(
      text: 'BlỘBTC J GUITŠGNJH5IŠ Bpsb',
      boundingBox: const Rect.fromLTRB(321, 47, 863, 79),
      page: 0,
    ),
    OCRBlock(
      text: 'Tamil Nadu State Transport Corporation Ltd.',
      boundingBox: const Rect.fromLTRB(341, 79, 848, 102),
      page: 0,
    ),
    OCRBlock(
      text: '(A GOVERNMENT OF TAMILNADU UNDERTAKING)',
      boundingBox: const Rect.fromLTRB(415, 107, 799, 120),
      page: 0,
    ),
    OCRBlock(
      text: 'E-Ticket/Reservation Voucher-H',
      boundingBox: const Rect.fromLTRB(443, 142, 743, 157),
      page: 0,
    ),
    OCRBlock(
      text: 'Corporation : SETC',
      boundingBox: const Rect.fromLTRB(241, 216, 417, 236),
      page: 0,
    ),
    OCRBlock(
      text: 'Date of Journey : 18/01/2026',
      boundingBox: const Rect.fromLTRB(207, 248, 463, 269),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Place: KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(178, 279, 479, 297),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Time: 13:15 Hrs.',
      boundingBox: const Rect.fromLTRB(182, 311, 438, 329),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Start Place : KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(157, 342, 479, 358),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Pickup Point : KUMBAKONAM',
      boundingBox: const Rect.fromLTRB(148, 372, 479, 388),
      page: 0,
    ),
    OCRBlock(
      text: 'Platform',
      boundingBox: const Rect.fromLTRB(188, 399, 263, 417),
      page: 0,
    ),
    OCRBlock(
      text: 'Number:',
      boundingBox: const Rect.fromLTRB(267, 400, 347, 418),
      page: 0,
    ),
    OCRBlock(
      text: 'Trip Code : 1315KUMCHEAB',
      boundingBox: const Rect.fromLTRB(258, 432, 494, 447),
      page: 0,
    ),
    OCRBlock(
      text: 'No. of Seats : 1 (Adults=1 Children=0)',
      boundingBox: const Rect.fromLTRB(235, 462, 575, 476),
      page: 0,
    ),
    OCRBlock(
      text: 'Bus ID No. : E-5494',
      boundingBox: const Rect.fromLTRB(230, 494, 434, 507),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Information',
      boundingBox: const Rect.fromLTRB(139, 530, 502, 557),
      page: 0,
    ),
    OCRBlock(
      text: 'Name',
      boundingBox: const Rect.fromLTRB(139, 576, 190, 588),
      page: 0,
    ),
    OCRBlock(
      text: 'HarishAnbalagan',
      boundingBox: const Rect.fromLTRB(138, 601, 275, 620),
      page: 0,
    ),
    OCRBlock(
      text: 'PNR Number : T73309927',
      boundingBox: const Rect.fromLTRB(685, 219, 904, 231),
      page: 0,
    ),
    OCRBlock(
      text: 'Route No : 307AB',
      boundingBox: const Rect.fromLTRB(713, 251, 863, 265),
      page: 0,
    ),
    OCRBlock(
      text: 'Service End Place : CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(643, 282, 1036, 294),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger End Place : CHENNAI-PT Dr.M.G.R. BS',
      boundingBox: const Rect.fromLTRB(620, 342, 1027, 356),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Pickup Time: 18/01/2026 13:15 Hrs.',
      boundingBox: const Rect.fromLTRB(601, 372, 1003, 387),
      page: 0,
    ),
    OCRBlock(
      text: 'Class of Service : AC SLEEPER SEATER',
      boundingBox: const Rect.fromLTRB(658, 402, 978, 414),
      page: 0,
    ),
    OCRBlock(
      text: 'OB Reference No. : OB31475439',
      boundingBox: const Rect.fromLTRB(643, 432, 917, 444),
      page: 0,
    ),
    OCRBlock(
      text: 'Bank Txn. No; : BAX6K8N 12PUH74',
      boundingBox: const Rect.fromLTRB(672, 462, 967, 476),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger category: GENERAL PUBLIC',
      boundingBox: const Rect.fromLTRB(628, 494, 954, 509),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult/Child',
      boundingBox: const Rect.fromLTRB(653, 576, 758, 590),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult',
      boundingBox: const Rect.fromLTRB(686, 602, 728, 616),
      page: 0,
    ),
    OCRBlock(
      text: 'Gender',
      boundingBox: const Rect.fromLTRB(811, 575, 877, 590),
      page: 0,
    ),
    OCRBlock(
      text: 'M',
      boundingBox: const Rect.fromLTRB(838, 604, 849, 615),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Number : 736960775578',
      boundingBox: const Rect.fromLTRB(627, 648, 928, 660),
      page: 0,
    ),
    OCRBlock(
      text: 'Seat :No.',
      boundingBox: const Rect.fromLTRB(943, 572, 1019, 589),
      page: 0,
    ),
    OCRBlock(
      text: '4UB',
      boundingBox: const Rect.fromLTRB(965, 603, 997, 617),
      page: 0,
    ),
    OCRBlock(
      text: 'Age',
      boundingBox: const Rect.fromLTRB(553, 576, 586, 591),
      page: 0,
    ),
    OCRBlock(
      text: '26',
      boundingBox: const Rect.fromLTRB(560, 604, 579, 615),
      page: 0,
    ),
    OCRBlock(
      text: 'Government Issued Photo',
      boundingBox: const Rect.fromLTRB(332, 636, 573, 648),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Type rD Card',
      boundingBox: const Rect.fromLTRB(196, 642, 389, 673),
      page: 0,
    ),
    OCRBlock(
      text: 'Total Fare : 735.00 Rs.',
      boundingBox: const Rect.fromLTRB(141, 698, 518, 721),
      page: 0,
    ),
  ];

  /// Expected parsed values for t73309927 fixture
  static const Map<String, Object?> t73309927Expected = {
    'pnrNumber': 'T73309927',
    'corporation': 'SETC',
    'journeyDate': '18/01/2026',
    'routeNo': '307AB',
    'serviceStartPlace': 'KUMBAKONAM',
    'serviceEndPlace': 'CHENNAI-PT DR. M.G.R. BS',
    'serviceStartTime': '13:15',
    'passengerPickupPoint': 'KUMBAKONAM',
    'platformNumber': null, // Platform Number value is on separate line
    'classOfService': 'AC SLEEPER SEATER',
    'tripCode': '1315KUMCHEAB',
    'busIdNumber': 'E-5494',
    'totalFare': 735.00,
    'passengerName': 'HarishAnbalagan',
    'passengerAge': 26,
    'passengerGender': 'M',
    // Seat label is 'Seat :No.' which parser doesn't recognize
    'seatNumber': null,
  };

  /// SETC ticket 4: Chennai to Bengaluru (12/12/2025)
  /// PNR: T73910447
  /// Route: 831NS
  /// Class: NON AC SLEEPER SEATER
  static final t73910447 = <OCRBlock>[
    OCRBlock(
      text: 'Tamil Nadu State Transport Corporation Ltd.',
      boundingBox: const Rect.fromLTRB(342, 81, 840, 100),
      page: 0,
    ),
    OCRBlock(
      text: '(A GOVERN MENT OF TAMILNADU UNDERTAKING)',
      boundingBox: const Rect.fromLTRB(416, 103, 800, 121),
      page: 0,
    ),
    OCRBlock(
      text: 'E-Ticket/Reservation Voucher',
      boundingBox: const Rect.fromLTRB(456, 142, 734, 156),
      page: 0,
    ),
    OCRBlock(
      text: 'PNR Number: T73910447',
      boundingBox: const Rect.fromLTRB(675, 200, 904, 218),
      page: 0,
    ),
    OCRBlock(
      text: 'Route No : 831NS',
      boundingBox: const Rect.fromLTRB(715, 235, 865, 246),
      page: 0,
    ),
    OCRBlock(
      text: 'Service End Place: BENGALURU',
      boundingBox: const Rect.fromLTRB(641, 258, 913, 275),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger End Place : SHANTHI NAGAR BS',
      boundingBox: const Rect.fromLTRB(622, 317, 980, 332),
      page: 0,
    ),
    OCRBlock(
      text: 'Corporation : SETC',
      boundingBox: const Rect.fromLTRB(242, 202, 417, 219),
      page: 0,
    ),
    OCRBlock(
      text: 'Date of Journey : 12/12/2025',
      boundingBox: const Rect.fromLTRB(208, 234, 463, 249),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Place: CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(182, 262, 586, 274),
      page: 0,
    ),
    OCRBlock(
      text: 'Service Start Time: 21:00 Hrs.',
      boundingBox: const Rect.fromLTRB(185, 287, 441, 304),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Start Place : CHENNAI-PT DR. M.G.R. BS',
      boundingBox: const Rect.fromLTRB(160, 317, 586, 333),
      page: 0,
    ),
    OCRBlock(
      text:
          'Passenger Pickup Point : CHENNAI-PT Dr.M.G.R. BS Passenger Pickup Time: 12/12/2025 21:00 Hrs.',
      boundingBox: const Rect.fromLTRB(149, 343, 1002, 361),
      page: 0,
    ),
    OCRBlock(
      text: 'Platform Number :',
      boundingBox: const Rect.fromLTRB(198, 373, 348, 385),
      page: 0,
    ),
    OCRBlock(
      text: 'Trip Code: 2100CHEBANNS',
      boundingBox: const Rect.fromLTRB(253, 397, 493, 416),
      page: 0,
    ),
    OCRBlock(
      text: 'No. of Seats : 3 (Adults=3 Children=0)',
      boundingBox: const Rect.fromLTRB(238, 428, 576, 443),
      page: 0,
    ),
    OCRBlock(
      text: 'Bus ID No. : E-4892',
      boundingBox: const Rect.fromLTRB(231, 457, 435, 471),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger Information',
      boundingBox: const Rect.fromLTRB(139, 488, 349, 504),
      page: 0,
    ),
    OCRBlock(
      text: 'Name',
      boundingBox: const Rect.fromLTRB(139, 523, 191, 536),
      page: 0,
    ),
    OCRBlock(
      text: 'HarishAnbalagan',
      boundingBox: const Rect.fromLTRB(139, 548, 277, 565),
      page: 0,
    ),
    OCRBlock(
      text: 'Rogith',
      boundingBox: const Rect.fromLTRB(139, 570, 189, 587),
      page: 0,
    ),
    OCRBlock(
      text: 'Kumarank',
      boundingBox: const Rect.fromLTRB(140, 593, 222, 605),
      page: 0,
    ),
    OCRBlock(
      text: 'Age',
      boundingBox: const Rect.fromLTRB(553, 523, 587, 541),
      page: 0,
    ),
    OCRBlock(
      text: '26',
      boundingBox: const Rect.fromLTRB(560, 549, 578, 562),
      page: 0,
    ),
    OCRBlock(
      text: '21',
      boundingBox: const Rect.fromLTRB(561, 571, 577, 584),
      page: 0,
    ),
    OCRBlock(
      text: '24',
      boundingBox: const Rect.fromLTRB(561, 593, 579, 606),
      page: 0,
    ),
    OCRBlock(
      text: 'Government Issued Photo',
      boundingBox: const Rect.fromLTRB(334, 623, 574, 636),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Type TD Card',
      boundingBox: const Rect.fromLTRB(198, 629, 391, 660),
      page: 0,
    ),
    OCRBlock(
      text: 'Total Fare : 1990.00 Rs.',
      boundingBox: const Rect.fromLTRB(142, 677, 400, 692),
      page: 0,
    ),
    OCRBlock(
      text: 'Important',
      boundingBox: const Rect.fromLTRB(143, 736, 237, 753),
      page: 0,
    ),
    OCRBlock(
      text: '• The seat(s) booked under this ticket is/are not transferable.',
      boundingBox: const Rect.fromLTRB(184, 765, 698, 780),
      page: 0,
    ),
    OCRBlock(
      text:
          '• This e-ticket is valid only for the seat number and bus service specified herein.',
      boundingBox: const Rect.fromLTRB(184, 785, 850, 801),
      page: 0,
    ),
    OCRBlock(
      text:
          '• e-Ticket and Mobile Ticket Passengers must carry a printed/Soft copy of the ticket at the time of',
      boundingBox: const Rect.fromLTRB(184, 806, 1002, 821),
      page: 0,
    ),
    OCRBlock(
      text:
          'journey. It is passengers responsibility to keep the Printout/Softcopy of the ticket till end of the',
      boundingBox: const Rect.fromLTRB(201, 826, 994, 841),
      page: 0,
    ),
    OCRBlock(
      text: 'journey.',
      boundingBox: const Rect.fromLTRB(201, 847, 267, 861),
      page: 0,
    ),
    OCRBlock(
      text:
          "• If the passenger is traveling with 'e-Ticket/ Mobile Ticket', he will have to produce the Original",
      boundingBox: const Rect.fromLTRB(184, 866, 988, 881),
      page: 0,
    ),
    OCRBlock(
      text:
          "Identity Card mentioned in the 'e-Ticket / Mobile Ticket' at the time of journey.",
      boundingBox: const Rect.fromLTRB(203, 885, 862, 902),
      page: 0,
    ),
    OCRBlock(
      text:
          '• Departure time, Running time and Arrival time mentioned in the website is subject to standard',
      boundingBox: const Rect.fromLTRB(184, 907, 989, 922),
      page: 0,
    ),
    OCRBlock(
      text:
          'operating condition. These timings may get varied due to Road block, Traffic condition, Natural',
      boundingBox: const Rect.fromLTRB(203, 927, 987, 942),
      page: 0,
    ),
    OCRBlock(
      text: 'calamity and unavoidable circumstances.',
      boundingBox: const Rect.fromLTRB(203, 947, 540, 963),
      page: 0,
    ),
    OCRBlock(
      text:
          '• The Bus/Seat No. May be subject to change due to curtailment/clubbing of other services and',
      boundingBox: const Rect.fromLTRB(184, 968, 980, 983),
      page: 0,
    ),
    OCRBlock(
      text: 'unavoidable circumstances.',
      boundingBox: const Rect.fromLTRB(203, 988, 428, 1000),
      page: 0,
    ),
    OCRBlock(
      text: '• Please keep the ticket safely till the end of the journey.',
      boundingBox: const Rect.fromLTRB(184, 1008, 658, 1023),
      page: 0,
    ),
    OCRBlock(
      text: '• Please show the ticket at the time of checking.',
      boundingBox: const Rect.fromLTRB(184, 1028, 586, 1044),
      page: 0,
    ),
    OCRBlock(
      text:
          '• Corporation reserves the rights to change/cancel the class of service.',
      boundingBox: const Rect.fromLTRB(184, 1049, 775, 1063),
      page: 0,
    ),
    OCRBlock(
      text: '• Time is in 24 hour Railways time format(24HH:MM).',
      boundingBox: const Rect.fromLTRB(184, 1069, 633, 1084),
      page: 0,
    ),
    OCRBlock(
      text:
          '• Half ticket eligible for children between 5 to 12 years. Children above 130cms height will be charged',
      boundingBox: const Rect.fromLTRB(184, 1089, 1035, 1105),
      page: 0,
    ),
    OCRBlock(
      text:
          'full fare unless original age proof certificate is produced at time of journey.',
      boundingBox: const Rect.fromLTRB(202, 1109, 819, 1125),
      page: 0,
    ),
    OCRBlock(
      text:
          'Further, Full ticket fare will be charged for Sleeper Births for children.',
      boundingBox: const Rect.fromLTRB(203, 1130, 777, 1144),
      page: 0,
    ),
    OCRBlock(
      text:
          '• Cancellation of e-ticket / Mobile tickets is allowed only up to One (1) hour before the scheduled',
      boundingBox: const Rect.fromLTRB(184, 1150, 993, 1165),
      page: 0,
    ),
    OCRBlock(
      text:
          'departure of the bus service from the Origin Point. After that cancellation will not be allowed. Further,',
      boundingBox: const Rect.fromLTRB(203, 1170, 1044, 1185),
      page: 0,
    ),
    OCRBlock(
      text:
          'cancellation can be done only before 9 PM for the current date journey after 10 PM and next day',
      boundingBox: const Rect.fromLTRB(203, 1190, 1003, 1206),
      page: 0,
    ),
    OCRBlock(
      text: 'journey before 7 AM.',
      boundingBox: const Rect.fromLTRB(201, 1211, 374, 1226),
      page: 0,
    ),
    OCRBlock(
      text:
          '• For more detail please see the rules & Regulations in www.tnstc.in website.',
      boundingBox: const Rect.fromLTRB(184, 1231, 826, 1246),
      page: 0,
    ),
    OCRBlock(
      text:
          '• For Refund Status please contact to TNSTC Toll Free Number 08066006572/9513948001 or can',
      boundingBox: const Rect.fromLTRB(184, 1251, 995, 1266),
      page: 0,
    ),
    OCRBlock(
      text:
          'contact for Bank Queries-Billdesk / Helpdesk: 044-49076316 / 49076326.',
      boundingBox: const Rect.fromLTRB(203, 1268, 817, 1287),
      page: 0,
    ),
    OCRBlock(
      text: 'Booked By: () Printed On :08/12/2025 At :19:01:47',
      boundingBox: const Rect.fromLTRB(564, 1317, 1049, 1332),
      page: 0,
    ),
    OCRBlock(
      text: 'Close Print',
      boundingBox: const Rect.fromLTRB(524, 1337, 647, 1356),
      page: 0,
    ),
    OCRBlock(
      text: 'www.radiantinfo.com',
      boundingBox: const Rect.fromLTRB(499, 1422, 690, 1435),
      page: 0,
    ),
    OCRBlock(
      text: 'Class of Service : NON AC SLEEPER SEATER',
      boundingBox: const Rect.fromLTRB(659, 373, 1024, 385),
      page: 0,
    ),
    OCRBlock(
      text: 'OB Reference No. : OB31630966',
      boundingBox: const Rect.fromLTRB(645, 401, 919, 413),
      page: 0,
    ),
    OCRBlock(
      text: 'Bank Txn. No; : CAX6SFN14MSE8P',
      boundingBox: const Rect.fromLTRB(674, 428, 961, 442),
      page: 0,
    ),
    OCRBlock(
      text: 'Passenger category : GENERAL PUBLIC',
      boundingBox: const Rect.fromLTRB(630, 458, 956, 473),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult/Child',
      boundingBox: const Rect.fromLTRB(655, 523, 760, 537),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult',
      boundingBox: const Rect.fromLTRB(686, 548, 729, 562),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult',
      boundingBox: const Rect.fromLTRB(686, 570, 729, 585),
      page: 0,
    ),
    OCRBlock(
      text: 'Adult',
      boundingBox: const Rect.fromLTRB(686, 592, 729, 606),
      page: 0,
    ),
    OCRBlock(
      text: 'ID Card Number :',
      boundingBox: const Rect.fromLTRB(629, 634, 774, 646),
      page: 0,
    ),
    OCRBlock(
      text: 'Gender',
      boundingBox: const Rect.fromLTRB(813, 523, 877, 535),
      page: 0,
    ),
    OCRBlock(
      text: 'M',
      boundingBox: const Rect.fromLTRB(839, 550, 849, 560),
      page: 0,
    ),
    OCRBlock(
      text: 'M',
      boundingBox: const Rect.fromLTRB(840, 571, 850, 583),
      page: 0,
    ),
    OCRBlock(
      text: 'M',
      boundingBox: const Rect.fromLTRB(840, 593, 850, 606),
      page: 0,
    ),
    OCRBlock(
      text: '736960775578',
      boundingBox: const Rect.fromLTRB(791, 634, 930, 646),
      page: 0,
    ),
    OCRBlock(
      text: 'Seat No.',
      boundingBox: const Rect.fromLTRB(944, 523, 1019, 536),
      page: 0,
    ),
    OCRBlock(
      text: '10UB',
      boundingBox: const Rect.fromLTRB(962, 549, 1004, 563),
      page: 0,
    ),
    OCRBlock(
      text: '11UB',
      boundingBox: const Rect.fromLTRB(963, 571, 1004, 583),
      page: 0,
    ),
    OCRBlock(
      text: '120B',
      boundingBox: const Rect.fromLTRB(962, 592, 1004, 606),
      page: 0,
    ),
  ];

  /// Expected parsed values for t73910447 fixture
  static const Map<String, Object?> t73910447Expected = {
    'pnrNumber': 'T73910447',
    'corporation': 'SETC',
    'journeyDate': '12/12/2025',
    'routeNo': '831NS',
    'serviceStartPlace': 'CHENNAI-PT DR. M.G.R. BS',
    'serviceEndPlace': 'BENGALURU',
    'serviceStartTime': '21:00',
    'passengerPickupPoint': 'CHENNAI-PT Dr.M.G.R. BS',
    'platformNumber': '',
    'classOfService': 'NON AC SLEEPER SEATER',
    'tripCode': '2100CHEBANNS',
    'busIdNumber': 'E-4892',
    'totalFare': 1990.00,
    'passengerName': 'HarishAnbalagan, Rogith, Kumarank',
    'passengerAge': 26,
    'passengerGender': 'M',
    'seatNumber': '10UB, 11UB, 120B',
  };
}
