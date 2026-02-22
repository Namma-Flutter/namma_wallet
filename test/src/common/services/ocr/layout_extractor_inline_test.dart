import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

void main() {
  group('LayoutExtractor _extractInlineValue', () {
    test(
      'should extract only pickup point when combined with pickup time',
      () {
        // This is the actual problematic OCR block from the t73910447 fixture
        final blocks = [
          OCRBlock(
            text:
                'Passenger Pickup Point : CHENNAI-PT Dr.M.G.R. BS Passenger Pickup Time: 12/12/2025 21:00 Hrs.',
            boundingBox: const Rect.fromLTRB(149, 343, 1002, 361),
            page: 0,
          ),
        ];

        final extractor = LayoutExtractor(blocks);

        // Test extracting pickup point
        final pickupPoint = extractor.findValueForKey('Passenger Pickup Point');
        expect(pickupPoint, 'CHENNAI-PT Dr.M.G.R. BS');

        // Test extracting pickup time
        final pickupTime = extractor.findValueForKey('Passenger Pickup Time');
        expect(pickupTime, '12/12/2025 21:00 Hrs');
      },
    );

    test('should handle single inline key-value pair', () {
      final blocks = [
        OCRBlock(
          text: 'Service End Place : BENGALURU',
          boundingBox: const Rect.fromLTRB(0, 0, 100, 20),
          page: 0,
        ),
      ];

      final extractor = LayoutExtractor(blocks);
      final value = extractor.findValueForKey('Service End Place');
      expect(value, 'BENGALURU');
    });

    test(
      'should handle block with time value (contains colon)',
      () {
        final blocks = [
          OCRBlock(
            text: 'Service Start Time: 21:00 Hrs.',
            boundingBox: const Rect.fromLTRB(0, 0, 100, 20),
            page: 0,
          ),
        ];

        final extractor = LayoutExtractor(blocks);
        final value = extractor.findValueForKey('Service Start Time');
        // Should return the time value including the colon
        expect(value, '21:00 Hrs');
      },
    );

    test(
      'should handle empty inline value and not fall through to spatial search',
      () {
        final blocks = [
          // Simulate a row where Trip Code has a value, but Route No does not
          // (it only has a colon)
          OCRBlock(
            text: 'Trip Code : 2100CHEBANNS Route No :',
            boundingBox: const Rect.fromLTRB(100, 300, 800, 320),
            page: 0,
          ),
          // Add some blocks below to ensure it doesn't fall through and pick them up
          OCRBlock(
            text: 'Source Type',
            boundingBox: const Rect.fromLTRB(100, 340, 200, 360),
            page: 0,
          ),
          OCRBlock(
            text: 'PDF',
            boundingBox: const Rect.fromLTRB(100, 380, 200, 400),
            page: 0,
          ),
        ];

        final extractor = LayoutExtractor(blocks);

        // Trip code should work normally
        final tripCode = extractor.findValueForKey('Trip Code');
        expect(tripCode, '2100CHEBANNS');

        // Route No is empty inline, so it should be null and NOT fall through
        // to pick up "Source Type" or "PDF" spatially below it.
        final routeNo = extractor.findValueForKey('Route No');
        expect(routeNo, isNull);
      },
    );

    test(
      'should not grab unrelated date/time field during spatial search fallback',
      () {
        final blocks = [
          OCRBlock(
            text: 'Route No :',
            boundingBox: const Rect.fromLTRB(100, 300, 200, 320),
            page: 0,
          ),
          // A block directly below it that has a date/time but also a field label
          OCRBlock(
            text: 'Passenger Pickup Time: 12/12/2025 21:00 Hrs.',
            boundingBox: const Rect.fromLTRB(100, 340, 800, 360),
            page: 0,
          ),
        ];

        final extractor = LayoutExtractor(blocks);

        // It should attempt spatial search but skip 'Passenger Pickup Time'
        // because it's a recognized field label, despite containing a date
        final routeNo = extractor.findValueForKey('Route No');
        expect(routeNo, isNull);
      },
    );
  });
}
