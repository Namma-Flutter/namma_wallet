import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
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

    // Use regex for IRCTC since layout extraction is unreliable
    //with pseudo-blocks
    // Match across multiple lines - use [\s\S]* to match anything
    final pnrRaw = _extractByRegex(plainText, [
      r'PNR[\s\S]*?(\d{6,12})',
      r'PNR\b[\s\S]{0,30}?\b([A-Z0-9]{6,12})\b',
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
    var trainName = trainLineMatch?.group(2)?.trim();

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
      trainName = trainNameMatch?.group(1)?.trim();
    }

    // Date format is "13-Apr-2025" - need to convert to parseDate format
    final journeyDateStr = _extractByRegex(plainText, [
      r'Start Date\*\s*(\d{1,2}-[A-Za-z]{3}-\d{4})',
      r'(\d{1,2}-[A-Za-z]{3}-\d{4})',
    ]);
    // Convert "13-Apr-2025" to "13/04/2025"
    final journeyDate = _parseIrctcDate(journeyDateStr);

    // Time format is "18:55 13-Apr-2025", but can also be "N.A."
    final departureTimeStr = _extractByRegex(plainText, [
      r'Departure\*\s*(\d{1,2}:\d{2}|N\.A\.)',
    ]);

    DateTime? scheduledDeparture;
    if (journeyDate != null &&
        departureTimeStr != null &&
        departureTimeStr != 'N.A.') {
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
      r'([A-Z][A-Za-z &.]+\([A-Z]{2,4}\))\n(?:Start Date|Departure)',
      r'([A-Z][A-Za-z &.]+ - [A-Z]{2,4})\n(?:[^\n]+\n)?(?:Start Date|Departure)',
      r'([A-Za-z][A-Za-z &.]+\([A-Z]{2,4}\))\n(?:Start Date|Departure)',
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
    final arrivalTime = arrivalMatch?.group(1);

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
      pnrNumber: pnrNumber,
      passengerName: firstPassenger?['name'],
      age: int.tryParse(firstPassenger?['age'] ?? ''),
      status: firstPassenger?['status'],
      trainNumber: trainNumber,
      trainName: trainName,
      scheduledDeparture: scheduledDeparture,
      dateOfJourney: journeyDate,
      boardingStation: boardingStation,
      travelClass: travelClass,
      fromStation: fromStation,
      toStation: toStation,
      ticketFare: fare,
      irctcFee: irctcFee,
      quota: quota,
      gender: firstPassenger?['gender'],
      transactionId: transactionId,
      arrivalTime: arrivalTime,
      distance: distance,
      seatNumber: firstPassenger?['seat'],
    );

    var ticket = Ticket.fromIRCTC(model);

    // Add extras for additional passengers (2nd, 3rd, etc.)
    if (passengers.length > 1) {
      final additionalExtras = <ExtrasModel>[];
      for (var i = 1; i < passengers.length; i++) {
        final p = passengers[i];
        final n = i + 1;
        additionalExtras.addAll(
          [
            ExtrasModel(title: 'Passenger $n', value: p['name']),
            ExtrasModel(title: 'Gender $n', value: p['gender']),
            ExtrasModel(title: 'Age $n', value: p['age']),
            ExtrasModel(title: 'Berth $n', value: p['seat']),
          ].where((e) => e.value != null && e.value!.isNotEmpty),
        );
      }
      ticket = ticket.copyWith(
        extras: [...?ticket.extras, ...additionalExtras],
      );
    }

    return ticket;
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
    // Group 1: row number, Group 2: name, Group 3: age, Group 4: gender,
    // Group 5: status (CNF/WL/RAC), Group 6: coach, Group 7: seat number,
    // Group 8: berth type.
    final passengerPattern = RegExp(
      r'(\d+)\.?\s+([A-Z][A-Za-z .\n]*?)\s+(\d{1,3})\s+(FEMALE|MALE|[MF])\s+(?:(?:NO FOOD|VEG|NON VEG)\s+)?(CNF|WL|RAC|[A-Z]+)(?:\s*/([A-Z0-9]+))?(?:\s*/(\d+))?(?:\s*/([A-Z]+(?: [A-Z]+)?))?',
      caseSensitive: false,
    );

    for (final match in passengerPattern.allMatches(plainText)) {
      passengers.add({
        'name': match
            .group(2)
            ?.replaceAll('\n', ' ')
            .trim()
            .replaceAll(RegExp(r'\s+'), ' '),
        'age': match.group(3)?.trim(),
        'gender': _normalizeGender(match.group(4)),
        'status': match.group(5)?.trim(),
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

  String? _buildSeat(RegExpMatch match, {int startGroup = 5}) {
    final parts = <String>[];
    for (var i = startGroup; i <= startGroup + 3; i++) {
      final part = match.group(i);
      if (part != null && part.isNotEmpty) {
        if (i == startGroup) {
          // Include waitlist/RAC status in the berth string (e.g., WL/111)
          // but exclude CNF (so CNF/S2/32 becomes S2/32)
          if (part.toUpperCase() != 'CNF') {
            parts.add(part);
          }
        } else {
          parts.add(part);
        }
      }
    }
    return parts.isNotEmpty ? parts.join('/') : null;
  }

  @override
  Ticket parseTicket(String pdfText) {
    return parseTicketFromBlocks(OCRBlock.fromPlainText(pdfText));
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
      final rawMonth = match.group(2) ?? '';
      final year = int.tryParse(match.group(3) ?? '');
      final monthStr = rawMonth.isEmpty
          ? ''
          : rawMonth[0].toUpperCase() + rawMonth.substring(1).toLowerCase();

      final month = months[monthStr];
      if (day != null && month != null && year != null) {
        return DateTime.utc(year, int.parse(month), day);
      }
    }
    return null;
  }
}
