import 'package:meta/meta.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';
import 'package:namma_wallet/src/features/travel/application/travel_pdf_parser.dart';

/// TNSTC parser using layout-based extraction (geometry + OCR blocks).
///
/// This approach uses spatial relationships to map keys to values.
/// For plain text inputs, pseudo-blocks are created to reuse this logic.
///
/// Usage:
/// ```dart
/// final parser = TNSTCLayoutParser(logger: logger);
/// final ticket = parser.parseTicketFromBlocks(ocrBlocks);
/// ```
class TNSTCLayoutParser extends TravelPDFParser {
  TNSTCLayoutParser({required super.logger});

  /// Parses TNSTC ticket from OCR blocks (with geometry).
  Ticket parseTicketFromBlocks(List<OCRBlock> blocks) {
    final extractor = LayoutExtractor(blocks);

    // Extract fields using layout analysis
    final pnrRaw = extractor.findValueForKey('PNR Number');
    final pnrNumber = pnrRaw
        ?.replaceAll(RegExp(r'\s'), '') // Remove whitespace
        .replaceAll('o', '0') // Fix OCR o → 0
        .toUpperCase();

    final journeyDateStr = extractor.findValueForKey('Date of Journey');
    final journeyDate = parseDate(journeyDateStr);

    final routeNo = nullIfEmpty(extractor.findValueForKey('Route No'));

    final serviceStartPlace = nullIfEmpty(
      extractor.findValueForKey('Service Start Place'),
    );

    final serviceEndPlace = nullIfEmpty(
      extractor.findValueForKey('Service End Place'),
    );

    final serviceStartTimeRaw = extractor.findValueForKey('Service Start Time');
    final serviceStartTime = _formatTime(serviceStartTimeRaw);

    final passengerStartPlace = nullIfEmpty(
      extractor.findValueForKey('Passenger Start Place'),
    );

    final passengerEndPlace = nullIfEmpty(
      extractor.findValueForKey('Passenger End Place'),
    );

    final passengerPickupPoint = nullIfEmpty(
      extractor.findValueForKey('Passenger Pickup Point'),
    );

    final passengerPickupTimeStr = extractor.findValueForKey(
      'Passenger Pickup Time',
    );
    final passengerPickupTime = parseDateTime(passengerPickupTimeStr);

    final platformNumber = nullIfEmpty(
      extractor.findValueForKey('Platform Number'),
    );

    final classOfService = nullIfEmpty(
      extractor.findValueForKey('Class of Service'),
    );

    final tripCode = nullIfEmpty(extractor.findValueForKey('Trip Code'));

    final obReferenceNumber = nullIfEmpty(
      extractor.findValueForKey('OB Reference No'),
    );

    final numberOfSeatsStr = extractor.findValueForKey('No. of Seats');
    final numberOfSeats = numberOfSeatsStr != null
        ? int.tryParse(numberOfSeatsStr)
        : null;

    final busIdNumber = nullIfEmpty(extractor.findValueForKey('Bus ID No'));

    final passengerCategory = nullIfEmpty(
      extractor.findValueForKey('Passenger Category'),
    );

    final totalFareStr = extractor.findValueForKey('Total Fare');
    final totalFare = totalFareStr != null
        ? double.tryParse(
            // Remove currency symbols and text,
            // keep only digits and decimal point
            totalFareStr
                .replaceAll(RegExp(r'[^\d.]'), '')
                .replaceAll(RegExp(r'\.+$'), ''), // Remove trailing dots
          )
        : null;

    // Extract passenger info from table section
    final passengers = _extractPassengers(extractor);

    // Use actual passenger count if available,
    // otherwise use numberOfSeats field
    final actualSeatCount = passengers.isNotEmpty
        ? passengers.length
        : numberOfSeats;

    // Corporation with fallback - clean and extract just the corp name
    var corporation = nullIfEmpty(extractor.findValueForKey('Corporation'));

    // Clean corporation value if it contains extra text
    if (corporation != null) {
      // Remove common prefixes and extract just the corporation name
      corporation = corporation
          .replaceAll(RegExp(r'\(.*?\)', multiLine: true), '') // Remove (...)
          .replaceAll(
            RegExp('A GOVERNMENT OF.*?UNDERTAKING', caseSensitive: false),
            '',
          )
          .replaceAll(RegExp(r'[-\s]+$'), '') // Remove trailing dashes/spaces
          .trim();

      // If nothing meaningful left, set to null to trigger fallback
      if (corporation.isEmpty || corporation.length > 20) {
        corporation = null;
      }
    }

    // Fallback: detect from plain text
    if (corporation == null) {
      final plainText = extractor.toPlainText();
      if (plainText.contains('SETC')) {
        corporation = 'SETC';
      } else if (plainText.contains('TNSTC')) {
        corporation = 'TNSTC';
      }
    }

    // Set boarding point with fallback chain
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
      numberOfSeats: actualSeatCount,
      busIdNumber: busIdNumber,
      passengerCategory: passengerCategory,
      passengers: passengers,
      totalFare: totalFare,
      boardingPoint: boardingPoint,
    );

    return Ticket.fromTNSTC(tnstcModel);
  }

  /// Extracts passenger information from table section.
  ///
  /// Looks for blocks between "Name" header and "Total Fare" section,
  /// then uses column alignment to parse rows.
  List<PassengerInfo> _extractPassengers(LayoutExtractor extractor) {
    final passengers = <PassengerInfo>[];

    // Try table-based extraction first
    final tableBlocks = extractor.extractTableSection(
      startPattern: 'Name',
      endPattern: 'Total Fare',
    );

    if (tableBlocks.isEmpty) return passengers;

    // Calculate dynamic Y-tolerance based on average block height.
    // This makes grouping resilient to different PDF resolutions.
    final avgHeight =
        tableBlocks.map((b) => b.boundingBox.height).reduce((a, b) => a + b) /
        tableBlocks.length;
    final rowTolerance = avgHeight > 0 ? avgHeight * 0.5 : 10.0;

    // Group blocks by row (blocks with similar Y coordinates)
    final rows = <List<OCRBlock>>[];
    for (final block in tableBlocks) {
      // Find existing row with similar Y coordinate
      List<OCRBlock>? targetRow;
      for (final row in rows) {
        if ((row.first.centerY - block.centerY).abs() < rowTolerance) {
          targetRow = row;
          break;
        }
      }

      if (targetRow == null) {
        rows.add([block]);
      } else {
        targetRow.add(block);
      }
    }

    // Parse each row as a passenger
    for (final row in rows) {
      // Sort blocks in row by X coordinate (left to right)
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));

      // Skip header rows
      if (row.any(
        (b) =>
            b.text.toLowerCase().contains('age') ||
            b.text.toLowerCase().contains('gender'),
      )) {
        continue;
      }

      // Expected columns: Name, Age, Adult/Child, Gender, Seat No
      if (row.length < 3) continue; // Not enough data

      final name = row[0].text.trim();
      final age = row.length > 1 ? int.tryParse(row[1].text.trim()) : null;
      final type = row.length > 2 ? nullIfEmpty(row[2].text.trim()) : null;
      final gender = row.length > 3 ? nullIfEmpty(row[3].text.trim()) : null;
      final seatNumber = row.length > 4
          ? nullIfEmpty(row[4].text.trim())
          : null;

      if (name.isNotEmpty) {
        passengers.add(
          PassengerInfo(
            name: name,
            age: age,
            type: type,
            gender: gender,
            seatNumber: seatNumber,
          ),
        );
      }
    }

    return passengers;
  }

  @visibleForTesting
  String? formatTimeForTesting(String? timeStr) => _formatTime(timeStr);

  /// Converts 24-hour time format to 12-hour format with AM/PM.
  /// Examples: "13:15" → "01:15 PM", "09:30" → "09:30 AM"
  String? _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;

    // Try to parse time in HH:MM format (24-hour)
    // Using ^ and $ to ensure the entire string matches the time format.
    final timePattern = RegExp(r'^(\d{1,2}):(\d{2})$');
    final match = timePattern.firstMatch(timeStr.trim());

    if (match == null) return null;

    final hourStr = match.group(1);
    final minuteStr = match.group(2);

    if (hourStr == null || minuteStr == null) return null;

    final hour = int.tryParse(hourStr);
    if (hour == null || hour < 0 || hour > 23) return null;

    // minuteStr should be numeric and two digits per regex
    final minute = int.tryParse(minuteStr);
    if (minute == null || minute < 0 || minute > 59) return null;

    // Convert to 12-hour format
    String period;
    int displayHour;

    if (hour == 0) {
      displayHour = 12;
      period = 'AM';
    } else if (hour < 12) {
      displayHour = hour;
      period = 'AM';
    } else if (hour == 12) {
      displayHour = 12;
      period = 'PM';
    } else {
      displayHour = hour - 12;
      period = 'PM';
    }

    return '${displayHour.toString().padLeft(2, '0')}:$minuteStr $period';
  }

  /// Helper to convert empty strings to null
  String? nullIfEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  @override
  Ticket parseTicket(String pdfText) {
    // Convert plain text to pseudo-blocks for layout parsing.
    // This allows us to reuse the same parsing logic for both PDF and text.
    final pseudoBlocks = OCRBlock.fromPlainText(pdfText);
    return parseTicketFromBlocks(pseudoBlocks);
  }
}
