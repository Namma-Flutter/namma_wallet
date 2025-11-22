import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';

class IRCTCPDFParser implements ITicketParser {
  IRCTCPDFParser({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  @override
  Ticket parseTicket(String rawText) {
    String pick(String pattern, {int group = 1}) {
      final m = RegExp(pattern, multiLine: true).firstMatch(rawText);
      return m == null ? '' : (m.group(group) ?? '').trim();
    }

    int pickInt(String pattern) {
      final v = pick(pattern);
      return int.tryParse(v) ?? 0;
    }

    double pickDouble(String pattern) {
      final v = pick(pattern);
      return double.tryParse(v) ?? 0.0;
    }

    DateTime parseDT({required String date, required String time}) {
      if (date.isEmpty || time.isEmpty) return DateTime.now();
      try {
        final parts = date.split('-'); // e.g. 11-Jan-2026
        final day = int.parse(parts[0]);
        final month = _monthToInt(parts[1]);
        final year = int.parse(parts[2]);

        final t = time.split(':');
        final hour = int.tryParse(t[0]) ?? 0;
        final minute = int.tryParse(t[1]) ?? 0;

        return DateTime(year, month, day, hour, minute);
      } on Exception catch (e) {
        _logger.warning('IRCTC PDF date parse failed: $e');
        return DateTime.now();
      }
    }

    // -----------------------------
    // Extract fields (from uploaded PDF format)
    // -----------------------------

    final pnr = pick(r'PNR\s+(\d{10})');
    final trainNumber = pick(r'Train No\./ Name\s*(\d{5})');
    final trainName = pick(r'Train No\./ Name\s*\d{5}\s*/\s*(.*)');

    final travelClass = pick(r'Class\s*([A-Za-z ()]+)');
    final quota = pick(r'Quota\s*([A-Za-z ()]+)');

    final fromStation = pick(r'Boarding From\s*([A-Z ()]+)');
    final toStation = pick(r'To\s*([A-Z ()]+)');

    final depTime = pick(r'Departure\*\s*(\d{2}:\d{2})');
    final depDate = pick(r'Departure\*.*?(\d{2}-[A-Za-z]{3}-\d{4})');

    // dateOfJourney = scheduledDeparture.date
    final scheduledDeparture = parseDT(date: depDate, time: depTime);

    // Passenger fields
    final passengerName = pick(r'1\.\s*([A-Z .]+)\s+\d+\s+[MF]');
    final passengerAge = pickInt(r'1\.\s*[A-Z .]+\s+(\d+)\s+[MF]');
    final passengerGender = pick(r'1\.\s*[A-Z .]+\s+\d+\s+([MF])');

    final status = pick(
      r'1\..*?\s+[MF]\s+NO FOOD\s+([A-Z0-9/ ]+)\s+[A-Z0-9/ ]+',
    );

    // Fare
    final ticketFare = pickDouble(r'Ticket Fare\s*:\s*([\d.]+)');
    final irctcFee = pickDouble(r'Convenience Fee\s*:\s*([\d.]+)');

    // -----------------------------
    // Build IRCTC ticket model
    // -----------------------------
    final model = IRCTCTicket(
      pnrNumber: pnr,
      transactionId: pick(r'Transaction Id-\((\d+)\)'),
      passengerName: passengerName,
      gender: passengerGender,
      age: passengerAge,
      status: status,
      quota: quota,
      trainNumber: trainNumber,
      trainName: trainName,
      scheduledDeparture: scheduledDeparture,
      dateOfJourney: DateTime(
        scheduledDeparture.year,
        scheduledDeparture.month,
        scheduledDeparture.day,
      ),
      boardingStation: fromStation,
      travelClass: travelClass,
      fromStation: fromStation,
      toStation: toStation,
      ticketFare: ticketFare,
      irctcFee: irctcFee,
    );

    return Ticket.fromIRCTC(model);
  }

  int _monthToInt(String m) {
    const map = {
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
    return map[m] ?? 1;
  }
}
