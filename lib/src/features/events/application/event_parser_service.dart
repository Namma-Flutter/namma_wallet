import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/events/application/movie_layout_parser.dart';

class EventParserService {
  EventParserService({required ILogger logger})
    : _logger = logger,
      _parsers = [
        DistrictMovieParser(logger: logger),
      ];
  final ILogger _logger;
  final List<MovieTicketParser> _parsers;

  Future<Ticket?> parseTicketFromBlocks(
    List<OCRBlock> blocks,
    String imagePath, {
    SourceType? sourceType,
  }) async {
    try {
      // Convert blocks to text for canParse check
      final extractor = LayoutExtractor(blocks);
      final text = extractor.toPlainText();

      for (final parser in _parsers) {
        if (parser.canParse(text)) {
          // Log metadata only (no PII)
          _logger
            ..debug(
              '[EventParserService] Parsing with ${parser.providerName} '
              'using ${blocks.length} OCR blocks',
            )
            ..info(
              '[EventParserService] Attempting to parse with '
              '${parser.providerName} parser (layout-based)',
            );

          final ticket = await parser.parseTicketFromBlocks(blocks, imagePath);
          if (ticket == null) {
            _logger.warning(
              '[EventParserService] ${parser.providerName} parser '
              'failed to extract ticket from blocks',
            );
            continue;
          }

          final augmentedTicket = _augmentTicket(
            ticket,
            parser.providerName,
            sourceType,
          );

          _logger.info(
            '[EventParserService] Successfully parsed ticket with '
            '${parser.providerName} (layout-based)',
          );

          return augmentedTicket;
        }
      }

      _logger.warning(
        '[EventParserService] No parser could handle the OCR blocks',
      );
      return null;
    } on FormatException catch (e, stackTrace) {
      _logger.error(
        '[EventParserService] Format error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[EventParserService] Unexpected error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Adds "Provider" and "Source Type" extras if not already present.
  Ticket _augmentTicket(
    Ticket ticket,
    String providerName,
    SourceType? sourceType,
  ) {
    var updated = ticket;

    // 1. Add Provider extra if missing
    final hasProvider =
        updated.extras?.any((e) => e.title == 'Provider') ?? false;
    if (!hasProvider) {
      updated = updated.copyWith(
        extras: [
          ...?updated.extras,
          ExtrasModel(title: 'Provider', value: providerName),
        ],
      );
    }

    // 2. Add Source Type extra if provided and missing
    if (sourceType != null) {
      final hasSourceType =
          updated.extras?.any((e) => e.title == 'Source Type') ?? false;

      if (!hasSourceType) {
        updated = updated.copyWith(
          extras: [
            ...?updated.extras,
            ExtrasModel(title: 'Source Type', value: sourceType.name),
          ],
        );
      }
    }

    return updated;
  }
}
