import 'dart:ui';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

final List<OCRBlock> devfest2025 = [
  OCRBlock(
    text: 'Booking Date: September 29, 2025',
    boundingBox: const Rect.fromLTWH(10, 10, 200, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Booking ID: cdda2c1f',
    boundingBox: const Rect.fromLTWH(10, 40, 200, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Attendee Details',
    boundingBox: const Rect.fromLTWH(10, 70, 200, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'KEERTHIVASAN S',
    boundingBox: const Rect.fromLTWH(10, 100, 200, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Thiran Technologies',
    boundingBox: const Rect.fromLTWH(10, 130, 200, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Event Name: DevFest 2025 Chennai',
    boundingBox: const Rect.fromLTWH(10, 160, 200, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Event Date: November 08 (09:00 AM to 06:00 PM)',
    boundingBox: const Rect.fromLTWH(10, 190, 300, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Ticket Name: Early Bird Professional',
    boundingBox: const Rect.fromLTWH(10, 220, 250, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Location: IIT Madras Research Park, MGR Film City Road,',
    boundingBox: const Rect.fromLTWH(10, 250, 350, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'Kanagam, Tharamani, Chennai, Tamil Nadu,',
    boundingBox: const Rect.fromLTWH(10, 270, 350, 20),
    page: 1,
  ),
  OCRBlock(
    text: 'India',
    boundingBox: const Rect.fromLTWH(10, 290, 100, 20),
    page: 1,
  ),
];

const Map<String, Object> devfest2025Expected = {
  'bookingId': 'cdda2c1f',
  'bookingYear': 2025,
  'bookingMonth': 9,
  'bookingDay': 29,
  'attendeeName': 'KEERTHIVASAN S',
  'organization': 'Thiran Technologies',
  'eventName': 'DevFest 2025 Chennai',
  'eventYear': 2025,
  'eventMonth': 11,
  'eventDay': 8,
  'startHour': 9,
  'startMinute': 0,
  'endHour': 18,
  'endMinute': 0,
  'ticketName': 'Early Bird Professional',
  'location':
      'IIT Madras Research Park, MGR Film City Road, Kanagam, Tharamani, '
          'Chennai, Tamil Nadu, India',
};
