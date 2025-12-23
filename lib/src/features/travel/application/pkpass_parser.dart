import 'dart:io';
import 'dart:typed_data';

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
  PKPassParser({required ILogger logger}) : _logger = logger;

  final ILogger _logger;

  @override
  Future<Ticket?> parsePKPass(Uint8List data) async {
    try {
      final passFile = await PassFile.parse(data);

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
      );
    } on Object catch (e, stackTrace) {
      _logger.error('Failed to parse pkpass file', e, stackTrace);
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
    return _findFieldValue(passFile, [
      'pnr',
      'confirmation_number',
      'booking_id',
      'ticket_number',
    ]);
  }

  String _getPrimaryText(PassFile passFile) {
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

    if (origin != null && destination != null) {
      return '$origin → $destination';
    }

    final logoText = metadata.logoText;
    if (logoText != null && logoText.isNotEmpty) return logoText;

    final orgName = metadata.organizationName;
    if (orgName.isNotEmpty) return orgName;

    return 'Unknown Ticket';
  }

  String _getSecondaryText(PassFile passFile) {
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
      return (description.isNotEmpty) ? description : 'Ticket Details';
    }

    return parts.join(' • ');
  }

  DateTime? _getStartTime(PassFile passFile) {
    final metadata = passFile.metadata;
    return metadata.relevantDate;
  }

  String _getLocation(PassFile passFile) {
    return _findFieldValue(passFile, [
          'boarding_point',
          'gate',
          'platform',
          'boarding_gate',
        ]) ??
        'Unknown';
  }

  TicketType _getTicketType(PassFile passFile) {
    final metadata = passFile.metadata;
    if (metadata.boardingPass != null) {
      final transitType = metadata.boardingPass!.transitType;
      if (transitType == TransitType.train) return TicketType.train;
      if (transitType == TransitType.bus) return TicketType.bus;
    }
    return TicketType.train; // Default
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
    final metadata = passFile.metadata;
    final extras = <ExtrasModel>[];

    // Collect all fields from various sections
    final allFields = [
      ...?metadata.boardingPass?.primaryFields,
      ...?metadata.boardingPass?.secondaryFields,
      ...?metadata.boardingPass?.auxiliaryFields,
      ...?metadata.boardingPass?.headerFields,
      ...?metadata.boardingPass?.backFields,
      ...?metadata.eventTicket?.primaryFields,
      ...?metadata.eventTicket?.secondaryFields,
      ...?metadata.coupon?.primaryFields,
      ...?metadata.storeCard?.primaryFields,
      ...?metadata.generic?.primaryFields,
    ];

    for (final field in allFields) {
      final label = field.label;
      final dynamic val = field.value;
      if (label != null && val != null) {
        // DictionaryValue in pkpass package wraps actual
        // values in specific properties
        final dynamic value = _getDictionaryValue(val);

        String displayValue;
        if (value is String) {
          displayValue = value;
        } else if (value is Map) {
          // Handle complex values by looking for common keys
          displayValue =
              value['full_address']?.toString() ??
              value['address']?.toString() ??
              value['name']?.toString() ??
              value.values.firstOrNull?.toString() ??
              value.toString();
        } else if (value is Iterable) {
          displayValue = value.join(', ');
        } else {
          displayValue = value?.toString() ?? '';
        }

        if (displayValue.isNotEmpty) {
          extras.add(
            ExtrasModel(
              title: label,
              value: displayValue,
            ),
          );
        }
      }
    }

    final orgName = metadata.organizationName;
    if (orgName.isNotEmpty) {
      extras.add(ExtrasModel(title: 'Provider', value: orgName));
    }

    return extras;
  }

  String? _findFieldValue(PassFile passFile, List<String> keys) {
    final metadata = passFile.metadata;
    final allFields = [
      ...?metadata.boardingPass?.primaryFields,
      ...?metadata.boardingPass?.secondaryFields,
      ...?metadata.boardingPass?.auxiliaryFields,
      ...?metadata.boardingPass?.headerFields,
      ...?metadata.eventTicket?.primaryFields,
      ...?metadata.generic?.primaryFields,
    ];

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
}
