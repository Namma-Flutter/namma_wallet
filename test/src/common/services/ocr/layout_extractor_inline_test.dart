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
        expect(pickupTime, '12/12/2025 21:00 Hrs.');
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
        expect(value, '21:00 Hrs.');
      },
    );
  });
}
