// this is just fixtures and may contain more than 80 character

import 'dart:ui';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

const Map<String, Object?> tdahhpyExpected = {
  'bookingId': 'TDAHHPY',
  'movieName': 'Coolie',
  'theatreName': 'PVR VR Mall, Anna Nagar, Chennai',
  'screen': 'AUDI 4',
  'seats': 'PR - L13, L14, L15',
  'language': 'Tamil',
  'format': '2D',
  'provider': 'District',
  'showYear': 2026, // Assumes current year since its not in ticket.
  'showMonth': 8,
  'showDay': 24,
  'showHour': 11,
  'showMinute': 55,
};

// Total blocks: 15
final tdahhpy = <OCRBlock>[
  OCRBlock(
    text: 'district',
    boundingBox: const Rect.fromLTRB(
      39,
      1488,
      220,
      1545,
    ),
    page: 0,
    confidence: 0.49658203125,
  ),
  OCRBlock(
    text: 'BY ZOMATO',
    boundingBox: const Rect.fromLTRB(
      74,
      1555,
      188,
      1565,
    ),
    page: 0,
    confidence: 0.73828125,
  ),
  OCRBlock(
    text: 'distrit',
    boundingBox: const Rect.fromLTRB(
      348,
      197,
      537,
      251,
    ),
    page: 0,
    confidence: 0.671875,
  ),
  OCRBlock(
    text: 'Coolie',
    boundingBox: const Rect.fromLTRB(
      277,
      362,
      368,
      385,
    ),
    page: 0,
    confidence: 0.8736979365348816,
  ),
  OCRBlock(
    text: 'BY ZOMATO',
    boundingBox: const Rect.fromLTRB(
      383,
      263,
      501,
      275,
    ),
    page: 0,
    confidence: 0.75927734375,
  ),
  OCRBlock(
    text: 'A Tamil 2D',
    boundingBox: const Rect.fromLTRB(
      275,
      408,
      444,
      424,
    ),
    page: 0,
    confidence: 0.80419921875,
  ),
  OCRBlock(
    text: 'Sunday 24 Aug',
    boundingBox: const Rect.fromLTRB(
      276,
      455,
      455,
      483,
    ),
    page: 0,
    confidence: 0.8895596861839294,
  ),
  OCRBlock(
    text: '11:55 AM',
    boundingBox: const Rect.fromLTRB(
      502,
      458,
      612,
      477,
    ),
    page: 0,
    confidence: 0.8727678656578064,
  ),
  OCRBlock(
    text: 'Scan this QR code at theatre',
    boundingBox: const Rect.fromLTRB(
      296,
      518,
      590,
      539,
    ),
    page: 0,
    confidence: 0.88230299949646,
  ),
  OCRBlock(
    text: 'AUDI 04',
    boundingBox: const Rect.fromLTRB(
      393,
      930,
      493,
      949,
    ),
    page: 0,
    confidence: 0.7766926884651184,
  ),
  OCRBlock(
    text: 'PR - L13, L14, L15',
    boundingBox: const Rect.fromLTRB(
      332,
      969,
      555,
      990,
    ),
    page: 0,
    confidence: 0.8473772406578064,
  ),
  OCRBlock(
    text: 'PVR VR Mall, Anna Nagar, Chennai',
    boundingBox: const Rect.fromLTRB(
      231,
      1095,
      655,
      1120,
    ),
    page: 0,
    confidence: 0.8532986044883728,
  ),
  OCRBlock(
    text: 'Booking ID: TDAHHPY',
    boundingBox: const Rect.fromLTRB(
      336,
      1160,
      547,
      1184,
    ),
    page: 0,
    confidence: 0.841911792755127,
  ),
  OCRBlock(
    text: '#SeeYouThere',
    boundingBox: const Rect.fromLTRB(
      367,
      1229,
      519,
      1246,
    ),
    page: 0,
    confidence: 0.8655598759651184,
  ),
  OCRBlock(
    text: '#SeeYouThere',
    boundingBox: const Rect.fromLTRB(
      621,
      1517,
      844,
      1540,
    ),
    page: 0,
    confidence: 0.8115234375,
  ),
];
