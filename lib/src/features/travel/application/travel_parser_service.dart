import 'dart:convert';

import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_pdf_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_layout_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/domain/ticket_update_info.dart';

abstract class TravelTicketParser {
  bool canParse(String text);

  /// Parse ticket from OCR blocks (preferred for PDFs)
  Ticket parseTicketFromBlocks(List<OCRBlock> blocks) {
    // Default implementation: convert blocks to text and use text parser
    final extractor = LayoutExtractor(blocks);
    final text = extractor.toPlainText();
    return parseTicket(text);
  }

  /// Parse ticket from plain text (for SMS or legacy support)
  Ticket parseTicket(String text);

  bool isSMSFormat(String text);

  TicketUpdateInfo? parseUpdate(String text) => null;

  String get providerName;

  TicketType get ticketType;
}

class TNSTCBusParser extends TravelTicketParser {
  TNSTCBusParser({required ILogger logger}) : _logger = logger;
  final ILogger _logger;

  @override
  String get providerName => 'TNSTC';

  @override
  TicketType get ticketType => TicketType.bus;

  @override
  bool canParse(String text) {
    // Must have at least one TNSTC-specific keyword
    final tnstcKeywords = [
      'TNSTC',
      'Tamil Nadu',
      'Corporation',
      'Service Start Place',
      'Trip Code',
    ];

    final hasTNSTCKeyword = tnstcKeywords.any(
      (pattern) => text.toLowerCase().contains(pattern.toLowerCase()),
    );

    // And should not have IRCTC keyword
    final hasIRCTCKeyword = text.toLowerCase().contains('irctc');

    return hasTNSTCKeyword && !hasIRCTCKeyword;
  }

  /// Detects if the text is SMS format by checking for SMS-specific patterns
  @override
  bool isSMSFormat(String text) {
    // SMS contains TNSTC SMS-style patterns
    // like "From :", "To ", "Trip :"
    // PDF has "Service Start Place", "PNR Number", "Date of Journey"
    final smsPatterns = [
      r'From\s*:\s*[A-Z]',
      r'To\s*[A-Z]',
      r'Trip\s*:\s*',
      r'Time\s*:\s*,?\s*\d{1,2}:\d{2}',
      r'Boarding at\s*:',
    ];

    final pdfPatterns = [
      'Service Start Place',
      'Service End Place',
      'Passenger Pickup Point',
      'PNR Number',
      'Bank Txn',
    ];

    // Check if it matches SMS patterns
    final hasSmsPattern = smsPatterns.any(
      (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text),
    );

    // Check if it matches PDF patterns
    final hasPdfPattern = pdfPatterns.any(
      (pattern) => text.toLowerCase().contains(pattern.toLowerCase()),
    );

    // If has SMS patterns and no PDF patterns, it's SMS
    return hasSmsPattern && !hasPdfPattern;
  }

  @override
  Ticket parseTicketFromBlocks(List<OCRBlock> blocks) {
    // Use layout parser for PDFs (with geometry)
    final layoutParser = TNSTCLayoutParser(logger: _logger);
    return layoutParser.parseTicketFromBlocks(blocks);
  }

  @override
  Ticket parseTicket(String text) {
    // Detect if this is SMS or PDF format
    final isSMS = isSMSFormat(text);

    // Use appropriate parser based on format
    if (isSMS) {
      final smsParser = TNSTCSMSParser();
      return smsParser.parseTicket(text);
    } else {
      // Use the layout parser via pseudo-blocks for plain text.
      // This ensures consistent parsing logic regardless of input source.
      final layoutParser = TNSTCLayoutParser(logger: _logger);
      return layoutParser.parseTicket(text);
    }
  }

  @override
  TicketUpdateInfo? parseUpdate(String text) {
    // Match TNSTC update pattern
    if (text.toUpperCase().contains('TNSTC') &&
        (text.toLowerCase().contains('conductor mobile no') ||
            text.toLowerCase().contains('vehicle no'))) {
      // Extract PNR - handle both "PNR:" and "PNR NO." formats
      final pnrMatch = RegExp(
        r'(?:PNR NO\.\s*|PNR)\s*:\s*([^,\s]+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (pnrMatch == null) return null;

      final pnr = pnrMatch.group(1)!.trim();
      final updates = <String, Object?>{};
      final extrasUpdates = <Map<String, dynamic>>[];

      // Extract Conductor Mobile No
      final mobileMatch = RegExp(
        r'Conductor Mobile No\s*:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (mobileMatch != null) {
        extrasUpdates.add({
          'title': 'Conductor Mobile No',
          'value': mobileMatch.group(1)!.trim(),
        });
      }

      // Extract Vehicle No
      final vehicleMatch = RegExp(
        r'Vehicle No\s*:\s*([^,\s]+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (vehicleMatch != null) {
        extrasUpdates.add({
          'title': 'Vehicle No',
          'value': vehicleMatch.group(1)!.trim(),
        });
      }

      // If nothing extracted, return null
      if (extrasUpdates.isEmpty) return null;

      // Convert extras into JSON (so updateTicketById can merge it)
      updates['extras'] = jsonEncode(extrasUpdates);

      // Safe logging
      final sanitizedPnr = _maskPnr(pnr);
      _logger.info(
        '[TicketParserService] TNSTC update SMS for PNR: $sanitizedPnr '
        '(extras updated: ${extrasUpdates.length})',
      );

      return TicketUpdateInfo(
        pnrNumber: pnr,
        providerName: 'TNSTC', // logical info, NOT stored in DB
        updates: updates,
      );
    }

    return null;
  }

  /// Mask PNR to show only last 3 characters for safe logging
  /// Returns '***' for null, empty, or short PNRs (≤3 chars)
  String _maskPnr(String? pnr) {
    if (pnr == null || pnr.isEmpty || pnr.length <= 3) {
      return '***';
    }
    return '${'*' * (pnr.length - 3)}${pnr.substring(pnr.length - 3)}';
  }
}

/// IRCTC train ticket parser.
///
/// Currently uses text-based parsing for both SMS and PDF formats.
// TODO(harish): Consider implementing geometry-aware extraction (similar to
// TNSTCLayoutParser) for IRCTC PDFs in a future iteration to better handle
// complex layouts and improve extraction accuracy.
class IRCTCTrainParser extends TravelTicketParser {
  IRCTCTrainParser({required ILogger logger}) : _logger = logger;
  final ILogger _logger;

  /// Sentinel value for invalid/missing journey dates
  /// This is UTC(1970,1,1) - epoch start time
  static final DateTime invalidDateSentinel = DateTime.utc(1970);

  @override
  String get providerName => 'IRCTC';

  @override
  TicketType get ticketType => TicketType.train;

  @override
  bool canParse(String text) {
    return text.toLowerCase().contains('irctc');
  }

  @override
  bool isSMSFormat(String text) {
    final lower = text.toLowerCase();

    final smsPatterns = [
      r'pnr[:\s\-]*\d{6,10}',
      r'trn[:\s\-]*\d{3,5}',
      r'doj[:\s\-]*\d{1,2}[-/]\d{1,2}[-/]\d{2,4}',
      r'\b[A-Z]{2,5}-[A-Z]{2,5}\b',
      r'dp[:\s\-]*\d{1,2}[:.]\d{2}',
      r'boarding at\s+[A-Z]{2,5}',
      r'[A-Za-z]+[ ]?[A-Za-z]*\+?\d*,',
      '-irctc',
    ];

    final pdfPatterns = [
      'ticket details',
      'boarding station',
      'reservation up-to',
      'train name',
      'passenger details',
      'quota',
      'booking id',
      'berth',
      'charting status',
      'fare break-up',
      'adhar',
    ];

    final hasSmsPattern = smsPatterns.any(
      (p) => RegExp(p, caseSensitive: false).hasMatch(text),
    );

    final hasPdfPattern = pdfPatterns.any(
      (p) => lower.contains(p.toLowerCase()),
    );

    return hasSmsPattern && !hasPdfPattern;
  }

  @override
  Ticket parseTicket(String text) {
    final isSMS = isSMSFormat(text);

    if (isSMS) {
      final smsParser = IRCTCSMSParser();
      return smsParser.parseTicket(text);
    } else {
      final pdfParser = IRCTCPDFParser(logger: _logger);
      return pdfParser.parseTicket(text);
    }
  }

  @override
  TicketUpdateInfo? parseUpdate(String text) => null;
}

/// SETC bus ticket parser.
class SETCBusParser extends TravelTicketParser {
  SETCBusParser({required ILogger logger}) : _logger = logger;
  final ILogger _logger;
  @override
  String get providerName => 'SETC';

  @override
  TicketType get ticketType => TicketType.bus;

  @override
  bool canParse(String text) {
    // SETC-specific patterns (without TNSTC)
    final setcPatterns = [
      'SETC',
      'South Tamil Nadu',
    ];

    // Check if it contains SETC but not TNSTC
    final hasSETC = setcPatterns.any(
      (pattern) => text.toUpperCase().contains(pattern.toUpperCase()),
    );
    return hasSETC;
  }

  @override
  Ticket parseTicketFromBlocks(List<OCRBlock> blocks) {
    // Use layout parser for PDFs (with geometry).
    // SETC layout is identical to TNSTC.
    final layoutParser = TNSTCLayoutParser(logger: _logger);
    return layoutParser.parseTicketFromBlocks(blocks);
  }

  @override
  Ticket parseTicket(String text) {
    // Detect if this is SMS or PDF format
    final isSMS = isSMSFormat(text);

    // Use appropriate parser based on format
    if (isSMS) {
      final smsParser = TNSTCSMSParser();
      return smsParser.parseTicket(text);
    } else {
      // Use the layout parser via pseudo-blocks for plain text.
      final layoutParser = TNSTCLayoutParser(logger: _logger);
      return layoutParser.parseTicket(text);
    }
  }

  @override
  bool isSMSFormat(String text) {
    // SMS contains SETC SMS-style patterns (same as TNSTC)
    final smsPatterns = [
      r'From\s*:\s*[A-Z]',
      r'To\s*[A-Z]',
      r'Trip\s*:\s*',
      r'Time\s*:\s*,?\s*\d{1,2}:\d{2}',
      r'Boarding at\s*:',
    ];

    final pdfPatterns = [
      'Service Start Place',
      'Service End Place',
      'Passenger Pickup Point',
      'PNR Number',
      'Bank Txn',
    ];

    final hasSmsPattern = smsPatterns.any(
      (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text),
    );

    final hasPdfPattern = pdfPatterns.any(
      (pattern) => text.toLowerCase().contains(pattern.toLowerCase()),
    );

    return hasSmsPattern && !hasPdfPattern;
  }
}

class TravelParserService implements ITravelParser {
  TravelParserService({required ILogger logger})
    : _logger = logger,
      _parsers = [
        SETCBusParser(logger: logger),
        TNSTCBusParser(logger: logger),
        IRCTCTrainParser(logger: logger),
      ];
  final ILogger _logger;
  final List<TravelTicketParser> _parsers;

  /// Detects if this is an update SMS (e.g., conductor details for TNSTC)
  @override
  TicketUpdateInfo? parseUpdateSMS(String text) {
    for (final parser in _parsers) {
      final update = parser.parseUpdate(text);
      if (update != null) {
        return update;
      }
    }
    return null;
  }

  @override
  Ticket? parseTicketFromBlocks(
    List<OCRBlock> blocks, {
    SourceType? sourceType,
  }) {
    try {
      // Convert blocks to text for canParse check
      final extractor = LayoutExtractor(blocks);
      final text = extractor.toPlainText();

      for (final parser in _parsers) {
        if (parser.canParse(text)) {
          // Log metadata only (no PII)
          _logger
            ..debug(
              '[TravelParserService] Parsing with ${parser.providerName} '
              'using ${blocks.length} OCR blocks',
            )
            ..info(
              '[TravelParserService] Attempting to parse with '
              '${parser.providerName} parser (layout-based)',
            );

          final ticket = parser.parseTicketFromBlocks(blocks);
          final augmentedTicket = _augmentTicket(
            ticket,
            parser.providerName,
            sourceType,
          );

          _logger.info(
            '[TravelParserService] Successfully parsed ticket with '
            '${parser.providerName} (layout-based)',
          );

          return augmentedTicket;
        }
      }

      _logger.warning(
        '[TravelParserService] No parser could handle the OCR blocks',
      );
      return null;
    } on FormatException catch (e, stackTrace) {
      _logger.error(
        '[TravelParserService] Format error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[TravelParserService] Unexpected error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Ticket? parseTicketFromText(
    String text, {
    SourceType? sourceType,
  }) {
    try {
      for (final parser in _parsers) {
        if (parser.canParse(text)) {
          // Log metadata only (no PII from raw text)
          final lineCount = text.split('\n').length;
          final wordCount = text.split(RegExp(r'\s+')).length;
          _logger
            ..debug(
              '[TravelParserService] Ticket text metadata: '
              '${text.length} chars, $lineCount lines, $wordCount words',
            )
            ..info(
              '[TravelParserService] Attempting to parse with '
              '${parser.providerName} parser',
            );

          final ticket = parser.parseTicket(text);
          final augmentedTicket = _augmentTicket(
            ticket,
            parser.providerName,
            sourceType,
          );

          _logger.info(
            '[TravelParserService] Successfully parsed ticket with '
            '${parser.providerName}',
          );

          return augmentedTicket;
        }
      }

      _logger.warning(
        '[TravelParserService] No parser could handle the text',
      );
      return null;
    } on FormatException catch (e, stackTrace) {
      _logger.error(
        '[TravelParserService] Format error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[TravelParserService] Unexpected error during ticket parsing',
        e,
        stackTrace,
      );
      return null;
    }
  }

  List<String> getSupportedProviders() {
    return _parsers.map((parser) => parser.providerName).toList();
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

  bool isTicketText(String text) {
    return _parsers.any((parser) => parser.canParse(text));
  }
}
