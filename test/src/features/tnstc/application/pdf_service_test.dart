import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('PDFService Text Cleaning Tests', () {
    test(r'should not corrupt text with $1 literals', () {
      String cleanExtractedText(String rawText) {
        var cleanedText = rawText;

        // The fixed regexes using replaceAllMapped
        cleanedText = cleanedText.replaceAllMapped(
          RegExp(r'(\w+)\s+:\s*'),
          (match) => '${match.group(1)}: ',
        );

        cleanedText = cleanedText.replaceAllMapped(
          RegExp(r'Corporation\s*:\s*\n([A-Z\s]+)\n'),
          (match) => 'Corporation: ${match.group(1)}\n',
        );

        return cleanedText;
      }

      const input = 'Date of Journey : 18/01/2026';
      final output = cleanExtractedText(input);

      // This expectation should FAIL if the bug exists
      expect(
        output,
        equals('Date of Journey: 18/01/2026'),
        reason: 'Should preserve "Journey"',
      );
      expect(
        output,
        isNot(contains(r'$1')),
        reason: r'Should not contain literal $1',
      );
    });
  });
}
