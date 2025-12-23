import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:namma_wallet/src/features/travel/application/pkpass_parser.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../helpers/fake_logger.dart';

class FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return 'test/temp_docs';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PKPassParser', () {
    late PKPassParser parser;
    late FakeLogger fakeLogger;
    late Directory tempDocs;

    setUp(() async {
      fakeLogger = FakeLogger();
      parser = PKPassParser(logger: fakeLogger);

      PathProviderPlatform.instance = FakePathProvider();
      tempDocs = Directory('test/temp_docs');
      if (!tempDocs.existsSync()) {
        await tempDocs.create(recursive: true);
      }
    });

    tearDown(() async {
      if (tempDocs.existsSync()) {
        await tempDocs.delete(recursive: true);
      }
    });

    test('should parse Flutter Devcon pkpass file correctly', () async {
      // Path to the sample file provided by the user
      final file = File('test/assets/pkpass/Flutter Devcon.pkpass');
      if (!file.existsSync()) {
        fail('Sample pkpass file not found at ${file.absolute.path}');
      }

      final bytes = await file.readAsBytes();
      final ticket = await parser.parsePKPass(bytes);

      expect(ticket, isNotNull);
      // Based on the file name, it's likely a generic or event ticket
      expect(ticket!.primaryText, contains('Devcon'));
      // Since it's not a boarding pass, type should be null
      expect(ticket.type, isNull);

      // Check for extras to verify data refinement
      expect(ticket.extras, isNotEmpty);
      for (final extra in ticket.extras!) {
        expect(extra.value, isNot(contains('Instance of')));
      }

      expect(ticket.imagePath, isNotNull);
      expect(File(ticket.imagePath!).existsSync(), isTrue);
    });

    test(
      'should return null for missing fields instead of "Unknown"',
      () async {
        final file = File('test/assets/pkpass/Flutter Devcon.pkpass');
        final bytes = await file.readAsBytes();
        final ticket = await parser.parsePKPass(bytes);

        expect(ticket, isNotNull);
        // 'location' is empty in this sample pkpass
        expect(ticket!.location, isNull);
      },
    );

    test(
      'should return null when parsing invalid/malformed pkpass data',
      () async {
        // Create some random bytes that are not a valid zip file
        final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final ticket = await parser.parsePKPass(invalidBytes);

        expect(ticket, isNull);
      },
    );
  });
}
