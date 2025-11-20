import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

class OCRService {
  Future<String> extractTextFromPDF(File pdfFile) async {
    final logger = getIt<ILogger>();

    PdfDocument? doc;
    TextRecognizer? textRecognizer;

    try {
      logger.debug('[OCRService] Starting OCR extraction from PDF');

      // Open the PDF document
      doc = await PdfDocument.openFile(pdfFile.path);
      logger.debug('[OCRService] PDF opened, pages: ${doc.pages.length}');

      textRecognizer = TextRecognizer();
      final extractedTexts = <String>[];

      // Get temp directory once outside the loop
      final tempDir = await getTemporaryDirectory();

      // Process each page
      for (var pageNum = 0; pageNum < doc.pages.length; pageNum++) {
        logger.debug('[OCRService] Processing page ${pageNum + 1}...');

        File? tempImageFile;
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
            logger.warning(
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
          tempImageFile = File(
            '${tempDir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}_'
            'page_${pageNum + 1}.png',
          );

          await tempImageFile.writeAsBytes(pngBytes);

          logger.debug(
            '[OCRService] Page ${pageNum + 1} rendered to image: '
            '${tempImageFile.path} (${pngBytes.length} bytes)',
          );

          // Perform OCR on the image
          final inputImage = InputImage.fromFile(tempImageFile);
          final recognizedText = await textRecognizer.processImage(inputImage);

          logger.debug(
            '[OCRService] Page ${pageNum + 1} OCR: '
            '${recognizedText.text.length} chars extracted',
          );

          if (recognizedText.text.isNotEmpty) {
            extractedTexts.add(recognizedText.text);
          }
        } on Object catch (e, stackTrace) {
          logger.error(
            '[OCRService] Error processing page ${pageNum + 1}',
            e,
            stackTrace,
          );
        } finally {
          // Always clean up temporary file, even if an exception occurred
          if (tempImageFile != null && tempImageFile.existsSync()) {
            try {
              await tempImageFile.delete();
            } on Object catch (e) {
              logger.debug('[OCRService] Failed to delete temp file: $e');
            }
          }
        }
      }

      final combinedText = extractedTexts.join('\n\n');
      logger.debug(
        '[OCRService] OCR complete: ${combinedText.length} total chars from '
        '${extractedTexts.length} pages',
      );

      return combinedText;
    } on Object catch (e, stackTrace) {
      logger.error('[OCRService] OCR extraction failed', e, stackTrace);
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
}
