import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/helper/original_file_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/fake/doc/dir';
  }
}

void main() {
  setUp(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  group('resolveOriginalFilePath', () {
    test('returns correct path for simple filename', () async {
      final result = await resolveOriginalFilePath('test.pdf');
      expect(result, p.join('/fake/doc/dir', originalFilesDirName, 'test.pdf'));
    });

    test('prevents path traversal by extracting basename', () async {
      final result = await resolveOriginalFilePath('../../etc/passwd');
      expect(result, p.join('/fake/doc/dir', originalFilesDirName, 'passwd'));
    });

    test('handles filename with forward slashes safely', () async {
      final result = await resolveOriginalFilePath('some/nested/file.png');
      expect(result, p.join('/fake/doc/dir', originalFilesDirName, 'file.png'));
    });
  });
}
