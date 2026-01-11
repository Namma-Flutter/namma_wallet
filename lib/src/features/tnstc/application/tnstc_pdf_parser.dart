import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';
import 'package:namma_wallet/src/features/travel/application/travel_pdf_parser.dart';

/// Parses TNSTC (Tamil Nadu State Transport Corporation) PDF tickets
/// into structured ticket data.
///
/// This parser handles both table-formatted and loose-text formats
/// that may appear in TNSTC e-tickets. It uses regex patterns to
/// extract fields like PNR, journey dates, passenger info, etc.
///
/// Falls back to default values if parsing fails for individual fields.
/// Never throws - returns a model with partial data on errors.
class TNSTCPDFParser extends TravelPDFParser {
  TNSTCPDFParser({required super.logger});

  /// Parses the given PDF text and returns a [Ticket].
  @override
  Ticket parseTicket(String pdfText) {
    final passengers = <PassengerInfo>[];

    // Extract all fields using PDF-specific patterns
    // Use non-greedy matching and stop at newlines
    final corporation = extractMatch(
      r'Corporation\s*:\s*([A-Za-z\s-]+?)(?:\n|$)',
      pdfText,
    );
    // PNR may have invisible characters/whitespace from PDF extraction
    // First extract raw PNR (stop at newline), then clean it
    final pnrRaw = extractMatch(
      r'PNR Number\s*:\s*([A-Za-z0-9](?:[A-Za-z0-9\s]*[A-Za-z0-9])?)(?:\n|$)',
      pdfText,
    );
    // Remove whitespace and fix OCR errors
    // (o -> 0, since PNRs only have digits+uppercase)
    final pnrNumber = pnrRaw
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll('o', '0') // OCR sometimes reads 0 as o
        .toUpperCase();
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
    // OCR may read columns out of order, causing pickup point to be split:
    // "Passenger Pickup Point : OFFICE)" followed by
    // "KOTTIVAKKAM(RTO" on next line
    // Use dotAll flag to capture across newlines, and manually extract
    final pickupRegex = RegExp(
      r'Passenger Pickup Point\s*:\s*(.*?)(?:\n(.+?))?(?=\nPlatform Number|\nPassenger Pickup Time|\nTrip Code|$)',
      dotAll: true,
    );
    final pickupMatch = pickupRegex.firstMatch(pdfText);
    var passengerPickupPoint = '';
    if (pickupMatch != null) {
      final part1 = pickupMatch.group(1)?.trim() ?? '';
      final part2 = pickupMatch.group(2)?.trim() ?? '';

      // Combine parts and check if they need reordering
      // e.g., part1="OFFICE)",
      // part2="KOTTIVAKKAM(RTO" -> "KOTTIVAKKAM(RTO OFFICE)"
      if (part1.isNotEmpty && part2.isNotEmpty) {
        // Check if parts are reversed (part1 ends with ), part2 has opening ()
        if (part1.endsWith(')') &&
            part2.contains('(') &&
            !part2.contains(')')) {
          passengerPickupPoint = '$part2 $part1';
        } else {
          passengerPickupPoint = '$part1 $part2';
        }
      } else {
        passengerPickupPoint = part1.isNotEmpty ? part1 : part2;
      }
    }
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
    // Trip code may be on a different line due to OCR column ordering
    // First try direct extraction, then look for pattern like 2100KUMCHELB or 2200CHEKUMLB
    var tripCode = extractMatch(r'Trip Code\s*:\s*([0-9]+[A-Z]+)', pdfText);
    if (tripCode.isEmpty) {
      // Look for trip code pattern anywhere in the text (4 digits followed by uppercased letters)
      final tripCodeMatch = RegExp(r'\b(\d{4}[A-Z]{4,})\b').firstMatch(pdfText);
      if (tripCodeMatch != null) {
        tripCode = tripCodeMatch.group(1) ?? '';
      }
    }
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
    // NOTE: Current implementation extracts only the first passenger.
    // TODO(enhancement): Use allMatches() to extract all passengers when
    // multiple passenger rows are detected in the table format.
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
      // OCR often puts "Name" on one line and actual name on next line
      // Try to get the line after "Name" header (not after "Passenger Information")
      var nameMatch = RegExp(
        r'^Name\s*$\n\s*([A-Za-z][^\n]+)',
        multiLine: true,
      ).firstMatch(pdfText);
      if (nameMatch != null) {
        passengerName = nameMatch.group(1)?.trim() ?? '';
      } else {
        // Secondary fallback: line after Passenger Information
        nameMatch = RegExp(
          r'Passenger Information\s*\n\s*Name\s*\n\s*([^\n]+)',
          multiLine: true,
        ).firstMatch(pdfText);
        if (nameMatch != null) {
          passengerName = nameMatch.group(1)?.trim() ?? '';
        }
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
      r'ID Card Type\s*:\s*(.+?)(?:\n|$)',
      pdfText,
    );

    // Fallback if precise regex fails
    if (idCardType.isEmpty) {
      if (pdfText.contains('Government Issued Photo')) {
        idCardType = 'Government Issued Photo ID Card';
      } else {
        // Try looser match - explicitly handle optional colon and whitespace
        idCardType = extractMatch(r'ID Card Type\s*:?\s*(.*)', pdfText).trim();
      }
    }

    // Always apply cleanup if 'rD Card' is present
    if (idCardType.contains('rD Card')) {
      idCardType = idCardType.replaceAll('rD Card', 'ID Card');
    }

    // Remove any leading colon or punctuation that might remain
    idCardType = idCardType.replaceFirst(RegExp(r'^[:;\s]+'), '').trim();

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

    // Set boarding point with fallback chain:
    // passengerPickupPoint > passengerStartPlace > null
    final boardingPoint = passengerPickupPoint.isNotEmpty
        ? passengerPickupPoint
        : (passengerStartPlace.isNotEmpty ? passengerStartPlace : null);

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
