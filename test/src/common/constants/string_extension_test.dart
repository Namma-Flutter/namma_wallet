import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/constants/string_extension.dart';

void main() {
  group('StringExtensions', () {
    group('isNullOrEmpty', () {
      test('returns true for null', () {
        String? value;
        expect(value.isNullOrEmpty, isTrue);
      });

      test('returns true for empty string', () {
        String? value = '';
        expect(value.isNullOrEmpty, isTrue);
      });

      test('returns true for string with only whitespace', () {
        String? value = '   ';
        expect(value.isNullOrEmpty, isTrue);
      });

      test('returns true for string with tabs', () {
        String? value = '\t\t';
        expect(value.isNullOrEmpty, isTrue);
      });

      test('returns true for string with newlines', () {
        String? value = '\n\n';
        expect(value.isNullOrEmpty, isTrue);
      });

      test('returns false for string with characters', () {
        String? value = 'hello';
        expect(value.isNullOrEmpty, isFalse);
      });

      test('returns false for string with characters and whitespace', () {
        String? value = ' hello ';
        expect(value.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullOrEmpty', () {
      test('returns false for null', () {
        String? value;
        expect(value.isNotNullOrEmpty, isFalse);
      });

      test('returns false for empty string', () {
        String? value = '';
        expect(value.isNotNullOrEmpty, isFalse);
      });

      test('returns false for string with only whitespace', () {
        String? value = '   ';
        expect(value.isNotNullOrEmpty, isFalse);
      });

      test('returns false for string with tabs', () {
        String? value = '\t\t';
        expect(value.isNotNullOrEmpty, isFalse);
      });

      test('returns false for string with newlines', () {
        String? value = '\n\n';
        expect(value.isNotNullOrEmpty, isFalse);
      });

      test('returns true for string with characters', () {
        String? value = 'hello';
        expect(value.isNotNullOrEmpty, isTrue);
      });

      test('returns true for string with characters and whitespace', () {
        String? value = ' hello ';
        expect(value.isNotNullOrEmpty, isTrue);
      });
    });
  });
}
