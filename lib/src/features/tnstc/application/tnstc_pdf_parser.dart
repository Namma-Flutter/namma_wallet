import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

/// Parses TNSTC (Tamil Nadu State Transport Corporation) PDF tickets
/// into structured ticket data.
///
/// This parser handles both table-formatted and loose-text formats
/// that may appear in TNSTC e-tickets. It uses regex patterns to
/// extract fields like PNR, journey dates, passenger info, etc.
///
/// Falls back to default values if parsing fails for individual fields.
/// Never throws - returns a model with partial data on errors.
class TNSTCPDFParser implements ITicketParser {
  TNSTCPDFParser({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;
  // TODO(optimization): Move RegExp compilation to static final fields
  // to avoid recompiling patterns on each parse call, improving performance.

  /// Parses the given PDF text and returns a [Ticket].
  @override
  Ticket parseTicket(String pdfText) {
    final passengers = <PassengerInfo>[];
    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true);
      final match = regex.firstMatch(input);

      if (match != null && groupIndex <= match.groupCount) {
        // Safely extract the matched group, or return empty string if null
        return match.group(groupIndex)?.trim() ?? '';
      }
      // Return empty string if the match or group is invalid
      return '';
    }

    DateTime parseDate(String date) {
      if (date.isEmpty) return DateTime.now();

      // Handle both '-' and '/' separators
      final parts = date.contains('/') ? date.split('/') : date.split('-');
      if (parts.length != 3) {
        _logger.warning(
          'Invalid date format encountered in TNSTC PDF',
        );
        return DateTime.now();
      }

      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } on FormatException catch (e) {
        _logger.warning('Failed to parse date in TNSTC PDF: $e');
        return DateTime.now();
      }
    }

    DateTime parseDateTime(String dateTime) {
      if (dateTime.isEmpty) return DateTime.now();

      final parts = dateTime.split(' '); // Split into date and time
      if (parts.length < 2) {
        _logger.warning('Invalid datetime format encountered in TNSTC PDF');
        return DateTime.now();
      }

      try {
        // Handle both '-' and '/' separators for date
        final dateParts = parts[0].contains('/')
            ? parts[0].split('/')
            : parts[0].split('-');
        if (dateParts.length != 3) {
          _logger.warning('Invalid date part in TNSTC datetime');
          return DateTime.now();
        }

        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        // Extract time part (might have "Hrs." suffix)
        final timePart = parts[1].replaceAll(RegExp(r'\s*Hrs\.?'), '');
        final timeParts = timePart.split(':'); // Split the time by ':'
        if (timeParts.length != 2) {
          _logger.warning('Invalid time part in TNSTC datetime');
          return DateTime.now();
        }

        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        return DateTime(year, month, day, hour, minute);
      } on FormatException catch (e) {
        _logger.warning('Failed to parse datetime in TNSTC PDF: $e');
        return DateTime.now();
      }
    }

    // Extract all fields using PDF-specific patterns
    // Use non-greedy matching and stop at newlines
    final corporation = extractMatch(
      r'Corporation\s*:\s*([A-Za-z\s-]+?)(?:\n|$)',
      pdfText,
    );
    final pnrNumber = extractMatch(
      r'PNR Number\s*:\s*([A-Z0-9]+)',
      pdfText,
    );
    final journeyDate = parseDate(
      extractMatch(r'Date of Journey\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', pdfText),
    );
    final routeNo = extractMatch(r'Route No\s*:\s*(\S+)', pdfText);
    final serviceStartPlace = extractMatch(
      r'Service Start Place\s*:\s*([A-Za-z0-9\s.,()\-]+?)(?:\n|$)',
      pdfText,
    );
    final serviceEndPlace = extractMatch(
      r'Service End Place\s*:\s*([A-Za-z0-9\s.,()\-]+?)(?:\n|$)',
      pdfText,
    );
    final serviceStartTime = extractMatch(
      r'Service Start Time\s*:\s*(\d{1,2}:\d{2})(?:\s*Hrs\.?)?',
      pdfText,
    );
    final passengerStartPlace = extractMatch(
      r'Passenger Start Place\s*:\s*([A-Za-z0-9\s.,()\-]+?)(?:\n|$)',
      pdfText,
    );
    final passengerEndPlace = extractMatch(
      r'Passenger End Place\s*:\s*([A-Za-z0-9\s.,()\-]+?)(?:\n|$)',
      pdfText,
    );
    final passengerPickupPoint = extractMatch(
      r'Passenger Pickup Point\s*:\s*([A-Za-z0-9\s.,()\-]+?)(?:\n|$)',
      pdfText,
    );
    final passengerPickupTime = parseDateTime(
      extractMatch(
        r'Passenger Pickup Time\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4}\s+\d{2}:\d{2}(?:\s*Hrs\.?)?)',
        pdfText,
      ),
    );
    final platformNumber = extractMatch(
      r'Platform Number\s*:[ \t]*([^\n]*?)(?:\n|$)',
      pdfText,
    );
    final classOfService = extractMatch(
      r'Class of Service\s*:\s*([A-Za-z0-9\s]+?)(?:\n|$)',
      pdfText,
    );
    final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', pdfText);
    final obReferenceNumber = extractMatch(
      r'OB Reference No\.\s*:\s*([A-Z0-9]+)',
      pdfText,
    );

    // Safe parsing for numbers
    final numberOfSeatsStr = extractMatch(
      r'No\. of Seats\s*:\s*(\d+)',
      pdfText,
    );
    final numberOfSeats = numberOfSeatsStr.isNotEmpty
        ? int.tryParse(numberOfSeatsStr) ?? 1
        : 1;

    final bankTransactionNumber = extractMatch(
      r'Bank Txn\. No[;.]?\s*:\s*([A-Z0-9]+)',
      pdfText,
    );
    final busIdNumber = extractMatch(
      r'Bus ID No\.\s*:\s*([A-Z0-9-]+)',
      pdfText,
    );
    final passengerCategory = extractMatch(
      r'Passenger [Cc]ategory\s*:\s*([A-Za-z\s]+?)(?:\n|$)',
      pdfText,
    );

    // Extract passenger info
    // First try the table format
    final passengerPattern = RegExp(
      r"Name\s+Age\s+Adult/Child\s+Gender\s+Seat No\.\s*\n\s*([A-Za-z](?:[A-Za-z\s\-'])*[A-Za-z])\s+(\d+)\s+(Adult|Child)\s+(M|F)\s+([A-Z0-9]+)",
      multiLine: true,
    );
    final passengerMatch = passengerPattern.firstMatch(pdfText);

    var passengerName = '';
    var passengerAge = 0;
    var passengerType = '';
    var passengerGender = '';
    var passengerSeatNumber = '';

    if (passengerMatch != null) {
      passengerName = passengerMatch.group(1) ?? '';
      passengerAge = int.tryParse(passengerMatch.group(2) ?? '0') ?? 0;
      passengerType = passengerMatch.group(3) ?? '';
      passengerGender = passengerMatch.group(4) ?? '';
      passengerSeatNumber = passengerMatch.group(5) ?? '';
    } else {
      // Fallback: Extract fields individually if table format is broken
      // Name is usually after "Passenger Information"
      // Support multi-word names with spaces, hyphens, and apostrophes
      final nameMatch = RegExp(
        r'Passenger Information\s*\n\s*([^\n]+)',
        multiLine: true,
      ).firstMatch(pdfText);
      if (nameMatch != null) {
        passengerName = nameMatch.group(1) ?? '';
      }

      final ageMatch = RegExp(r'Age\s*\n\s*(\d+)', multiLine: true).firstMatch(
        pdfText,
      );
      if (ageMatch != null) {
        passengerAge = int.tryParse(ageMatch.group(1) ?? '0') ?? 0;
      }

      final genderMatch = RegExp(
        r'Gender\s*\n\s*([MF])',
        multiLine: true,
      ).firstMatch(pdfText);
      if (genderMatch != null) {
        passengerGender = genderMatch.group(1) ?? '';
      }

      // Extract Adult/Child type
      final typeMatch = RegExp(
        r'Adult/Child\s*\n\s*(Adult|Child)',
        multiLine: true,
      ).firstMatch(pdfText);
      if (typeMatch != null) {
        passengerType = typeMatch.group(1) ?? '';
      }

      final seatInlineMatch = RegExp(
        r'Seat No\.?\s*(?:[:\-]?\s*)?(?:\n\s*)?([A-Z0-9]+(?:\s*,\s*[A-Z0-9]+)*)',
        multiLine: true,
      ).firstMatch(pdfText);
      if (seatInlineMatch != null) {
        passengerSeatNumber = (seatInlineMatch.group(1) ?? '').trim();
      } else {
        final genderBlockSeatMatch = RegExp(
          r'Gender\s*\n\s*[MF]\s*\n\s*([A-Z0-9]+)',
          multiLine: true,
        ).firstMatch(pdfText);
        if (genderBlockSeatMatch != null) {
          passengerSeatNumber = (genderBlockSeatMatch.group(1) ?? '').trim();
        }
      }
    }

    var idCardType = extractMatch(
      r'ID Card Type\s*:\s*([A-Za-z\s]+?)(?=\s*ID Card Number)',
      pdfText,
    );
    // Fallback for ID Card Type if the specific lookahead fails
    if (idCardType.isEmpty) {
      // Look for "Government Issued Photo" specifically as it
      // appears in the raw text
      if (pdfText.contains('Government Issued Photo')) {
        idCardType = 'Government Issued Photo ID Card';
      } else {
        // Try looser match - explicitly handle optional colon and whitespace
        idCardType = extractMatch(r'ID Card Type\s*:?\s*(.*)', pdfText).trim();
        // Clean up if it grabbed too much or garbage
        if (idCardType.contains('rD Card')) {
          idCardType = idCardType.replaceAll('rD Card', '').trim();
        }
        // Remove any leading colon or punctuation that might remain
        idCardType = idCardType.replaceFirst(RegExp(r'^[:;\s]+'), '');
      }
    }

    final idCardNumber = extractMatch(
      r'ID Card Number\s*:\s*([0-9]+)',
      pdfText,
    );

    // Safe parsing for total fare
    final totalFareStr = extractMatch(
      r'Total Fare\s*:\s*(\d+\.?\d*)\s*Rs\.',
      pdfText,
    );
    final totalFare = totalFareStr.isNotEmpty
        ? double.tryParse(totalFareStr) ?? 0.0
        : 0.0;

    if (passengerName.isNotEmpty) {
      final passengerInfo = PassengerInfo(
        name: passengerName,
        age: passengerAge,
        type: passengerType,
        gender: passengerGender,
        seatNumber: passengerSeatNumber,
      );
      passengers.add(passengerInfo);
    }

    // Set boarding point to passenger pickup point if not explicitly provided
    final boardingPoint = passengerPickupPoint.isNotEmpty
        ? passengerPickupPoint
        : null;

    final tnstcModel = TNSTCTicketModel(
      corporation: corporation,
      pnrNumber: pnrNumber,
      journeyDate: journeyDate,
      routeNo: routeNo,
      serviceStartPlace: serviceStartPlace,
      serviceEndPlace: serviceEndPlace,
      serviceStartTime: serviceStartTime,
      passengerStartPlace: passengerStartPlace,
      passengerEndPlace: passengerEndPlace,
      passengerPickupPoint: passengerPickupPoint,
      passengerPickupTime: passengerPickupTime,
      platformNumber: platformNumber,
      classOfService: classOfService,
      tripCode: tripCode,
      obReferenceNumber: obReferenceNumber,
      numberOfSeats: numberOfSeats,
      bankTransactionNumber: bankTransactionNumber,
      busIdNumber: busIdNumber,
      passengerCategory: passengerCategory,
      passengers: passengers,
      idCardType: idCardType,
      idCardNumber: idCardNumber,
      totalFare: totalFare,
      boardingPoint: boardingPoint,
    );

    // Convert TNSTCTicketModel to Ticket using the factory method
    return Ticket.fromTNSTC(tnstcModel);
  }
}
