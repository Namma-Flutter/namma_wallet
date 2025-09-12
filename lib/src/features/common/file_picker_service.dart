import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<File?> pickFile() async {
    // TODO: Multi file pick
    final result = await FilePicker.platform.pickFiles();
    File? file;
    if (result != null) {
      file = File(result.files.single.path!);
    } else {
      // TODO: User canceled the picker
    }
    return file;
  }
}
