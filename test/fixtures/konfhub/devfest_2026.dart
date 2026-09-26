import 'dart:ui';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

// Generated fixture from: Ticket (1).pdf
// Total blocks: 28

final sampleOCRBlocks = <OCRBlock>[
  OCRBlock(
    text: 'Booking ID: 870ef2aa',
    boundingBox: const Rect.fromLTRB(
      0,
      20,
      100,
      40,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Booking Date: Sep 06, 2026',
    boundingBox: const Rect.fromLTRB(
      0,
      40,
      100,
      60,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Professional - IDC Exclusive',
    boundingBox: const Rect.fromLTRB(
      0,
      60,
      100,
      80,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Keerthivasan S',
    boundingBox: const Rect.fromLTRB(
      0,
      100,
      100,
      120,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Thiran Technologies',
    boundingBox: const Rect.fromLTRB(
      0,
      140,
      100,
      160,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Event Name',
    boundingBox: const Rect.fromLTRB(
      0,
      180,
      100,
      200,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'DevFest 2026 Chennai',
    boundingBox: const Rect.fromLTRB(
      0,
      220,
      100,
      240,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Date & Time',
    boundingBox: const Rect.fromLTRB(
      0,
      260,
      100,
      280,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Oct 17 (08:30 AM to 6PM IST)',
    boundingBox: const Rect.fromLTRB(
      0,
      300,
      100,
      320,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Add-ons',
    boundingBox: const Rect.fromLTRB(
      0,
      340,
      100,
      360,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'GDG Chennai Tshirt (1), Bike parking (1)',
    boundingBox: const Rect.fromLTRB(
      0,
      380,
      100,
      400,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Venue',
    boundingBox: const Rect.fromLTRB(
      0,
      420,
      100,
      440,
    ),
    page: 0,
  ),
  OCRBlock(
    text:
        'IIT Madras Research Park, MGR Film City Road, Kanagam, Tharamani, '
        'Chennai, Tamil Nadu,',
    boundingBox: const Rect.fromLTRB(
      0,
      460,
      100,
      480,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'India',
    boundingBox: const Rect.fromLTRB(
      0,
      480,
      100,
      500,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Additional Venue Details',
    boundingBox: const Rect.fromLTRB(
      0,
      520,
      100,
      540,
    ),
    page: 0,
  ),
  OCRBlock(
    text: '•',
    boundingBox: const Rect.fromLTRB(
      0,
      580,
      100,
      600,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Parking available at the venue',
    boundingBox: const Rect.fromLTRB(
      0,
      600,
      100,
      620,
    ),
    page: 0,
  ),
  OCRBlock(
    text: '•',
    boundingBox: const Rect.fromLTRB(
      0,
      620,
      100,
      640,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Please bring your own refillable water bottles',
    boundingBox: const Rect.fromLTRB(
      0,
      640,
      100,
      660,
    ),
    page: 0,
  ),
  OCRBlock(
    text: '•',
    boundingBox: const Rect.fromLTRB(
      0,
      660,
      100,
      680,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Weather advisory - Please stay prepared for rain/sun',
    boundingBox: const Rect.fromLTRB(
      0,
      680,
      100,
      700,
    ),
    page: 0,
  ),
  OCRBlock(
    text: '•',
    boundingBox: const Rect.fromLTRB(
      0,
      20,
      100,
      40,
    ),
    page: 1,
  ),
  OCRBlock(
    text: 'We serve only pure-veg food during the event',
    boundingBox: const Rect.fromLTRB(
      0,
      40,
      100,
      60,
    ),
    page: 1,
  ),
  OCRBlock(
    text: '•',
    boundingBox: const Rect.fromLTRB(
      0,
      60,
      100,
      80,
    ),
    page: 1,
  ),
  OCRBlock(
    text: 'Basic first-aid and sanitary facilities available',
    boundingBox: const Rect.fromLTRB(
      0,
      80,
      100,
      100,
    ),
    page: 1,
  ),
  OCRBlock(
    text: '•',
    boundingBox: const Rect.fromLTRB(
      0,
      100,
      100,
      120,
    ),
    page: 1,
  ),
  OCRBlock(
    text:
        'We do not have specific medical facilities (if any requests, '
        'please discuss with us -',
    boundingBox: const Rect.fromLTRB(
      0,
      120,
      100,
      140,
    ),
    page: 1,
  ),
  OCRBlock(
    text: 'gdgchennaiteam@gmail.com)',
    boundingBox: const Rect.fromLTRB(
      0,
      140,
      100,
      160,
    ),
    page: 1,
  ),
];

const Map<String, Object> devfest2026Expected = {
  'bookingId': '870ef2aa',
  'bookingYear': 2026,
  'bookingMonth': 9,
  'bookingDay': 6,
  'attendeeName': 'Keerthivasan S',
  'organization': 'Thiran Technologies',
  'eventName': 'DevFest 2026 Chennai',
  'eventYear': 2026,
  'eventMonth': 10,
  'eventDay': 17,
  'startHour': 8,
  'startMinute': 30,
  'endHour': 18,
  'endMinute': 0,
  'ticketName': 'Professional - IDC Exclusive',
  'location':
      'IIT Madras Research Park, MGR Film City Road, Kanagam, Tharamani, '
      'Chennai, Tamil Nadu, India',
  'addOns': 'GDG Chennai Tshirt (1), Bike parking (1)',
  'additionalVenueDetails':
      '• Parking available at the venue\n'
      '• Please bring your own refillable water bottles\n'
      '• Weather advisory - Please stay prepared for rain/sun\n'
      '• We serve only pure-veg food during the event\n'
      '• Basic first-aid and sanitary facilities available\n'
      '• We do not have specific medical facilities (if any requests, '
      'please discuss with us - gdgchennaiteam@gmail.com)',
};
