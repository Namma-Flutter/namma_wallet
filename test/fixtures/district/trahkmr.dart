// this is just fixtures and may contain more than 80 character

import 'dart:ui';

import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

const Map<String, Object?> trahkmrExpected = {
  'bookingId': 'TRAHKMR',
  'movieName': 'Project Hail Mary',
  'theatreName': 'PVR VR Mall, Anna Nagar, Chennai',
  'screen': 'AUDI 2',
  'seats': 'PR - F1, F2, F3',
  'language': 'English',
  'format': '2D',
  'provider': 'District',
  'showYear': 2026,
  'showMonth': 5,
  'showDay': 24,
  'showHour': 12,
  'showMinute': 5,
};

// Total blocks: 15
final trahkmr = <OCRBlock>[
  OCRBlock(
    text: 'district',
    boundingBox: const Rect.fromLTRB(
      40,
      1492,
      223,
      1543,
    ),
    page: 0,
    confidence: 0.56591796875,
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
    text: 'distrizt',
    boundingBox: const Rect.fromLTRB(
      348,
      197,
      537,
      251,
    ),
    page: 0,
    confidence: 0.61376953125,
  ),
  OCRBlock(
    text: 'BY ZOMATO',
    boundingBox: const Rect.fromLTRB(
      384,
      263,
      501,
      275,
    ),
    page: 0,
    confidence: 0.77587890625,
  ),
  OCRBlock(
    text: 'Project Hail Mary',
    boundingBox: const Rect.fromLTRB(
      277,
      362,
      524,
      391,
    ),
    page: 0,
    confidence: 0.9005208611488342,
  ),
  OCRBlock(
    text: 'UA13+ English',
    boundingBox: const Rect.fromLTRB(
      277,
      410,
      449,
      429,
    ),
    page: 0,
    confidence: 0.7727864384651184,
  ),
  OCRBlock(
    text: '2D',
    boundingBox: const Rect.fromLTRB(
      492,
      410,
      515,
      425,
    ),
    page: 0,
    confidence: 0.796875,
  ),
  OCRBlock(
    text: 'Sunday 24 May 12:05 PM',
    boundingBox: const Rect.fromLTRB(
      277,
      457,
      618,
      483,
    ),
    page: 0,
    confidence: 0.8899739384651184,
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
    confidence: 0.881963312625885,
  ),
  OCRBlock(
    text: 'AUDI 02',
    boundingBox: const Rect.fromLTRB(
      393,
      930,
      492,
      949,
    ),
    page: 0,
    confidence: 0.7643229365348816,
  ),
  OCRBlock(
    text: 'PR - F1, F2, F3',
    boundingBox: const Rect.fromLTRB(
      363,
      964,
      535,
      992,
    ),
    page: 0,
    confidence: 0.8096590638160706,
  ),
  OCRBlock(
    text: 'PVR VR Mall, Anna Nagar, Chennai',
    boundingBox: const Rect.fromLTRB(
      239,
      1093,
      655,
      1119,
    ),
    page: 0,
    confidence: 0.8450520634651184,
  ),
  OCRBlock(
    text: 'Booking ID: TRAHKMR',
    boundingBox: const Rect.fromLTRB(
      335,
      1165,
      551,
      1184,
    ),
    page: 0,
    confidence: 0.8545496463775635,
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
    confidence: 0.8050130009651184,
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
    confidence: 0.791015625,
  ),
];
