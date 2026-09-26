import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/events/application/event_layout_parser.dart';
import 'package:namma_wallet/src/features/events/domain/konfhub_ticket_model.dart';
import 'package:namma_wallet/src/features/travel/application/travel_text_parser_utils.dart';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

/// Parses KonfHub event ticket PDFs.
class KonfHubLayoutParser extends EventLayoutParser {
  KonfHubLayoutParser({required this.logger});
  final ILogger logger;

  @override
  String get providerName => 'KonfHub';

  @override
  bool canParse(String text) {
    final lower = text.toLowerCase();
    return lower.contains('konfhub') ||
        (lower.contains('attendee details') &&
            lower.contains('event name') &&
            lower.contains('ticket name')) ||
        (lower.contains('booking id') &&
            lower.contains('event name') &&
            (lower.contains('date & time') ||
                lower.contains('date and time') ||
                lower.contains('venue')));
  }

  @override
  Future<Ticket?> parseTicketFromBlocks(
    List<OCRBlock> blocks,
    String imagePath,
  ) async {
    final extractor = LayoutExtractor(blocks);
    final plain = extractor.toPlainText();

    if (!canParse(plain)) return null;

    final bookingId = extractor.findValueForKey('Booking ID');
    final bookingDateStr = extractor.findValueForKey('Booking Date');

    var eventName = extractor.findValueForKey('Event Name');
    if (eventName == null) {
      final eventNameKeyBlock = blocks.firstWhere(
        (b) {
          final t = b.text.toLowerCase().trim();
          return t == 'event name' || t.startsWith('event name:');
        },
        orElse: () => OCRBlock(text: '', boundingBox: Rect.zero, page: -1),
      );
      if (eventNameKeyBlock.page != -1) {
        final below =
            blocks.where((b) {
              return b.page == eventNameKeyBlock.page &&
                  b.boundingBox.top >=
                      eventNameKeyBlock.boundingBox.bottom - 5 &&
                  b.boundingBox.top <
                      eventNameKeyBlock.boundingBox.bottom + 60 &&
                  (b.boundingBox.left - eventNameKeyBlock.boundingBox.left)
                          .abs() <
                      50;
            }).toList()..sort(
              (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
            );
        if (below.isNotEmpty) {
          eventName = below.first.text.trim();
        }
      }
    }

    var ticketName = extractor.findValueForKey('Ticket Name');
    String? attendeeName;
    String? organization;

    final attendeeDetailsBlock = blocks.firstWhere(
      (b) => b.text.toLowerCase().contains('attendee details'),
      orElse: () => OCRBlock(text: '', boundingBox: Rect.zero, page: -1),
    );
    final eventNameBlock = blocks.firstWhere(
      (b) {
        final t = b.text.toLowerCase().trim();
        return t == 'event name' || t.startsWith('event name:');
      },
      orElse: () => OCRBlock(text: '', boundingBox: Rect.zero, page: -1),
    );

    if (attendeeDetailsBlock.page != -1 && eventNameBlock.page != -1) {
      // Old layout: text between "Attendee Details" and "Event Name"
      final betweenBlocks =
          blocks.where((b) {
            return b.page == attendeeDetailsBlock.page &&
                b.boundingBox.top > attendeeDetailsBlock.boundingBox.bottom &&
                b.boundingBox.top < eventNameBlock.boundingBox.top;
          }).toList()..sort(
            (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
          );

      if (betweenBlocks.isNotEmpty) {
        attendeeName = betweenBlocks[0].text.trim();
      }
      if (betweenBlocks.length > 1) {
        organization = betweenBlocks[1].text.trim();
      }
    } else if (eventNameBlock.page != -1) {
      // New layout: blocks before "Event Name" on page 0
      final beforeBlocks =
          blocks.where((b) {
            final textLower = b.text.toLowerCase().trim();
            return b.page == eventNameBlock.page &&
                b.boundingBox.top < eventNameBlock.boundingBox.top &&
                !textLower.startsWith('booking id') &&
                !textLower.startsWith('booking date') &&
                !textLower.contains('konfhub') &&
                textLower.isNotEmpty;
          }).toList()..sort(
            (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
          );

      if (beforeBlocks.length >= 3) {
        ticketName ??= beforeBlocks[0].text.trim();
        attendeeName = beforeBlocks[1].text.trim();
        organization = beforeBlocks[2].text.trim();
      } else if (beforeBlocks.length == 2) {
        ticketName ??= beforeBlocks[0].text.trim();
        attendeeName = beforeBlocks[1].text.trim();
      } else if (beforeBlocks.length == 1) {
        attendeeName = beforeBlocks[0].text.trim();
      }
    }

    // Extract Location / Venue which might span multiple blocks
    var location =
        extractor.findValueForKey('Venue') ??
        extractor.findValueForKey('Location');
    if (location != null) {
      // Find the location block to get any blocks directly below it
      final locBlock = blocks.firstWhere(
        (b) => b.text.contains(location!),
        orElse: () => blocks.firstWhere(
          (b) => b.text.contains('Venue') || b.text.contains('Location'),
          orElse: () => OCRBlock(text: '', boundingBox: Rect.zero, page: 0),
        ),
      );

      if (locBlock.text.isNotEmpty) {
        final belowBlocks =
            blocks.where((b) {
              return b != locBlock &&
                  b.page == locBlock.page &&
                  b.boundingBox.top >= locBlock.boundingBox.bottom - 5 &&
                  b.boundingBox.top < locBlock.boundingBox.bottom + 100 &&
                  (b.boundingBox.left - locBlock.boundingBox.left).abs() < 20;
            }).toList()..sort(
              (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
            );
        final buffer = StringBuffer(location);
        for (final b in belowBlocks) {
          final t = b.text.trim();
          if (t.toLowerCase().startsWith('additional') ||
              t == '•' ||
              t.contains(':') ||
              t.toLowerCase().contains('venue details')) {
            break;
          }
          buffer.write(' $t');
        }
        location = buffer.toString();
        location = location
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r',\s*,'), ',')
            .replaceAll(RegExp(r',\s*$'), '')
            .trim();
      }
    }

    var eventDateRaw =
        extractor.findValueForKey('Event Date') ??
        extractor.findValueForKey('Date & Time') ??
        extractor.findValueForKey('Date and Time');

    if (eventDateRaw == null) {
      final dateTimeBlock = blocks.firstWhere(
        (b) {
          final t = b.text.toLowerCase().trim();
          return t == 'date & time' ||
              t == 'date and time' ||
              t.startsWith('event date');
        },
        orElse: () => OCRBlock(text: '', boundingBox: Rect.zero, page: -1),
      );
      if (dateTimeBlock.page != -1) {
        final below =
            blocks.where((b) {
              return b.page == dateTimeBlock.page &&
                  b.boundingBox.top >= dateTimeBlock.boundingBox.bottom - 5 &&
                  b.boundingBox.top < dateTimeBlock.boundingBox.bottom + 60 &&
                  (b.boundingBox.left - dateTimeBlock.boundingBox.left).abs() <
                      50;
            }).toList()..sort(
              (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
            );
        if (below.isNotEmpty) {
          eventDateRaw = below.first.text.trim();
        }
      }
    }

    DateTime? eventDate;
    DateTime? eventStartTime;
    DateTime? eventEndTime;

    if (eventDateRaw != null) {
      // Try to parse "November 08", "Oct 17", or similar.
      final dateMatch = RegExp(
        r'([A-Za-z]+)\s+(\d{1,2})',
      ).firstMatch(eventDateRaw);
      if (dateMatch != null) {
        final monthStr = dateMatch.group(1)!;
        final day = int.tryParse(dateMatch.group(2)!);
        final month = _monthFromName(monthStr);

        if (month != null && day != null) {
          // Require explicit year from eventDateRaw or eventName (e.g. 2025)
          final yearMatch =
              RegExp(r'(20\d{2})').firstMatch(eventDateRaw) ??
              RegExp(r'(20\d{2})').firstMatch(eventName ?? '');
          if (yearMatch != null) {
            final year = int.parse(yearMatch.group(1)!);
            final parsedDate = DateTime(year, month, day);
            if (parsedDate.year == year &&
                parsedDate.month == month &&
                parsedDate.day == day) {
              eventDate = parsedDate;
            }
          }
        }
      }

      // Try to parse times
      // Supports "09:00 AM to 06:00 PM", "08:30 AM to 6PM IST",
      // "8:30 AM - 6 PM", etc.
      final timeMatch = RegExp(
        r'(\d{1,2})(?::(\d{2}))?\s*([AaPp][Mm])\s*(?:to|-)\s*(\d{1,2})(?::(\d{2}))?\s*([AaPp][Mm])',
      ).firstMatch(eventDateRaw);
      if (timeMatch != null && eventDate != null) {
        var startHour = int.parse(timeMatch.group(1)!);
        final startMinute = timeMatch.group(2) != null
            ? int.parse(timeMatch.group(2)!)
            : 0;
        final startAmPm = timeMatch.group(3)!.toUpperCase();

        if (startAmPm == 'PM' && startHour < 12) startHour += 12;
        if (startAmPm == 'AM' && startHour == 12) startHour = 0;

        var endHour = int.parse(timeMatch.group(4)!);
        final endMinute = timeMatch.group(5) != null
            ? int.parse(timeMatch.group(5)!)
            : 0;
        final endAmPm = timeMatch.group(6)!.toUpperCase();

        if (endAmPm == 'PM' && endHour < 12) endHour += 12;
        if (endAmPm == 'AM' && endHour == 12) endHour = 0;

        eventStartTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          startHour,
          startMinute,
        );
        eventEndTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          endHour,
          endMinute,
        );
      }
    }

    // Critical fields - never invent data
    if (eventName == null || eventDate == null) {
      logger.warning('[KonfHubLayoutParser] Missing eventName or eventDate');
      return null;
    }

    final additionalDetails = <String, String>{};
    final knownKeys = [
      'booking id',
      'booking date',
      'event name',
      'ticket name',
      'location',
      'venue',
      'event date',
      'date & time',
      'date and time',
      'attendee details',
      'attendee',
      'organization',
      'date',
      'time',
      'add-ons',
      'add-on',
      'additional venue details',
    ];

    // Explicit Add-ons extraction
    final addOns =
        extractor.findValueForKey('Add-ons') ??
        extractor.findValueForKey('Add-on') ??
        extractor.findValueForKey('Addons');
    if (addOns != null && addOns.isNotEmpty) {
      additionalDetails['Add-ons'] = addOns;
    }

    // Explicit Additional Venue Details extraction
    final sortedBlocks = List<OCRBlock>.from(blocks)
      ..sort(LayoutExtractor.readingOrderComparator);
    final additionalVenueIndex = sortedBlocks.indexWhere(
      (b) => b.text.toLowerCase().contains('additional venue details'),
    );
    if (additionalVenueIndex != -1) {
      final bullets = <String>[];
      var current = StringBuffer();

      for (var i = additionalVenueIndex + 1; i < sortedBlocks.length; i++) {
        final b = sortedBlocks[i];
        final text = b.text.trim();
        if (text.isEmpty) continue;

        if (text == '•' || text == '-' || text == '*') {
          if (current.isNotEmpty) {
            bullets.add(current.toString().trim());
            current = StringBuffer();
          }
        } else if (text.startsWith('•') || text.startsWith('- ')) {
          if (current.isNotEmpty) {
            bullets.add(current.toString().trim());
            current = StringBuffer();
          }
          current.write(text.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''));
        } else {
          if (current.isNotEmpty) {
            current.write(' ');
          }
          current.write(text);
        }
      }
      if (current.isNotEmpty) {
        bullets.add(current.toString().trim());
      }

      if (bullets.isNotEmpty) {
        additionalDetails['Additional Venue Details'] = bullets
            .map((b) => '• $b')
            .join('\n');
      }
    }

    final validKeyRegex = RegExp(r'^[A-Za-z][A-Za-z\s\-_/]{1,30}$');

    for (final b in blocks) {
      final text = b.text.trim();

      // Skip blocks already parsed as main fields
      if (eventDateRaw != null &&
          (text.contains(eventDateRaw) || eventDateRaw.contains(text))) {
        continue;
      }
      if (location != null &&
          (location.contains(text) || text.contains(location))) {
        continue;
      }
      if (attendeeName != null && text.contains(attendeeName)) {
        continue;
      }
      if (organization != null && text.contains(organization)) {
        continue;
      }
      if (ticketName != null && text.contains(ticketName)) {
        continue;
      }
      if (addOns != null && text.contains(addOns)) {
        continue;
      }

      if (text.contains(':')) {
        final colonIndex = text.indexOf(':');
        final key = text.substring(0, colonIndex).trim();
        final value = text.substring(colonIndex + 1).trim();

        if (key.isNotEmpty && value.isNotEmpty && validKeyRegex.hasMatch(key)) {
          final isKnown = knownKeys.any((k) => key.toLowerCase().contains(k));
          if (!isKnown) {
            additionalDetails[key] = value;
          }
        }
      }
    }

    final qrData = await _extractQrFromPdf(imagePath);

    final model = KonfHubTicketModel(
      bookingId: bookingId,
      bookingDate: _parseBookingDate(bookingDateStr),
      attendeeName: attendeeName,
      organization: organization,
      eventName: eventName,
      eventDate: eventDate,
      eventStartTime: eventStartTime,
      eventEndTime: eventEndTime,
      ticketName: ticketName,
      location: location,
      additionalDetails: additionalDetails.isEmpty ? null : additionalDetails,
      qrData: qrData,
    );

    return Ticket.fromKonfHub(model);
  }

  DateTime? _parseBookingDate(String? bookingDateStr) {
    if (bookingDateStr == null || bookingDateStr.trim().isEmpty) return null;

    final standardDate = TravelTextParserUtils.parseDate(
      bookingDateStr,
      logger: logger,
    );
    if (standardDate != null) return standardDate;

    // Handle "Sep 06, 2026" or "September 29, 2025"
    final match = RegExp(
      r'([A-Za-z]+)\s+(\d{1,2}),?\s+(\d{4})',
    ).firstMatch(bookingDateStr);
    if (match != null) {
      final month = _monthFromName(match.group(1)!);
      final day = int.tryParse(match.group(2)!);
      final year = int.tryParse(match.group(3)!);
      if (month != null && day != null && year != null) {
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day) {
          return date;
        }
      }
    }

    final matchDayFirst = RegExp(
      r'(\d{1,2})\s+([A-Za-z]+),?\s+(\d{4})',
    ).firstMatch(bookingDateStr);
    if (matchDayFirst != null) {
      final day = int.tryParse(matchDayFirst.group(1)!);
      final month = _monthFromName(matchDayFirst.group(2)!);
      final year = int.tryParse(matchDayFirst.group(3)!);
      if (month != null && day != null && year != null) {
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day) {
          return date;
        }
      }
    }

    return null;
  }

  Future<String?> _extractQrFromPdf(String filePath) async {
    if (kIsWeb || filePath.trim().isEmpty) return null;

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        logger.warning(
          '[KonfHubLayoutParser] PDF file does not exist for QR extraction',
        );
        return null;
      }

      final barcodes = await PdfBarcodeDecoder.decodeFile(
        file,
        config: const DecoderConfig(
          formats: [BarcodeFormat.qr],
          firstPageOnly: true,
          stopAfterFirst: true,
        ),
      );

      if (barcodes.isNotEmpty) {
        final raw = barcodes.first.value;
        if (raw.trim().isNotEmpty) {
          logger.info('[KonfHubLayoutParser] Extracted QR code from PDF');
          return raw.trim();
        }
      }
      return null;
    } on Object {
      logger.warning(
        '[KonfHubLayoutParser] Failed to extract QR from PDF',
      );
      return null;
    }
  }

  int? _monthFromName(String name) {
    const map = {
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return map[name.toLowerCase()];
  }
}
