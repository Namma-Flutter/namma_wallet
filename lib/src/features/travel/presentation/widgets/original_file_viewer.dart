import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:pdfrx/pdfrx.dart';

const _imageExtensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'};

/// Full-screen viewer for the original ticket file (PDF or image) stored
/// alongside a ticket.
class OriginalFileViewer extends StatelessWidget {
  const OriginalFileViewer({required this.filePath, super.key});

  final String filePath;

  bool get _isImage {
    final lower = filePath.toLowerCase();
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
      body: _isImage
          ? InteractiveViewer(child: Center(child: Image.file(File(filePath))))
          : PdfViewer.file(filePath),
    );
  }
}
