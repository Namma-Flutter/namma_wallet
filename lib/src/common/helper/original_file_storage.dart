import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Subdirectory (under the app's document directory) where copies of
/// imported ticket files (PDF/image) are stored.
const originalFilesDirName = 'ticket_originals';

/// Resolves the absolute path for a ticket's original file given the
/// relative [fileName] stored in the database.
///
/// Only the filename is persisted (not the full path) because the app's
/// document directory path can change between app updates/reinstalls
/// (e.g. the sandbox UUID on iOS), which would otherwise leave stored
/// absolute paths pointing at a directory that no longer exists.
Future<String> resolveOriginalFilePath(String fileName) async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return p.join(appDocDir.path, originalFilesDirName, fileName);
}
