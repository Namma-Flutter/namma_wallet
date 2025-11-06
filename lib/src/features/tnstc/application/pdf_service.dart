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

      // Log raw text before cleaning
      getIt<ILogger>().debug('[PDFService] === RAW PDF TEXT ===');
      getIt<ILogger>().debug('[PDFService] $rawText');
      getIt<ILogger>().debug('[PDFService] === END RAW PDF TEXT ===');

      // Clean and normalize the extracted text
      final cleanedText = _cleanExtractedText(rawText);

      // Log for debugging
      getIt<ILogger>().debug(
        '[PDFService] Raw PDF text length: ${rawText.length}',
      );
      getIt<ILogger>().debug(
        '[PDFService] Cleaned PDF text length: ${cleanedText.length}',
      );

      return cleanedText;
    } catch (e) {
      getIt<ILogger>().error(
        '[PDFService] Error extracting text from PDF',
        e is Exception ? e : Exception(e.toString()),
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

    // Log cleaned text for debugging (first 500 chars)
    final preview = cleanedText.length > 500
        ? '${cleanedText.substring(0, 500)}...'
        : cleanedText;
    getIt<ILogger>().debug('[PDFService] Cleaned PDF text preview: $preview');

    return cleanedText;
  }
}
