import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/constants/string_extension.dart';

void main() {
  group('StringExtensions', () {
    group('isNullOrEmpty', () {
      test('returns true for null string', () {
        const String? testString = null;
        expect(testString.isNullOrEmpty, isTrue);
      });

      test('returns true for empty string', () {
        const String? testString = '';
        expect(testString.isNullOrEmpty, isTrue);
      });

      test('returns true for whitespace string', () {
        const String? testString = '   ';
        expect(testString.isNullOrEmpty, isTrue);
      });

      test('returns true for string with newlines and tabs', () {
        const String? testString = '\n\t  ';
        expect(testString.isNullOrEmpty, isTrue);
      });

      test('returns false for string with characters', () {
        const String? testString = 'hello';
        expect(testString.isNullOrEmpty, isFalse);
      });

      test('returns false for string with characters and whitespace', () {
        const String? testString = '  hello  ';
        expect(testString.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullOrEmpty', () {
      test('returns false for null string', () {
        const String? testString = null;
        expect(testString.isNotNullOrEmpty, isFalse);
      });

      test('returns false for empty string', () {
        const String? testString = '';
        expect(testString.isNotNullOrEmpty, isFalse);
      });

      test('returns false for whitespace string', () {
        const String? testString = '   ';
        expect(testString.isNotNullOrEmpty, isFalse);
      });

      test('returns false for string with newlines and tabs', () {
        const String? testString = '\n\t  ';
        expect(testString.isNotNullOrEmpty, isFalse);
      });

      test('returns true for string with characters', () {
        const String? testString = 'hello';
        expect(testString.isNotNullOrEmpty, isTrue);
      });

      test('returns true for string with characters and whitespace', () {
        const String? testString = '  hello  ';
        expect(testString.isNotNullOrEmpty, isTrue);
      });
    });
  });
}
