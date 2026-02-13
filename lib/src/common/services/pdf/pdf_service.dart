import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService implements IPDFService {
  PDFService({
    required IOCRService ocrService,
    required ILogger logger,
  }) : _ocrService = ocrService,
       _logger = logger;

  final IOCRService _ocrService;
  final ILogger _logger;

  // Minimum expected text length threshold for successful extraction
  static const _minExpectedTextLength = 10;

  @override
  Future<String> extractTextForDisplay(XFile pdf) async {
    try {
      // Load an existing PDF document.
      final document = PdfDocument(inputBytes: await pdf.readAsBytes());

      // Use try-finally to ensure document is always disposed
      try {
        _logger.debug(
          '[PDFService] PDF loaded, pages: ${document.pages.count}',
        );

        // Try extracting text from all pages at once first
        var rawText = PdfTextExtractor(document).extractText();

        // If extraction yields very little text, try page-by-page extraction
        if (rawText.length < _minExpectedTextLength &&
            document.pages.count > 0) {
          _logger.debug(
            '[PDFService] Initial extraction yielded only '
            '${rawText.length} chars, trying page-by-page extraction',
          );

          final pageTexts = <String>[];
          for (var i = 0; i < document.pages.count; i++) {
            final pageText = PdfTextExtractor(
              document,
            ).extractText(startPageIndex: i, endPageIndex: i);
            _logger.debug(
              '[PDFService] Page ${i + 1}: ${pageText.length} chars',
            );
            if (pageText.isNotEmpty) {
              pageTexts.add(pageText);
            }
          }

          if (pageTexts.isNotEmpty) {
            rawText = pageTexts.join('\n');
            _logger.debug(
              '[PDFService] Page-by-page extraction: '
              '${rawText.length} chars total',
            );
          }
        }

        // Check if PDF might be image-based or use unsupported fonts
        if (rawText.trim().isEmpty) {
          _logger.warning(
            '[PDFService] No text extracted from PDF. This PDF may be '
            'image-based or use fonts that are not supported. '
            'PDF has ${document.pages.count} pages. Trying OCR fallback...',
          );

          // Try OCR as fallback for image-based PDFs
          try {
            rawText = await _ocrService.extractTextFromPDF(pdf);
            _logger.info(
              '[PDFService] OCR fallback extracted ${rawText.length} chars',
            );
          } on Object catch (e, stackTrace) {
            _logger.error(
              '[PDFService] OCR fallback also failed',
              e,
              stackTrace,
            );
            // Throw exception if OCR also fails
            throw Exception(
              'Failed to extract text from PDF: OCR fallback failed',
            );
          }
        }

        // Log text metadata only (no PII)
        final lineCount = rawText.split('\n').length;
        _logger.debug(
          '[PDFService] Extracted text: ${rawText.length} chars, '
          '$lineCount lines',
        );

        // Clean and normalize the extracted text
        final cleanedText = _cleanExtractedText(rawText);

        // Log metadata after cleaning (no PII)
        final cleanedLineCount = cleanedText.split('\n').length;
        _logger.debug(
          '[PDFService] Cleaned text: ${cleanedText.length} chars, '
          '$cleanedLineCount lines',
        );

        return cleanedText;
      } finally {
        // Ensure document is disposed even if an exception occurs
        document.dispose();
      }
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[PDFService] Error extracting text from PDF',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<OCRBlock>> extractBlocks(XFile pdf) async {
    try {
      // Load an existing PDF document.
      final document = PdfDocument(inputBytes: await pdf.readAsBytes());

      try {
        _logger.debug(
          '[PDFService] PDF loaded for block extraction, '
          'pages: ${document.pages.count}',
        );

        // Try extracting text from all pages first
        final rawText = PdfTextExtractor(document).extractText();

        // Check if PDF has extractable text
        if (rawText.trim().isEmpty || rawText.length < _minExpectedTextLength) {
          _logger.warning(
            '[PDFService] No text layer found, using OCR for block extraction',
          );

          // Use OCR to get blocks with geometry
          try {
            final blocks = await _ocrService.extractBlocksFromPDF(pdf);
            _logger.info(
              '[PDFService] OCR block extraction: ${blocks.length} blocks',
            );
            return blocks;
          } on Object catch (e, stackTrace) {
            _logger.error(
              '[PDFService] OCR block extraction failed',
              e,
              stackTrace,
            );
            throw Exception(
              'Failed to extract blocks from PDF: OCR fallback failed',
            );
          }
        }

        // Text layer exists - create pseudo-blocks from text lines

        final extractedBlocks = <OCRBlock>[];

        for (var pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
          final pageText = PdfTextExtractor(
            document,
          ).extractText(startPageIndex: pageIndex, endPageIndex: pageIndex);

          extractedBlocks.addAll(
            OCRBlock.fromPlainText(pageText, page: pageIndex),
          );
        }

        _logger.debug(
          '[PDFService] Created ${extractedBlocks.length} pseudo-blocks '
          'from text layer',
        );

        return extractedBlocks;
      } finally {
        document.dispose();
      }
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[PDFService] Error extracting blocks from PDF',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Extracts structured data from a PDF file using layout analysis.
  ///
  /// NOTE: This implementation is currently optimized for TNSTC-style documents
  // TODO(harish): Consider accepting field-mapping configuration or delegating
  // to type-specific extractors as more ticket types are added.
  @override
  Future<Map<String, dynamic>> extractStructuredData(XFile pdf) async {
    try {
      _logger.debug('[PDFService] Starting structured data extraction');

      // Extract blocks with geometry
      final blocks = await extractBlocks(pdf);

      // Use layout extractor to get structured data
      final extractor = LayoutExtractor(blocks);

      // Extract common fields (can be customized per ticket type)
      final structuredData = <String, dynamic>{
        'pnr': extractor.findValueForKey('PNR Number'),
        'date': extractor.findValueForKey('Date of Journey'),
        'route': extractor.findValueForKey('Route No'),
        'from':
            extractor.findValueForKey('Service Start Place') ??
            extractor.findValueForKey('Passenger Start Place'),
        'to':
            extractor.findValueForKey('Service End Place') ??
            extractor.findValueForKey('Passenger End Place'),
        'fare': extractor.findValueForKey('Total Fare'),
        'seat': extractor.findValueForKey('Seat No'),
        // Add more fields as needed
      };

      // Remove null values
      return structuredData..removeWhere((key, value) => value == null);
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[PDFService] Error extracting structured data from PDF',
        e,
        stackTrace,
      );
      rethrow;
    } finally {
      _logger.debug('[PDFService] Structured data extraction complete');
    }
  }

  @override
  Future<String> extractTextFrom(XFile pdf) => extractTextForDisplay(pdf);

  /// Cleans extracted text for human-readable display.
  ///
  /// ⚠️ WARNING: This method alters field names and should ONLY be used
  /// for display purposes, NOT for structured data extraction.
  ///
  /// The regex normalization will break multi-word keys like
  /// "Service Start Place" by removing spaces around colons.
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

    // Normalize "key : value" patterns to "key: value"
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'(\w+)\s+:\s*'),
      (match) => '${match.group(1)}: ',
    );

    // Clean up any remaining extra whitespace
    cleanedText = cleanedText.trim();

    // No logging of actual text content to avoid PII exposure
    // Text metadata is logged in extractTextFrom() instead

    return cleanedText;
  }
}
