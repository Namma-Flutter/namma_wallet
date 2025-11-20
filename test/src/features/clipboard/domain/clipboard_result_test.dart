import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_content_type.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_result.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

void main() {
  group('ClipboardResult Domain Model Tests', () {
    group('Success Factory Constructor', () {
      test(
        'Given text content type, When creating success result, '
        'Then returns result with correct type and content',
        () {
          // Arrange (Given)
          const contentType = ClipboardContentType.text;
          const content = 'Plain text from clipboard';

          // Act (When)
          final result = ClipboardResult.success(contentType, content);

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.text));
          expect(result.content, equals(content));
          expect(result.ticket, isNull);
          expect(result.errorMessage, isNull);
        },
      );

      test(
        'Given travel ticket content type with ticket, '
        'When creating success result, '
        'Then returns result with ticket data',
        () {
          // Arrange (Given)
          const contentType = ClipboardContentType.travelTicket;
          const content = 'PNR: T12345678, From: Chennai To: Bangalore';
          final ticket = Ticket(
            ticketId: 'T12345678',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC - TEST123',
            startTime: DateTime(2024, 12, 15, 14, 30),
            location: 'Koyambedu',
          );

          // Act (When)
          final result = ClipboardResult.success(
            contentType,
            content,
            ticket: ticket,
          );

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.travelTicket));
          expect(result.content, equals(content));
          expect(result.ticket, isNotNull);
          expect(result.ticket?.ticketId, equals('T12345678'));
          expect(result.errorMessage, isNull);
        },
      );

      test(
        'Given travel ticket content type without ticket, '
        'When creating success result, '
        'Then returns result with null ticket',
        () {
          // Arrange (Given)
          const contentType = ClipboardContentType.travelTicket;
          const content = 'Update SMS: Conductor: 9876543210';

          // Act (When)
          final result = ClipboardResult.success(contentType, content);

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.travelTicket));
          expect(result.content, equals(content));
          expect(result.ticket, isNull);
          expect(result.errorMessage, isNull);
        },
      );

      test(
        'Given empty content string, When creating success result, '
        'Then returns result with empty content',
        () {
          // Arrange (Given)
          const contentType = ClipboardContentType.text;
          const content = '';

          // Act (When)
          final result = ClipboardResult.success(contentType, content);

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(contentType));
          expect(result.content, isEmpty);
        },
      );

      test(
        'Given very long content, When creating success result, '
        'Then returns result with full content',
        () {
          // Arrange (Given)
          const contentType = ClipboardContentType.text;
          final content = 'A' * 10000;

          // Act (When)
          final result = ClipboardResult.success(contentType, content);

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.content?.length, equals(10000));
        },
      );
    });

    group('Error Factory Constructor', () {
      test(
        'Given error message, When creating error result, '
        'Then returns result with invalid type and error message',
        () {
          // Arrange (Given)
          const errorMessage = 'No content found in clipboard';

          // Act (When)
          final result = ClipboardResult.error(errorMessage);

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.type, equals(ClipboardContentType.invalid));
          expect(result.errorMessage, equals(errorMessage));
          expect(result.content, isNull);
          expect(result.ticket, isNull);
        },
      );

      test(
        'Given empty error message, When creating error result, '
        'Then returns result with empty error message',
        () {
          // Arrange (Given)
          const errorMessage = '';

          // Act (When)
          final result = ClipboardResult.error(errorMessage);

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, isEmpty);
        },
      );

      test(
        'Given detailed error message, When creating error result, '
        'Then preserves full error details',
        () {
          // Arrange (Given)
          const errorMessage =
              'Platform exception: Unable to access clipboard content. '
              'Please copy plain text only.';

          // Act (When)
          final result = ClipboardResult.error(errorMessage);

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, equals(errorMessage));
          expect(result.errorMessage, contains('Platform exception'));
        },
      );
    });

    group('Direct Constructor', () {
      test(
        'Given all parameters, When creating result directly, '
        'Then constructs result with all fields',
        () {
          // Arrange (Given)
          const type = ClipboardContentType.text;
          const content = 'Test content';
          const errorMessage = 'Test error';
          final ticket = Ticket(
            ticketId: 'TEST123',
            primaryText: 'Test',
            secondaryText: 'Test',
            startTime: DateTime.now(),
            location: 'Test Location',
          );

          // Act (When)
          final result = ClipboardResult(
            type: type,
            isSuccess: true,
            content: content,
            ticket: ticket,
            errorMessage: errorMessage,
          );

          // Assert (Then)
          expect(result.type, equals(type));
          expect(result.isSuccess, isTrue);
          expect(result.content, equals(content));
          expect(result.ticket, equals(ticket));
          expect(result.errorMessage, equals(errorMessage));
        },
      );

      test(
        'Given minimal parameters, When creating result directly, '
        'Then constructs result with required fields only',
        () {
          // Arrange (Given)
          const type = ClipboardContentType.invalid;
          const isSuccess = false;

          // Act (When)
          const result = ClipboardResult(
            type: type,
            isSuccess: isSuccess,
          );

          // Assert (Then)
          expect(result.type, equals(type));
          expect(result.isSuccess, isFalse);
          expect(result.content, isNull);
          expect(result.ticket, isNull);
          expect(result.errorMessage, isNull);
        },
      );
    });

    group('Content Type Variations', () {
      test(
        'Given text content type, When checking result properties, '
        'Then has correct content type classification',
        () {
          // Arrange & Act (Given & When)
          final result = ClipboardResult.success(
            ClipboardContentType.text,
            'Sample text',
          );

          // Assert (Then)
          expect(result.type, equals(ClipboardContentType.text));
          expect(
            result.type,
            isNot(equals(ClipboardContentType.travelTicket)),
          );
          expect(result.type, isNot(equals(ClipboardContentType.invalid)));
        },
      );

      test(
        'Given travel ticket content type, When checking result properties, '
        'Then has correct content type classification',
        () {
          // Arrange & Act (Given & When)
          final result = ClipboardResult.success(
            ClipboardContentType.travelTicket,
            'PNR: T12345678',
          );

          // Assert (Then)
          expect(result.type, equals(ClipboardContentType.travelTicket));
          expect(result.type, isNot(equals(ClipboardContentType.text)));
          expect(result.type, isNot(equals(ClipboardContentType.invalid)));
        },
      );

      test(
        'Given invalid content type, When checking result properties, '
        'Then has correct content type classification',
        () {
          // Arrange & Act (Given & When)
          final result = ClipboardResult.error('Invalid content');

          // Assert (Then)
          expect(result.type, equals(ClipboardContentType.invalid));
          expect(result.type, isNot(equals(ClipboardContentType.text)));
          expect(
            result.type,
            isNot(equals(ClipboardContentType.travelTicket)),
          );
        },
      );
    });

    group('Edge Cases and Boundary Conditions', () {
      test(
        'Given special characters in content, When creating success result, '
        'Then preserves special characters',
        () {
          // Arrange (Given)
          const content = 'Test\n\t@#\$%^&*()_+{}|:"<>?[]\\;\',./-=';

          // Act (When)
          final result = ClipboardResult.success(
            ClipboardContentType.text,
            content,
          );

          // Assert (Then)
          expect(result.content, equals(content));
          expect(result.content, contains('\n'));
          expect(result.content, contains('\t'));
        },
      );

      test(
        'Given Unicode characters in content, When creating success result, '
        'Then preserves Unicode characters',
        () {
          // Arrange (Given)
          const content = 'தமிழ் நாடு பேருந்து 中文 한국어 🎫';

          // Act (When)
          final result = ClipboardResult.success(
            ClipboardContentType.text,
            content,
          );

          // Assert (Then)
          expect(result.content, equals(content));
          expect(result.content, contains('தமிழ்'));
          expect(result.content, contains('🎫'));
        },
      );

      test(
        'Given whitespace-only content, When creating success result, '
        'Then preserves whitespace',
        () {
          // Arrange (Given)
          const content = '   \n\t   ';

          // Act (When)
          final result = ClipboardResult.success(
            ClipboardContentType.text,
            content,
          );

          // Assert (Then)
          expect(result.content, equals(content));
          expect(result.content?.trim(), isEmpty);
        },
      );

      test(
        'Given null ticket in success result, When checking ticket property, '
        'Then ticket is null',
        () {
          // Arrange & Act (Given & When)
          final result = ClipboardResult.success(
            ClipboardContentType.text,
            'content',
          );

          // Assert (Then)
          expect(result.ticket, isNull);
        },
      );
    });
  });
}
