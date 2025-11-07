import 'dart:io';

import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService {
  String extractTextFrom(File pdf) {
    try {
      // Load an existing PDF document.
      final document = PdfDocument(inputBytes: pdf.readAsBytesSync());

      // Extract the text from all the pages.
      final rawText = PdfTextExtractor(document).extractText();

      // Dispose the document.
      document.dispose();

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
    cleanedText = cleanedText.replaceAll(RegExp(r'(\w+)\s+:\s*'), r'$1: ');

    // Sometimes values get split across lines - try to rejoin obvious cases
    cleanedText = cleanedText.replaceAll(
      RegExp(r'Corporation\s*:\s*\n([A-Z\s]+)\n'),
      r'Corporation: $1\n',
    );
    cleanedText = cleanedText.replaceAll(
      RegExp(r'Service Start Place\s*:\s*\n([A-Z\s.-]+)\n'),
      r'Service Start Place: $1\n',
    );
    cleanedText = cleanedText.replaceAll(
      RegExp(r'Service End Place\s*:\s*\n([A-Z\s.-]+)\n'),
      r'Service End Place: $1\n',
    );
    cleanedText = cleanedText.replaceAll(
      RegExp(r'Passenger Start Place\s*:\s*\n([A-Z\s.-]+)\n'),
      r'Passenger Start Place: $1\n',
    );
    cleanedText = cleanedText.replaceAll(
      RegExp(r'Passenger End Place\s*:\s*\n([A-Z\s.-]+)\n'),
      r'Passenger End Place: $1\n',
    );
    cleanedText = cleanedText.replaceAll(
      RegExp(r'Passenger Pickup Point\s*:\s*\n([A-Z\s.\-()]+)\n'),
      r'Passenger Pickup Point: $1\n',
    );

    // Clean up any remaining extra whitespace
    cleanedText = cleanedText.trim();

    // No logging of actual text content to avoid PII exposure
    // Text metadata is logged in extractTextFrom() instead

    return cleanedText;
  }
}
