import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

class IRCTCPDFParser implements ITicketParser {
  IRCTCPDFParser({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  /// Parses IRCTC ticket text and extracts ticket details into a Ticket model.
  @override
  Ticket parseTicket(String rawText) {
    /// Allowed IRCTC travel class codes.
    const allowedClasses = {
      'SL',
      '1A',
      '2A',
      '3A',
      'CC',
      '2S',
      '3E',
      'FC',
      'EC',
      '1E',
      '2E',
    };

    /// Codes to be ignored when detecting station names from the text.
    const ignoredCodes = {
      'ERS',
      'NCH',
      'VRM',
      'GST',
      'TDR',
      'RFD',
      'CNF',
      'RAC',
      'WL',
      'GN',
      'PQWL',
      'RLWL',
      'RSWL',
      'LB',
      'UB',
      'MB',
      'SL',
      'SU',
      'PDF',
      'APP',
      'UPI',
      'OTP',
      'CVV',
      'PIN',
      'IRCTC',
      'GGM',
      'IT',
      'SURE',
      'MSG',
      'SMS',
      'IN',
      'AC',
      'NA',
      'SF',
      'SIDE',
      'ROAD',
      'PREMIUM',
      'TATKAL',
      'TQ',
      'PT',
      'CC',
    };

    List<PassengerInfo> extractAllPassengers(String text) {
      final passengers = <PassengerInfo>[];

      // This regex looks for rows starting with a number followed by name,
      // age, and gender
      // It accounts for both single-line and multi-line (Confirmtkt/IRCTC) formats
      final passengerRegex = RegExp(
        r'(\d+)\.?\s+([A-Za-z\s\.]{3,})\s+(\d{1,3})\s+([MF]|MALE|FEMALE)',
        caseSensitive: false,
        multiLine: true,
      );

      final matches = passengerRegex.allMatches(text).toList();

      for (var i = 0; i < matches.length; i++) {
        final name = matches[i].group(2)!.trim().replaceAll('\n', ' ');
        final age = int.tryParse(matches[i].group(3)!) ?? 0;
        final genderRaw = matches[i].group(4)!.toUpperCase();
        final gender = genderRaw.startsWith('M') ? 'M' : 'F';
        final type = age > 12 ? 'Adult' : 'Child';

        // Capture Seat/Status info by looking at the text block after the passenger row
        // but before the next passenger row starts.
        var seatNumber = 'N/A';
        final startSearch = matches[i].end;
        final endSearch = (i + 1 < matches.length)
            ? matches[i + 1].start
            : (startSearch + 200).clamp(0, text.length);

        final statusBlock = text.substring(startSearch, endSearch);

        // Look for confirmed seat patterns (e.g., S8/56)
        // or Waitlist codes (e.g., RLWL18)
        final statusMatch = RegExp(
          r'([A-Z0-9]{1,3}/\d{1,3}(?:/[A-Z\s]+)?)|((?:RLWL|PQWL|RSWL|WL)\s*\d+/?\d*)',
          caseSensitive: false,
        ).firstMatch(statusBlock);

        if (statusMatch != null) {
          seatNumber = statusMatch.group(0)!.trim().replaceAll('\n', ' ');
        } else if (statusBlock.contains('CAN')) {
          seatNumber = 'Cancelled'; // Specific to the second PDF
        }

        passengers.add(
          PassengerInfo(
            name: name,
            age: age,
            type: type,
            gender: gender,
            seatNumber: seatNumber,
          ),
        );
      }
      return passengers;
    }

    /// Commented for future reference
    // List<PassengerInfo> extractAllPassengers(String text) {
    //   final passengers = <PassengerInfo>[];
    //
    //   // 🔒 FIX: Use Passenger Details section if present
    //   final detailsIndex = text.toLowerCase().indexOf('passenger details');
    //   if (detailsIndex != -1) {
    //     text = text.substring(detailsIndex);
    //   }
    //
    //   final normalized = text
    //       .replaceAll('\r', '')
    //       .replaceAll(RegExp(r'[ \t]+'), ' ')
    //       .replaceAll(RegExp(r'\n{2,}'), '\n');
    //
    //   final passengerHeaderRegex = RegExp(
    //     r'^\s*(\d{1,2})\.\s+([A-Z][A-Z\s\.]{2,})\s*$',
    //     caseSensitive: false,
    //     multiLine: true,
    //   );
    //
    //   final matches = passengerHeaderRegex.allMatches(normalized).toList();
    //
    //   for (var i = 0; i < matches.length; i++) {
    //     final name = matches[i].group(2)!.trim();
    //     if (name.length < 3 || RegExp(r'\d').hasMatch(name)) continue;
    //
    //     final start = matches[i].end;
    //     final end = (i + 1 < matches.length)
    //         ? matches[i + 1].start
    //         : (start + 400).clamp(0, normalized.length);
    //
    //     final block = normalized.substring(start, end);
    //
    //     final ageMatch = RegExp(
    //       r'Age[:\s]*(\d{1,3})|\b(\d{1,3})\s*(?:Years)?',
    //       caseSensitive: false,
    //     ).firstMatch(block);
    //
    //     final age =
    //         int.tryParse(ageMatch?.group(1) ??
    //         ageMatch?.group(2) ?? '') ?? 0;
    //
    //     final genderMatch = RegExp(
    //       r'\b(MALE|FEMALE|M|F)\b',
    //       caseSensitive: false,
    //     ).firstMatch(block);
    //
    //     final genderRaw = genderMatch?.group(1)?.toUpperCase() ?? 'M';
    //     final gender = genderRaw.startsWith('M') ? 'M' : 'F';
    //
    //     final seatMatch = RegExp(
    //       r'(?:Current Status[:\s]*)?'
    //       r'((?:RLWL|WL|PQWL|RSWL|RAC)\s*/?\s*\d+|\b[A-Z]\d+/\d+(?:/[A-Z ]+)?)',
    //       caseSensitive: false,
    //     ).firstMatch(block);
    //
    //     final seat =
    //         seatMatch?.group(1)?.replaceAll(RegExp(r'\s+'), '').toUpperCase() ??
    //         'N/A';
    //
    //     passengers.add(
    //       PassengerInfo(
    //         name: name,
    //         age: age,
    //         type: age > 12 ? 'Adult' : 'Child',
    //         gender: gender,
    //         seatNumber: seat,
    //       ),
    //     );
    //   }
    //   return passengers;
    // }

    final allPassengers = extractAllPassengers(rawText);

    String? normalizeClass(String? raw) {
      if (raw == null || raw.isEmpty) return null;

      final upper = raw.toUpperCase().replaceAll(RegExp(r'["\n]'), '').trim();

      final parenMatch = RegExp(r'\(([A-Z0-9]{2,3})\)').firstMatch(upper);
      if (parenMatch != null) {
        return parenMatch.group(1);
      }

      // 2. Keyword Matching (Specific to Generic)
      if (upper.contains('AC 3') ||
          upper.contains('3RD AC') ||
          upper.contains('3A')) {
        return '3A';
      }
      if (upper.contains('AC 2') ||
          upper.contains('2ND AC') ||
          upper.contains('2A')) {
        return '2A';
      }
      if (upper.contains('AC 1') ||
          upper.contains('1ST AC') ||
          upper.contains('FIRST AC') ||
          upper.contains('1A')) {
        return '1A';
      }
      if (upper.contains('CHAIR') || upper.contains('CC')) return 'CC';
      if (upper.contains('SLEEPER') || upper.contains('SL')) return 'SL';
      if (upper.contains('2S') || upper.contains('SECOND')) return '2S';
      if (upper.contains('EXECUTIVE')) return 'EC';

      if (upper.length <= 3) return upper;

      return null;
    }

    /// Normalizes raw class text to a valid IRCTC class code.
    String? extractClass(String text) {
      final m1 = RegExp(
        r'Class\s*[:\-]\s*([A-Za-z0-9 ()/]+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (m1 != null) return normalizeClass(m1.group(1));

      final m2 = RegExp(
        r'Class\s*\n[^\n]*\n.*?\s([A-Za-z ]*\([A-Z0-9]{2,3}\))',
        caseSensitive: false,
      ).firstMatch(text);
      if (m2 != null) return normalizeClass(m2.group(1));

      final fallback = RegExp(r'\(([A-Z0-9]{2,3})\)').allMatches(text);
      for (final match in fallback) {
        final code = match.group(1)!;
        if (allowedClasses.contains(code)) return code;
      }

      return null;
    }

    /// Converts month abbreviation to integer representation.
    int? monthToInt(String month) {
      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      if (month.isEmpty) return null;
      final key = month.substring(0, 3);
      final normalized = key[0].toUpperCase() + key.substring(1).toLowerCase();
      return months[normalized];
    }

    /// Returns the first matching regex group for the given list of patterns.
    String pick(
      List<String> patterns, {
      int group = 1,
      bool caseSensitive = false,
    }) {
      for (final pattern in patterns) {
        final m = RegExp(
          pattern,
          caseSensitive: caseSensitive,
          multiLine: true,
        ).firstMatch(rawText);
        if (m != null && m.group(group) != null) {
          return m.group(group)!.trim().replaceAll('"', '');
        }
      }
      return '';
    }

    /// Extracts a numeric double value from the matched pattern.
    double pickDouble(List<String> patterns) {
      final v = pick(
        patterns,
      ).replaceAll(',', '').replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(v) ?? 0.0;
    }

    /// Extracts PNR number using multiple regex variations.
    final pnr = pick([
      r'PNR(?:[\s\S]{0,50}?)(\d{10})',
      r'PNR\s*[:.-]?\s*(\d{10})',
    ]);

    /// Extracted origin station name.
    var fromStn = '';

    /// Extracted destination station name.
    var toStn = '';

    /// Extracted boarding station name.
    var boardingStn = '';

    /// Regex to capture station name and code pairs.
    final stationRegex = RegExp(
      r'([A-Za-z &.]{2,})\s*(?:\(\s*([A-Z]{2,4})\s*\)|-\s*([A-Z]{2,4}))',
      multiLine: true,
    );

    /// All detected station matches.
    final stationMatches = stationRegex.allMatches(rawText);
    final foundStations = <String>[];

    /// Iterates through detected stations, filtering invalid or noisy entries.
    for (final m in stationMatches) {
      final rawName = m.group(1)!;
      final code = m.group(2) ?? m.group(3);

      if (code == null) continue;
      if (ignoredCodes.contains(code)) continue;

      final name = rawName.replaceAll('\n', ' ').trim();

      if (name.length <= 4 || name.toUpperCase() == code) continue;
      foundStations.add('$name ($code)');
    }

    /// Assigns from, to, and boarding stations based on parsed list.
    /// Assigns from, boarding, and to stations safely
    if (foundStations.isNotEmpty) {
      if (foundStations.length == 1) {
        fromStn = foundStations.first;
        boardingStn = foundStations.first;
        toStn = '';
      } else if (foundStations.length == 2) {
        fromStn = foundStations[0];
        boardingStn = foundStations[0];
        toStn = foundStations[1];
      } else {
        fromStn = foundStations.first;
        boardingStn = foundStations[1]; // IMPORTANT
        toStn = foundStations.last;
      }
    }

    /// Fallback regex for "From"
    if (fromStn.isEmpty) {
      fromStn = pick([
        r'From\s*[:]?\s*([A-Z ]+\([A-Z]+\))',
      ], caseSensitive: true);
    }

    /// Fallback regex for "To"
    if (toStn.isEmpty) {
      toStn = pick([r'To\s*[:]?\s*([A-Z ]+\([A-Z]+\))'], caseSensitive: true);
    }

    /// Matches boarding station code.
    final explicitBoarding = pick([r'Boarding At\s*[:]?\s*([A-Z]{3,4})']);

    /// Assign explicit boarding station if found.
    if (explicitBoarding.isNotEmpty) {
      final match = foundStations.firstWhere(
        (s) => s.contains('($explicitBoarding)'),
        orElse: () => explicitBoarding,
      );
      boardingStn = match;
    } else {
      final fullBoarding = pick([
        r'Boarding At\s*[:]?\s*([A-Z ]+\([A-Z]+\))',
      ], caseSensitive: true);
      if (fullBoarding.isNotEmpty) boardingStn = fullBoarding;
    }

    /// Extracts train number.
    final trainNumber = pick([
      r'Train No\./\s*Name\s+(?:[:.-])?\s*(\d{5})(?!\d)',
      r'(?:Train No|Train Name|Train)\s*[:.-]?\s*\b(\d{5})\b',
      r'(?:Train No|Train Name|Train)[\s\S]{0,30}?\b(\d{5})\b',
    ]);

    /// Extracts train name.
    final trainName = pick([
      r'Train No\./\s*Name\s+(?:[:.-])?\s*\d{5}\s*/\s*(.*)',
      r'(?:Train No|Train Name|Train)[\s\S]{0,30}?\d{5}\s*/\s*(.*)',
    ]);

    /// Raw travel class as printed on ticket.
    final travelClass = extractClass(rawText);

    /// Quota extracted from ticket text.
    final quota = pick([r'Quota(?:[\s\S]{0,20}?)([A-Za-z ]+\([A-Z]+\))']);

    /// Raw date-time text extracted from ticket text.
    final dateTimeRaw = pick([
      r'Scheduled Departure[\s\S]{0,10}?[:"]+\s*(\d{2}-[A-Za-z]{3}-\d{4}\s+\d{2}:\d{2})',
      r'Departure[\s\S]{0,10}?\s*(\d{1,2}:\d{2}[\s\S]{0,25}?\d{4})',
      r'Departure[\s\S]{0,10}?\s*(\d{2}-[A-Za-z]{3}-\d{4}[\s\S]{0,25}?\d{1,2}:\d{2})',
    ]);

    /// Parses multiple date formats safely.
    DateTime? parseFlexibleDate(String raw) {
      if (raw.isEmpty) return null;
      try {
        final cleaned = raw.replaceAll(RegExp(r'[*"\n]'), ' ').trim();
        final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(cleaned);
        final dateMatch = RegExp(
          r'(\d{2}-[A-Za-z]{3}-\d{4})',
          caseSensitive: false,
        ).firstMatch(cleaned);

        if (timeMatch != null && dateMatch != null) {
          final timeParts = timeMatch.group(1)!.split(':');
          final dateParts = dateMatch.group(1)!.split('-');
          final month = monthToInt(dateParts[1]);
          if (month == null) {
            return null;
          } else {
            return DateTime(
              int.parse(dateParts[2]),
              month,
              int.parse(dateParts[0]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
          }
        }
      } on Exception catch (e, stackTree) {
        _logger.error(
          '[IRCTCPDFParser] Failed to parse date: $e',
          e,
          stackTree,
        );
      }
      return null;
    }

    /// Final parsed scheduled departure DateTime.
    final scheduledDeparture = parseFlexibleDate(dateTimeRaw);

    /// Extracts journey date (removes time).
    final dateOfJourney = scheduledDeparture != null
        ? DateTime(
            scheduledDeparture.year,
            scheduledDeparture.month,
            scheduledDeparture.day,
          )
        : null;

    /// Passenger booking status (CNF, RAC, WL).
    var pStatus = '';

    /// Matches standard passenger listing format.
    final stdPassengerRegex = RegExp(
      r'(?:^|\n)\s*1[.]?\s+([A-Za-z .]+)\s+(\d{1,3})\s+(Male|Female|MALE|FEMALE|M|F)',
      caseSensitive: false,
      multiLine: true,
    );

    /// Matches alternative email-format passenger listing.
    final emailPassengerRegex = RegExp(
      r'([A-Za-z .]+)\s*\n\s*1\s*\n\s*(\d{1,3})\s*\n\s*(Male|Female|M|F)',
      caseSensitive: false,
      multiLine: true,
    );

    /// Extract passenger details.
    var pMatch = stdPassengerRegex.firstMatch(rawText);
    pMatch ??= emailPassengerRegex.firstMatch(rawText);

    if (pMatch != null) {
      // pName = pMatch.group(1)!.trim();
      // pAge = int.tryParse(pMatch.group(2) ?? '0') ?? 0;
      // pGender = pMatch.group(3)!.trim();

      /// Look ahead for passenger status code.
      final lookAhead = rawText.substring(
        pMatch.end,
        (pMatch.end + 200).clamp(0, rawText.length),
      );

      final statusMatch = RegExp(
        '((?:CNF|WL|RAC|RLWL|PQWL|RSWL)[A-Z0-9/ ]*)',
      ).firstMatch(lookAhead);

      if (statusMatch != null) {
        pStatus = statusMatch.group(1)?.trim() ?? '';
      } else if (lookAhead.contains('CNF')) {
        pStatus = 'CNF';
      }
    }

    /// Extracts ticket fare amount from various formats.
    final ticketFare = pickDouble([
      r'Ticket Fare\s*[:]\s*([\d,]+(?:\.\d+)?)',
      r'Ticket [Ff]are(?:[\s\S]{0,50}?)Rs\.?\s*([\d,]+\.\d{2})',
      r'Ticket [Ff]are(?:[\s\S]{0,50}?)([\d,]+\.\d{2})',
      // r'Total [Ff]are(?:[\s\S]{0,50}?)([\d,]+\.\d{2})',
    ]);

    double? extractTotalFareFallback(String text) {
      final matches = RegExp(
        r'₹\s*([\d,]+\.\d{2})',
        multiLine: true,
      ).allMatches(text);

      if (matches.isEmpty) return null;

      final last = matches.last.group(1)!;
      return double.tryParse(last.replaceAll(',', ''));
    }

    final resolvedTicketFare = ticketFare > 0
        ? ticketFare
        : extractTotalFareFallback(rawText);

    /// Extracts IRCTC service fee or convenience fee.
    final irctcFee = pickDouble([
      r'Convenience Fee(?:[\s\S]{0,100}?)Rs\.?\s*[\d,]+\.\d{2}(?:[\s\S]{0,50}?)Rs\.?\s*([\d,]+\.\d{2})',
      r'Convenience Fee(?:[\s\S]{0,30}?)Rs\.?\s*([\d,]+\.?\d{0,2})',
      r'Convenience Fee(?:[\s\S]{0,30}?)([\d,]+\.?\d{0,2})',
      r'IRCTC Fee(?:[\s\S]{0,30}?)([\d,]+\.?\d{0,2})',
    ]);

    double? extractIrctcFeeFallback(String text) {
      final matches = RegExp(
        r'₹\s*([\d,]+\.\d{2})',
      ).allMatches(text).toList();

      if (matches.length < 2) return null;

      final value = matches[1].group(1)!;
      return double.tryParse(value.replaceAll(',', ''));
    }

    final resolvedIrctcFee = irctcFee > 0
        ? irctcFee
        : extractIrctcFeeFallback(rawText);

    /// Creates IRCTCTicket model using extracted values.
    final model = IRCTCTicket(
      pnrNumber: pnr,
      transactionId: pick([r'Transaction (?:ID|Id)[-:]?\s*\(?(\d+)']),
      passengers: allPassengers,
      // gender: pGender,
      // age: pAge,
      status: pStatus,
      quota: quota,
      trainNumber: trainNumber,
      trainName: trainName,
      scheduledDeparture: scheduledDeparture,
      dateOfJourney: dateOfJourney,
      boardingStation: boardingStn,
      travelClass: travelClass,
      fromStation: fromStn,
      toStation: toStn,
      ticketFare: resolvedTicketFare,
      irctcFee: resolvedIrctcFee,
    );

    /// Converts IRCTCTicket model to Ticket entity.
    return Ticket.fromIRCTC(model);
  }
}
