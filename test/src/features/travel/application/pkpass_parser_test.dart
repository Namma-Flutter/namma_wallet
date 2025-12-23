import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/travel/application/pkpass_parser.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
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
      if (!await tempDocs.exists()) {
        await tempDocs.create(recursive: true);
      }
    });

    tearDown(() async {
      if (await tempDocs.exists()) {
        await tempDocs.delete(recursive: true);
      }
    });

    test('should parse Flutter Devcon pkpass file correctly', () async {
      // Path to the sample file provided by the user
      final file = File('test/assets/pkpass/Flutter Devcon.pkpass');
      if (!await file.exists()) {
        fail('Sample pkpass file not found at ${file.absolute.path}');
      }

      final bytes = await file.readAsBytes();
      final ticket = await parser.parsePKPass(bytes);

      if (ticket == null) {
        print('Fake Logger Errors: ${fakeLogger.errorLogs}');
      }

      expect(ticket, isNotNull);
      // Based on the file name, it's likely a generic or event ticket
      expect(ticket!.primaryText, contains('Devcon'));
      expect(
        ticket.type,
        TicketType.train,
      ); // Default is train if not boardingPass

      // Check if image was "saved" (even if dummy)
      // Note: If the sample pass has no image, this will be null
      print('Parsed Ticket Image Path: ${ticket.imagePath}');

      // Check for extras to verify data refinement
      expect(ticket.extras, isNotEmpty);
      for (final extra in ticket.extras!) {
        expect(extra.value, isNot(contains('Instance of')));
      }
    });
  });
}
