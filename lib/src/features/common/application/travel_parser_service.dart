import 'dart:convert';

import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/enums/source_type.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_ticket_model.dart';

abstract class TravelTicketParser {
  bool canParse(String text);

  Ticket? parseTicket(String text);

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
    ];
    return patterns.any(
      (pattern) => text.toLowerCase().contains(pattern.toLowerCase()),
    );
  }

  @override
  Ticket? parseTicket(String text) {
    if (!canParse(text)) return null;

    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    DateTime? parseDate(String date) {
      if (date.isEmpty) return null;

      // Handle both '/' and '-' separators
      final parts = date.contains('/') ? date.split('/') : date.split('-');
      if (parts.length != 3) return null;

      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } on FormatException {
        return null;
      }
    }

    // Try multiple PNR patterns (handles "PNR:", "PNR NO.", "PNR Number")
    var pnrNumber = extractMatch(
      r'PNR\s*(?:NO\.?|Number)?\s*:\s*([^,\s]+)',
      text,
    );

    // Try multiple date patterns (DOJ, Journey Date, Date of Journey)
    final journeyDateStr = extractMatch(
      r'(?:DOJ|Journey Date|Date of Journey)\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})',
      text,
    );
    var journeyDate = parseDate(journeyDateStr);

    // Try multiple patterns for route/vehicle information
    final vehicleNo = extractMatch(r'Vehicle No\s*:\s*([^,\s]+)', text);
    final routeNo = extractMatch(r'Route No\s*:\s*([^,.\s]+)', text);

    // Try SMS patterns with various formats
    var corporation = extractMatch(r'Corporation\s*:\s*(.*?)(?=\s*,)', text);
    var from = extractMatch(r'From\s*:\s*(.*?)(?=\s+To)', text);
    var to = extractMatch(r'To\s+([^,]+)', text);
    final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', text);
    var departureTime = extractMatch(
      r'Time\s*:\s*(?:\d{2}/\d{2}/\d{4},)?\s*,?\s*(\d{2}:\d{2})',
      text,
    );
    var seatNumbers = extractMatch(
      r'Seat No\.\s*:\s*([0-9A-Z,\s\-#]+)',
      text,
    ).replaceAll(RegExp(r'[,\s]+$'), '');
    var classOfService = extractMatch(
      r'Class\s*:\s*(.*?)(?=\s*[,\.]|\s*Boarding|\s*For\s+e-Ticket|$)',
      text,
    );
    var boardingPoint = extractMatch(
      r'Boarding at\s*:\s*(.*?)(?=\s*\.|$)',
      text,
    );

    // If SMS patterns failed, try PDF patterns
    if (corporation.isEmpty && pnrNumber.isEmpty) {
      corporation = extractMatch(r'Corporation\s*:\s*(.*)', text);
      pnrNumber = extractMatch(r'PNR Number\s*:\s*(\S+)', text);
    }

    if (from.isEmpty || to.isEmpty) {
      from = from.isNotEmpty
          ? from
          : extractMatch(r'Service Start Place\s*:\s*(.*)', text);
      to = to.isNotEmpty
          ? to
          : extractMatch(r'Service End Place\s*:\s*(.*)', text);
    }

    journeyDate ??= parseDate(
      extractMatch(r'Date of Journey\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', text),
    );

    if (departureTime.isEmpty) {
      departureTime = extractMatch(
        r'Service Start Time\s*:\s*(\d{2}:\d{2})',
        text,
      );
    }

    if (classOfService.isEmpty) {
      classOfService = extractMatch(r'Class of Service\s*:\s*(.*)', text);
    }

    if (boardingPoint.isEmpty) {
      boardingPoint = extractMatch(r'Passenger Pickup Point\s*:\s*(.*)', text);
    }

    // For PDF, try to extract seat number differently
    if (seatNumbers.isEmpty) {
      seatNumbers = extractMatch(r'\d+[A-Z]+', text);
    }

    // Use vehicle/route number as trip code if tripCode is empty
    final finalTripCode = tripCode.isNotEmpty
        ? tripCode
        : (vehicleNo.isNotEmpty ? vehicleNo : routeNo);

    // ✅ Map extracted values into Ticket
    return Ticket(
      ticketId: pnrNumber,
      primaryText:
          '${from.isNotEmpty ? from : 'Unknown'} → '
          '${to.isNotEmpty ? to : 'Unknown'}',
      secondaryText:
          '${corporation.isNotEmpty ? corporation : 'TNSTC'} - '
          '${finalTripCode.isNotEmpty ? finalTripCode : 'Bus'}',
      startTime: journeyDate ?? DateTime.now(),
      endTime: journeyDate?.add(const Duration(hours: 6)),
      location: boardingPoint.isNotEmpty
          ? boardingPoint
          : (from.isNotEmpty ? from : 'Unknown'),
      type: TicketType.bus,
      tags: [
        if (finalTripCode.isNotEmpty)
          TagModel(value: finalTripCode, icon: 'confirmation_number'),
        if (pnrNumber.isNotEmpty) TagModel(value: pnrNumber, icon: 'qr_code'),
        if (departureTime.isNotEmpty)
          TagModel(value: departureTime, icon: 'access_time'),
        if (seatNumbers.isNotEmpty)
          TagModel(value: seatNumbers, icon: 'event_seat'),
        if (classOfService.isNotEmpty)
          TagModel(value: classOfService, icon: 'workspace_premium'),
      ],
      extras: [
        ExtrasModel(
          title: 'Provider',
          value: corporation.isNotEmpty ? corporation : 'TNSTC',
        ),
        if (finalTripCode.isNotEmpty)
          ExtrasModel(title: 'Trip Code', value: finalTripCode),
        if (from.isNotEmpty) ExtrasModel(title: 'From', value: from),
        if (to.isNotEmpty) ExtrasModel(title: 'To', value: to),
        if (seatNumbers.isNotEmpty)
          ExtrasModel(title: 'Seat', value: seatNumbers),
        if (journeyDateStr.isNotEmpty)
          ExtrasModel(title: 'Journey Date', value: journeyDateStr),
        if (departureTime.isNotEmpty)
          ExtrasModel(title: 'Departure Time', value: departureTime),
        if (classOfService.isNotEmpty)
          ExtrasModel(title: 'Class', value: classOfService),
        if (boardingPoint.isNotEmpty)
          ExtrasModel(title: 'Boarding', value: boardingPoint),
        ExtrasModel(title: 'Source Type', value: 'SMS'),
      ],
    );
  }
}

class IRCTCTrainParser implements TravelTicketParser {
  late final ILogger _logger = getIt<ILogger>();

  @override
  String get providerName => 'IRCTC';

  @override
  TicketType get ticketType => TicketType.train;

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

  @override
  Ticket? parseTicket(String text) {
    // Normalise content: Replace newlines and excessive whitespace with single spaces
    text = text.replaceAll(RegExp(r'[\r\n]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    // ---------------------- UTIL ----------------------
    String extract(String pattern, {int group = 1}) {
      // Uses word boundary \b for better matching accuracy
      final m = RegExp(pattern, caseSensitive: false).firstMatch(text);
      return m == null ? '' : (m.group(group) ?? '').trim();
    }

    // ---------------------- PNR ----------------------
    String pnr = extract(r'PNR[:\-\s]*([0-9]{6,10})\b');
    if (pnr.isEmpty) {
      pnr = extract(r'(?<!TRN[:\-\s]*)([0-9]{10})\b', group: 1);
    }
    if (pnr.isEmpty) return null;

    // ---------------------- TRAIN NUMBER ----------------------
    final trainNumber = extract(r'(?:TRN|Train|Trn)[:\-\s]*([0-9]{3,5})\b');

    // ---------------------- DATE OF JOURNEY ----------------------
    String dojRaw = extract(
      r'(?:DOJ|Dt|Date|Journey Date|Date of Journey)[:\-\s]*'
      r'([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
    );
    if (dojRaw.isEmpty) {
      dojRaw = extract(r'^\s*([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})');
    }

    DateTime? doj;
    if (dojRaw.isNotEmpty) {
      final parts = dojRaw.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final y = parts[2].length == 2 ? 2000 + int.parse(parts[2]) : int.parse(parts[2]);
        doj = DateTime(y, m, d);
      }
    }
    doj ??= DateTime.now();

    // ---------------------- CLASS (FINAL FIXED: Prioritize SL, eliminate URL match) ----------------------
    String travelClass = '';
    const knownClasses = <String>{
      'SL', '1A', '2A', '3A', 'CC', '2S', '3E', 'FC', 'EC', '1E', '2E'
    };

    // 1) Explicit label check
    travelClass = extract(r'(?:Class|Cls)[:\-\s]*([A-Za-z0-9\/]+)\b');

    // 2) Aggressive extraction from the key data block (PNR,TRN,DOJ,CLASS,ROUTE)
    // This targets the comma-separated token after the date but BEFORE the route.
    if (travelClass.isEmpty) {
      // Pattern: DOJ token, date, comma, Class token (2-3 chars), comma
      final m = RegExp(
        r'([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4}),\s*([A-Za-z0-9\/]{2,3})\b,',
        caseSensitive: false,
      ).firstMatch(text);

      if (m != null) {
        final candidate = m.group(2) ?? '';
        final candClean = candidate.toUpperCase();

        if (knownClasses.contains(candClean)) {
          travelClass = candClean;
        }
      }
    }

    // 3) Fallback: Infer from Coach Code if necessary (matches user's suggested requirement)
    if (travelClass.isEmpty) {
      // Look for S\d, B\d, A\d, H\d, E\d, PC, etc. as the first part of a seat number
      final coachMatch = extract(r'([SABHE]?[0-9]|PC)\s*[0-9]{1,2}', group: 1);

      if (coachMatch.isNotEmpty) {
        final coachPrefix = coachMatch.toUpperCase().substring(0, 1);

        // Simple mapping from Coach Prefix to Travel Class (This is a guess based on standard railway practice)
        const coachToClass = {
          'S': 'SL', // Sleeper
          'B': '3A', // AC 3 Tier
          'A': '2A', // AC 2 Tier
          'H': '1A', // AC First Class
          'E': '3E', // AC Economy/3E
          'C': 'CC', // AC Chair Car
        };

        travelClass = knownClasses.contains(coachMatch.toUpperCase())
            ? coachMatch.toUpperCase()
            : coachToClass[coachPrefix] ?? '';
      }
    }

    // The final fallback logic that was likely grabbing 'B0' from the URL is REMOVED
    // to prioritize correctly extracted data and prevent false positives from URLs.

    travelClass = travelClass.toUpperCase();


    // ---------------------- FROM - TO ----------------------
    String fromStation = '';
    String toStation = '';

    // 1) Match ABC-XYZ format (e.g., YPR-MAS)
    final m1 = RegExp(r'\b([A-Z]{2,5})-([A-Z]{2,5})\b').firstMatch(text);
    if (m1 != null) {
      fromStation = m1.group(1)!;
      toStation = m1.group(2)!;
    } else {
      // 2) Match 'Frm ABC to XYZ' or 'From ABC to XYZ'
      final m2 = RegExp(
        r'(?:Frm|From|Boarding)[^\w]*([A-Za-z]{2,5})\b[^\w]+(?:to|To)[^\w]*([A-Za-z]{2,5})\b',
        caseSensitive: false,
      ).firstMatch(text);
      if (m2 != null) {
        fromStation = m2.group(1)!;
        toStation = m2.group(2)!;
      }
    }
    fromStation = fromStation.toUpperCase();
    toStation = toStation.toUpperCase();

    // ---------------------- DEPARTURE TIME ----------------------
    final dep = extract(r'(?:DP|Dep|Departure)[:\-\s]*([0-9]{1,2}[:.][0-9]{2})\b');
    DateTime scheduledDeparture = doj;
    if (dep.isNotEmpty) {
      final hm = dep.replaceAll('.', ':').split(':');
      scheduledDeparture = DateTime(
        doj.year,
        doj.month,
        doj.day,
        int.parse(hm[0]),
        int.parse(hm[1]),
      );
    }

    // ---------------------- PASSENGER NAME ----------------------
    String passenger = '';

    // 1) Explicit label: Passenger: NAME
    passenger = extract(r'Passenger[:\-\s]*([A-Za-z \+]+)\b');

    // 2) Passenger list format: NAME+N,S_XX,NAME
    if (passenger.isEmpty) {
      // HARISH ANBALAGAN+2,S4 15
      passenger = extract(r'([A-Za-z ]+\+?[0-9]*)\b[, ]+(?:S\d+\s+\d+|WL\s*\d+|RAC|CNF|D\d+)\b');
    }

    // 3) Fallback (kept safe)
    if (passenger.isEmpty) {
      final m = RegExp(r'(?:^|,\s*|\n\s*)([A-Za-z ]{3,40})\b', caseSensitive: false).firstMatch(text);
      if (m != null) {
        final candidate = m.group(1)!;
        if (candidate.toUpperCase() != candidate || candidate.length > 5) {
          passenger = candidate.trim();
        }
      }
    }


    // ---------------------- STATUS ----------------------
    String status = extract(r'(Cancelled|CNF|CONFIRMED|RAC|WL\s*\d+|Waitlist)\b', group: 1);
    if (status.isEmpty && text.toLowerCase().contains('cancel')) status = 'Cancelled';
    if (status.isEmpty && text.toLowerCase().contains('cnf')) status = 'CNF';

    // ---------------------- FARE ----------------------
    double ticketFare = 0.0;
    final farePatterns = [
      r'(?:Fare|Amount)[:\-\s]*([0-9]+\.[0-9]{2})',
      r'(?:Fare|Amount)[:\-\s]*([0-9]+)',
      r'(?:Rs\.?|₹)\s*([0-9]+(?:\.[0-9]+)?)',
    ];
    for (final p in farePatterns) {
      final v = extract(p);
      if (v.isNotEmpty) {
        ticketFare = double.tryParse(v) ?? 0.0;
        if (ticketFare > 0) break;
      }
    }

    // ---------------------- IRCTC FEE ----------------------
    final irctcFee = double.tryParse(extract(r'C Fee[:\-\s]*([0-9]+(?:\.[0-9]+)?)')) ?? 0.0;

    // ---------------------- BUILD MODEL ----------------------
    final boardingStation = fromStation;

    final irctc = IRCTCTicket(
      pnrNumber: pnr,
      transactionId: '',
      passengerName: passenger,
      gender: '',
      age: 0,
      status: status,
      quota: '',
      trainNumber: trainNumber,
      trainName: '',
      scheduledDeparture: scheduledDeparture,
      dateOfJourney: doj,
      boardingStation: boardingStation,
      travelClass: travelClass,
      fromStation: fromStation,
      toStation: toStation,
      ticketFare: ticketFare,
      irctcFee: irctcFee,
    );

    return Ticket.fromIRCTC(irctc);
  }
///
  // @override
  // Ticket? parseTicket(String text) {
  //   // Normalise content: Replace newlines and excessive whitespace with single spaces
  //   text = text
  //       .replaceAll(RegExp(r'[\r\n]+'), ' ')
  //       .replaceAll(RegExp(r'\s+'), ' ')
  //       .trim();
  //
  //   // ---------------------- UTIL ----------------------
  //   String extract(String pattern, {int group = 1}) {
  //     // Uses word boundary \b for better matching accuracy
  //     final m = RegExp(pattern, caseSensitive: false).firstMatch(text);
  //     return m == null ? '' : (m.group(group) ?? '').trim();
  //   }
  //
  //   // ---------------------- PNR (FIXED for flexibility and refund SMS) ----------------------
  //   // PNR in IRCTC is 10 digits, but we allow 6-10 for robustness against reference numbers/older formats.
  //   String pnr = extract(r'PNR[:\-\s]*([0-9]{6,10})\b');
  //
  //   // Secondary check: If no explicit PNR, look for a 10-digit number surrounded by spaces/punctuation,
  //   // as it is often the PNR/Ref number in cancellation/refund SMS.
  //   if (pnr.isEmpty) {
  //     pnr = extract(r'(?<!TRN[:\-\s]*)([0-9]{10})\b', group: 1);
  //   }
  //
  //   if (pnr.isEmpty) return null; // Must have a 6-10 digit PNR/Ref number
  //
  //   // ---------------------- TRAIN NUMBER ----------------------
  //   final trainNumber = extract(r'(?:TRN|Train|Trn)[:\-\s]*([0-9]{3,5})\b');
  //
  //   // ---------------------- DATE OF JOURNEY ----------------------
  //   String dojRaw = extract(
  //     r'(?:DOJ|Dt|Date|Journey Date|Date of Journey)[:\-\s]*'
  //     r'([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
  //   );
  //
  //   // Fallback: Check for date pattern at the start of the string
  //   if (dojRaw.isEmpty) {
  //     dojRaw = extract(
  //       r'^\s*([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
  //     );
  //   }
  //
  //   DateTime? doj;
  //   if (dojRaw.isNotEmpty) {
  //     final parts = dojRaw.split(RegExp(r'[-/]'));
  //     if (parts.length == 3) {
  //       final d = int.parse(parts[0]);
  //       final m = int.parse(parts[1]);
  //       // Improved year handling: assume 2-digit years are in the 2000s
  //       final y = parts[2].length == 2
  //           ? 2000 + int.parse(parts[2])
  //           : int.parse(parts[2]);
  //       doj = DateTime(y, m, d);
  //     }
  //   }
  //   doj ??= DateTime.now();
  //
  //   // ---------------------- CLASS (FIXED for SL/B0 confusion) ----------------------
  //   String travelClass = '';
  //   const knownClasses = <String>{
  //     'SL',
  //     '1A',
  //     '2A',
  //     '3A',
  //     'CC',
  //     '2S',
  //     '3E',
  //     'FC',
  //     'EC',
  //     '1E',
  //     '2E',
  //   };
  //
  //   // 1) Explicit label check (first priority)
  //   travelClass = extract(r'(?:Class|Cls|CL)[:\-\s]*([A-Za-z0-9\/]+)\b');
  //
  //   // 2) Aggressive extraction from the key data block (PNR,TRN,DOJ,CLASS,ROUTE)
  //   if (travelClass.isEmpty) {
  //     // Pattern: DOJ token, date, comma, Class token (2-3 chars), comma
  //     final m = RegExp(
  //       r'(?:DOJ|Dt|Date|Journey Date|Date of Journey)[:\-\s]*[0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4},\s*([A-Za-z0-9\/]{2,3})\b,',
  //       caseSensitive: false,
  //     ).firstMatch(text);
  //
  //     if (m != null) {
  //       final candidate = m.group(1) ?? '';
  //       final candClean = candidate.toUpperCase();
  //
  //       if (knownClasses.contains(candClean)) {
  //         travelClass = candClean;
  //       }
  //     }
  //   }
  //
  //   // 3) Fallback: Original logic (kept for robustness against varied formats)
  //   if (travelClass.isEmpty) {
  //     final dojMatch = RegExp(
  //       r'(?:DOJ|Dt|Date|Journey Date|Date of Journey)[:\-\s]*([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
  //       caseSensitive: false,
  //     ).firstMatch(text);
  //
  //     final dojFallbackMatch =
  //         dojMatch ??
  //         RegExp(
  //           r'^\s*([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
  //         ).firstMatch(text);
  //
  //     if (dojFallbackMatch != null) {
  //       final end = dojFallbackMatch.end;
  //       final tail = text.substring(end).trimLeft();
  //       final candidate = tail
  //           .split(',')
  //           .map((s) => s.trim())
  //           .firstWhere(
  //             (s) => s.isNotEmpty,
  //             orElse: () => '',
  //           );
  //
  //       if (candidate.isNotEmpty) {
  //         final candClean = candidate
  //             .split(' ')
  //             .first
  //             .replaceAll(RegExp(r'[^A-Za-z0-9\/]'), '')
  //             .toUpperCase();
  //
  //         // Accept candidate if it's a known class OR short (<=3) and not a station code (3 letters all caps)
  //         if (knownClasses.contains(candClean) ||
  //             (candClean.length <= 3 &&
  //                 RegExp(r'^[A-Z0-9\/]+$').hasMatch(candClean) &&
  //                 !RegExp(r'^[A-Z]{3}$').hasMatch(candClean))) {
  //           travelClass = candClean;
  //         }
  //       }
  //     }
  //   }
  //   travelClass = travelClass.toUpperCase();
  //
  //   // ---------------------- FROM - TO ----------------------
  //   String fromStation = '';
  //   String toStation = '';
  //
  //   // 1) Match ABC-XYZ format (e.g., YPR-MAS)
  //   final m1 = RegExp(r'\b([A-Z]{2,5})-([A-Z]{2,5})\b').firstMatch(text);
  //   if (m1 != null) {
  //     fromStation = m1.group(1)!;
  //     toStation = m1.group(2)!;
  //   } else {
  //     // 2) Match 'Frm ABC to XYZ' or 'From ABC to XYZ'
  //     final m2 = RegExp(
  //       r'(?:Frm|From|Boarding)[^\w]*([A-Za-z]{2,5})\b[^\w]+(?:to|To)[^\w]*([A-Za-z]{2,5})\b',
  //       caseSensitive: false,
  //     ).firstMatch(text);
  //     if (m2 != null) {
  //       fromStation = m2.group(1)!;
  //       toStation = m2.group(2)!;
  //     }
  //   }
  //   fromStation = fromStation.toUpperCase();
  //   toStation = toStation.toUpperCase();
  //
  //   // ---------------------- DEPARTURE TIME ----------------------
  //   final dep = extract(
  //     r'(?:DP|Dep|Departure)[:\-\s]*([0-9]{1,2}[:.][0-9]{2})\b',
  //   );
  //   DateTime scheduledDeparture = doj;
  //   if (dep.isNotEmpty) {
  //     final hm = dep.replaceAll('.', ':').split(':');
  //     scheduledDeparture = DateTime(
  //       doj.year,
  //       doj.month,
  //       doj.day,
  //       int.parse(hm[0]),
  //       int.parse(hm[1]),
  //     );
  //   }
  //
  //   // ---------------------- PASSENGER NAME ----------------------
  //   String passenger = '';
  //
  //   // 1) Explicit label: Passenger: NAME
  //   passenger = extract(r'Passenger[:\-\s]*([A-Za-z \+]+)\b');
  //
  //   // 2) Passenger list format: NAME+N,S_XX,NAME
  //   if (passenger.isEmpty) {
  //     passenger = extract(
  //       r'([A-Za-z ]+\+?[0-9]*)\b[, ]+(?:S\d+\s+\d+|WL\s*\d+|RAC|CNF|D\d+)\b',
  //     );
  //   }
  //
  //   // 3) Fallback: sequence of 3-40 letters/spaces at the start of a logical line/after a comma
  //   if (passenger.isEmpty) {
  //     final m = RegExp(
  //       r'(?:^|,\s*|\n\s*)([A-Za-z ]{3,40})\b',
  //       caseSensitive: false,
  //     ).firstMatch(text);
  //     if (m != null) {
  //       final candidate = m.group(1)!;
  //       // Simple heuristic to reject if it looks like a train label (all caps 3-5 chars)
  //       if (candidate.toUpperCase() != candidate || candidate.length > 5) {
  //         passenger = candidate.trim();
  //       }
  //     }
  //   }
  //
  //   // ---------------------- STATUS ----------------------
  //   String status = extract(
  //     r'(Cancelled|CNF|CONFIRMED|RAC|WL\s*\d+|Waitlist)\b',
  //     group: 1,
  //   );
  //   if (status.isEmpty && text.toLowerCase().contains('cancel'))
  //     status = 'Cancelled';
  //   if (status.isEmpty && text.toLowerCase().contains('cnf')) status = 'CNF';
  //
  //   // ---------------------- FARE ----------------------
  //   double ticketFare = 0.0;
  //   final farePatterns = [
  //     // 1. Explicit labels with decimals: Fare/Amount: 1234.56
  //     r'(?:Fare|Amount)[:\-\s]*([0-9]+\.[0-9]{2})',
  //     // 2. Explicit labels without decimals: Fare/Amount: 1234
  //     r'(?:Fare|Amount)[:\-\s]*([0-9]+)',
  //     // 3. Currency symbol (common in refund SMS): Rs. 1234 or ₹1234
  //     r'(?:Rs\.?|₹)\s*([0-9]+(?:\.[0-9]+)?)',
  //   ];
  //   for (final p in farePatterns) {
  //     final v = extract(p);
  //     if (v.isNotEmpty) {
  //       ticketFare = double.tryParse(v) ?? 0.0;
  //       if (ticketFare > 0) break;
  //     }
  //   }
  //
  //   // ---------------------- IRCTC FEE ----------------------
  //   // C Fee: 11.8+PG
  //   final irctcFee =
  //       double.tryParse(extract(r'C Fee[:\-\s]*([0-9]+(?:\.[0-9]+)?)')) ?? 0.0;
  //
  //   // ---------------------- BUILD MODEL ----------------------
  //   final boardingStation =
  //       fromStation; // Default to 'from' station if not separate
  //
  //   final irctc = IRCTCTicket(
  //     pnrNumber: pnr,
  //     transactionId: '',
  //     passengerName: passenger,
  //     gender: '',
  //     age: 0,
  //     status: status,
  //     quota: '',
  //     trainNumber: trainNumber,
  //     trainName: '',
  //     scheduledDeparture: scheduledDeparture,
  //     dateOfJourney: doj,
  //     boardingStation: boardingStation,
  //     travelClass: travelClass,
  //     fromStation: fromStation,
  //     toStation: toStation,
  //     ticketFare: ticketFare,
  //     irctcFee: irctcFee,
  //   );
  //
  //   return Ticket.fromIRCTC(irctc);
  // }
///
  // @override
  // Ticket? parseTicket(String text) {
  //   if (!canParse(text)) return null;
  //
  //   String extractMatch(String pattern, String input, {int groupIndex = 1}) {
  //     final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
  //     final match = regex.firstMatch(input);
  //     if (match != null && groupIndex <= match.groupCount) {
  //       return match.group(groupIndex)?.trim() ?? '';
  //     }
  //     return '';
  //   }
  //
  //   final pnr = extractMatch(r'PNR[:\-\s]*([0-9]{10})');
  //   final trainNo = extractMatch(r'(?:TRN|Train|Trn)[:\-\s]*([0-9]{4,5})');
  //   final doj = extractMatch(r'(?:DOJ|Dt|Date)[:\-\s]*([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})');
  //   final cls = extractMatch(r'(?:Class|Cls|CL)[:\-\s]*([A-Z0-9]+)');
  //   final fromTo = extract(r'([A-Z]{2,5})[-\s]+([A-Z]{2,5})');
  //   final passenger = extract(r'([A-Za-z ]+)(?:,|\s+)(?:S\d+|WL|GN|D\d+)');
  //   final status = extract(r'(CNF|WL\s*\d+|RAC\s*\d+|Cancelled|Waitlist)', group: 0);
  //   final fare = extract(r'Fare[:\-\s]*([0-9]+(\.[0-9]+)?)');
  //   final fee = extract(r'(?:C Fee|Conv Fee)[:\-\s]*([0-9]+(\.[0-9]+)?)');
  //   final dep = extract(r'(?:DP|Dep|Departure)[:\-\s]*([0-9]{2}:[0-9]{2})');
  //
  //
  //   DateTime? parsedDate;
  //   try {
  //     parsedDate = DateTime.parse(dateTime);
  //   } on Exception catch (_) {
  //     _logger.warning(
  //       '[IRCTCTrainParser] Failed to parse date: "$dateTime", '
  //       'using current date as fallback',
  //     );
  //     parsedDate = null;
  //   }
  //
  //   return Ticket(
  //     ticketId: pnrNumber,
  //     primaryText:
  //         '${from.isNotEmpty ? from : 'Unknown'} →'
  //         ' ${to.isNotEmpty ? to : 'Unknown'}',
  //     secondaryText:
  //         'Train ${trainNumber.isNotEmpty ? trainNumber : 'N/A'} • '
  //         '${classService.isNotEmpty ? classService : 'Class N/A'} • '
  //         '${seat.isNotEmpty ? seat : 'Seat N/A'}',
  //     startTime: parsedDate ?? DateTime.now(),
  //     location: from.isNotEmpty ? from : 'Unknown',
  //     tags: [
  //       if (pnrNumber.isNotEmpty)
  //         TagModel(value: pnrNumber, icon: 'confirmation_number'),
  //       if (trainNumber.isNotEmpty) TagModel(value: trainNumber, icon: 'train'),
  //       if (coach.isNotEmpty)
  //         TagModel(value: coach, icon: 'directions_transit'),
  //       if (seat.isNotEmpty) TagModel(value: seat, icon: 'event_seat'),
  //       if (classService.isNotEmpty)
  //         TagModel(value: classService, icon: 'workspace_premium'),
  //       if (dateTime.isNotEmpty) TagModel(value: dateTime, icon: 'today'),
  //     ],
  //     extras: [
  //       ExtrasModel(title: 'Provider', value: 'IRCTC'),
  //       if (trainNumber.isNotEmpty)
  //         ExtrasModel(title: 'Train Number', value: trainNumber),
  //       if (from.isNotEmpty) ExtrasModel(title: 'From', value: from),
  //       if (to.isNotEmpty) ExtrasModel(title: 'To', value: to),
  //       if (coach.isNotEmpty) ExtrasModel(title: 'Coach', value: coach),
  //       if (seat.isNotEmpty) ExtrasModel(title: 'Seat', value: seat),
  //       if (classService.isNotEmpty)
  //         ExtrasModel(title: 'Class', value: classService),
  //       if (dateTime.isNotEmpty)
  //         ExtrasModel(title: 'Journey Date', value: dateTime),
  //       ExtrasModel(title: 'Source Type', value: 'SMS'),
  //     ],
  //   );
  // }
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
  Ticket? parseTicket(String text) {
    if (!canParse(text)) return null;

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
          if (ticket != null) {
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
