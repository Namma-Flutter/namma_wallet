import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/settings/application/ai_service_status.dart';

void main() {
  group('AIServiceStatus', () {
    test('starts as supported with no error message', () {
      final status = AIServiceStatus();
      expect(status.isGemmaSupported, isTrue);
      expect(status.errorMessage, isNull);
    });

    test('setGemmaSupport(false, error) updates state and notifies', () {
      final status = AIServiceStatus();
      var notified = 0;
      status
        ..addListener(() => notified++)
        ..setGemmaSupport(supported: false, error: 'no GPU');

      expect(status.isGemmaSupported, isFalse);
      expect(status.errorMessage, equals('no GPU'));
      expect(notified, equals(1));
    });

    test('setGemmaSupport(true) clears the error', () {
      final status = AIServiceStatus()
        ..setGemmaSupport(supported: false, error: 'temporarily unavailable')
        ..setGemmaSupport(supported: true);

      expect(status.isGemmaSupported, isTrue);
      expect(status.errorMessage, isNull);
    });
  });
}
