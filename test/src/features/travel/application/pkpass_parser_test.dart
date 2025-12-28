import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
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
      expect(ticket, isNotNull);
      // Based on the file name, it's likely a generic or event ticket
      expect(ticket!.primaryText, contains('Flutter Devcon'));

      // Should be identifed as event
      expect(ticket.type, equals(TicketType.event));

      // Should have location
      expect(ticket.location, contains('PayPal India'));

      // Should fall back to serial number since no PNR field
      // Actually, since barcode is present, it takes precedence.
      expect(
        ticket.ticketId,
        equals(
          'https://luma.com/check-in/evt-UbFJYLx0uKfphCt?pk=g-5OaenLTfc4WNbgl',
        ),
      );

      // Check for extras to verify data refinement
      expect(ticket.extras, isNotEmpty);
      for (final extra in ticket.extras!) {
        expect(extra.value, isNot(contains('Instance of')));
      }

      expect(ticket.imagePath, isNotNull);
      expect(File(ticket.imagePath!).existsSync(), isTrue);

      // Verify URL extraction
      expect(ticket.directionsUrl, contains('google.com/maps'));
    });

    test(
      'should extract improved fields like location from real file',
      () async {
        final file = File('test/assets/pkpass/Flutter Devcon.pkpass');
        final bytes = await file.readAsBytes();
        final ticket = await parser.parsePKPass(bytes);

        expect(ticket, isNotNull);
        // 'location' is now found due to improved parsing
        expect(ticket!.location, equals('PayPal India Development Center'));
      },
    );

    test(
      'should return null when parsing invalid/malformed pkpass data',
      () async {
        // Create some random bytes that are not a valid zip file
        final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final ticket = await parser.parsePKPass(invalidBytes);

        expect(ticket, isNull);
        expect(fakeLogger.logs.last, contains('Failed to parse pkpass file'));
      },
    );

    // NOTE: Further tests for specific TicketType (train/bus) mapping logic
    // require valid .pkpass samples with valid signatures/manifests, or
    // a way to mock the 3rd party PassFile class which is currently not exported/mockable.

    test(
      'fetchLatestPass should return null '
      'given invalid pkpass data (not a zip)',
      () async {
        final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = await parser.fetchLatestPass(invalidBytes);
        expect(result, isNull);
        // ZipDecoder might throw or just fail to find files.
        // If it throws, we log error. If it returns invalid archive,
        // we log warning.
        // We just ensure we handled it.
        expect(
          fakeLogger.logs.join('\n'),
          contains(RegExp('(Failed to fetch|pass.json not found)')),
        );
      },
    );
  });
}
