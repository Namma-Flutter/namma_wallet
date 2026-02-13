import 'package:namma_wallet/src/common/constants/station_code.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';

class IRCTCSMSParser implements ITicketParser {
  @override
  Ticket parseTicket(String smsText) {
    final rawText = smsText
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Safe extractor – always returns empty string on failure.
    String extract(String pattern, {int group = 1}) {
      final m = RegExp(pattern, caseSensitive: false).firstMatch(rawText);
      return m == null ? '' : (m.group(group) ?? '').trim();
    }

    // Safe date parser – falls back to today if malformed/missing.
    DateTime parseDate(String value) {
      if (value.isEmpty) return DateTime.utc(1970);

      final parts = value.split(RegExp('[-/]'));
      if (parts.length != 3) return DateTime.utc(1970);

      try {
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final y = parts[2].length == 2
            ? 2000 + int.parse(parts[2])
            : int.parse(parts[2]);
        return DateTime(y, m, d);
      } on Exception catch (_) {
        return DateTime.utc(1970);
      }
    }

    /// List of keywords that indicate the SMS is an update/notification
    /// (e.g., cancellation, delay, reschedule, chart prepared).
    const updateKeywords = <String>[
      'cancelled',
      'cancel',
      'refund',
      'running late',
      'reschedule',
      'chart prepared',
      'chart preparation',
      'wl after chart',
      'cancellation',
    ];

    /// Detects if the SMS is an update message (e.g., cancellation, delay).
    ///
    /// This is often indicated by specific keywords and the absence of
    /// full PNR/Train/DOJ key-value pairs typical of a booking SMS.
    bool isUpdateMessage(String smsText) {
      final lowerCaseText = smsText.toLowerCase();

      final containsUpdateKeyword = updateKeywords.any(
        lowerCaseText.contains,
      );
      final isStandardBooking =
          lowerCaseText.contains('pnr:') ||
          lowerCaseText.contains('trn:') ||
          lowerCaseText.contains('doj:');

      return containsUpdateKeyword && !isStandardBooking;
    }

    final isUpdate = isUpdateMessage(smsText);

    var pnr = extract(r'PNR(?:[\s\S]{0,10}?)\b([0-9]{10})\b');
    if (pnr.isEmpty) {
      for (final m in RegExp(r'\b([0-9]{10})\b').allMatches(rawText)) {
        final start = m.start;
        final prefixStart = start - 16;
        final prefix = rawText.substring(
          prefixStart < 0 ? 0 : prefixStart,
          start,
        );
        final isTrainNumber = RegExp(
          r'(?:TRN|Train|Trn)[:\-\s]*$',
          caseSensitive: false,
        ).hasMatch(prefix);
        if (!isTrainNumber) {
          pnr = m.group(1) ?? '';
          break;
        }
      }
    }

    if (pnr.isEmpty) {
      throw const FormatException('IRCTC SMS parse failed: PNR not found');
    }

    final trainNumber = extract(r'(?:TRN|Train|Trn)[:\-\s]*([0-9]{3,5})');

    final dojRaw = extract(
      /// this ignore is added here because, changing the regex making the
      /// parser fails.
      // ignore: missing_whitespace_between_adjacent_strings
      r'(?:DOJ|Journey Date|Date|Date of Journey|Dt)[:\-\s]*'
      '([0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4})',
    );

    final doj = parseDate(dojRaw);

    var travelClass = extract(r'(?:Class|Cls)[:\-\s]*([A-Za-z0-9\/]{2,3})');

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

    if (travelClass.isEmpty) {
      final coach = extract(r'([SABHEC][0-9])\s*[0-9]{1,2}');
      if (coach.isNotEmpty) {
        final code = coach.toUpperCase()[0];
        const mapping = {
          'S': 'SL',
          'B': '3A',
          'A': '2A',
          'H': '1A',
          'E': '3E',
          'C': 'CC',
        };
        travelClass = mapping[code] ?? '';
      }
    }

    travelClass = travelClass.toUpperCase();
    if (!allowedClasses.contains(travelClass)) travelClass = '';

    var fromStation = '';
    var toStation = '';

    final route = RegExp(r'\b([A-Z]{2,5})-([A-Z]{2,5})\b').firstMatch(rawText);

    if (route != null) {
      fromStation = route.group(1) ?? '';
      toStation = route.group(2) ?? '';
    } else {
      final alt = RegExp(
        r'(?:Frm|From)\s+([A-Z]{2,5})\s+to\s+([A-Z]{2,5})',
        caseSensitive: false,
      ).firstMatch(rawText);

      if (alt != null) {
        fromStation = alt.group(1) ?? '';
        toStation = alt.group(2) ?? '';
      }
    }

    fromStation = StationRegistry.getName(fromStation);
    toStation = StationRegistry.getName(toStation);

    final depRaw = extract(
      r'(?:DP|Dep|Departure)[:\-\s]*([0-9]{1,2}[:.][0-9]{2})',
    );

    DateTime? scheduledDeparture = doj;
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
        scheduledDeparture = null;
      }
    }

    var passenger = extract(r'Passenger[:\-\s]*([A-Za-z \+]+)');

    if (passenger.isEmpty) {
      passenger = extract(
        r'([A-Za-z][A-Za-z ]+\+?[0-9]*)[, ]+(?:S\d+|WL\d+|RAC|CNF)',
      );
    }

    var status = extract(
      r'(Cancelled|CNF|CONFIRMED|RAC|WL\s*[0-9]+|Waitlist)',
    );

    if (status.isEmpty && rawText.toLowerCase().contains('cancel')) {
      status = 'Cancelled';
    }
    if (status.isEmpty && rawText.toLowerCase().contains('allocated')) {
      status = 'Coach Allocated'; // derived
    }
    if (status.isEmpty && rawText.toLowerCase().contains('cnf')) {
      status = 'CNF';
    }

    var fare = 0.0;

    for (final pattern in [
      r'(?:Fare|Amount)[:\-\s]*([0-9]+\.[0-9]{2})',
      r'(?:Fare|Amount)[:\-\s]*([0-9]+)',
      r'(?:Rs\.?|₹)\s*([0-9]+(?:\.[0-9]+)?)',
    ]) {
      final v = extract(pattern);
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

    final irctcModel = IRCTCTicket(
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

    return Ticket.fromIRCTC(irctcModel, isUpdate: isUpdate);
  }
}
