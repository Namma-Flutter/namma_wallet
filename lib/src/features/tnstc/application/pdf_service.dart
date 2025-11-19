import 'dart:io';

import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService {
  PDFService({OCRService? ocrService})
    : _ocrService = ocrService ?? getIt<OCRService>();

  final OCRService _ocrService;

  Future<String> extractTextFrom(File pdf) async {
    try {
      // Load an existing PDF document.
      final document = PdfDocument(inputBytes: pdf.readAsBytesSync());

      // Use try-finally to ensure document is always disposed
      try {
        getIt<ILogger>().debug(
          '[PDFService] PDF loaded, pages: ${document.pages.count}',
        );

        // Try extracting text from all pages at once first
        var rawText = PdfTextExtractor(document).extractText();

        // If extraction yields very little text, try page-by-page extraction
        if (rawText.length < 10 && document.pages.count > 0) {
          getIt<ILogger>().debug(
            '[PDFService] Initial extraction yielded only '
            '${rawText.length} chars, trying page-by-page extraction',
          );

          final pageTexts = <String>[];
          for (var i = 0; i < document.pages.count; i++) {
            final pageText = PdfTextExtractor(
              document,
            ).extractText(startPageIndex: i, endPageIndex: i);
            getIt<ILogger>().debug(
              '[PDFService] Page ${i + 1}: ${pageText.length} chars',
            );
            if (pageText.isNotEmpty) {
              pageTexts.add(pageText);
            }
          }

          if (pageTexts.isNotEmpty) {
            rawText = pageTexts.join('\n');
            getIt<ILogger>().debug(
              '[PDFService] Page-by-page extraction: '
              '${rawText.length} chars total',
            );
          }
        }

        // Check if PDF might be image-based or use unsupported fonts
        if (rawText.trim().isEmpty) {
          getIt<ILogger>().warning(
            '[PDFService] No text extracted from PDF. This PDF may be '
            'image-based or use fonts that are not supported. '
            'PDF has ${document.pages.count} pages. Trying OCR fallback...',
          );

          // Dispose Syncfusion document before trying OCR
          document.dispose();

          // Try OCR as fallback for image-based PDFs
          try {
            rawText = await _ocrService.extractTextFromPDF(pdf);
            getIt<ILogger>().info(
              '[PDFService] OCR fallback extracted ${rawText.length} chars',
            );
          } on Object catch (e, stackTrace) {
            getIt<ILogger>().error(
              '[PDFService] OCR fallback also failed',
              e,
              stackTrace,
            );
            // Return empty text if OCR also fails
            return '';
          }
        } else {
          // Dispose the document if we got text from Syncfusion
          document.dispose();
        }

        // Log text metadata only (no PII)
        final lineCount = rawText.split('\n').length;
        getIt<ILogger>().debug(
          '[PDFService] Extracted text: ${rawText.length} chars, '
          '$lineCount lines',
        );

        // Clean and normalize the extracted text
        final cleanedText = _cleanExtractedText(rawText);

        // Log metadata after cleaning (no PII)
        final cleanedLineCount = cleanedText.split('\n').length;
        getIt<ILogger>().debug(
          '[PDFService] Cleaned text: ${cleanedText.length} chars, '
          '$cleanedLineCount lines',
        );

        return cleanedText;
      } finally {
        // Ensure document is disposed even if an exception occurs
        // Note: document.dispose() is safe to call multiple times
        document.dispose();
      }
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[PDFService] Error extracting text from PDF',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  String _cleanExtractedText(String rawText) {
    if (rawText.isEmpty) return rawText;

    var cleanedText = rawText;

    // Remove excessive whitespace and normalize line breaks
    cleanedText = cleanedText.replaceAll(RegExp(r'\r\n'), '\n');
    cleanedText = cleanedText.replaceAll(RegExp(r'\r'), '\n');

    // Remove excessive spaces but preserve single spaces
    cleanedText = cleanedText.replaceAll(RegExp('[ ]{2,}'), ' ');

    // Remove excessive newlines but preserve structure
    cleanedText = cleanedText.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Fix common PDF extraction issues
    // Sometimes colons get separated from labels -
    // fix spacing but keep original text
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'(\w+)\s+:\s*'),
      (match) => '${match.group(1)}: ',
    );

    // Sometimes values get split across lines - try to rejoin obvious cases
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'Corporation\s*:\s*\n([A-Z\s]+)\n'),
      (match) => 'Corporation: ${match.group(1)}\n',
    );
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'Service Start Place\s*:\s*\n([A-Z\s.-]+)\n'),
      (match) => 'Service Start Place: ${match.group(1)}\n',
    );
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'Service End Place\s*:\s*\n([A-Z\s.-]+)\n'),
      (match) => 'Service End Place: ${match.group(1)}\n',
    );
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'Passenger Start Place\s*:\s*\n([A-Z\s.-]+)\n'),
      (match) => 'Passenger Start Place: ${match.group(1)}\n',
    );
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'Passenger End Place\s*:\s*\n([A-Z\s.-]+)\n'),
      (match) => 'Passenger End Place: ${match.group(1)}\n',
    );
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'Passenger Pickup Point\s*:\s*\n([A-Z\s.\-()]+)\n'),
      (match) => 'Passenger Pickup Point: ${match.group(1)}\n',
    );

    // Clean up any remaining extra whitespace
    cleanedText = cleanedText.trim();

    // No logging of actual text content to avoid PII exposure
    // Text metadata is logged in extractTextFrom() instead

    return cleanedText;
  }
}
