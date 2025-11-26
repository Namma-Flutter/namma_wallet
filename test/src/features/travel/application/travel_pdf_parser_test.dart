import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/travel/application/travel_pdf_parser.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  group('TravelPDFParser', () {
    late TravelPDFParser parser;
    late FakeLogger fakeLogger;

    setUp(() {
      fakeLogger = FakeLogger();
      parser = TNSTCPDFParser(logger: fakeLogger);
    });

    group('parseInt', () {
      test('should return the parsed integer for a valid string', () {
        // Arrange
        const value = '123';
        // Act
        final result = parser.parseInt(value);
        // Assert
        expect(result, 123);
      });

      test('should return the default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseInt(value);
        // Assert
        expect(result, 0);
      });

      test('should return the custom default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseInt(value, defaultValue: -1);
        // Assert
        expect(result, -1);
      });
    });

    group('parseDouble', () {
      test('should return the parsed double for a valid string', () {
        // Arrange
        const value = '123.45';
        // Act
        final result = parser.parseDouble(value);
        // Assert
        expect(result, 123.45);
      });

      test('should return the default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseDouble(value);
        // Assert
        expect(result, 0.0);
      });

      test('should return the custom default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseDouble(value, defaultValue: -1);
        // Assert
        expect(result, -1.0);
      });
    });

    group('TNSTCPDFParser.parseTicket - idCardType cleanup', () {
      test(
        'should correctly clean up "rD Card" from idCardType',
        () {
          // Arrange
          const pdfText = '''
ID Card Type: Government Issued Photo rD Card
ID Card Number: 1234567890
''';
          // Act
          final ticket = (parser as TNSTCPDFParser).parseTicket(pdfText);

          // Assert
          expect(ticket.extras, isNotNull);
          final idCardTypeExtra = ticket.extras!.firstWhere(
            (e) => e.title == 'ID Card Type',
            orElse: () => throw Exception('ID Card Type extra not found'),
          );
          expect(
            idCardTypeExtra.value,
            equals('Government Issued Photo ID Card'),
          );
        },
      );

      test(
        'should correctly clean up "rD Card" from idCardType'
        ' when also contains colon',
        () {
          // Arrange
          const pdfText = '''
ID Card Type: : Government Issued Photo rD Card
ID Card Number: 1234567890
''';
          // Act
          final ticket = (parser as TNSTCPDFParser).parseTicket(pdfText);

          // Assert
          expect(ticket.extras, isNotNull);
          final idCardTypeExtra = ticket.extras!.firstWhere(
            (e) => e.title == 'ID Card Type',
            orElse: () => throw Exception('ID Card Type extra not found'),
          );
          expect(
            idCardTypeExtra.value,
            equals('Government Issued Photo ID Card'),
          );
        },
      );
    });
  });
}
