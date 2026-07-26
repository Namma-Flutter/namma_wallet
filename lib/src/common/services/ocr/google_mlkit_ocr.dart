// coverage:ignore-file
import 'dart:io';

import 'package:cross_file/cross_file.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

class GoogleMLKitOCR implements IOCRService {
  GoogleMLKitOCR({required this._logger});

  final ILogger _logger;

  @override
  Future<List<OCRBlock>> extractBlocksFromPDF(XFile pdfFile) async {
    PdfDocument? doc;
    TextRecognizer? textRecognizer;

    try {
      _logger.debug('[OCRService] Starting OCR extraction from PDF');

      // Open the PDF document
      doc = await PdfDocument.openFile(pdfFile.path);
      _logger.debug('[OCRService] PDF opened, pages: ${doc.pages.length}');

      textRecognizer = TextRecognizer();
      final allBlocks = <OCRBlock>[];

      // Get temp directory once outside the loop
      final tempDir = await getTemporaryDirectory();

      // Process each page
      for (var pageNum = 0; pageNum < doc.pages.length; pageNum++) {
        _logger.debug('[OCRService] Processing page ${pageNum + 1}...');

        File? tempImage;
        try {
          // Get the page
          final page = doc.pages[pageNum];

          // Render page to image at high resolution for better OCR
          // Using 2x scale for better quality (144 DPI)
          final pageImage = await page.render(
            fullWidth: page.width * 2,
            fullHeight: page.height * 2,
          );

          if (pageImage == null) {
            _logger.warning(
              '[OCRService] Failed to render page ${pageNum + 1}',
            );
            continue;
          }

          // Convert PdfImage to image package format and encode to PNG
          final image = pageImage.createImageNF();
          final pngBytes = img.encodePng(image);

          // Dispose the PdfImage as it's no longer needed
          pageImage.dispose();

          // Save temporarily for ML Kit processing
          // Use timestamp to avoid conflicts between concurrent calls
          tempImage = File(
            '${tempDir.path}/ocr_${DateTime.timestamp().microsecondsSinceEpoch}_'
            'page_${pageNum + 1}.png',
          );

          await tempImage.writeAsBytes(pngBytes);

          _logger.debug(
            '[OCRService] Page ${pageNum + 1} rendered to image: '
            '${tempImage.path} (${pngBytes.length} bytes)',
          );

          // Perform OCR on the image
          final inputImage = InputImage.fromFile(tempImage);
          final recognizedText = await textRecognizer.processImage(inputImage);

          final startIndex = allBlocks.length;
          // Extract blocks with geometry from ML Kit
          for (final textBlock in recognizedText.blocks) {
            // ML Kit can return text blocks, lines, or elements
            // For maximum granularity, we extract at line level
            for (final line in textBlock.lines) {
              if (line.text.trim().isEmpty) continue;

              allBlocks.add(
                OCRBlock(
                  text: line.text.trim(),
                  boundingBox: line.boundingBox,
                  page: pageNum,
                  confidence: line.confidence,
                ),
              );
            }
          }

          final blocksOnPage = allBlocks.length - startIndex;
          _logger.debug(
            '[OCRService] Page ${pageNum + 1} OCR: '
            '$blocksOnPage blocks extracted',
          );
        } on Object catch (e, stackTrace) {
          _logger.error(
            '[OCRService] Error processing page ${pageNum + 1}',
            e,
            stackTrace,
          );
        } finally {
          // Always clean up temporary file, even if an exception occurred
          if (tempImage != null && tempImage.existsSync()) {
            try {
              await tempImage.delete();
            } on Object catch (e) {
              _logger.debug('[OCRService] Failed to delete temp file: $e');
            }
          }
        }
      }

      _logger.debug(
        '[OCRService] OCR complete: ${allBlocks.length} total blocks from '
        '${doc.pages.length} pages',
      );

      return allBlocks;
    } on Object catch (e, stackTrace) {
      _logger.error('[OCRService] OCR extraction failed', e, stackTrace);
      rethrow;
    } finally {
      // Always clean up resources, even if an exception occurred
      if (textRecognizer != null) {
        await textRecognizer.close();
      }
      if (doc != null) {
        await doc.dispose();
      }
    }
  }

  @override
  Future<String> extractTextFromPDF(XFile pdfFile) async {
    // Legacy method: use the new blocks API and concatenate text
    final blocks = await extractBlocksFromPDF(pdfFile);

    // Group by page and concatenate
    final pageTexts = <int, List<String>>{};
    for (final block in blocks) {
      pageTexts.putIfAbsent(block.page, () => []).add(block.text);
    }

    // Join pages with double newlines
    final sortedPages = pageTexts.keys.toList()..sort();
    final combinedText = sortedPages
        .map((page) => pageTexts[page]!.join('\n'))
        .join('\n\n');

    return combinedText;
  }

  @override
  Future<List<OCRBlock>> extractBlocksFromImage(XFile image) async {
    TextRecognizer? textRecognizer;

    try {
      _logger.debug('[OCRService] Starting OCR extraction from Image');

      textRecognizer = TextRecognizer();
      final allBlocks = <OCRBlock>[];

      // Convert XFile path directly to a native File for ML Kit
      final file = File(image.path);

      if (!file.existsSync()) {
        _logger.warning(
          '[OCRService] Image file does not exist at path: ${image.path}',
        );
        return const [];
      }

      // Feed directly into Google ML Kit
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Extract blocks with geometry at the line level (matching PDF behavior)
      for (final textBlock in recognizedText.blocks) {
        for (final line in textBlock.lines) {
          if (line.text.trim().isEmpty) continue;

          allBlocks.add(
            OCRBlock(
              text: line.text.trim(),
              boundingBox: line.boundingBox,
              page: 0, // Always page 0 for a single image
              confidence: line.confidence,
            ),
          );
        }
      }

      _logger.debug(
        '[OCRService] Image OCR complete: ${allBlocks.length} blocks extracted',
      );

      return allBlocks;
    } on Object catch (e, stackTrace) {
      _logger.error('[OCRService] Image OCR extraction failed', e, stackTrace);
      rethrow;
    } finally {
      // Clean up the ML Kit text recognizer resource
      if (textRecognizer != null) {
        await textRecognizer.close();
      }
    }
  }
}
