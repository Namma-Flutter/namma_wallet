import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/travel/application/travel_pdf_parser.dart';

class IRCTCLayoutParser extends TravelPDFParser {
  IRCTCLayoutParser({required super.logger});

  static const allowedClasses = {
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

  Ticket parseTicketFromBlocks(List<OCRBlock> blocks) {
    final extractor = LayoutExtractor(blocks);
    final plainText = extractor.toPlainText();

    logger.info('IRCTC: Parsing with plainText length: ${plainText.length}');
    if (plainText.length > 500) {
      logger.info('IRCTC: First 500 chars: ${plainText.substring(0, 500)}');
    } else {
      logger.info('IRCTC: Full text: $plainText');
    }

    // Use regex for IRCTC since layout extraction is unreliable
    //with pseudo-blocks
    // Match across multiple lines - use [\s\S]* to match anything
    final pnrRaw = _extractByRegex(plainText, [
      r'PNR[\s\S]*?(\d{6,12})',
    ], dotAll: true);
    final pnrNumber = pnrRaw?.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // Extract train number and name - find the pattern that looks like
    //"12634 / KANYAKUMARI EXP"
    // Use [\s\S] instead of actual newline to avoid string break
    final trainLineMatch = RegExp(
      r'Train No\.?\s*/?\s*Name[\s\S]{0,50}?(\d{5})\s*/\s*([^\n\r]+)',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(plainText);
    var trainNumber = trainLineMatch?.group(1);
    var trainName = trainLineMatch?.group(2);

    // If train number/name not found in first pattern, try alternative patterns
    if (trainNumber == null || trainName == null) {
      final trainNumberMatch = RegExp(
        r'(?:Train No|Train)\s*[:.-]?\s*(\d{5})',
        caseSensitive: false,
      ).firstMatch(plainText);
      trainNumber = trainNumberMatch?.group(1);

      final trainNameMatch = RegExp(
        r'Train Name[\s\S]{0,20}?([^\n\r]+)',
        caseSensitive: false,
      ).firstMatch(plainText);
      trainName = trainNameMatch?.group(1);
    }

    // Date format is "13-Apr-2025" - need to convert to parseDate format
    final journeyDateStr = _extractByRegex(plainText, [
      r'Start Date\*\s*(\d{1,2}-[A-Za-z]{3}-\d{4})',
      r'(\d{1,2}-[A-Za-z]{3}-\d{4})',
    ]);
    // Convert "13-Apr-2025" to "13/04/2025"
    final journeyDate = _parseIrctcDate(journeyDateStr);

    // Time format is "18:55 13-Apr-2025" - need to extract just the time
    final departureTimeStr = _extractByRegex(plainText, [
      r'Departure\*\s*(\d{1,2}:\d{2})',
    ]);
    // Convert "18:55 13-Apr-2025" to just time "18:55"
    final departureTime = parseDateTime(departureTimeStr?.split(' ').first);

    DateTime? scheduledDeparture;
    if (journeyDate != null && departureTime != null) {
      scheduledDeparture = DateTime.utc(
        journeyDate.year,
        journeyDate.month,
        journeyDate.day,
        departureTime.hour,
        departureTime.minute,
      );
    } else if (journeyDate != null && departureTimeStr != null) {
      final timeMatch = RegExp(
        r'(\d{1,2}):(\d{2})',
      ).firstMatch(departureTimeStr);
      if (timeMatch != null) {
        final hour = int.tryParse(timeMatch.group(1) ?? '');
        final minute = int.tryParse(timeMatch.group(2) ?? '');
        if (hour != null && minute != null) {
          scheduledDeparture = DateTime.utc(
            journeyDate.year,
            journeyDate.month,
            journeyDate.day,
            hour,
            minute,
          );
        }
      }
    }

    // "Booked From" or "Boarding From" is a column header, optionally
    // followed by "To" on the next line. Skip it before capturing the station.
    // Handles three station formats:
    //   (a) "STATION NAME (CODE)" — parenthesized code
    //   (b) "STATION NAME - CODE" — dash-separated code
    //   (c) "Station Name\n(CODE)" — name and code on separate lines
    final fromStationRaw = _extractByRegex(plainText, [
      r'(?:Booked|Boarding) From\n(?:To\n)?([A-Z][A-Za-z &.]+\([A-Z]{2,4}\))',
      r'(?:Booked|Boarding) From\n(?:To\n)?([A-Z][A-Za-z &.]+ - [A-Z]{2,4})',
      r'(?:Booked|Boarding) From\n(?:To\n)?([A-Z][A-Za-z &.]+)\n\([A-Z]{2,4}\)',
    ]);
    // For split-block format, append the code from the next line
    var fromStation = _formatStation(fromStationRaw);
    if (fromStation != null &&
        !RegExp(r'\([A-Z]{2,4}\)').hasMatch(fromStation) &&
        !fromStation.contains(' - ')) {
      final codeMatch = RegExp(
        r'(?:Booked|Boarding) From\n(?:To\n)?' +
            RegExp.escape(fromStationRaw ?? '') +
            r'\n(\([A-Z]{2,4}\))',
      ).firstMatch(plainText);
      if (codeMatch != null) {
        fromStation = '${fromStation.trim()} ${codeMatch.group(1)}';
      }
    }

    // The destination station appears immediately before "Start Date*" in the
    // plain text, which is more reliable than matching the "To" column header.
    // Handles three formats:
    //   (a) "STATION NAME (CODE)\nStart Date*"
    //   (b) "STATION NAME - CODE\n[optional line]\nStart Date*"
    //   (c) "Station Name (CODE)" — mixed case with parenthesized code
    final toStationRaw = _extractByRegex(plainText, [
      r'([A-Z][A-Za-z &.]+\([A-Z]{2,4}\))\nStart Date',
      r'([A-Z][A-Za-z &.]+ - [A-Z]{2,4})\n(?:[^\n]+\n)?Start Date',
      r'([A-Za-z][A-Za-z &.]+\([A-Z]{2,4}\))\nStart Date',
    ]);
    final toStation = _formatStation(toStationRaw);

    final boardingStationRaw = fromStationRaw;
    final boardingStation = _formatStation(boardingStationRaw);

    // Find the class from plainText
    final classMatch = RegExp(
      r'\((SL|1A|2A|3A|CC|2S|3E|FC|EC|1E|2E)\)',
    ).firstMatch(plainText);
    final travelClassRaw = classMatch?.group(1);
    final travelClass = normalizeClass(travelClassRaw);

    // Quota - from "PREMIUM TATKAL (PT)" pattern - get the last match
    // with PT or other quota codes
    // Also match just the quota name without parentheses
    final quotaRegex = RegExp(
      r'(PREMIUM TATKAL|TATKAL|GENERAL|PRAVIS|LOUIS|RAILWAY|PQ|CK|RL|RS|LB|OP)\s*\(?(PT|TQ|GN|PQ|CK|RL|RS|LB|OP)\)?',
      caseSensitive: false,
    );
    final quotaMatch = quotaRegex.firstMatch(plainText);
    final quota = quotaMatch?.group(0);

    // Distance
    final distanceStr = _extractByRegex(plainText, [
      r'(\d+)\s*KM',
    ]);
    final distance = int.tryParse(distanceStr ?? '');

    // Transaction ID
    final transactionIdMatch = RegExp(
      r'Transaction ID:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(plainText);
    final transactionId = transactionIdMatch?.group(1);

    // Arrival Time
    final arrivalMatch = RegExp(
      r'Arrival\*\s*(\d{1,2}:\d{2})',
      caseSensitive: false,
    ).firstMatch(plainText);
    arrivalMatch?.group(1);

    // Extract fare amounts from OCR blocks.
    // First try the ₹-prefixed format: "₹ 520.00"
    // Then fall back to label-based format: "Total Fare : 308.0"
    final allFares = RegExp(
      r'₹\s*([\d,]+\.\d{1,2})',
      caseSensitive: false,
    ).allMatches(plainText).toList();
    double? ticketFare;
    double? irctcFee;
    double? totalFare;

    double? parseFare(String raw) => double.tryParse(raw.replaceAll(',', ''));

    if (allFares.isNotEmpty) {
      ticketFare = parseFare(allFares[0].group(1)!);
      totalFare = parseFare(allFares.last.group(1)!);
    }

    // Extract IRCTC fee by label to avoid positional errors
    // (old approach assumed 2nd ₹ amount was IRCTC fee, but catering
    // charges ₹0.00 appear before IRCTC fee in some ticket formats).
    // Allow \n between label and ₹ amount since OCR may split them.
    final irctcFeeMatch = RegExp(
      r'(?:IRCTC Convenience Fee|Convenience Fee)[^₹]*?₹\s*([\d,]+\.\d{1,2})',
      caseSensitive: false,
    ).firstMatch(plainText);
    if (irctcFeeMatch != null) {
      irctcFee = parseFare(irctcFeeMatch.group(1)!);
    } else {
      // Try label-based format: "Convenience Fee : 17.7"
      final convFeeMatch = RegExp(
        r'Convenience Fee\s*:\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ).firstMatch(plainText);
      if (convFeeMatch != null) {
        irctcFee = parseFare(convFeeMatch.group(1)!);
      } else if (allFares.length > 1) {
        // Last resort: use positional (2nd amount)
        irctcFee = parseFare(allFares[1].group(1)!);
      }
    }

    // Try label-based fare extraction if ₹-prefixed fares not found
    if (ticketFare == null) {
      final labelFareMatch = RegExp(
        r'(?:Total Fare|Total Amount)\s*(?:\(.*?\))?\s*:\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ).firstMatch(plainText);
      if (labelFareMatch != null) {
        totalFare = parseFare(labelFareMatch.group(1)!);
        ticketFare = totalFare;
      }
    }

    final fare = totalFare ?? ticketFare;

    final passengers = _extractPassengers(extractor);
    final firstPassenger = passengers.isNotEmpty ? passengers.first : null;

    final model = IRCTCTicket(
      pnrNumber: pnrNumber ?? '',
      passengerName: firstPassenger?['name'] ?? '',
      age: int.tryParse(firstPassenger?['age'] ?? ''),
      status: firstPassenger?['status'] ?? '',
      trainNumber: trainNumber ?? '',
      trainName: trainName ?? '',
      scheduledDeparture: scheduledDeparture,
      dateOfJourney: journeyDate,
      boardingStation: boardingStation ?? '',
      travelClass: travelClass,
      fromStation: fromStation ?? '',
      toStation: toStation ?? '',
      ticketFare: fare ?? ticketFare,
      irctcFee: irctcFee,
      quota: quota,
      gender: firstPassenger?['gender'],
      transactionId: transactionId,
      distance: distance,
      seatNumber: firstPassenger?['seat'],
    );

    return Ticket.fromIRCTC(model);
  }

  String? _formatStation(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? normalizeClass(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final upper = raw.toUpperCase().replaceAll(RegExp(r'["\n]'), '').trim();

    final parenMatch = RegExp(r'\(([A-Z0-9]{2,3})\)').firstMatch(upper);
    if (parenMatch != null) {
      final code = parenMatch.group(1);
      if (allowedClasses.contains(code)) return code;
    }

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

    if (upper.length <= 3 && allowedClasses.contains(upper)) {
      return upper;
    }

    return null;
  }

  List<Map<String, String?>> _extractPassengers(LayoutExtractor extractor) {
    final passengers = <Map<String, String?>>[];

    final plainText = extractor.toPlainText();

    // Passenger names may contain spaces (e.g. "MURUGESAN M"), so use a lazy
    // match for the name group that stops at the first standalone age number.
    // Updated to allow optional catering service (like "NO FOOD") before status
    // Allow "1." or just "1" (without period) as the row number prefix,
    // since some newer IRCTC ticket formats omit the period.
    // Gender is matched as FEMALE→F, MALE→M (full words), or single M/F.
    final passengerPattern = RegExp(
      r'1\.?\s+([A-Z][A-Za-z .\n]*?)\s+(\d{1,3})\s+(FEMALE|MALE|[MF])\s+(?:(?:NO FOOD|VEG|NON VEG)\s+)?(CNF|WL|RAC|[A-Z]+)(?:\s*/([A-Z0-9]+))?(?:\s*/(\d+))?(?:\s*/([A-Z]+(?: [A-Z]+)?))?',
      caseSensitive: false,
    );

    final match = passengerPattern.firstMatch(plainText);
    if (match != null) {
      passengers.add({
        'name': match
            .group(1)
            ?.replaceAll('\n', ' ')
            .trim()
            .replaceAll(RegExp(r'\s+'), ' '),
        'age': match.group(2)?.trim(),
        'gender': _normalizeGender(match.group(3)),
        'status': match.group(4)?.trim(),
        'seat': _buildSeat(match),
      });
    }

    if (passengers.isEmpty) {
      final fallbackPattern = RegExp(
        r'1\.?\s+([A-Z][A-Za-z .\n]*?)\s+(\d{1,3})\s+(FEMALE|MALE|[MF])',
        caseSensitive: false,
      );
      final fallbackMatch = fallbackPattern.firstMatch(plainText);
      if (fallbackMatch != null) {
        passengers.add({
          'name': fallbackMatch
              .group(1)
              ?.replaceAll('\n', ' ')
              .trim()
              .replaceAll(RegExp(r'\s+'), ' '),
          'age': fallbackMatch.group(2)?.trim(),
          'gender': _normalizeGender(fallbackMatch.group(3)),
          'status': null,
        });
      }
    }

    return passengers;
  }

  /// Normalizes gender values: FEMALE→F, MALE→M, keeps M/F as-is.
  String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    final upper = raw.trim().toUpperCase();
    if (upper == 'FEMALE') return 'F';
    if (upper == 'MALE') return 'M';
    return upper;
  }

  String? _buildSeat(RegExpMatch match) {
    final parts = <String>[];
    for (var i = 4; i <= 7; i++) {
      final part = match.group(i);
      if (part != null && part.isNotEmpty) {
        // Exclude the status from the seat string if it is group 4
        if (i > 4) {
          parts.add(part);
        }
      }
    }
    return parts.isNotEmpty ? parts.join('/') : null;
  }

  String? nullIfEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  @override
  Ticket parseTicket(String pdfText) {
    final blocks = OCRBlock.fromPlainText(pdfText);
    final extractor = LayoutExtractor(blocks);
    final plainText = extractor.toPlainText();

    final pnr = _extractByRegex(plainText, [
      r'PNR\s*(?:No\.?)?\s*[:.-]?\s*(\d{6,12})',
      r'PNR\b[\s\S]{0,30}?\b([A-Z0-9]{6,12})\b',
    ]);

    final trainNumber = _extractByRegex(plainText, [
      r'Train No\.?\s*/?\s*Name\s+(?:[:.-])?\s*(\d{5})',
      r'(?:Train No|Train)\s*[:.-]?\s*(\d{5})',
      r'(\d{5})\s*/\s*[A-Za-z]',
    ]);

    final trainNameRaw = _extractByRegex(plainText, [
      r'Train No\.?\s*/?\s*Name\s+(?:[:.-])?\s*\d{5}\s*/\s*([^\n]+)',
      r'(?:Train No|Train Name|Train)[\s\S]{0,30}?\d{5}\s*/\s*(.*)',
      r'Train Name\s*[:.-]?\s*([^\n]+)',
      r'\d{5}\s*/\s*([A-Za-z]+)',
    ]);

    final journeyDate = _parseDateWithRegex(plainText);
    final departureTime = _parseTimeWithRegex(plainText);

    DateTime? scheduledDeparture;
    if (journeyDate != null && departureTime != null) {
      scheduledDeparture = DateTime.utc(
        journeyDate.year,
        journeyDate.month,
        journeyDate.day,
        departureTime.hour,
        departureTime.minute,
      );
    }

    final fromStation = _extractStation(plainText, 'from');
    final toStation = _extractStation(plainText, 'to');
    final boardingStation =
        _extractStation(plainText, 'boarding') ?? fromStation;

    final travelClassRaw = _extractByRegex(plainText, [
      r'Class\s*[:\-]\s*([A-Za-z0-9 ()/]+)',
      r'\((SL|1A|2A|3A|CC|2S|3E|FC|EC|1E|2E)\)',
      r'SLEEPER CLASS\s*\(([A-Z0-9]{2,3})\)',
    ]);
    final travelClass = normalizeClass(travelClassRaw);

    final quota = _extractByRegex(plainText, [
      r'Quota(?:[\s\S]{0,20}?)([A-Za-z ]+\([A-Z]+\))',
    ]);

    final distanceStr = _extractByRegex(plainText, [
      r'(\d+)\s*KM',
    ]);
    final distance = int.tryParse(distanceStr ?? '');

    // Extract all fare amounts
    final allFares = RegExp(
      r'₹\s*(\d+\.\d{2})',
      caseSensitive: false,
    ).allMatches(plainText).toList();
    double? ticketFare;
    double? irctcFee;
    double? totalFare;

    if (allFares.isNotEmpty) {
      // First fare: 520.00
      ticketFare = double.tryParse(allFares[0].group(1)!);
      // Second fare: 17.70 (IRCTC fee)
      if (allFares.length > 1) {
        irctcFee = double.tryParse(allFares[1].group(1)!);
      }
      // Last fare: 549.95 (total)
      final lastFareMatch = allFares.last;
      totalFare = double.tryParse(lastFareMatch.group(1)!);
    }

    final passengers = _extractPassengersFromText(plainText);
    final firstPassenger = passengers.isNotEmpty ? passengers.first : null;

    final model = IRCTCTicket(
      pnrNumber: pnr ?? '',
      passengerName: firstPassenger?['name'] ?? '',
      age: int.tryParse(firstPassenger?['age'] ?? ''),
      status: firstPassenger?['status'] ?? '',
      trainNumber: trainNumber ?? '',
      trainName: trainNameRaw ?? '',
      scheduledDeparture: scheduledDeparture,
      dateOfJourney: journeyDate,
      boardingStation: boardingStation ?? '',
      travelClass: travelClass,
      fromStation: fromStation ?? '',
      toStation: toStation ?? '',
      ticketFare: totalFare ?? ticketFare,
      irctcFee: irctcFee,
      quota: quota,
      gender: firstPassenger?['gender'],
      distance: distance,
      seatNumber: firstPassenger?['seat'],
    );

    return Ticket.fromIRCTC(model);
  }

  String? _extractByRegex(
    String text,
    List<String> patterns, {
    bool dotAll = false,
  }) {
    for (final pattern in patterns) {
      final match = RegExp(
        pattern,
        caseSensitive: false,
        multiLine: true,
        dotAll: dotAll,
      ).firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    return null;
  }

  DateTime? _parseIrctcDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    final months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12',
    };

    final match = RegExp(
      r'(\d{1,2})-([A-Za-z]{3})-(\d{4})',
    ).firstMatch(dateStr);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '');
      final monthStr = match.group(2) ?? '';
      final year = int.tryParse(match.group(3) ?? '');

      final month = months[monthStr];
      if (day != null && month != null && year != null) {
        return DateTime.utc(year, int.parse(month), day);
      }
    }
    return null;
  }

  DateTime? _parseDateWithRegex(String text) {
    // First try to get date from "Start Date*" pattern
    final startDatePattern = RegExp(
      r'Start Date\*\s*(\d{1,2}-[A-Za-z]{3}-\d{4})',
      caseSensitive: false,
    );
    final startDateMatch = startDatePattern.firstMatch(text);
    if (startDateMatch != null) {
      final dateStr = startDateMatch.group(1)!;
      final converted = _convertMonthNameToNumber(dateStr);
      final parsed = parseDate(converted);
      return parsed;
    }

    final dateTimePatterns = [
      r'Scheduled Departure[\s\S]{0,10}?[:"]+\s*(\d{2}-[A-Za-z]{3}-\d{4}\s+\d{2}:\d{2})',
      r'Departure[\s\S]{0,10}?\s*(\d{1,2}:\d{2}[\s\S]{0,25}?\d{4})',
      r'Departure[\s\S]{0,10}?\s*(\d{2}-[A-Za-z]{3}-\d{4}[\s\S]{0,25}?\d{1,2}:\d{2})',
      r'(Date of Journey\s*[:.-]?\s*\d{2}[-/]\d{2}[-/]\d{2,4}[\s\S]*?Scheduled Departure\s*[:.-]?\s*\d{1,2}[:.]\d{2})',
      r'(Date of Journey\s*[:.-]?\s*\d{2}[-/]\d{2}[-/]\d{2,4}[\s\S]*?Time\s*[:.-]?\s*\d{1,2}[:.]\d{2})',
    ];

    for (final pattern in dateTimePatterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) {
        final parsed = _parseFlexibleDate(match.group(1)!);
        if (parsed != null) return parsed;
      }
    }

    final datePatterns = [
      r'Date of Journey\s*[:.-]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})',
      r'DOJ\s*[:.-]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})',
      r'(\d{2}[-/][A-Za-z]{3}[-/]\d{2,4})',
    ];

    for (final pattern in datePatterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) {
        var dateStr = match.group(1)!.trim();
        dateStr = _convertMonthNameToNumber(dateStr);
        final parsed = parseDate(dateStr);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  DateTime? _parseTimeWithRegex(String text) {
    // First try to get time from "Departure*" pattern with time before date
    final depTimePattern = RegExp(
      r'Departure\*\s*(\d{1,2}:\d{2})',
      caseSensitive: false,
    );
    final depMatch = depTimePattern.firstMatch(text);
    if (depMatch != null) {
      final timeStr = depMatch.group(1)!.trim();
      // Parse time manually since parseDateTime expects date+time
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return DateTime.utc(1970, 1, 1, hour, minute);
        }
      }
    }

    final patterns = [
      r'Scheduled Departure[\s\S]{0,10}?[:"]+\s*(\d{2}:\d{2})',
      r'Departure[\s\S]{0,10}?\s*(\d{1,2}:\d{2})',
      r'Dep Time\s*[:.-]?\s*(\d{1,2}:\d{2})',
    ];

    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) {
        final timeStr = match.group(1)!.trim();
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            return DateTime.utc(1970, 1, 1, hour, minute);
          }
        }
      }
    }
    return null;
  }

  DateTime? _parseFlexibleDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      final cleaned = raw.replaceAll(RegExp(r'[*"\n]'), ' ').trim();
      final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(cleaned);
      final dateMatch = RegExp(
        r'(\d{2}[-/][A-Za-z0-9]{2,3}[-/]\d{2,4})',
        caseSensitive: false,
      ).firstMatch(cleaned);

      if (timeMatch != null && dateMatch != null) {
        final timeParts = timeMatch.group(1)!.split(':');
        var dateStr = dateMatch.group(1)!;
        dateStr = _convertMonthNameToNumber(dateStr);
        final dateParts = dateStr.split(RegExp('[-/]'));

        var year = int.tryParse(dateParts[2]);
        if (year != null && year < 100) year += 2000;

        final monthStr = dateParts[1];
        var month = int.tryParse(monthStr);
        month ??= _monthToInt(monthStr);

        if (month == null || year == null) {
          return null;
        }

        final day = int.tryParse(dateParts[0]);
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);

        if (day == null || hour == null || minute == null) {
          return null;
        }

        return DateTime.utc(year, month, day, hour, minute);
      }
    } on Object catch (e, s) {
      logger.error('[IRCTC] Failed to parse flexible date', e, s);
    }
    return null;
  }

  int? _monthToInt(String month) {
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

  String _convertMonthNameToNumber(String dateStr) {
    const months = {
      'jan': '01',
      'feb': '02',
      'mar': '03',
      'apr': '04',
      'may': '05',
      'jun': '06',
      'jul': '07',
      'aug': '08',
      'sep': '09',
      'oct': '10',
      'nov': '11',
      'dec': '12',
    };

    final regex = RegExp(
      r'(\d{1,2})[-/]([A-Za-z]{3})[-/](\d{2,4})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(dateStr);
    if (match != null) {
      final day = match.group(1)!;
      final month = match.group(2)!.toLowerCase();
      var year = match.group(3)!;

      if (year.length == 2) {
        year = (int.tryParse(year) ?? 0) < 50 ? '20$year' : '19$year';
      }

      final monthNum = months[month];
      if (monthNum != null) {
        return '$day/$monthNum/$year';
      }
    }

    return dateStr;
  }

  String? _extractStation(String text, String type) {
    final stationRegex = RegExp(
      r'([A-Za-z &.]{2,})\s*(?:\(\s*([A-Z]{2,4})\s*\)|-\s*([A-Z]{2,4}))',
      multiLine: true,
    );

    final matches = stationRegex.allMatches(text).toList();
    if (matches.isEmpty) return null;

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

    final foundStations = <String>[];
    final seenStations = <String>{};
    for (final m in matches) {
      final code = m.group(2) ?? m.group(3);
      if (code == null) continue;
      if (ignoredCodes.contains(code)) continue;

      final name = m.group(1)!.replaceAll('\n', ' ').trim();
      if (name.length <= 4 || name.toUpperCase() == code) continue;

      final station = '$name ($code)';
      if (seenStations.contains(station)) continue;
      seenStations.add(station);
      foundStations.add(station);
    }

    if (foundStations.isEmpty) return null;

    if (type == 'from') {
      return foundStations.isNotEmpty ? foundStations.first : null;
    } else if (type == 'to') {
      return foundStations.length > 1
          ? foundStations.last
          : (foundStations.isNotEmpty ? foundStations.first : null);
    } else if (type == 'boarding') {
      return foundStations.length > 1 ? foundStations[1] : foundStations.first;
    }
    return null;
  }

  List<Map<String, String?>> _extractPassengersFromText(String text) {
    final passengers = <Map<String, String?>>[];

    final passengerRegex = RegExp(
      r'(?:^|\n)\s*1[.]?\s+([A-Za-z .]+)\s+(\d{1,3})\s+(Male|Female|MALE|FEMALE|M|F)',
      caseSensitive: false,
      multiLine: true,
    );

    final match = passengerRegex.firstMatch(text);
    if (match != null) {
      final name = match.group(1)!.trim();
      final age = match.group(2)!.trim();
      final gender = match.group(3)!.trim();

      final lookAhead = text.substring(
        match.end,
        (match.end + 200).clamp(0, text.length),
      );

      String? status;
      final statusMatch = RegExp(
        '((?:CNF|WL|RAC|RLWL|PQWL|RSWL)[A-Z0-9/]*)',
      ).firstMatch(lookAhead);

      if (statusMatch != null) {
        status = statusMatch.group(1)!.trim();
      } else if (lookAhead.contains('CNF')) {
        status = 'CNF';
      }

      String? seatStr;
      if (status != null && status.contains('/')) {
        final parts = status.split('/');
        status = parts.first;
        if (parts.length > 1) {
          seatStr = parts.sublist(1).join('/');
        }
      }

      passengers.add({
        'name': name,
        'age': age,
        'gender': gender,
        'status': status,
        'seat': ?seatStr,
      });
    }

    return passengers;
  }
}
