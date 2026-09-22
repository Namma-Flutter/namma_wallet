import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';

class ImageService {
  ImageService({
    required this._ocrService,
    required this._logger,
  });

  final IOCRService _ocrService;
  final ILogger _logger;

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
        '[ImageService] Starting Image OCR block extraction',
      );

      // Extract blocks directly via the OCR vision engine
      final blocks = await _ocrService.extractBlocksFromImage(image);

      if (blocks.isEmpty) {
        _logger.warning(
          '[ImageService] OCR extraction has yielded 0 blocks for this image'
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
}
