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

    // Helper to convert empty strings to null for nullable model fields
    String? nullIfEmpty(String value) => value.isNotEmpty ? value : null;

    // Helper to parse fields that might be on same line or next line,
    //skipping punctuation
    String parseField(
      String labelPattern, {
      String? valuePattern,
      bool skipBulleted = false,
    }) {
      final pattern = valuePattern ?? r'([^\n]+)';
      // Try same line first
      final matches = RegExp(
        '$labelPattern\\s*[:\\.]?\\s*$pattern',
        multiLine: true,
        caseSensitive: false,
      ).allMatches(pdfText);

      for (final match in matches) {
        final val = match.group(1)?.trim() ?? '';
        if (val == '.' || val.isEmpty) continue;
        if (skipBulleted && val.startsWith('•')) continue;
        if (skipBulleted && val.toLowerCase().contains('time is in')) continue;
        return val;
      }

      // Try next line ONLY if same line returned nothing
      final nextLineMatches = RegExp(
        '$labelPattern\\s*[:\\.]?\\s*\\n\\s*$pattern',
        multiLine: true,
        caseSensitive: false,
      ).allMatches(pdfText);

      for (final match in nextLineMatches) {
        final val = match.group(1)?.trim() ?? '';
        if (val == '.' || val.isEmpty) continue;
        if (val.toLowerCase() == 'ltd') continue; // Skip header noise
        if (skipBulleted && val.startsWith('•')) continue;
        if (skipBulleted && val.toLowerCase().contains('time is in')) continue;
        return val;
      }

      return '';
    }

    // Extract Corporation - can be on same line or next line
    var corporationRaw = extractMatch(
      r'(?:^|\n)Corporation\s*:\s*([A-Za-z\s-]+)(?:\n|$)',
      pdfText,
    );
    if (corporationRaw.isEmpty || corporationRaw == '.') {
      corporationRaw = extractMatch(
        r'(?:^|\n)Corporation\s*:\s*\n\s*([A-Za-z\s-]+)(?:\n|$)',
        pdfText,
      );
    }
    var corporation = nullIfEmpty(corporationRaw.trim());

    // Fallback detection if standard format is missing
    if (corporation == null || corporation.isEmpty) {
      if (pdfText.contains('SETC')) {
        corporation = 'SETC';
      } else if (pdfText.contains('TNSTC')) {
        corporation = 'TNSTC';
      }
    }
    // PNR may have invisible characters/whitespace from PDF extraction
    // First extract raw PNR (stop at newline), then clean it
    final pnrRaw = extractMatch(
      r'PNR Number\s*:\s*([A-Za-z0-9](?:[A-Za-z0-9\s]*[A-Za-z0-9])?)(?:\n|$)',
      pdfText,
    );
    // Remove whitespace and fix OCR errors
    // (o -> 0, since PNRs only have digits+uppercase)
    final pnrNumber = pnrRaw.isNotEmpty
        ? pnrRaw
              .replaceAll(RegExp(r'\s'), '')
              .replaceAll('o', '0') // OCR sometimes reads 0 as o
              .toUpperCase()
        : null;
    final journeyDate = parseDate(
      extractMatch(r'Date of Journey\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4})', pdfText),
    );
    final routeNo = nullIfEmpty(
      extractMatch(r'Route No\s*:\s*(\S+)', pdfText),
    );
    final serviceStartPlace = nullIfEmpty(
      extractMatch(
        r'Service Start Place\s*:\s*([A-Za-z0-9\s.,()-]+?)(?:\n|$)',
        pdfText,
      ),
    );
    final serviceEndPlace = nullIfEmpty(
      extractMatch(
        r'Service End Place\s*:\s*([A-Za-z0-9\s.,()-]+?)(?:\n|$)',
        pdfText,
      ),
    );
    final serviceStartTime = nullIfEmpty(
      extractMatch(
        r'Service Start Time\s*:\s*(\d{1,2}:\d{2})(?:\s*Hrs\.?)?',
        pdfText,
      ),
    );
    final passengerStartPlace = nullIfEmpty(
      extractMatch(
        r'Passenger Start Place\s*:\s*([A-Za-z0-9\s.,()-]+?)(?:\n|$)',
        pdfText,
      ),
    );
    final passengerEndPlace = nullIfEmpty(
      extractMatch(
        r'Passenger End Place\s*:\s*([A-Za-z0-9\s.,()-]+?)(?:\n|$)',
        pdfText,
      ),
    );
    // OCR may read columns out of order, causing pickup point to be split:
    // "Passenger Pickup Point : OFFICE)" followed by
    // "KOTTIVAKKAM(RTO" on next line
    // Use line-based matching instead of dotAll to avoid consuming
    //subsequent fields
    final pickupRegex = RegExp(
      r'Passenger Pickup Point\s*:\s*([^\n\r]*?)(?=\s*(?:Platform Number|Passenger Pickup Time|Trip Code|Passenger End Place|Service Start Time)|\n|$)(?:\s*\n([^\n]*))?',
    );
    final pickupMatch = pickupRegex.firstMatch(pdfText);
    String? passengerPickupPoint;
    if (pickupMatch != null) {
      var part1 = pickupMatch.group(1)?.trim() ?? '';
      var part2 = pickupMatch.group(2)?.trim() ?? '';

      // Helper to check if a string looks like a field label
      bool isFieldLabel(String s) {
        return s.startsWith('Platform Number') ||
            s.startsWith('Passenger Pickup Time') ||
            s.startsWith('Trip Code') ||
            s.startsWith('Passenger End Place') ||
            s.startsWith('Service Start Time');
      }

      if (isFieldLabel(part1)) part1 = '';
      if (isFieldLabel(part2)) part2 = '';

      logger.debug(
        '[TNSTCPDFParser] Pickup point parts: '
        'part1="$part1", part2="$part2"',
      );

      // Combine parts and check if they need reordering
      // e.g., part1="OFFICE)",
      // part2="KOTTIVAKKAM(RTO" -> "KOTTIVAKKAM(RTO OFFICE)"
      if (part1.isNotEmpty && part2.isNotEmpty) {
        // Check if parts are reversed (part1 ends with ), part2 has opening ())
        if (part1.endsWith(')') &&
            part2.contains('(') &&
            !part2.contains(')')) {
          passengerPickupPoint = '$part2 $part1';
        } else {
          passengerPickupPoint = '$part1 $part2';
        }
      } else if (part1.isNotEmpty) {
        passengerPickupPoint = part1;
      } else if (part2.isNotEmpty) {
        passengerPickupPoint = part2;
      }
      // If both parts are empty, passengerPickupPoint remains null
    }
    final passengerPickupTime = parseDateTime(
      extractMatch(
        r'Passenger Pickup Time\s*:\s*(\d{2}[/-]\d{2}[/-]\d{4}\s+\d{2}:\d{2}(?:\s*Hrs\.?)?)',
        pdfText,
      ),
    );
    final platformNumber = nullIfEmpty(
      extractMatch(
        r'Platform Number\s*[:\.]?\s*([^\n\r]*?)(?=\s*(?:Class of Service|Trip Code|PNR Number|Date of Journey|Route No|Service End Place)|\n|$)',
        pdfText,
      ),
    );
    final classOfService = nullIfEmpty(
      parseField(
        r'Class\s+of\s+Service',
        valuePattern: r'([^\n]+)',
        skipBulleted: true,
      ),
    );
    // Trip code may be on a different line due to OCR column ordering
    // First try direct extraction, then look for pattern like
    // 2100KUMCHELB or 2200CHEKUMLB or 2110BANTIDVVO1L
    // Must start with digits to avoid capturing labels like "No."
    var tripCodeRaw = extractMatch(r'Trip Code\s*:\s*(\d+[A-Z0-9]+)', pdfText);
    if (tripCodeRaw.isEmpty) {
      // Look for trip code pattern anywhere in the text (4 digits followed
      // by alphanumeric)
      final tripCodeMatch = RegExp(
        r'\b(\d{4}[A-Z0-9]{4,})\b',
      ).firstMatch(pdfText);
      if (tripCodeMatch != null) {
        tripCodeRaw = tripCodeMatch.group(1) ?? '';
      }
    }
    final tripCode = nullIfEmpty(tripCodeRaw);
    final obReferenceNumber = nullIfEmpty(
      extractMatch(
        r'OB Reference No\.\s*:\s*([A-Z0-9 ]+)(?:\n|$)',
        pdfText,
      ),
    );

    // Safe parsing for numbers
    final numberOfSeatsStr = extractMatch(
      r'No\. of Seats\s*:\s*(\d+)',
      pdfText,
    );
    final numberOfSeats = numberOfSeatsStr.isNotEmpty
        ? int.tryParse(numberOfSeatsStr) ?? 1
        : 1;

    var busIdNumber = extractMatch(
      r'Bus ID No\.\s*:\s*([A-Z0-9-]+)',
      pdfText,
    );
    // Hard check to prevent capturing "Passenger" if OCR jumps to next section
    if (busIdNumber.toLowerCase().contains('passenger')) {
      busIdNumber = '';
    }

    if (busIdNumber.isEmpty) {
      // Fallback: Look for pattern like E-1234, V-3630 (Letter-Numbers)
      final busIdMatch = RegExp(r'\b([A-Z]+-\d{4,})\b').firstMatch(pdfText);
      if (busIdMatch != null) {
        busIdNumber = busIdMatch.group(1) ?? '';
      }
    }
    // Final null check
    final busIdNumberClean = nullIfEmpty(busIdNumber);
    final passengerCategory = nullIfEmpty(
      extractMatch(
        r'Passenger [Cc]ategory\s*:\s*([A-Za-z\s]+?)(?:\n|$)',
        pdfText,
      ),
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
      // OCR often puts "Name" on one line and actual name on next line(s)
      // Capture until we see "Age" or "Passenger category" or end of section
      var nameSectionMatch = RegExp(
        r'Name\s*\n\s*([\s\S]+?)(?=\n\s*(?:Age|Passenger|Children|Total Fare|PNR Number|Route No|SATELLITE|BS\b|Bus Stand|Terminus|Terminal|Office|ID Card Type|ID Card Number))',
        multiLine: true,
      ).firstMatch(pdfText);

      // If strict match fails, try broader match after Passenger Information
      nameSectionMatch ??= RegExp(
        r'Passenger Information\s*\n\s*(?:Name\s*\n\s*)?([\s\S]+?)(?=\n\s*(?:Age|Passenger|Children|Total Fare|PNR Number|Route No|SATELLITE|BS\b|Bus Stand|Terminus|Terminal|Office|ID Card Type|ID Card Number))',
        multiLine: true,
      ).firstMatch(pdfText);

      if (nameSectionMatch != null) {
        final nameBlock = nameSectionMatch.group(1) ?? '';
        // Split by newline and clean up
        final names = nameBlock.split('\n').map((s) => s.trim()).where((s) {
          if (s.isEmpty) return false;
          if (s.toLowerCase().contains('name')) return false;

          // Filter out lines that look like locations (Bus Stand, etc)
          final lower = s.toLowerCase();
          if (lower.endsWith(' bs')) return false;
          if (lower == 'bs') return false;
          if (lower.contains('bus stand')) return false;
          if (lower.contains('satellite')) return false;
          if (lower.contains('terminus')) return false;
          if (lower.contains('terminal')) return false;
          if (lower.contains('office')) return false;
          if (lower.contains('id card type')) return false;
          if (lower.contains('id card number')) return false;

          return true;
        }).toList();

        // Temporarily store joined names if we are in single-passenger
        //fallback mode
        // But ideally we should create multiple PassengerInfo objects if valid
        // For now, let's just join them so at least they appear in the
        //Ticket model
        passengerName = names.join(', ');
      }

      final ageMatch = RegExp(
        r'Age\s*\n\s*(?:(?:\(\d+\)|\d+\.|•)\s*)?(\d+)',
        multiLine: true,
      ).firstMatch(pdfText);
      if (ageMatch != null) {
        passengerAge = int.tryParse(ageMatch.group(1) ?? '0') ?? 0;
      }

      final genderMatch = RegExp(
        r'Gender\s*\n\s*(?:(?:\(\d+\)|\d+\.?|•)\s*)?([MF])',
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
        // Match seat numbers separated by comma OR newline
        // Ensure subsequent lines don't start with keywords like Age, Gender,
        // Important, etc.
        r'^Seat\s*[:\.]?\s*No\.?\s*(?:[:\-]?\s*)?(?:\n\s*)?([A-Z0-9]+(?:(?:\s*,\s*|\s*\n\s*(?!Age|Gender|Total|Government|ID|Class|Important|Name)(?=[A-Z0-9]))[A-Z0-9]+)*)',
        multiLine: true,
        caseSensitive: false,
      ).firstMatch(pdfText);
      if (seatInlineMatch != null) {
        passengerSeatNumber = (seatInlineMatch.group(1) ?? '')
            .replaceAll('\n', ', ')
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(', ,', ',')
            .replaceAll(RegExp(r',\s*,'), ',');
        // Final trim and ensure single spaces after commas
        passengerSeatNumber = passengerSeatNumber
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .join(', ');
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
    final boardingPoint = (passengerPickupPoint?.isNotEmpty ?? false)
        ? passengerPickupPoint
        : ((passengerStartPlace?.isNotEmpty ?? false)
              ? passengerStartPlace
              : null);

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
      busIdNumber: busIdNumberClean,
      passengerCategory: passengerCategory,
      passengers: passengers,
      totalFare: totalFare,
      boardingPoint: boardingPoint,
    );

    // Convert TNSTCTicketModel to Ticket using the factory method
    return Ticket.fromTNSTC(tnstcModel);
  }
}
