import 'dart:convert';

import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/enums/source_type.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_pdf_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

abstract class TravelTicketParser {
  bool canParse(String text);

  Ticket parseTicket(String text);

  String get providerName;

  TicketType get ticketType;
}

class TNSTCBusParser implements TravelTicketParser {
  @override
  String get providerName => 'TNSTC';

  @override
  TicketType get ticketType => TicketType.bus;

  @override
  bool canParse(String text) {
    final patterns = [
      'TNSTC',
      'Tamil Nadu',
      'Corporation',
      'PNR NO.',
      'PNR Number',
      'Trip Code',
      'Service Start Place',
      'Date of Journey',
      'SETC',
    ];
    return patterns.any(
      (pattern) => text.toLowerCase().contains(pattern.toLowerCase()),
    );
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
    // If has SETC and no PDF patterns, it's SMS
    // (SETC can appear in both formats)
    return (hasSmsPattern && !hasPdfPattern) ||
        (text.toUpperCase().contains('SETC') && !hasPdfPattern);
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
      final pdfParser = TNSTCPDFParser();
      return pdfParser.parseTicket(text);
    }
  }
}

class IRCTCTrainParser implements TravelTicketParser {
  @override
  String get providerName => 'IRCTC';

  @override
  TicketType get ticketType => TicketType.train;

  @override
  bool canParse(String text) {
    final patterns = [
      r'\bIRCTC\b',
      r'PNR[:\-\s]*\d{10}',
      r'\bTrn[:\-\s]*\d{4,5}',
      r'\bTrain[:\-\s]*\d{4,5}',
      r'\bDOJ[:\-\s]*\d{1,2}[-/]\d{1,2}',
      r'\bDt[:\-\s]*\d{1,2}[-/]\d{1,2}',
      'Chart Prepared',
    ];

    return patterns.any(
      (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text),
    );
  }

  bool _isSMSFormat(String text) {
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

    // Does it look like SMS?
    final hasSmsPattern = smsPatterns.any(
      (p) => RegExp(p, caseSensitive: false).hasMatch(text),
    );

    // Does it look like PDF text?
    final hasPdfPattern = pdfPatterns.any(
      (p) => lower.contains(p.toLowerCase()),
    );

    // Decision logic
    return hasSmsPattern && !hasPdfPattern;
  }

  @override
  Ticket parseTicket(String text) {
    final isSMS = _isSMSFormat(text);

    if (isSMS) {
      final irctcSmsParser = IRCTCSMSParser();
      return irctcSmsParser.parseTicket(text);
    } else {
      final irctcPdfParser = IRCTCPDFParser();
      return irctcPdfParser.parseTicket(text);
    }
  }
}

class SETCBusParser implements TravelTicketParser {
  late final ILogger _logger = getIt<ILogger>();

  @override
  String get providerName => 'SETC';

  @override
  TicketType get ticketType => TicketType.bus;

  @override
  bool canParse(String text) {
    final patterns = [
      'SETC',
      'State Express',
      'Booking ID',
      'Bus No',
    ];
    return patterns.any(
      (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(text),
    );
  }

  @override
  Ticket parseTicket(String text) {
    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    final bookingId = extractMatch(r'Booking ID\s*[:-]\s*([A-Z0-9]+)', text);
    final busNumber = extractMatch(r'Bus No\s*[:-]\s*([A-Z0-9\s]+)', text);
    final from = extractMatch(r'From\s*[:-]\s*([^-\n]+)', text);
    final to = extractMatch(r'To\s*[:-]\s*([^-\n]+)', text);
    final dateTime = extractMatch(r'Date\s*[:-]\s*([^-\n]+)', text);
    final seat = extractMatch(r'Seat\s*[:-]\s*([A-Z0-9,\s]+)', text);

    // 🕒 Try parsing date if available
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(dateTime);
    } on Exception catch (_) {
      _logger.warning(
        '[IRCTCTrainParser] Failed to parse date: "$dateTime", '
        'using current date as fallback',
      );
      parsedDate = null; // fallback
    }

    return Ticket(
      ticketId: bookingId,
      primaryText:
          '${from.isNotEmpty ? from : 'Unknown'} → '
          '${to.isNotEmpty ? to : 'Unknown'}',
      secondaryText:
          '${busNumber.isNotEmpty ? busNumber : 'SETC Bus'} • '
          '${seat.isNotEmpty ? seat : 'Seat N/A'}',
      type: TicketType.bus,
      startTime: parsedDate ?? DateTime.now(),
      location: from.isNotEmpty ? from : 'Unknown',
      tags: [
        if (bookingId.isNotEmpty)
          TagModel(value: bookingId, icon: 'confirmation_number'),
        if (busNumber.isNotEmpty)
          TagModel(value: busNumber, icon: 'directions_bus'),
        if (seat.isNotEmpty) TagModel(value: seat, icon: 'event_seat'),
        if (dateTime.isNotEmpty) TagModel(value: dateTime, icon: 'today'),
      ],
      extras: [
        ExtrasModel(title: 'Provider', value: 'SETC'),
        if (bookingId.isNotEmpty)
          ExtrasModel(title: 'Booking ID', value: bookingId),
        if (busNumber.isNotEmpty)
          ExtrasModel(title: 'Bus Number', value: busNumber),
        if (from.isNotEmpty) ExtrasModel(title: 'From', value: from),
        if (to.isNotEmpty) ExtrasModel(title: 'To', value: to),
        if (seat.isNotEmpty) ExtrasModel(title: 'Seat', value: seat),
        if (dateTime.isNotEmpty)
          ExtrasModel(title: 'Journey Date', value: dateTime),
        ExtrasModel(title: 'Source Type', value: 'SMS'),
      ],
    );
  }
}

class TicketUpdateInfo {
  TicketUpdateInfo({
    required this.pnrNumber,
    required this.providerName,
    required this.updates,
  });

  final String pnrNumber;
  final String providerName;
  final Map<String, Object?> updates;
}

class TravelParserService {
  TravelParserService({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;
  final List<TravelTicketParser> _parsers = [
    TNSTCBusParser(),
    IRCTCTrainParser(),
    SETCBusParser(),
  ];

  /// Create a sanitized summary of ticket for safe logging (no PII)
  Map<String, dynamic> _createTicketSummary(Ticket ticket) {
    return {
      'ticketType': ticket.type.name,
      'ticketId': ticket.ticketId,
      'primaryText': ticket.primaryText,
      'secondaryText': ticket.secondaryText,
      'hasStartTime': ticket.startTime,
      'hasEndTime': ticket.endTime != null,
      'hasLocation': ticket.location.isNotEmpty,
      'hasTags': ticket.tags != null && ticket.tags!.isNotEmpty,
      'hasExtras': ticket.extras != null && ticket.extras!.isNotEmpty,
      'tagCount': ticket.tags?.length ?? 0,
      'extraCount': ticket.extras?.length ?? 0,
      'startTime': ticket.startTime.toIso8601String(),
      'endTime': ticket.endTime?.toIso8601String(),
    };
  }

  /// Mask PNR to show only last 3 characters for safe logging
  /// Returns '***' for null, empty, or short PNRs (≤3 chars)
  String _maskPnr(String? pnr) {
    if (pnr == null || pnr.isEmpty || pnr.length <= 3) {
      return '***';
    }
    return '${'*' * (pnr.length - 3)}${pnr.substring(pnr.length - 3)}';
  }

  /// Mask phone number to show only last 3 digits
  String _maskPhoneNumber(String phone) {
    if (phone.length <= 3) return '***';
    return '${'*' * (phone.length - 3)}${phone.substring(phone.length - 3)}';
  }

  /// Create sanitized updates map for safe logging
  // ignore: unused_element
  Map<String, Object?> _sanitizeUpdates(Map<String, Object?> updates) {
    // Explicit allowlist of fields that can be safely logged
    const allowedFields = <String>{
      'contact_mobile',
      'trip_code',
      'vehicle_number',
      'status',
      'boarding_point',
      'coach_number',
      'seat_number',
    };

    final sanitized = <String, Object?>{};

    for (final entry in updates.entries) {
      final key = entry.key;
      final value = entry.value;

      // Only include keys that are in the allowlist
      if (allowedFields.contains(key)) {
        if (key == 'contact_mobile' && value is String) {
          // Mask phone numbers
          sanitized[key] = _maskPhoneNumber(value);
        } else {
          // Pass through other allowed values
          sanitized[key] = value;
        }
      }
      // Unknown fields are omitted (not logged)
    }

    return sanitized;
  }

  /// Detects if this is an update SMS (e.g., conductor details for TNSTC)
  // TODO(Keerthivasan-ai & harishwarriror): need to add IRCTC update logic.
  TicketUpdateInfo? parseUpdateSMS(String text) {
    // Match TNSTC update pattern
    if (text.toUpperCase().contains('TNSTC') &&
        (text.toLowerCase().contains('conductor mobile no') ||
            text.toLowerCase().contains('vehicle no'))) {
      // Extract PNR
      final pnrMatch = RegExp(
        r'PNR\s*:\s*([^,\s]+)',
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
      updates['updated_at'] = DateTime.now().toIso8601String();

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

          // Log sanitized summary (no PII)
          final ticketSummary = _createTicketSummary(ticket);
          _logger
            ..debug(
              '[TravelParserService] Parsed ticket summary: $ticketSummary',
            )
            ..info(
              '[TravelParserService] Successfully parsed ticket with '
              '${parser.providerName}',
            );

          // TODO(keerthivasan-ai): need to clarify this with harishwarrior
          // if (sourceType != null) {
          //   return ticket.copyWith(sourceType: sourceType);
          // }
          return ticket;
        }
      }

      _logger.warning(
        '[TravelParserService] No parser could handle the text',
      );
      return null;
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[TravelParserService] Error during ticket parsing',
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
