import 'package:namma_wallet/src/features/ticket_parser/application/tnstc_ticket_parser.dart';
import 'package:uuid/uuid.dart';

class SMSService {
  String parseTicket(String text) {
    String extractMatch(String pattern, String input, {int groupIndex = 1}) {
      final regex = RegExp(pattern, multiLine: true);
      final match = regex.firstMatch(input);
      if (match != null && groupIndex <= match.groupCount) {
        return match.group(groupIndex)?.trim() ?? '';
      }
      return '';
    }

    DateTime parseDate(String date) {
      final parts = date.split('/'); // Split the date by '/'
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day); // Construct the DateTime object
    }

    final corporation = extractMatch(r'Corporation\s*:\s*(.*)', text);
    final pnrNumber = extractMatch(r'PNR NO\.\s*:\s*(\S+)', text);
    final from = extractMatch(r'From\s*:\s*(.*?)(?=To)', text);
    final to = extractMatch(r'To\s*[:\s]*([^,]+)', text);
    final tripCode = extractMatch(r'Trip Code\s*:\s*(\S+)', text);
    final journeyDate = parseDate(
      extractMatch(r'Journey Date\s*:\s*(\d{2}/\d{2}/\d{4})', text),
    );
    final departureTime = extractMatch(r'Time\s*:\s*(\d{2}:\d{2})', text);
    final classOfService = extractMatch(r'Class\s*:\s*(.*?)(?=,)', text);
    final passengerPickupPoint =
        extractMatch(r'Boarding at\s*:\s*(.*?)(?=\.|$)', text);

    return createGooglePass(
      BusTicket(
        corporation: corporation,
        pnrNumber: pnrNumber,
        serviceStartPlace: from,
        serviceEndPlace: to,
        tripCode: tripCode,
        journeyDate: journeyDate,
        serviceStartTime: departureTime,
        // seatNumber: seatNumber,
        classOfService: classOfService,
        passengerPickupPoint: passengerPickupPoint,
      ),
    );
  }

  String createGooglePass(BusTicket busTicket) {
    // Generate pass
    final passId = const Uuid().v4();
    const passClass = 'tnstc';
    const issuerId = '3388000000022803339';
    const issuerEmail = 'warriorharish95668@gmail.com';

    // Ensure origin_name is set based on destination
    var originName = (busTicket.serviceStartPlace ?? 'MNH').toAreaCode();
    final destinationName =
        (busTicket.serviceEndPlace ?? 'CHN').toAreaCode();

    // Check if destination is provided and origin is missing, then set originName to a default value
    if (destinationName.isNotEmpty && originName.isEmpty) {
      originName = 'Unknown Origin'; // Default or user-defined value
    }

    // Variables for JSON fields
    final ticketNumber = busTicket.pnrNumber ?? '';
    final tripId = busTicket.tripCode ?? '';
    final journeyDate = busTicket.journeyDate?.toIso8601String() ?? '';
    final fareAmount = busTicket.totalFare?.toString() ?? '0.0';
    final serviceClass = busTicket.classOfService ?? '';

    // Create JSON string with variables
    return '''
{
  "iss": "$issuerEmail",
  "aud": "google",
  "typ": "savetowallet",
  "origins": [],
  "payload": {
    "transitObjects": [
      {
        "id": "$issuerId.$passId",
        "classId": "$issuerId.$passClass",
        "state": "ACTIVE",
        "ticketNumber": "$ticketNumber",
        "tripId": "$tripId",
        "serviceClass": "$serviceClass",
        "ticketStatus": "ACTIVE",
        "hexBackgroundColor": "#4285f4",
        "tripType": "ONE_WAY",
        "validTimeInterval": {
          "start": {
            "date": "$journeyDate"
          }
        },
        "ticketLegs": [
          {
            "originStationCode": "$originName",
            "destinationStationCode": "$destinationName",
            "departureTime": {
              "date": "$journeyDate"
            },
            "fare": {
              "currencyCode": "INR",
              "amount": "$fareAmount"
            }
          }
        ],
        "cardTitle": {
          "defaultValue": {
            "language": "en",
            "value": "Transit Pass"
          }
        },
        "header": {
          "defaultValue": {
            "language": "en",
            "value": "Trip ID: $tripId"
          }
        },
        "subheader": {
          "defaultValue": {
            "language": "en",
            "value": "Service Class: $serviceClass"
          }
        }
      }
    ]
  }
}''';
  }
}

extension ShortFormExtension on String {
  /// Returns a short form of the string.
  /// For example:
  /// "CHENNAI-PT DR. M.G.R. BS" -> "CHE MGR"
  /// "KUMBAKONAM" -> "KUM"
  String toAreaCode() {
    // Split the string into words
    final words = split(RegExp(r'[\s\-\.]+'));

    // Handle special cases for specific names
    if (toUpperCase().contains('CHENNAI')) {
      return 'CHE';
    }
    if (toUpperCase().contains('KUMBAKONAM')) {
      return 'KUM';
    }

    // General rule: Return first three characters of the first word
    // and first three characters of the second word (if present)
    final firstPart =
        words.isNotEmpty ? words.first.substring(0, 3).toUpperCase() : '';
    final secondPart =
        words.length > 1 ? words[1].substring(0, 3).toUpperCase() : '';

    return [firstPart, secondPart].where((part) => part.isNotEmpty).join(' ');
  }
}
