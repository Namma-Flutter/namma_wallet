import 'dart:developer' as developer;
import 'dart:io';

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

      // Clean and normalize the extracted text
      final cleanedText = _cleanExtractedText(rawText);

      // Log for debugging
      developer.log('Raw PDF text length: ${rawText.length}',
          name: 'PDFService');
      developer.log('Cleaned PDF text length: ${cleanedText.length}',
          name: 'PDFService');

      return cleanedText;
    } catch (e) {
      developer.log('Error extracting text from PDF',
          name: 'PDFService', error: e);
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
    // Sometimes colons get separated from labels
    cleanedText = cleanedText.replaceAll(RegExp(r'(\w+)\s+:\s*'), r'$1: ');

    // Sometimes values get split across lines - try to rejoin obvious cases
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Corporation\s*:\s*\n([A-Z\s]+)\n'),
        r'Corporation: $1\n');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Service Start Place\s*:\s*\n([A-Z\s.-]+)\n'),
        r'Service Start Place: $1\n');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Service End Place\s*:\s*\n([A-Z\s.-]+)\n'),
        r'Service End Place: $1\n');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Passenger Start Place\s*:\s*\n([A-Z\s.-]+)\n'),
        r'Passenger Start Place: $1\n');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Passenger End Place\s*:\s*\n([A-Z\s.-]+)\n'),
        r'Passenger End Place: $1\n');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Passenger Pickup Point\s*:\s*\n([A-Z\s.\-()]+)\n'),
        r'Passenger Pickup Point: $1\n');

    // Clean up any remaining extra whitespace
    cleanedText = cleanedText.trim();

    // Log cleaned text for debugging (first 500 chars)
    final preview = cleanedText.length > 500
        ? '${cleanedText.substring(0, 500)}...'
        : cleanedText;
    developer.log('Cleaned PDF text preview: $preview',
        name: 'PDFService');

    return cleanedText;
  }
}
