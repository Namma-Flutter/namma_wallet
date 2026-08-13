import 'dart:ui';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/events/application/event_layout_parser.dart';
import 'package:namma_wallet/src/features/events/domain/konfhub_ticket_model.dart';
import 'package:namma_wallet/src/features/travel/application/travel_text_parser_utils.dart';

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
            lower.contains('ticket name'));
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
    final eventName = extractor.findValueForKey('Event Name');
    final ticketName = extractor.findValueForKey('Ticket Name');

    // Extract Location which might span multiple blocks
    var location = extractor.findValueForKey('Location');
    if (location != null) {
      // Find the location block to get any blocks directly below it
      final locBlock = blocks.firstWhere(
        (b) => b.text.contains(location!) || b.text.contains('Location'),
        orElse: () => OCRBlock(
          text: '',
          boundingBox: Rect.zero,
          page: 0,
        ),
      );

      if (locBlock.text.isNotEmpty) {
        // Simple heuristic: if there are blocks directly
        // below the location block,
        // with similar left alignment, append them.
        final belowBlocks =
            blocks.where((b) {
              return b != locBlock &&
                  b.page == locBlock.page &&
                  b.boundingBox.top >= locBlock.boundingBox.bottom - 5 &&
                  b.boundingBox.top <
                      locBlock.boundingBox.bottom +
                          100 && // within next few lines
                  (b.boundingBox.left - locBlock.boundingBox.left).abs() <
                      20; // roughly aligned
            }).toList()..sort(
              (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
            );
        final buffer = StringBuffer(location);
        for (final b in belowBlocks) {
          buffer.write(' ${b.text}');
        }
        location = buffer.toString();
        location = location
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r',\s*,'), ',') // clean up any double commas
            .trim();
      }
    }

    // Event Date format: "November 08 (09:00 AM to 06:00 PM)" or similar
    final eventDateRaw = extractor.findValueForKey('Event Date');
    DateTime? eventDate;
    DateTime? eventStartTime;
    DateTime? eventEndTime;

    if (eventDateRaw != null) {
      // Try to parse "November 08" or similar.
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
      final timeMatch = RegExp(
        r'(\d{1,2}):(\d{2})\s*([AMPMampm]+)\s*to\s*(\d{1,2}):(\d{2})\s*([AMPMampm]+)',
      ).firstMatch(eventDateRaw);
      if (timeMatch != null && eventDate != null) {
        var startHour = int.parse(timeMatch.group(1)!);
        final startMinute = int.parse(timeMatch.group(2)!);
        final startAmPm = timeMatch.group(3)!.toUpperCase();

        if (startAmPm == 'PM' && startHour < 12) startHour += 12;
        if (startAmPm == 'AM' && startHour == 12) startHour = 0;

        var endHour = int.parse(timeMatch.group(4)!);
        final endMinute = int.parse(timeMatch.group(5)!);
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

    // Extract Attendee Details
    // It's usually the block after "Attendee Details" and before "Event Name"
    String? attendeeName;
    String? organization;

    final attendeeDetailsBlock = blocks.firstWhere(
      (b) => b.text.toLowerCase().contains('attendee details'),
      orElse: () => OCRBlock(
        text: '',
        boundingBox: Rect.zero,
        page: 0,
      ),
    );
    final eventNameBlock = blocks.firstWhere(
      (b) => b.text.toLowerCase().contains('event name'),
      orElse: () => OCRBlock(
        text: '',
        boundingBox: Rect.zero,
        page: 0,
      ),
    );

    if (attendeeDetailsBlock.text.isNotEmpty &&
        eventNameBlock.text.isNotEmpty) {
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
    }

    // Critical fields - never invent data
    if (eventName == null || eventDate == null) {
      logger.warning('[KonfHubLayoutParser] Missing eventName or eventDate');
      return null;
    }

    // Dynamic extras extraction
    // Any block that looks like a key-value pair
    // and isn't one of our main fields
    final additionalDetails = <String, String>{};
    final knownKeys = [
      'booking id',
      'booking date',
      'event name',
      'ticket name',
      'location',
      'event date',
      'attendee details',
    ];

    for (final b in blocks) {
      final text = b.text.trim();
      if (text.contains(':')) {
        final parts = text.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();

          if (key.isNotEmpty && value.isNotEmpty) {
            final isKnown = knownKeys.any((k) => key.toLowerCase().contains(k));
            if (!isKnown) {
              additionalDetails[key] = value;
            }
          }
        }
      }
    }

    // TODO(KV): We skip QR code extraction from the PDF for now as
    //  it requires rendering the PDF page as an image first.
    // The QR likely contains the booking ID, which we extract anyway.

    final model = KonfHubTicketModel(
      bookingId: bookingId,
      bookingDate: TravelTextParserUtils.parseDate(
        bookingDateStr,
        logger: logger,
      ),
      attendeeName: attendeeName,
      organization: organization,
      eventName: eventName,
      eventDate: eventDate,
      eventStartTime: eventStartTime,
      eventEndTime: eventEndTime,
      ticketName: ticketName,
      location: location,
      additionalDetails: additionalDetails.isEmpty ? null : additionalDetails,
    );

    return Ticket.fromKonfHub(model);
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
