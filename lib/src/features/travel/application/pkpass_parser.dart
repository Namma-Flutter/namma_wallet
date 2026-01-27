import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/tag_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/travel/application/pkpass_parser_interface.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pkpass/pkpass.dart';
import 'package:uuid/uuid.dart';

class PKPassParser implements IPKPassParser {
  PKPassParser({
    required ILogger logger,
  }) : _logger = logger;

  final ILogger _logger;

  @override
  Future<Ticket?> parsePKPass(Uint8List data) async {
    try {
      final passFile = await PassFile.parse(data);
      _logFullPassDetails(passFile);
      // Extract basic info from barcode or primary fields
      final pnrNumber = _extractPNR(passFile);
      final primaryText = _getPrimaryText(passFile);
      final secondaryText = _getSecondaryText(passFile);
      final startTime = _getStartTime(passFile);
      final location = _getLocation(passFile);
      final ticketType = _getTicketType(passFile);

      final tags = _extractTags(passFile);
      final extras = _extractExtras(passFile);

      final imagePath = await _savePassImage(passFile);
      final directionsUrl = _extractDirectionsUrl(passFile);
      if (directionsUrl != null) {
        _logger.info('PKPassParser: Found directionsUrl: $directionsUrl');
      } else {
        _logger.info('PKPassParser: No directionsUrl found in pass fields.');
      }

      return Ticket(
        ticketId: pnrNumber,
        primaryText: primaryText,
        secondaryText: secondaryText,
        startTime: startTime,
        location: location,
        type: ticketType,
        tags: tags,
        extras: extras,
        imagePath: imagePath,
        directionsUrl: directionsUrl,
      );
    } on Object catch (e, stackTrace) {
      _logger.error('Failed to parse pkpass file', e, stackTrace);
      return null;
    }
  }

  @override
  Future<Uint8List?> fetchLatestPass(
    Uint8List currentPassData, {
    DateTime? modifiedSince,
  }) async {
    try {
      // Decode the PKPass (ZIP file) manually to access top-level fields
      // that might not be exposed by the pkpass package.
      final archive = ZipDecoder().decodeBytes(currentPassData);
      final passJsonFile = archive.findFile('pass.json');

      if (passJsonFile == null) {
        _logger.warning('pass.json not found in pkpass archive');
        return null;
      }

      final passJsonContent = utf8.decode(passJsonFile.content as List<int>);
      final passJson = jsonDecode(passJsonContent) as Map<String, dynamic>;

      final webServiceUrl = passJson['webServiceURL'] as String?;
      final authenticationToken = passJson['authenticationToken'] as String?;
      final serialNumber = passJson['serialNumber'] as String?;
      final passTypeIdentifier = passJson['passTypeIdentifier'] as String?;

      if (webServiceUrl == null ||
          authenticationToken == null ||
          serialNumber == null ||
          passTypeIdentifier == null) {
        return null;
      }

      // Construct URL: {webServiceURL}/v1/passes/{passTypeIdentifier}/{serialNumber}
      final uri = Uri.parse(webServiceUrl).replace(
        pathSegments: [
          ...Uri.parse(webServiceUrl).pathSegments,
          'v1',
          'passes',
          passTypeIdentifier,
          serialNumber,
        ],
      );

      final headers = {
        'Authorization': 'ApplePass $authenticationToken',
      };

      if (modifiedSince != null) {
        headers['If-Modified-Since'] = HttpDate.format(modifiedSince);
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 304) {
        return null; // Not modified
      } else {
        _logger.warning(
          'Failed to fetch latest '
          'pass: ${response.statusCode} ${response.reasonPhrase}',
        );
        return null;
      }
    } on Object catch (e, stackTrace) {
      _logger.error('Failed to fetch latest pass version', e, stackTrace);
      return null;
    }
  }

  Future<String?> _savePassImage(PassFile passFile) async {
    try {
      // Try to get thumbnail, logo or strip in order of preference
      final imageBytes =
          passFile.getThumbnail() ?? passFile.getLogo() ?? passFile.getStrip();

      if (imageBytes == null) return null;

      final appDocDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDocDir.path, 'ticket_images'));
      if (!imagesDir.existsSync()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${const Uuid().v4()}.png';
      final filePath = p.join(imagesDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } on Object catch (e, stackTrace) {
      _logger.error('Failed to save pkpass image', e, stackTrace);
      return null;
    }
  }

  String? _extractPNR(PassFile passFile) {
    final metadata = passFile.metadata;
    // Try to get confirmation number or PNR from barcodes
    if (metadata.barcodes.isNotEmpty) {
      return metadata.barcodes.first.message;
    }

    // Fallback to fields
    final fromFields = _findFieldValue(passFile, [
      'pnr',
      'confirmation_number',
      'booking_id',
      'ticket_number',
    ]);

    if (fromFields != null) return fromFields;

    // Fallback to serial number if nothing else found
    if (metadata.serialNumber.isNotEmpty) {
      return metadata.serialNumber;
    }

    return null;
  }

  String? _getPrimaryText(PassFile passFile) {
    final metadata = passFile.metadata;
    // For boarding passes, often {origin} -> {destination}
    final origin = _findFieldValue(passFile, [
      'origin',
      'from',
      'departure_airport',
      'from_station',
    ]);
    final destination = _findFieldValue(passFile, [
      'destination',
      'to',
      'arrival_airport',
      'to_station',
    ]);

    final eventName = _findFieldValue(passFile, ['event_name', 'event']);

    if (origin != null && destination != null) {
      return '$origin → $destination';
    }

    if (eventName != null) return eventName;

    final logoText = metadata.logoText;
    if (logoText != null && logoText.isNotEmpty) return logoText;

    final orgName = metadata.organizationName;
    if (orgName.isNotEmpty) return orgName;

    return null;
  }

  String? _getSecondaryText(PassFile passFile) {
    final metadata = passFile.metadata;
    final service = _findFieldValue(passFile, [
      'flight_number',
      'train_number',
      'bus_number',
      'service',
    ]);
    final className = _findFieldValue(passFile, [
      'class',
      'cabin',
      'seat_class',
    ]);

    final parts = [
      if (service != null && service.isNotEmpty) service,
      if (className != null && className.isNotEmpty) className,
    ];

    if (parts.isEmpty) {
      final description = metadata.description;
      return (description.isNotEmpty) ? description : null;
    }

    return parts.join(' • ');
  }

  DateTime? _getStartTime(PassFile passFile) {
    final metadata = passFile.metadata;
    return metadata.relevantDate;
  }

  String? _getLocation(PassFile passFile) {
    return _findFieldValue(passFile, [
      'boarding_point',
      'gate',
      'platform',
      'boarding_gate',
      'event_address',
      'venue_name',
      'address',
    ]);
  }

  String? _extractDirectionsUrl(PassFile passFile) {
    return _findFieldValue(passFile, [
      'google_maps_url',
      'directions',
      'map_url',
      'venue_maps_url',
    ]);
  }

  TicketType? _getTicketType(PassFile passFile) {
    final metadata = passFile.metadata;
    if (metadata.boardingPass != null) {
      final transitType = metadata.boardingPass!.transitType;
      if (transitType == TransitType.train) {
        return TicketType.train;
      }
      if (transitType == TransitType.bus) {
        return TicketType.bus;
      }
      if (transitType == TransitType.air) {
        return TicketType.flight;
      }
    }
    if (metadata.eventTicket != null) {
      return TicketType.event;
    }
    return null;
  }

  List<TagModel> _extractTags(PassFile passFile) {
    final tags = <TagModel>[];

    final pnr = _extractPNR(passFile);
    if (pnr != null) {
      tags.add(TagModel(value: pnr, icon: 'confirmation_number'));
    }

    final seat = _findFieldValue(passFile, ['seat', 'seat_number']);
    if (seat != null) {
      tags.add(TagModel(value: seat, icon: 'event_seat'));
    }

    return tags;
  }

  List<ExtrasModel> _extractExtras(PassFile passFile) {
    final extras = <ExtrasModel>[];

    // Collect all fields from various sections
    final allFields = _getAllFields(passFile.metadata);

    for (final field in allFields) {
      if (field is! DictionaryField) continue;

      final label = field.label;
      final dynamic val = field.value;
      if (label != null && val != null) {
        // DictionaryValue in pkpass package wraps actual
        // values in specific properties
        final dynamic value = _getDictionaryValue(val);

        String? displayValue;
        if (value is String) {
          displayValue = value;
        } else if (value is Map) {
          // Handle complex values by looking for common keys
          displayValue =
              value['full_address']?.toString() ??
              value['address']?.toString() ??
              value['name']?.toString() ??
              value.values.firstOrNull?.toString();
        } else if (value is Iterable) {
          if (value.isNotEmpty) {
            displayValue = value.join(', ');
          }
        } else {
          displayValue = value?.toString();
        }

        if (displayValue != null && displayValue.isNotEmpty) {
          extras.add(
            ExtrasModel(
              title: label,
              value: displayValue,
            ),
          );
        }
      }
    }

    final orgName = passFile.metadata.organizationName;
    if (orgName.isNotEmpty) {
      extras.add(ExtrasModel(title: 'Provider', value: orgName));
    }

    return extras;
  }

  String? _findFieldValue(PassFile passFile, List<String> keys) {
    final allFields = _getAllFields(passFile.metadata);

    for (final key in keys) {
      final field = allFields
          .whereType<DictionaryField>()
          .cast<DictionaryField?>()
          .firstWhere(
            (f) => f!.key.toLowerCase() == key.toLowerCase(),
            orElse: () => null,
          );
      if (field != null) {
        final dynamic val = _getDictionaryValue(field.value);
        if (val is String && val.isNotEmpty) return val;
        // If it's a map (like Address), try to get a meaningful string
        if (val is Map) {
          return val['name']?.toString() ??
              val['full_address']?.toString() ??
              val.values.firstOrNull?.toString();
        }
      }
    }
    return null;
  }

  /// Helper to get all fields from all pass structures and sections
  List<dynamic> _getAllFields(PassMetadata metadata) {
    final allFields = <dynamic>[];

    void addFields(PassStructureDictionary? structure) {
      if (structure == null) return;

      allFields
        ..addAll(structure.headerFields)
        ..addAll(structure.primaryFields)
        ..addAll(structure.secondaryFields)
        ..addAll(structure.auxiliaryFields)
        ..addAll(structure.backFields);
    }

    addFields(metadata.boardingPass);
    addFields(metadata.eventTicket);
    addFields(metadata.coupon);
    addFields(metadata.storeCard);
    addFields(metadata.generic);

    return allFields;
  }

  /// Helper to extract raw value from DictionaryValue subclasses
  dynamic _getDictionaryValue(dynamic val) {
    if (val == null) return null;
    try {
      if (val is StringDictionaryValue) return val.string;
      if (val is NumberDictionaryValue) return val.number;
      if (val is DateTimeDictionaryValue) return val.dateTime;

      // Fallback for any other types or if types are not exactly matched
      return (val as dynamic).value;
    } on Object catch (_) {
      try {
        // Ultimate fallback
        return val.toString();
      } on Object catch (_) {
        return null;
      }
    }
  }

  void _logFullPassDetails(PassFile passFile) {
    if (!kDebugMode) return;
    try {
      final metadata = passFile.metadata;

      Map<String, dynamic> structToMap(PassStructureDictionary? s) {
        if (s == null) return {};
        return {
          'headerFields': _fieldsToList(s.headerFields),
          'primaryFields': _fieldsToList(s.primaryFields),
          'secondaryFields': _fieldsToList(s.secondaryFields),
          'auxiliaryFields': _fieldsToList(s.auxiliaryFields),
          'backFields': _fieldsToList(s.backFields),
        };
      }

      final map = {
        'description': metadata.description,
        'organizationName': metadata.organizationName,
        'passTypeIdentifier': metadata.passTypeIdentifier,
        'serialNumber': metadata.serialNumber,
        'teamIdentifier': metadata.teamIdentifier,
        'relevantDate': metadata.relevantDate?.toIso8601String(),
        'expirationDate': metadata.expirationDate?.toIso8601String(),
        'voided': metadata.voided,
        'logoText': metadata.logoText,
        'barcodes': metadata.barcodes
            .map(
              (b) => {
                'message': b.message,
                'format': b.format.toString(),
                'altText': b.altText,
              },
            )
            .toList(),
        if (metadata.boardingPass != null)
          'boardingPass': {
            'transitType': metadata.boardingPass!.transitType.toString(),
            ...structToMap(metadata.boardingPass),
          },
        if (metadata.eventTicket != null)
          'eventTicket': structToMap(metadata.eventTicket),
        if (metadata.coupon != null) 'coupon': structToMap(metadata.coupon),
        if (metadata.storeCard != null)
          'storeCard': structToMap(metadata.storeCard),
        if (metadata.generic != null) 'generic': structToMap(metadata.generic),
      };

      // Helper to handle DateTime and other non-JSON types
      Object? toEncodable(dynamic object) {
        if (object is DateTime) return object.toIso8601String();
        try {
          // Explicitly cast to dynamic to call toJson if it exists
          return (object as dynamic).toJson() as Object?;
        } on Exception catch (_) {
          // Fallback to toString if toJson doesn't exist or throws
          return object.toString();
        }
      }

      final prettyString = JsonEncoder.withIndent(
        '  ',
        toEncodable,
      ).convert(map);
      _logger.debug(
        // ignore: lines_longer_than_80_chars - Separator line for debug output readability
        '--------------------------------------------------\nFULL PKPASS METADATA:\n$prettyString\n--------------------------------------------------',
      );
    } on Exception catch (e, s) {
      _logger.error('Failed to log full pass details', e, s);
    }
  }

  List<Map<String, dynamic>> _fieldsToList(List<dynamic>? fields) {
    if (fields == null) return [];
    return fields.whereType<DictionaryField>().map((f) {
      return {
        'key': f.key,
        'label': f.label,
        'value': _getDictionaryValue(f.value),
        'changeMessage': f.changeMessage,
      };
    }).toList();
  }
}
