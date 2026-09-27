import 'dart:ui';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

// Generated fixture from: Ticket (2).pdf
// Total blocks: 8

final sampleOCRBlocks = <OCRBlock>[
  OCRBlock(
    text: 'Booking ID: b17c27a4',
    boundingBox: const Rect.fromLTRB(
      0,
      20,
      100,
      40,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Booking Date: Sep 23, 2026',
    boundingBox: const Rect.fromLTRB(
      0,
      40,
      100,
      60,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Professional Homie',
    boundingBox: const Rect.fromLTRB(
      0,
      60,
      100,
      80,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Karthick M.V.',
    boundingBox: const Rect.fromLTRB(
      0,
      100,
      100,
      120,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Event Name',
    boundingBox: const Rect.fromLTRB(
      0,
      140,
      100,
      160,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Flutter South India',
    boundingBox: const Rect.fromLTRB(
      0,
      180,
      100,
      200,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'Date & Time',
    boundingBox: const Rect.fromLTRB(
      0,
      220,
      100,
      240,
    ),
    page: 0,
  ),
  OCRBlock(
    text: 'October 10, 2026 (9 AM to 6 PM IST)',
    boundingBox: const Rect.fromLTRB(
      0,
      260,
      100,
      280,
    ),
    page: 0,
  ),
];

const Map<String, Object?> flutterSouthIndia2026Expected = {
  'bookingId': 'b17c27a4',
  'bookingYear': 2026,
  'bookingMonth': 9,
  'bookingDay': 23,
  'attendeeName': 'Karthick M.V.',
  'eventName': 'Flutter South India',
  'eventYear': 2026,
  'eventMonth': 10,
  'eventDay': 10,
  'startHour': 9,
  'startMinute': 0,
  'endHour': 18,
  'endMinute': 0,
  'ticketName': 'Professional Homie',
  'location': null,
};
