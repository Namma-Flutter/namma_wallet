import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_service.dart';

/// Mock TravelParserService for testing purposes
class MockTravelParserService extends TravelParserService {
  MockTravelParserService({
    required super.logger,
    required super.stationPdfParser,
    this.mockUpdateInfo,
    this.mockTicket,
    DateTime? mockStartTime,
  }) : _mockStartTime = mockStartTime ?? DateTime(2024, 12, 15);

  /// Update info to return from parseUpdateSMS
  final TicketUpdateInfo? mockUpdateInfo;

  /// Ticket to return from parseTicketFromText
  final Ticket? mockTicket;

  final DateTime _mockStartTime;

  @override
  TicketUpdateInfo? parseUpdateSMS(String content) {
    return mockUpdateInfo;
  }

  @override
  Ticket? parseTicketFromText(
    String text, {
    SourceType? sourceType,
  }) {
    // If a mock ticket is provided, return it
    if (mockTicket != null) {
      return mockTicket;
    }

    // Only parse if content contains expected patterns
    if (!_looksLikeTicket(text)) {
      return null;
    }

    // Extract PNR from text if available for basic test cases
    final pnrMatch = RegExp(
      r'PNR\s*(?:NO\.?|Number)\s*:\s*([A-Z0-9]{8,})',
      caseSensitive: false,
    ).firstMatch(text);

    if (pnrMatch != null) {
      final pnr = pnrMatch.group(1)!;
      final fromLocation = _extractLocation(text, 'From', 'CHENNAI');
      final toLocation = _extractLocation(text, 'To', 'BANGALORE');

      // Return a mock ticket with the extracted PNR
      return Ticket(
        ticketId: pnr,
        primaryText: '$fromLocation → $toLocation',
        secondaryText: 'SETC - Bus',
        startTime: _mockStartTime,
        location: fromLocation,
        type: TicketType.bus,
        extras: [
          ExtrasModel(title: 'PNR Number', value: pnr),
          ExtrasModel(title: 'From', value: fromLocation),
          ExtrasModel(title: 'To', value: toLocation),
          ExtrasModel(title: 'Fare', value: '500.00'),
          ExtrasModel(title: 'Date', value: '15/12/2024'),
        ],
      );
    }

    // Return null for unparseable content
    return null;
  }

  /// Check if text looks like a valid ticket
  bool _looksLikeTicket(String text) {
    // Must contain PNR pattern
    final hasPnr = RegExp(
      r'PNR\s*(?:NO\.?|Number)\s*:',
      caseSensitive: false,
    ).hasMatch(text);

    // Must contain either FROM/TO or SETC/TNSTC pattern
    final hasFromTo = RegExp(
      r'(?:From\s*:\s*[A-Z]+|To\s+[A-Z]+)',
      caseSensitive: false,
    ).hasMatch(text);

    final hasProvider = RegExp(
      '(?:SETC|TNSTC|Corporation)',
      caseSensitive: false,
    ).hasMatch(text);

    // Empty or very short content should not parse
    if (text.trim().isEmpty || text.length < 10) {
      return false;
    }

    return hasPnr && (hasFromTo || hasProvider);
  }

  /// Extract location from text using patterns
  String _extractLocation(String text, String keyword, String defaultValue) {
    // Escape keyword to avoid regex meta-characters
    final escapedKeyword = RegExp.escape(keyword);
    final patterns = [
      RegExp('$escapedKeyword\\s*:\\s*([A-Z\\s]+)', caseSensitive: false),
      RegExp(
        '$escapedKeyword\\s+([A-Z\\s]+?)(?:\\s+To|\\s*\$)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }

    return defaultValue;
  }
}
