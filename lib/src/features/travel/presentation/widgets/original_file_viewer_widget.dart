import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/helper/original_file_storage.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:pdfrx/pdfrx.dart';

const _imageExtensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'};

/// Full-screen viewer for the original ticket file (PDF or image) stored
/// alongside a ticket.
///
/// [fileName] is the relative filename stored on the ticket; the absolute
/// path is resolved at runtime since the document directory's path can
/// change between app updates/reinstalls.
class OriginalFileViewerWidget extends StatelessWidget {
  const OriginalFileViewerWidget({required this.fileName, super.key});

  final String fileName;

  bool get _isImage {
    final lower = fileName.toLowerCase();
    return _imageExtensions.any(lower.endsWith);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const RoundedBackButton(),
        title: const Text('Original Ticket'),
      ),
      body: FutureBuilder<String>(
        future: resolveOriginalFilePath(fileName),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final filePath = snapshot.data!;
          if (!File(filePath).existsSync()) {
            return const Center(child: Text('Original file not found'));
          }

          return _isImage
              ? InteractiveViewer(
                  child: Center(child: Image.file(File(filePath))),
                )
              : PdfViewer.file(filePath);
        },
      ),
    );
  }
}
