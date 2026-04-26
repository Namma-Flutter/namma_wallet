import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/domain/models/tag_model.dart';

void main() {
  group('TagModel.iconData', () {
    test('maps each known icon name to a Material icon', () {
      const cases = <String, IconData>{
        'confirmation_number': Icons.confirmation_number,
        'qr_code': Icons.qr_code,
        'train': Icons.train,
        'access_time': Icons.access_time,
        'event_seat': Icons.event_seat,
        'attach_money': Icons.attach_money,
        'info': Icons.info,
      };
      for (final entry in cases.entries) {
        expect(
          TagModel(icon: entry.key, value: 'X').iconData,
          equals(entry.value),
          reason: 'icon=${entry.key}',
        );
      }
    });

    test('falls back to help_outline for unknown / null icon', () {
      expect(
        TagModel(icon: 'never_heard_of_it', value: 'X').iconData,
        Icons.help_outline,
      );
      expect(TagModel(icon: null, value: 'X').iconData, Icons.help_outline);
    });
  });
}
