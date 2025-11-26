import 'dart:convert';

import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

abstract class TravelTicketParser {
  bool canParse(String text);

  Ticket parseTicket(String text);

  TicketUpdateInfo? parseUpdate(String text) => null;

  String get providerName;

  TicketType get ticketType;
}

class TNSTCBusParser implements TravelTicketParser {
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
  bool _isSMSFormat(String text) {
    // SMS contains "SETC" or has SMS-style patterns
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
  Ticket parseTicket(String text) {
    // Detect if this is SMS or PDF format
    final isSMS = _isSMSFormat(text);

    // Use appropriate parser based on format
    if (isSMS) {
      final smsParser = TNSTCSMSParser();
      return smsParser.parseTicket(text);
    } else {
      final pdfParser = TNSTCPDFParser(logger: _logger);
      return pdfParser.parseTicket(text);
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

class IRCTCTrainParser implements TravelTicketParser {
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
    // Must have IRCTC keyword for reliable detection
    return text.toLowerCase().contains('irctc');
  }

  @override
  Ticket parseTicket(String text) {
    // For now, create a basic IRCTC ticket
    // TODO(keerthivasan): Implement proper IRCTC text parsing if needed
    // Currently IRCTC tickets are primarily handled via QR codes

    // Extract PNR number
    // Use [ \t]* instead of \s* to avoid matching across newlines
    final pnrMatch = RegExp(
      r'PNR No\.[ \t]*:[ \t]*([A-Z0-9]+)',
      caseSensitive: false,
    ).firstMatch(text);

    final pnrNumber = pnrMatch?.group(1)?.trim();
    if (pnrNumber == null || pnrNumber.isEmpty) {
      return Ticket(
        ticketId: '',
        primaryText: 'IRCTC Train Ticket',
        secondaryText: '',
        startTime: invalidDateSentinel,
        location: 'Unknown',
        extras: [ExtrasModel(title: 'Provider', value: 'IRCTC')],
      );
    }

    // Extract train information
    final trainNumberMatch = RegExp(
      r'Train No\.\s*:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(text);

    final trainNameMatch = RegExp(
      r'Train Name\s*:\s*([A-Za-z0-9\s\-]+)',
      caseSensitive: false,
    ).firstMatch(text);

    // Extract passenger name
    final passengerNameMatch = RegExp(
      r"Passenger Name\s*:\s*([A-Za-z\s.\-']+)",
      caseSensitive: false,
    ).firstMatch(text);

    // Extract journey date
    final dateMatch = RegExp(
      r'Date of Journey\s*:\s*(\d{2}\/\d{2}\/\d{4})',
      caseSensitive: false,
    ).firstMatch(text);

    DateTime? journeyDate;
    if (dateMatch != null) {
      try {
        final dateStr = dateMatch.group(1)!;
        journeyDate = DateTime.parse(
          '${dateStr.substring(6, 10)}-${dateStr.substring(3, 5)}'
          '-${dateStr.substring(0, 2)}',
        );
      } on FormatException catch (e) {
        _logger.debug(
          '[IRCTCTrainParser] Date parsing failed: ${dateMatch.group(1)} - $e',
        );
        journeyDate = null;
      }
    }

    // Extract from/to stations
    final fromMatch = RegExp(
      r'Boarding Point\s*:\s*([A-Za-z\s]+)',
      caseSensitive: false,
    ).firstMatch(text);

    final toMatch = RegExp(
      r'Reservation Upto\s*:\s*([A-Za-z\s]+)',
      caseSensitive: false,
    ).firstMatch(text);

    final primaryText =
        trainNameMatch?.group(1)?.trim() ?? 'IRCTC Train Ticket';
    final fromStation = fromMatch?.group(1)?.trim() ?? '';
    final toStation = toMatch?.group(1)?.trim() ?? '';
    final secondaryText = '$fromStation to $toStation';

    final extras = <ExtrasModel>[
      ExtrasModel(title: 'PNR Number', value: pnrNumber),
      if (trainNumberMatch != null)
        ExtrasModel(title: 'Train Number', value: trainNumberMatch.group(1)!),
      if (passengerNameMatch != null)
        ExtrasModel(
          title: 'Passenger Name',
          value: passengerNameMatch.group(1)!.trim(),
        ),
      if (journeyDate != null)
        ExtrasModel(
          title: 'Journey Date',
          value: journeyDate.toString().split(' ')[0],
        ),
      ExtrasModel(title: 'Provider', value: 'IRCTC'),
    ];

    // Use sentinel value if parsing fails, with warning log
    final startTime = journeyDate ?? invalidDateSentinel;
    if (journeyDate == null) {
      // Log warning when parsing fails so consumers can detect and handle
      // invalid/missing journey times. The sentinel value (epoch 1970-01-01)
      // is used as a fallback. Note: This parser is typically used only when
      // QR parsing fails, so missing dates should be rare.
      // Consumers should check for this sentinel value to detect invalid times.
      _logger.warning(
        '[IRCTCTrainParser] Journey date parsing failed for PNR: $pnrNumber. '
        'Using sentinel value ${invalidDateSentinel.toIso8601String()}',
      );
    }

    return Ticket(
      ticketId: pnrNumber,
      primaryText: primaryText,
      secondaryText: secondaryText.trim(),
      startTime: startTime,
      location: fromMatch?.group(1)?.trim() ?? 'Unknown',
      extras: extras,
    );
  }

  @override
  TicketUpdateInfo? parseUpdate(String text) => null;
}

class SETCBusParser implements TravelTicketParser {
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
    final hasTNSTC = text.toUpperCase().contains('TNSTC');

    return hasSETC && !hasTNSTC;
  }

  @override
  Ticket parseTicket(String text) {
    // SETC tickets use the same format as TNSTC SMS
    // Just delegate to the existing TNSTC SMS parser
    final smsParser = TNSTCSMSParser();
    final ticket = smsParser.parseTicket(text);

    // Update the provider name to SETC
    return ticket.copyWith(
      extras: [
        ...?ticket.extras?.where((e) => e.title != 'Provider'),
        ExtrasModel(title: 'Provider', value: 'SETC'),
      ],
    );
  }

  @override
  TicketUpdateInfo? parseUpdate(String text) => null;
}

class TravelParserService implements ITravelParser {
  TravelParserService({required ILogger logger})
    : _logger = logger,
      _parsers = [
        SETCBusParser(),
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

          _logger.info(
            '[TravelParserService] Successfully parsed ticket with '
            '${parser.providerName}',
          );

          if (sourceType != null) {
            // Check if Source Type already exists
            final hasSourceType =
                ticket.extras?.any(
                  (e) => e.title == 'Source Type',
                ) ??
                false;

            if (!hasSourceType) {
              return ticket.copyWith(
                extras: [
                  ...?ticket.extras,
                  ExtrasModel(title: 'Source Type', value: sourceType.name),
                ],
              );
            }
          }
          return ticket;
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

  bool isTicketText(String text) {
    return _parsers.any((parser) => parser.canParse(text));
  }
}
