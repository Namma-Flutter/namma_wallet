import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/events/domain/event_model.dart';

void main() {
  group('Event.getIconData', () {
    test('maps known icon names', () {
      expect(Event.getIconData('local_activity'), Icons.local_activity);
      expect(Event.getIconData('code'), Icons.code);
      expect(
        Event.getIconData('confirmation_number'),
        Icons.confirmation_number,
      );
    });

    test('falls back to Icons.event for unknown names', () {
      expect(Event.getIconData('???'), Icons.event);
      expect(Event.getIconData(''), Icons.event);
    });
  });

  group('Event.icon', () {
    test('returns the IconData for the configured iconName', () {
      final event = Event(
        iconName: 'code',
        title: 'CodeCon',
        subtitle: 'Tech',
        date: DateTime(2026, 6),
        price: 'Free',
      );

      expect(event.icon, Icons.code);
    });
  });
}
