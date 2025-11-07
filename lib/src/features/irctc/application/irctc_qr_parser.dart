import 'package:namma_wallet/src/common/services/namma_logger.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_ticket_model.dart';

class IRCTCQRParser {
  static final _logger = NammaLogger();

  static IRCTCTicket? parseQRCode(String qrData) {
    try {
      _logger.debug('Parsing IRCTC QR Data: $qrData');

      final lines = qrData.split(',').map((line) => line.trim()).toList();
      final data = <String, String>{};

      for (final line in lines) {
        final colonIndex = line.indexOf(':');
        if (colonIndex > 0) {
          final key = line.substring(0, colonIndex).trim();
          final value = line.substring(colonIndex + 1).trim();
          data[key] = value;
        }
      }

      _logger.debug('Parsed data: $data');

      return IRCTCTicket(
        pnrNumber: _extractValue(data, 'PNR No.'),
        transactionId: _extractValue(data, 'TXN ID'),
        passengerName: _extractValue(data, 'Passenger Name'),
        gender: _extractValue(data, 'Gender'),
        age: _parseInt(_extractValue(data, 'Age')),
        status: _extractValue(data, 'Status'),
        quota: _extractValue(data, 'Quota'),
        trainNumber: _extractValue(data, 'Train No.'),
        trainName: _extractValue(data, 'Train Name'),
        scheduledDeparture: _parseDateTime(
          _extractValue(data, 'Scheduled Departure'),
        ),
        dateOfJourney: _parseDate(_extractValue(data, 'Date Of Journey')),
        boardingStation: _extractValue(data, 'Boarding Station'),
        travelClass: _extractClassFromString(_extractValue(data, 'Class')),
        fromStation: _extractValue(data, 'From'),
        toStation: _extractValue(data, 'To'),
        ticketFare: _parseAmount(_extractValue(data, 'Ticket Fare')),
        irctcFee: _parseAmount(_extractValue(data, 'IRCTC C Fee')),
      );
    } on Object catch (e, stackTrace) {
      _logger
        ..error('Error parsing IRCTC QR code: $e')
        ..error('Stack trace: $stackTrace');
      return null;
    }
  }

  static String _extractValue(Map<String, String> data, String key) {
    return data[key] ?? '';
  }

  static int _parseInt(String value) {
    if (value.isEmpty) return 0;
    return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  static double _parseAmount(String value) {
    if (value.isEmpty) return 0;
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  static DateTime _parseDateTime(String value) {
    if (value.isEmpty) return DateTime.now();

    try {
      final parts = value.split(' ');
      if (parts.length >= 2) {
        final datePart = parts[0];
        final timePart = parts[1];

        final dateComponents = datePart.split('-');
        final timeComponents = timePart.split(':');

        if (dateComponents.length == 3 && timeComponents.length >= 2) {
          final day = int.parse(dateComponents[0]);
          final month = _parseMonth(dateComponents[1]);
          final year = int.parse(dateComponents[2]);
          final hour = int.parse(timeComponents[0]);
          final minute = int.parse(timeComponents[1]);

          return DateTime(year, month, day, hour, minute);
        }
      }
    } on Object catch (e) {
      _logger.error('Error parsing datetime: $value, error: $e');
    }

    return DateTime.now();
  }

  static DateTime _parseDate(String value) {
    if (value.isEmpty) return DateTime.now();

    try {
      final dateComponents = value.split('-');
      if (dateComponents.length == 3) {
        final day = int.parse(dateComponents[0]);
        final month = _parseMonth(dateComponents[1]);
        final year = int.parse(dateComponents[2]);

        return DateTime(year, month, day);
      }
    } on Object catch (e) {
      _logger.error('Error parsing date: $value, error: $e');
    }

    return DateTime.now();
  }

  static int _parseMonth(String monthStr) {
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

    return months[monthStr] ?? int.tryParse(monthStr) ?? 1;
  }

  static String _extractClassFromString(String classData) {
    if (classData.isEmpty) return '';

    final match = RegExp(r'([A-Z_]+)\s*\(([^)]+)\)').firstMatch(classData);
    if (match != null) {
      return '${match.group(1)} (${match.group(2)})';
    }

    return classData;
  }

  static bool isIRCTCQRCode(String qrData) {
    return qrData.contains('PNR No.:') ||
        qrData.contains('Train No.:') ||
        qrData.contains('IRCTC C Fee:');
  }
}
