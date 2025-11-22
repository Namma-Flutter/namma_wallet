import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';

class IRCTCSMSParser implements ITicketParser {
  @override
  Ticket parseTicket(String text) {
    final rawText = text
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    String extract(String pattern, {int group = 1}) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(rawText);
      return match == null ? '' : (match.group(group) ?? '').trim();
    }

    DateTime safeParseDate(String value) {
      if (value.isEmpty) return DateTime.now();

      final parts = value.split(RegExp('[-/]'));
      if (parts.length != 3) return DateTime.now();

      try {
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final y = parts[2].length == 2
            ? 2000 + int.parse(parts[2])
            : int.parse(parts[2]);
        return DateTime(y, m, d);
      } on Exception catch (_) {
        return DateTime.now();
      }
    }

    var pnr = extract(r'PNR[:\-\s]*([0-9]{6,10})');
    if (pnr.isEmpty) {
      pnr = extract(r'(?<!TRN[:\-\s]*)([0-9]{10})');
    }

    // Fallback (never throw)
    if (pnr.isEmpty) pnr = '';

    final trainNumber = extract(r'(?:TRN|Train|Trn)[:\-\s]*([0-9]{3,5})');

    final dojRaw = extract(
      r'(?:DOJ|Journey Date|Date|Date of Journey)[:\-\s]* '
      '([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
    );

    final doj = safeParseDate(dojRaw);

    var travelClass = extract(r'(?:Class|Cls)[:\-\s]*([A-Za-z0-9\/]{2,3})');

    const knownClasses = {
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

    // Fallback: detect via coach like S2 / B3 / A1 / H1 etc.
    if (travelClass.isEmpty) {
      final coach = extract(r'([SABHEC][0-9])\s*[0-9]{1,2}');
      if (coach.isNotEmpty) {
        final prefix = coach.toUpperCase()[0];
        const mapping = {
          'S': 'SL',
          'B': '3A',
          'A': '2A',
          'H': '1A',
          'E': '3E',
          'C': 'CC',
        };
        travelClass = mapping[prefix] ?? '';
      }
    }

    travelClass = travelClass.toUpperCase();
    if (!knownClasses.contains(travelClass)) {
      travelClass = '';
    }

    // ---------------------- FROM & TO ----------------------
    var fromStation = '';
    var toStation = '';

    final routeMatch = RegExp(
      r'\b([A-Z]{2,5})-([A-Z]{2,5})\b',
    ).firstMatch(rawText);

    if (routeMatch != null) {
      fromStation = routeMatch.group(1) ?? '';
      toStation = routeMatch.group(2) ?? '';
    } else {
      final oldFormatMatch = RegExp(
        r'(?:Frm|From)\s+([A-Z]{2,5})\s+to\s+([A-Z]{2,5})',
        caseSensitive: false,
      ).firstMatch(rawText);

      if (oldFormatMatch != null) {
        fromStation = oldFormatMatch.group(1) ?? '';
        toStation = oldFormatMatch.group(2) ?? '';
      }
    }

    fromStation = fromStation.toUpperCase();
    toStation = toStation.toUpperCase();

    final depRaw = extract(
      r'(?:DP|Dep|Departure)[:\-\s]*([0-9]{1,2}[:.][0-9]{2})',
    );
    var scheduledDeparture = doj;

    if (depRaw.isNotEmpty) {
      final hm = depRaw.replaceAll('.', ':').split(':');
      try {
        scheduledDeparture = DateTime(
          doj.year,
          doj.month,
          doj.day,
          int.parse(hm[0]),
          int.parse(hm[1]),
        );
      } on Exception catch (_) {
        // keep fallback
      }
    }

    var passenger = extract(r'Passenger[:\-\s]*([A-Za-z \+]+)');

    if (passenger.isEmpty) {
      passenger = extract(
        r'([A-Za-z][A-Za-z ]+\+?[0-9]*)[, ]+(?:S\d+|WL\d+|RAC|CNF)',
      );
    }

    if (passenger.isEmpty) {
      final m = RegExp(
        r'(?:^|[, ])([A-Za-z][A-Za-z ]{2,40})\b',
      ).firstMatch(rawText);

      if (m != null) {
        final candidate = m.group(1)!.trim();
        final isRealName = candidate.contains(' ');
        passenger = isRealName ? candidate : '';
      }
    }

    var status = extract(
      r'(Cancelled|CNF|CONFIRMED|RAC|WL\s*[0-9]+|Waitlist)',
    );

    if (status.isEmpty && rawText.toLowerCase().contains('cancel')) {
      status = 'Cancelled';
    }

    if (status.isEmpty && rawText.toLowerCase().contains('cnf')) {
      status = 'CNF';
    }

    // ---------------------- FARE ----------------------
    var fare = 0.0;
    for (final p in [
      r'(?:Fare|Amount)[:\-\s]*([0-9]+\.[0-9]{2})',
      r'(?:Fare|Amount)[:\-\s]*([0-9]+)',
      r'(?:Rs\.?|₹)\s*([0-9]+(?:\.[0-9]+)?)',
    ]) {
      final v = extract(p);
      if (v.isNotEmpty) {
        fare = double.tryParse(v) ?? 0.0;
        if (fare > 0) break;
      }
    }

    final irctcFee =
        double.tryParse(
          extract(r'C Fee[:\-\s]*([0-9]+(?:\.[0-9]+)?)'),
        ) ??
        0.0;

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
      boardingStation: fromStation,
      travelClass: travelClass,
      fromStation: fromStation,
      toStation: toStation,
      ticketFare: fare,
      irctcFee: irctcFee,
    );

    return Ticket.fromIRCTC(irctc, sourceType: 'SMS');
  }
}
