import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';

/// Comprehensive test suite for DateTimeConverter and IDateTimeConverter.
/// Tests both the abstract interface implementation and backward-compatible
/// top-level functions.
///
/// Coverage includes:
/// - formatTime: AM/PM formatting with lowercase, UTC to local conversion
/// - formatDate: DD/MM/YYYY formatting
/// - formatFullDateTime: Combined date and time formatting
/// - formatTimeString: 24-hour to 12-hour conversion with validation
/// - Edge cases: empty strings, invalid formats, boundary values
/// - Singleton pattern verification
void main() {
  group('DateTimeConverter Implementation Tests -', () {
    late IDateTimeConverter converter;

    setUp(() {
      // Arrange: Initialize converter instance
      converter = DateTimeConverter();
    });

    group('formatTime -', () {
      test(
        'Given a DateTime at midnight, '
        'When formatTime is called, '
        'Then returns 12:00 am',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18);

          // Act
          final result = converter.formatTime(dt);

          // Assert
          expect(result, equals('12:00 am'));
        },
      );

      test(
        'Given a DateTime at noon, '
        'When formatTime is called, '
        'Then returns 12:00 pm',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 12);

          // Act
          final result = converter.formatTime(dt);

          // Assert
          expect(result, equals('12:00 pm'));
        },
      );

      test(
        'Given a DateTime in the morning, '
        'When formatTime is called, '
        'Then returns time with am in lowercase',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 9, 30);

          // Act
          final result = converter.formatTime(dt);

          // Assert
          expect(result, equals('09:30 am'));
        },
      );

      test(
        'Given a DateTime in the afternoon, '
        'When formatTime is called, '
        'Then returns time with pm in lowercase',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 13, 15);

          // Act
          final result = converter.formatTime(dt);

          // Assert
          expect(result, equals('01:15 pm'));
        },
      );

      test(
        'Given a DateTime in the evening, '
        'When formatTime is called, '
        'Then returns time with pm in lowercase',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 23, 59);

          // Act
          final result = converter.formatTime(dt);

          // Assert
          expect(result, equals('11:59 pm'));
        },
      );

      test(
        'Given a UTC DateTime, '
        'When formatTime is called, '
        'Then converts to local time before formatting',
        () {
          // Arrange
          final utcDt = DateTime.utc(2026, 1, 18, 12);

          // Act
          final result = converter.formatTime(utcDt);

          // Assert
          // Result should be in local time zone
          final local = utcDt.toLocal();
          final hour12 = local.hour > 12
              ? (local.hour - 12).toString().padLeft(2, '0')
              : local.hour.toString().padLeft(2, '0');
          final minute = local.minute.toString().padLeft(2, '0');
          final period = local.hour >= 12 ? 'pm' : 'am';
          final expected = '$hour12:$minute $period';
          expect(result, equals(expected));
        },
      );

      test(
        'Given a DateTime with single-digit hour, '
        'When formatTime is called, '
        'Then pads hour with zero',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 1, 5);

          // Act
          final result = converter.formatTime(dt);

          // Assert
          expect(result, equals('01:05 am'));
        },
      );
    });

    group('formatDate -', () {
      test(
        'Given a DateTime, '
        'When formatDate is called, '
        'Then returns date in DD/MM/YYYY format',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 13, 15);

          // Act
          final result = converter.formatDate(dt);

          // Assert
          expect(result, equals('18/01/2026'));
        },
      );

      test(
        'Given a DateTime on first day of month, '
        'When formatDate is called, '
        'Then pads day with zero',
        () {
          // Arrange
          final dt = DateTime(2026, 3);

          // Act
          final result = converter.formatDate(dt);

          // Assert
          expect(result, equals('01/03/2026'));
        },
      );

      test(
        'Given a DateTime on last day of month, '
        'When formatDate is called, '
        'Then returns correct date',
        () {
          // Arrange
          final dt = DateTime(2026, 12, 31);

          // Act
          final result = converter.formatDate(dt);

          // Assert
          expect(result, equals('31/12/2026'));
        },
      );

      test(
        'Given a DateTime in February leap year, '
        'When formatDate is called, '
        'Then returns correct date',
        () {
          // Arrange
          final dt = DateTime(2024, 2, 29); // 2024 is a leap year

          // Act
          final result = converter.formatDate(dt);

          // Assert
          expect(result, equals('29/02/2024'));
        },
      );

      test(
        'Given a UTC DateTime, '
        'When formatDate is called, '
        'Then converts to local time before formatting',
        () {
          // Arrange
          final utcDt = DateTime.utc(2026, 1, 18, 23, 30);

          // Act
          final result = converter.formatDate(utcDt);

          // Assert
          final local = utcDt.toLocal();
          final day = local.day.toString().padLeft(2, '0');
          final month = local.month.toString().padLeft(2, '0');
          final year = local.year;
          final expected = '$day/$month/$year';
          expect(result, equals(expected));
        },
      );
    });

    group('formatFullDateTime -', () {
      test(
        'Given a DateTime, '
        'When formatFullDateTime is called, '
        'Then returns full date-time in DD-MM-YYYY hh:mm AM/PM format',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 13, 15);

          // Act
          final result = converter.formatFullDateTime(dt);

          // Assert
          expect(result, equals('18-01-2026 01:15 PM'));
        },
      );

      test(
        'Given a DateTime at midnight, '
        'When formatFullDateTime is called, '
        'Then returns date with 12:00 AM',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18);

          // Act
          final result = converter.formatFullDateTime(dt);

          // Assert
          expect(result, equals('18-01-2026 12:00 AM'));
        },
      );

      test(
        'Given a DateTime at noon, '
        'When formatFullDateTime is called, '
        'Then returns date with 12:00 PM',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 12);

          // Act
          final result = converter.formatFullDateTime(dt);

          // Assert
          expect(result, equals('18-01-2026 12:00 PM'));
        },
      );

      test(
        'Given a DateTime with single-digit values, '
        'When formatFullDateTime is called, '
        'Then pads with zeros',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 1, 1, 5);

          // Act
          final result = converter.formatFullDateTime(dt);

          // Assert
          expect(result, equals('01-01-2026 01:05 AM'));
        },
      );

      test(
        'Given a UTC DateTime, '
        'When formatFullDateTime is called, '
        'Then converts to local time before formatting',
        () {
          // Arrange
          final utcDt = DateTime.utc(2026, 1, 18, 13, 15);

          // Act
          final result = converter.formatFullDateTime(utcDt);

          // Assert
          final local = utcDt.toLocal();
          // Verify it contains the local date and time components
          expect(result, contains(local.day.toString().padLeft(2, '0')));
          expect(result, contains(local.month.toString().padLeft(2, '0')));
          expect(result, contains(local.year.toString()));
        },
      );

      test(
        "Given a DateTime on New Year's Eve, "
        'When formatFullDateTime is called, '
        'Then returns correct date-time',
        () {
          // Arrange
          final dt = DateTime(2025, 12, 31, 23, 59);

          // Act
          final result = converter.formatFullDateTime(dt);

          // Assert
          expect(result, equals('31-12-2025 11:59 PM'));
        },
      );
    });

    group('formatTimeString -', () {
      test(
        'Given valid 24-hour time string, '
        'When formatTimeString is called, '
        'Then converts to 12-hour format with AM',
        () {
          // Arrange
          const timeStr = '09:30';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('09:30 AM'));
        },
      );

      test(
        'Given valid 24-hour time string in afternoon, '
        'When formatTimeString is called, '
        'Then converts to 12-hour format with PM',
        () {
          // Arrange
          const timeStr = '13:15';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('01:15 PM'));
        },
      );

      test(
        'Given midnight time string, '
        'When formatTimeString is called, '
        'Then returns 12:00 AM',
        () {
          // Arrange
          const timeStr = '00:00';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('12:00 AM'));
        },
      );

      test(
        'Given noon time string, '
        'When formatTimeString is called, '
        'Then returns 12:00 PM',
        () {
          // Arrange
          const timeStr = '12:00';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('12:00 PM'));
        },
      );

      test(
        'Given late evening time string, '
        'When formatTimeString is called, '
        'Then converts correctly',
        () {
          // Arrange
          const timeStr = '23:59';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('11:59 PM'));
        },
      );

      test(
        'Given empty string, '
        'When formatTimeString is called, '
        'Then returns empty string',
        () {
          // Arrange
          const timeStr = '';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals(''));
        },
      );

      test(
        'Given invalid format without colon, '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '1315';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('1315'));
        },
      );

      test(
        'Given invalid format with multiple colons, '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '13:15:00';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('13:15:00'));
        },
      );

      test(
        'Given non-numeric hour, '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = 'ab:30';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('ab:30'));
        },
      );

      test(
        'Given non-numeric minute, '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '13:xy';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('13:xy'));
        },
      );

      test(
        'Given hour out of range (negative), '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '-1:30';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('-1:30'));
        },
      );

      test(
        'Given hour out of range (>= 24), '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '24:00';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('24:00'));
        },
      );

      test(
        'Given minute out of range (negative), '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '13:-1';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('13:-1'));
        },
      );

      test(
        'Given minute out of range (>= 60), '
        'When formatTimeString is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = '13:60';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('13:60'));
        },
      );

      test(
        'Given boundary hour value 23, '
        'When formatTimeString is called, '
        'Then converts correctly',
        () {
          // Arrange
          const timeStr = '23:00';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('11:00 PM'));
        },
      );

      test(
        'Given boundary minute value 59, '
        'When formatTimeString is called, '
        'Then converts correctly',
        () {
          // Arrange
          const timeStr = '13:59';

          // Act
          final result = converter.formatTimeString(timeStr);

          // Assert
          expect(result, equals('01:59 PM'));
        },
      );
    });

    group('Singleton Pattern -', () {
      test(
        'Given multiple DateTimeConverter instantiations, '
        'When factory is called, '
        'Then returns same instance',
        () {
          // Arrange & Act
          final instance1 = DateTimeConverter();
          final instance2 = DateTimeConverter();

          // Assert
          expect(identical(instance1, instance2), isTrue);
        },
      );

      test(
        'Given DateTimeConverter.instance, '
        'When accessed, '
        'Then returns singleton instance',
        () {
          // Arrange & Act
          final instance1 = DateTimeConverter.instance;
          final instance2 = DateTimeConverter();

          // Assert
          expect(identical(instance1, instance2), isTrue);
        },
      );
    });
  });

  group('Top-Level Function Backward Compatibility Tests -', () {
    group('formatTime top-level function -', () {
      test(
        'Given a DateTime, '
        'When formatTime top-level function is called, '
        'Then returns same result as converter',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 13, 15);

          // Act
          final topLevelResult = formatTime(dt);
          final converterResult = DateTimeConverter.instance.formatTime(dt);

          // Assert
          expect(topLevelResult, equals(converterResult));
          expect(topLevelResult, equals('01:15 pm'));
        },
      );

      test(
        'Given midnight DateTime, '
        'When formatTime top-level function is called, '
        'Then returns 12:00 am',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18);

          // Act
          final result = formatTime(dt);

          // Assert
          expect(result, equals('12:00 am'));
        },
      );
    });

    group('formatDate top-level function -', () {
      test(
        'Given a DateTime, '
        'When formatDate top-level function is called, '
        'Then returns same result as converter',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18);

          // Act
          final topLevelResult = formatDate(dt);
          final converterResult = DateTimeConverter.instance.formatDate(dt);

          // Assert
          expect(topLevelResult, equals(converterResult));
          expect(topLevelResult, equals('18/01/2026'));
        },
      );

      test(
        'Given first day of year, '
        'When formatDate top-level function is called, '
        'Then formats correctly',
        () {
          // Arrange
          final dt = DateTime(2026);

          // Act
          final result = formatDate(dt);

          // Assert
          expect(result, equals('01/01/2026'));
        },
      );
    });

    group('formatFullDateTime top-level function -', () {
      test(
        'Given a DateTime, '
        'When formatFullDateTime top-level function is called, '
        'Then returns same result as converter',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 13, 15);

          // Act
          final topLevelResult = formatFullDateTime(dt);
          final converterResult = DateTimeConverter.instance.formatFullDateTime(
            dt,
          );

          // Assert
          expect(topLevelResult, equals(converterResult));
          expect(topLevelResult, equals('18-01-2026 01:15 PM'));
        },
      );

      test(
        'Given noon DateTime, '
        'When formatFullDateTime top-level function is called, '
        'Then formats correctly',
        () {
          // Arrange
          final dt = DateTime(2026, 1, 18, 12);

          // Act
          final result = formatFullDateTime(dt);

          // Assert
          expect(result, equals('18-01-2026 12:00 PM'));
        },
      );
    });

    group('formatTimeString top-level function -', () {
      test(
        'Given valid time string, '
        'When formatTimeString top-level function is called, '
        'Then returns same result as converter',
        () {
          // Arrange
          const timeStr = '13:15';

          // Act
          final topLevelResult = formatTimeString(timeStr);
          final converterResult = DateTimeConverter.instance.formatTimeString(
            timeStr,
          );

          // Assert
          expect(topLevelResult, equals(converterResult));
          expect(topLevelResult, equals('01:15 PM'));
        },
      );

      test(
        'Given empty string, '
        'When formatTimeString top-level function is called, '
        'Then returns empty string',
        () {
          // Arrange
          const timeStr = '';

          // Act
          final result = formatTimeString(timeStr);

          // Assert
          expect(result, equals(''));
        },
      );

      test(
        'Given invalid time string, '
        'When formatTimeString top-level function is called, '
        'Then returns original string',
        () {
          // Arrange
          const timeStr = 'invalid';

          // Act
          final result = formatTimeString(timeStr);

          // Assert
          expect(result, equals('invalid'));
        },
      );
    });
  });

  group('Edge Cases and Boundary Tests -', () {
    late IDateTimeConverter converter;

    setUp(() {
      converter = DateTimeConverter();
    });

    test(
      'Given DateTime at year boundary (Dec 31 to Jan 1), '
      'When formatting, '
      'Then handles correctly',
      () {
        // Arrange
        final dt1 = DateTime(2025, 12, 31, 23, 59);
        final dt2 = DateTime(2026, 1, 1, 0, 1);

        // Act
        final result1 = converter.formatFullDateTime(dt1);
        final result2 = converter.formatFullDateTime(dt2);

        // Assert
        expect(result1, equals('31-12-2025 11:59 PM'));
        expect(result2, equals('01-01-2026 12:01 AM'));
      },
    );

    test(
      'Given very old date, '
      'When formatting, '
      'Then handles correctly without errors',
      () {
        // Arrange
        final dt = DateTime(1900, 1, 1, 12);

        // Act
        final dateResult = converter.formatDate(dt);
        final timeResult = converter.formatTime(dt);
        final fullResult = converter.formatFullDateTime(dt);

        // Assert
        expect(dateResult, equals('01/01/1900'));
        expect(timeResult, equals('12:00 pm'));
        expect(fullResult, equals('01-01-1900 12:00 PM'));
      },
    );

    test(
      'Given very far future date, '
      'When formatting, '
      'Then handles correctly without errors',
      () {
        // Arrange
        final dt = DateTime(2100, 12, 31, 23, 59);

        // Act
        final dateResult = converter.formatDate(dt);
        final timeResult = converter.formatTime(dt);
        final fullResult = converter.formatFullDateTime(dt);

        // Assert
        expect(dateResult, equals('31/12/2100'));
        expect(timeResult, equals('11:59 pm'));
        expect(fullResult, equals('31-12-2100 11:59 PM'));
      },
    );

    test(
      'Given time string with leading zeros, '
      'When formatTimeString is called, '
      'Then handles correctly',
      () {
        // Arrange
        const timeStr = '01:05';

        // Act
        final result = converter.formatTimeString(timeStr);

        // Assert
        expect(result, equals('01:05 AM'));
      },
    );

    test(
      'Given time string at hour boundary (11 to 12), '
      'When formatTimeString is called, '
      'Then converts correctly',
      () {
        // Arrange
        const time11am = '11:00';
        const time12pm = '12:00';
        const time11pm = '23:00';
        const time12am = '00:00';

        // Act
        final result11am = converter.formatTimeString(time11am);
        final result12pm = converter.formatTimeString(time12pm);
        final result11pm = converter.formatTimeString(time11pm);
        final result12am = converter.formatTimeString(time12am);

        // Assert
        expect(result11am, equals('11:00 AM'));
        expect(result12pm, equals('12:00 PM'));
        expect(result11pm, equals('11:00 PM'));
        expect(result12am, equals('12:00 AM'));
      },
    );
  });
}
