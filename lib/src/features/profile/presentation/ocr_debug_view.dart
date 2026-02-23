import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';

/// Debug page to view OCR blocks from uploaded PDFs.
///
/// This page helps developers:
/// - Extract OCR blocks from PDF tickets
/// - View text content and bounding box coordinates
/// - Copy OCR data to create test fixtures
///
/// Only accessible in debug mode.
class OCRDebugView extends StatefulWidget {
  const OCRDebugView({super.key});

  @override
  State<OCRDebugView> createState() => _OCRDebugViewState();
}

class _OCRDebugViewState extends State<OCRDebugView> {
  final IPDFService _pdfService = getIt<IPDFService>();
  List<OCRBlock>? _ocrBlocks;
  bool _isLoading = false;
  String? _fileName;

  Future<void> _pickAndProcessPDF() async {
    setState(() {
      _isLoading = true;
      _ocrBlocks = null;
      _fileName = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Load bytes only on web
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final file = result.files.first;
      _fileName = file.name;

      // Create XFile based on platform
      final XFile xFile;
      if (kIsWeb && file.bytes != null) {
        xFile = XFile.fromData(
          file.bytes!,
          name: file.name,
          mimeType: 'application/pdf',
        );
      } else if (file.path != null) {
        xFile = XFile(file.path!);
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackbar(
          context,
          'Could not read the selected file. Please try again.',
          isError: true,
        );
        return;
      }

      final blocks = await _pdfService.extractBlocks(xFile);

      if (!mounted) return;

      setState(() {
        _ocrBlocks = blocks;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      showSnackbar(
        context,
        'Failed to process PDF: $e',
        isError: true,
      );
    }
  }

  String _generateFixtureCode() {
    if (_ocrBlocks == null || _ocrBlocks!.isEmpty) {
      return '// No OCR blocks to export';
    }

    final buffer = StringBuffer()
      ..writeln('// Generated fixture from: $_fileName')
      ..writeln('// Total blocks: ${_ocrBlocks!.length}')
      ..writeln()
      ..writeln('static final sampleOCRBlocks = <OCRBlock>[');

    for (final block in _ocrBlocks!) {
      final box = block.boundingBox;
      buffer
        ..writeln('  OCRBlock(')
        ..writeln('    text: ${_escapeString(block.text)},')
        ..writeln('    boundingBox: Rect.fromLTRB(')
        ..writeln('      ${box.left},')
        ..writeln('      ${box.top},')
        ..writeln('      ${box.right},')
        ..writeln('      ${box.bottom},')
        ..writeln('    ),')
        ..writeln('    page: ${block.page},');
      if (block.confidence != null) {
        buffer.writeln('    confidence: ${block.confidence},');
      }
      buffer.writeln('  ),');
    }

    buffer.writeln('];');
    return buffer.toString();
  }

  String _generateJsonExport() {
    if (_ocrBlocks == null || _ocrBlocks!.isEmpty) {
      return '{}';
    }

    final json = _ocrBlocks!.map((block) {
      return {
        'text': block.text,
        'boundingBox': {
          'left': block.boundingBox.left,
          'top': block.boundingBox.top,
          'right': block.boundingBox.right,
          'bottom': block.boundingBox.bottom,
        },
        'page': block.page,
        if (block.confidence != null) 'confidence': block.confidence,
      };
    }).toList();

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({'blocks': json, 'fileName': _fileName});
  }

  String _escapeString(String str) {
    // Escape special characters for Dart string literal
    return """'${str.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n')}'""";
  }

  Future<void> _copyToClipboard(String content, String label) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;

    showSnackbar(
      context,
      '$label copied to clipboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Debug Viewer'),
        leading: const RoundedBackButton(),
        actions: [
          if (_ocrBlocks != null && _ocrBlocks!.isNotEmpty) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy data',
              onSelected: (value) {
                if (value == 'dart') {
                  unawaited(
                    _copyToClipboard(
                      _generateFixtureCode(),
                      'Dart fixture code',
                    ),
                  );
                } else if (value == 'json') {
                  unawaited(
                    _copyToClipboard(_generateJsonExport(), 'JSON data'),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'dart',
                  child: Row(
                    children: [
                      Icon(Icons.code),
                      SizedBox(width: 8),
                      Text('Copy as Dart'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'json',
                  child: Row(
                    children: [
                      Icon(Icons.data_object),
                      SizedBox(width: 8),
                      Text('Copy as JSON'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndProcessPDF,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_isLoading ? 'Processing...' : 'Upload PDF'),
                ),
                if (_fileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'File: $_fileName',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_ocrBlocks != null)
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total blocks: ${_ocrBlocks!.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: () => _showCodePreview(context),
                          icon: const Icon(Icons.visibility),
                          label: const Text('Preview code'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _ocrBlocks!.length,
                      itemBuilder: (context, index) {
                        final block = _ocrBlocks![index];
                        return _OCRBlockCard(
                          block: block,
                          index: index,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload a PDF to extract OCR blocks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the generated code to create test fixtures',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCodePreview(BuildContext context) {
    final code = _generateFixtureCode();

    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Fixture Code Preview'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      unawaited(_copyToClipboard(code, 'Fixture code'));
                      Navigator.pop(context);
                    },
                    tooltip: 'Copy',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OCRBlockCard extends StatelessWidget {
  const _OCRBlockCard({
    required this.block,
    required this.index,
  });

  final OCRBlock block;
  final int index;

  @override
  Widget build(BuildContext context) {
    final box = block.boundingBox;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Block #$index',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          block.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Text', value: '"${block.text}"'),
                const SizedBox(height: 8),
                _InfoRow(label: 'Page', value: block.page.toString()),
                const SizedBox(height: 8),
                if (block.confidence != null)
                  _InfoRow(
                    label: 'Confidence',
                    value: '${(block.confidence! * 100).toStringAsFixed(1)}%',
                  ),
                const Divider(height: 24),
                const Text(
                  'Bounding Box',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Left', value: box.left.toStringAsFixed(2)),
                _InfoRow(label: 'Top', value: box.top.toStringAsFixed(2)),
                _InfoRow(label: 'Right', value: box.right.toStringAsFixed(2)),
                _InfoRow(label: 'Bottom', value: box.bottom.toStringAsFixed(2)),
                _InfoRow(
                  label: 'Width',
                  value: box.width.toStringAsFixed(2),
                ),
                _InfoRow(
                  label: 'Height',
                  value: box.height.toStringAsFixed(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
