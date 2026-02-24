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

  /// Maximum length for a corporation name to be considered valid.
  ///
  /// This helps filter out OCR noise or misread headers that aren't actually
  /// corporation names (e.g., long legal disclaimers).
  /// Future improvements could use a lookup of known names or regex validation.
  static const int corporationMaxLength = 20;

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
      extractor.findValueForKey('Platform Number', searchAbove: false),
    );

    final classOfService = nullIfEmpty(
      extractor.findValueForKey('Class of Service'),
    );

    final tripCode = nullIfEmpty(extractor.findValueForKey('Trip Code'));

    final obReferenceNumber = nullIfEmpty(
      extractor.findValueForKey('OB Reference No'),
    );

    // Try multiple variations of the seat count key
    final numberOfSeatsStr =
        extractor.findValueForKey('No. of Seats') ??
        extractor.findValueForKey('Number of Seats') ??
        extractor.findValueForKey('Seats');

    final numberOfSeats = numberOfSeatsStr != null
        ? int.tryParse(
            RegExp(r'\d+').firstMatch(numberOfSeatsStr)?.group(0) ?? '',
          )
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
    final passengers = _extractPassengers(
      extractor,
      expectedCount: numberOfSeats,
    );

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

      // If nothing meaningful left or exceeds max length,
      // set to null to trigger fallback
      if (corporation.isEmpty || corporation.length > corporationMaxLength) {
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

  /// Corrects common OCR errors in seat numbers.
  ///
  /// Common patterns:
  /// - "120B" → "12UB" (0 misread as U)
  /// - "10LB" → "1OLB" → "10LB" (O misread as 0)
  String? _correctSeatNumber(String? seatNumber) {
    if (seatNumber == null || seatNumber.isEmpty) return seatNumber;

    var corrected = seatNumber;

    // Pattern: digits followed by "0B" → should be "UB"
    // Examples: "120B" → "12UB", "30B" → "3UB"
    if (RegExp(r'\d+0B$').hasMatch(corrected)) {
      corrected = corrected.replaceFirst(RegExp(r'0B$'), 'UB');
    }

    // Pattern: digits followed by "0L" → should be "UL"
    // Examples: "120L" → "12UL"
    if (RegExp(r'\d+0L$').hasMatch(corrected)) {
      corrected = corrected.replaceFirst(RegExp(r'0L$'), 'UL');
    }

    return corrected;
  }

  /// Extracts passenger information from table section.
  ///
  /// Looks for blocks between "Name" header and "Total Fare" section,
  /// then uses column alignment to parse rows.
  List<PassengerInfo> _extractPassengers(
    LayoutExtractor extractor, {
    int? expectedCount,
  }) {
    final passengers = <PassengerInfo>[];

    // Try table-based extraction first
    final tableBlocks = extractor.extractTableSection(
      startPattern: 'Name',
      endPattern: 'Total Fare',
    );

    if (tableBlocks.isEmpty) {
      return passengers;
    }

    // Calculate dynamic Y-tolerance based on average block height.
    // This makes grouping resilient to different PDF resolutions.
    final avgHeight =
        tableBlocks.map((b) => b.boundingBox.height).reduce((a, b) => a + b) /
        tableBlocks.length;
    final rowTolerance = avgHeight > 0 ? avgHeight * 0.8 : 12.0;

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

    // Find header row to determine column X positions
    List<OCRBlock>? headerRow;
    for (final row in rows) {
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      final hasTableHeaders = row.any(
        (b) =>
            b.text.toLowerCase().contains('age') ||
            b.text.toLowerCase().contains('gender') ||
            b.text.toLowerCase().contains('seat'),
      );
      if (hasTableHeaders) {
        headerRow = row;
        break;
      }
    }

    // Define column ranges based on header positions
    Map<String, double>? columnXPositions;
    if (headerRow != null) {
      columnXPositions = {};
      for (final headerBlock in headerRow) {
        final headerText = headerBlock.text.toLowerCase();
        if (headerText.contains('name')) {
          columnXPositions['name'] = headerBlock.boundingBox.left;
        } else if (headerText.contains('age')) {
          columnXPositions['age'] = headerBlock.boundingBox.left;
        } else if (headerText.contains('adult') ||
            headerText.contains('child')) {
          columnXPositions['type'] = headerBlock.boundingBox.left;
        } else if (headerText.contains('gender')) {
          columnXPositions['gender'] = headerBlock.boundingBox.left;
        } else if (headerText.contains('seat')) {
          columnXPositions['seat'] = headerBlock.boundingBox.left;
        }
      }
    }

    // Parse each row as a passenger
    for (final row in rows) {
      // Sort blocks in row by X coordinate (left to right)
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));

      // Skip header rows
      final hasHeaderKeyword = row.any(
        (b) =>
            b.text.toLowerCase().contains('age') ||
            b.text.toLowerCase().contains('gender') ||
            b.text.toLowerCase().contains('seat') ||
            b.text.toLowerCase().contains('name'),
      );
      if (hasHeaderKeyword) {
        continue;
      }

      if (row.length < 3) {
        continue; // Not enough data for a table row
      }

      // Use column alignment if available, otherwise fallback to index
      String? name;
      String? type;
      String? gender;
      String? seatNumber;
      int? age;

      if (columnXPositions != null && columnXPositions.isNotEmpty) {
        // Assign blocks to columns based on X position proximity
        for (final block in row) {
          final blockX = block.boundingBox.left;
          final blockText = block.text.trim();

          // Find closest column (within 100px tolerance)
          String? closestColumn;
          var minDistance = 100.0;

          for (final entry in columnXPositions.entries) {
            final distance = (blockX - entry.value).abs();
            if (distance < minDistance) {
              minDistance = distance;
              closestColumn = entry.key;
            }
          }

          // Assign to appropriate field
          switch (closestColumn) {
            case 'name':
              name = blockText;
            case 'age':
              age = int.tryParse(blockText);
            case 'type':
              type = nullIfEmpty(blockText);
            case 'gender':
              gender = nullIfEmpty(blockText);
            case 'seat':
              seatNumber = _correctSeatNumber(nullIfEmpty(blockText));
          }
        }
      } else {
        // Fallback to index-based (old behavior)
        name = row[0].text.trim();
        age = row.length > 1 ? int.tryParse(row[1].text.trim()) : null;
        type = row.length > 2 ? nullIfEmpty(row[2].text.trim()) : null;
        gender = row.length > 3 ? nullIfEmpty(row[3].text.trim()) : null;
        seatNumber = _correctSeatNumber(
          row.length > 4 ? nullIfEmpty(row[4].text.trim()) : null,
        );
      }

      // Skip rows that don't look like passenger data
      if (type != null) {
        final lowerType = type.toLowerCase();
        if (!lowerType.contains('adult') && !lowerType.contains('child')) {
          continue;
        }
      }

      if (name != null && name.isNotEmpty) {
        passengers.add(
          PassengerInfo(
            name: name,
            age: age,
            type: type,
            gender: gender,
            seatNumber: seatNumber,
          ),
        );
      } else {}
    }

    // If we already found the expected number of passengers,
    // no need for fallback
    if (expectedCount != null && passengers.length >= expectedCount) {
      return passengers;
    }

    // Vertical list fallback: If we couldn't find multi-column rows,
    // or if we found fewer passengers than expected.
    if (tableBlocks.isNotEmpty &&
        (passengers.isEmpty ||
            (expectedCount != null && passengers.length < expectedCount))) {
      final verticalPassengers = <PassengerInfo>[];

      // Filter out labels and headers
      final dataBlocks = tableBlocks.where((b) {
        final text = b.text.toLowerCase().replaceAll(':', '').trim();
        // Only exclude the exact header labels
        final isHeader =
            text == 'name' ||
            text == 'age' ||
            text == 'adult/child' ||
            text == 'gender' ||
            text == 'seat no.' ||
            text == 'seat no' ||
            text == 'passenger information';
        return !isHeader;
      }).toList();

      // Look for "Adult" or "Child" markers as anchors
      for (var i = 0; i < dataBlocks.length; i++) {
        final text = dataBlocks[i].text.toLowerCase().trim();
        if (text == 'adult' || text == 'child') {
          // Found 'type' field at index i.
          // In a vertical list: i-2=Name, i-1=Age, i=Type, i+1=Gender, i+2=Seat
          final name = i >= 2 ? dataBlocks[i - 2].text.trim() : '';
          final age = i >= 1
              ? int.tryParse(dataBlocks[i - 1].text.trim())
              : null;
          final type = dataBlocks[i].text.trim();
          final gender = i + 1 < dataBlocks.length
              ? nullIfEmpty(dataBlocks[i + 1].text.trim())
              : null;
          final seatNumber = _correctSeatNumber(
            i + 2 < dataBlocks.length
                ? nullIfEmpty(dataBlocks[i + 2].text.trim())
                : null,
          );

          if (name.isNotEmpty) {
            verticalPassengers.add(
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
      }

      // If vertical layout found more passengers, or if table layout failed
      // to find all expected passengers but vertical did (or found more),
      // use it.
      if (verticalPassengers.length > passengers.length) {
        passengers
          ..clear()
          ..addAll(verticalPassengers);
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

    // Strip trailing 'Hrs', 'Hrs.' and period suffixes from OCR artifacts
    final cleaned = timeStr
        .trim()
        .replaceAll(RegExp(r'\s*Hrs\.?\s*$', caseSensitive: false), '')
        .trim();

    // Try to parse time in HH:MM format (24-hour)
    // Using ^ and $ to ensure the entire string matches the time format.
    final timePattern = RegExp(r'^(\d{1,2}):(\d{2})$');
    final match = timePattern.firstMatch(cleaned);

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
