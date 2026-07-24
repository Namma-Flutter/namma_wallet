import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/common/services/image/image_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';

class ImageService implements IImageService {
  ImageService({
    required this._ocrService,
    required this._logger,
  });

  final IOCRService _ocrService;
  final ILogger _logger;

  @override
  Future<List<OCRBlock>> extractBlocks(XFile image) async {
    try {
      if (kIsWeb) {
        _logger.warning(
          '[ImageService] OCR block extraction is not supported on web',
        );
        throw UnsupportedError(
          'Failed to extract blocks from Image: OCR vision engines are not '
          'supported on the web platform. Web currently supports SMS '
          'extraction only.',
        );
      }

      _logger.debug(
        '[ImageService] Starting OCR block extraction for image: ${image.name}',
      );

      // Extract blocks directly via the OCR vision engine
      final blocks = await _ocrService.extractBlocksFromImage(image);

      if (blocks.isEmpty) {
        _logger.warning(
          '[ImageService] OCR extraction yielded 0 blocks for image: '
          '${image.name}',
        );
      } else {
        _logger.info(
          '[ImageService] Successfully extracted ${blocks.length} OCR blocks',
        );
      }

      return blocks;
    } on Object catch (e, stackTrace) {
      if (e is UnsupportedError) {
        _logger.warning('[ImageService] $e');
        rethrow;
      }

      _logger.error(
        '[ImageService] Error extracting blocks from Image',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Extracts structured data from an image file using layout analysis.
  ///
  /// NOTE: This implementation is currently optimized for TNSTC-style documents
  // TODO(sreeram): Check this
  @override
  Future<Map<String, dynamic>> extractStructuredData(XFile image) async {
    try {
      _logger.debug('[ImageService] Starting structured data extraction');

      // Extract blocks with geometry using the image OCR method
      final blocks = await extractBlocks(image);

      if (blocks.isEmpty) {
        return const <String, dynamic>{};
      }

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
      };

      // Remove null values (adhering to zero-fallback rule)
      return structuredData..removeWhere((key, value) => value == null);
    } on Object catch (e, stackTrace) {
      if (e is UnsupportedError) {
        _logger.warning('[ImageService] $e');
        rethrow;
      }

      _logger.error(
        '[ImageService] Error extracting structured data from Image',
        e,
        stackTrace,
      );
      rethrow;
    } finally {
      _logger.debug('[ImageService] Structured data extraction complete');
    }
  }
}
