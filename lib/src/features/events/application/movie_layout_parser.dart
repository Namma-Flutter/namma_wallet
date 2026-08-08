import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/layout_extractor.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/features/events/domain/movie_ticket_model.dart';

abstract class MovieTicketParser {
  bool canParse(String text);

  /// Parse ticket from OCR blocks
  Future<Ticket?> parseTicketFromBlocks(
    List<OCRBlock> blocks,
    String imagePath,
  );

  Future<String?> extractQrFromImage(String imagePath, ILogger logger) async {
    if (imagePath.trim().isEmpty) {
      logger.warning(
        '[DistrictMovieParser] Empty image path for QR extraction',
      );
      return null;
    }

    final controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      autoStart: false, // no camera needed
    );

    try {
      final capture = await controller.analyzeImage(
        imagePath,
        formats: [BarcodeFormat.qrCode],
      );

      if (capture == null || capture.barcodes.isEmpty) return null;

      for (final barcode in capture.barcodes) {
        final raw = barcode.rawValue;
        if (raw != null && raw.trim().isNotEmpty) {
          return raw.trim();
        }
      }
      return null;
    } on Object {
      logger.warning(
        '[DistrictMovieParser] Failed to extract QR from image: $imagePath',
      );
      return null;
    } finally {
      await controller.dispose();
    }
  }

  String get providerName;
}

/// Parses District (by Zomato) movie ticket screenshots / images.
class DistrictMovieParser extends MovieTicketParser {
  DistrictMovieParser({required this.logger});
  final ILogger logger;

  @override
  String get providerName => 'District';

  @override
  bool canParse(String text) {
    final lower = text.toLowerCase();
    return lower.contains('district') &&
        (lower.contains('zomato') || lower.contains('#seeyouthere'));
  }

  @override
  Future<Ticket?> parseTicketFromBlocks(
    List<OCRBlock> blocks,
    String imagePath,
  ) async {
    final extractor = LayoutExtractor(blocks);
    final plain = extractor.toPlainText();

    if (!canParse(plain)) return null;

    final bookingId = _extractBookingId(extractor, plain);
    final movieName = _extractMovieName(extractor, blocks, plain);
    final theatre = _extractTheatre(extractor, plain);
    final screen = _extractScreen(extractor, plain);
    final seats = _extractSeats(extractor, plain);
    final showDateTime = _extractShowDateTime(extractor, plain);
    final language = _extractLanguage(plain);
    final format = _extractFormat(plain);
    final certificate = _extractCertificate(plain);
    final qrData = await extractQrFromImage(imagePath, logger);

    // Critical fields – never invent data
    if (movieName == null || showDateTime == null) {
      logger.warning(
        '[DistrictMovieParser] Missing movieName or showDateTime',
      );
      return null;
    }

    final model = MovieTicketModel(
      bookingId: bookingId,
      movieName: movieName,
      certificate: certificate,
      theatreName: theatre,
      screen: screen,
      seats: seats,
      showDateTime: showDateTime,
      language: language,
      format: format,
      provider: providerName,
      qrData: qrData,
    );

    return Ticket.fromMovie(
      model,
    );
  }

  // ── Extraction helpers ────────────────────────────────────────────

  String? _extractBookingId(LayoutExtractor extractor, String plain) {
    // Layout: "Booking ID: TRAHKMR"
    final fromKey =
        extractor.findValueForKey('Booking ID') ??
        extractor.findValueForKey('Booking Id');
    if (fromKey != null && fromKey.trim().isNotEmpty) {
      return fromKey.trim().replaceAll(RegExp(r'\s'), '');
    }

    final m = RegExp(
      r'Booking\s*ID\s*[:\-]?\s*([A-Z0-9]+)',
      caseSensitive: false,
    ).firstMatch(plain);
    return m?.group(1)?.trim();
  }

  String? _extractMovieName(
    LayoutExtractor extractor,
    List<OCRBlock> blocks,
    String plain,
  ) {
    if (blocks.isEmpty) return null;

    // ── 1. Find the District / Zomato header band (top of card) ─────────
    OCRBlock? headerBlock;
    for (final b in blocks) {
      final lower = b.text.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
      if (lower.contains('district') ||
          lower.contains('distrizt') ||
          lower.contains('distrikt') ||
          lower.contains('zomato')) {
        if (headerBlock == null ||
            b.boundingBox.top < headerBlock.boundingBox.top) {
          headerBlock = b;
        }
      }
    }

    // ── 2. Find the certificate | language | format row ─────────────────────
    // e.g. "UA13+ | English | 2D"  or separate blocks on the same row
    OCRBlock? certificateBlock;
    for (final b in blocks) {
      final t = b.text.trim();
      final lower = t.toLowerCase();
      final isCertificate = RegExp(r'\b(UA\d*\+?|U|A|S)\b').hasMatch(t);
      final isLang = RegExp(
        r'\b(English|Hindi|Tamil|Telugu|Malayalam|Kannada|Marathi)\b',
        caseSensitive: false,
      ).hasMatch(t);
      final isFormat = RegExp(
        r'\b(2D|3D|IMAX|4DX)\b',
        caseSensitive: false,
      ).hasMatch(t);

      if (isCertificate || isLang || isFormat || lower.contains('|')) {
        if (certificateBlock == null ||
            b.boundingBox.top < certificateBlock.boundingBox.top) {
          certificateBlock = b;
        }
      }
    }

    // Need both anchors; otherwise fall back
    if (headerBlock == null || certificateBlock == null) {
      return _extractMovieNameFallback(blocks);
    }

    final headerBottom = headerBlock.boundingBox.bottom;
    final certificateTop = certificateBlock.boundingBox.top;

    // Guard: certificate must be below header
    if (certificateTop <= headerBottom) {
      return _extractMovieNameFallback(blocks);
    }

    // ── 3. Collect all blocks strictly between header and certificate ───────
    final titleBlocks =
        blocks.where((b) {
            final cy = b.centerY;
            // Strictly below header, strictly above certificate row
            return cy > headerBottom && cy < certificateTop;
          }).toList()
          // Reading order: top → bottom, then left → right
          ..sort((a, b) {
            final y = a.boundingBox.top.compareTo(b.boundingBox.top);
            if (y != 0) return y;
            return a.boundingBox.left.compareTo(b.boundingBox.left);
          });

    if (titleBlocks.isEmpty) {
      return _extractMovieNameFallback(blocks);
    }

    // ── 4. Join into one title (handles OCR splits: "Project" + "Hail Mary")
    final parts = <String>[];
    for (final b in titleBlocks) {
      final t = b.text.trim();
      if (t.isEmpty) continue;
      if (_isNoiseOrBrand(t)) continue;
      // Skip tiny fragments / pure punctuation
      if (t.length < 2) continue;
      parts.add(t);
    }

    if (parts.isEmpty) return _extractMovieNameFallback(blocks);

    final title = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return title.isEmpty ? null : title;
  }

  String? _extractTheatre(LayoutExtractor extractor, String plain) {
    // Often appears as a full address line near the bottom:
    // "PVR VR Mall, Anna Nagar, Chennai"
    final fromKey =
        extractor.findValueForKey('Cinema') ??
        extractor.findValueForKey('Theatre') ??
        extractor.findValueForKey('Theater');
    if (fromKey != null && fromKey.trim().isNotEmpty) return fromKey.trim();

    // Fallback: line that looks like "PVR …, City" or contains known chains
    final m = RegExp(
      r'((?:PVR|INOX|Cinepolis|SPI|AGS)[^,\n]*(?:,\s*[^,\n]+){1,3})',
      caseSensitive: false,
    ).firstMatch(plain);
    return m?.group(1)?.trim();
  }

  String? _extractScreen(LayoutExtractor extractor, String plain) {
    // District always uses "AUDI 02" style – match that first
    final audi = RegExp(
      r'\bAUDI\s*0*(\d+)\b',
      caseSensitive: false,
    ).firstMatch(plain);
    if (audi != null) return 'AUDI ${audi.group(1)}';

    final fromKey =
        extractor.findValueForKey('Screen') ??
        extractor.findValueForKey('Audi') ??
        extractor.findValueForKey('AUDI');
    if (fromKey != null) {
      final cleaned = fromKey.trim();
      // Reject if it looks like seats (F1, F2, …)
      if (!RegExp(r'\b[A-Z]\d+\b').hasMatch(cleaned) ||
          RegExp(r'\bAUDI\b', caseSensitive: false).hasMatch(cleaned)) {
        return cleaned;
      }
    }
    return null;
  }

  String? _extractSeats(LayoutExtractor extractor, String plain) {
    // "PR - F1, F2, F3"  (class + seat list)
    final fromKey =
        extractor.findValueForKey('Seat') ?? extractor.findValueForKey('Seats');
    if (fromKey != null && fromKey.trim().isNotEmpty) return fromKey.trim();

    // Pattern: optional class (PR/CL/…) then seat codes
    final m = RegExp(
      r'\b(?:PR|CL|EL|SL|GL)?\s*[-–]?\s*'
      r'([A-Z]\d+(?:\s*,\s*[A-Z]\d+)*)\b',
      caseSensitive: false,
    ).firstMatch(plain);
    if (m != null) {
      // Prefer full match including class if present
      return m.group(0)?.trim();
    }
    return null;
  }

  DateTime? _extractShowDateTime(LayoutExtractor extractor, String plain) {
    // "Sunday 24 May | 12:05 PM"
    final m = RegExp(
      r'(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)?\s*'
      r'(\d{1,2})\s+'
      '(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|'
      'Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|'
      r'Dec(?:ember)?)\s*'
      r'(?:\|)?\s*'
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(plain);

    if (m == null) return null;

    final day = int.tryParse(m.group(1)!);
    final monthStr = m.group(2)!.toLowerCase();
    final hourRaw = int.tryParse(m.group(3)!);
    final minute = int.tryParse(m.group(4)!);
    final period = m.group(5)!.toUpperCase();

    if (day == null || hourRaw == null || minute == null) return null;

    final month = _monthFromName(monthStr);
    if (month == null) return null;

    var hour = hourRaw;
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    // Year is often missing on District cards – use current year,
    // but only if the resulting date is not far in the past.
    // Prefer null over a wrong year if you want to be strict.
    final now = DateTime.now();
    final year = now.year;
    var dt = DateTime(year, month, day, hour, minute);

    // If the show date is > 6 months in the past, assume next year
    // (edge case around New Year). Adjust if you prefer stricter nulls.
    if (dt.isBefore(now.subtract(const Duration(days: 180)))) {
      dt = DateTime(year + 1, month, day, hour, minute);
    }

    return dt;
  }

  String? _extractLanguage(String plain) {
    final m = RegExp(
      r'\b(Hindi|Tamil|Telugu|English|Malayalam|Kannada|Marathi)\b',
      caseSensitive: false,
    ).firstMatch(plain);
    return m?.group(1);
  }

  String? _extractFormat(String plain) {
    final m = RegExp(
      r'\b(2D|3D|IMAX|4DX|ScreenX)\b',
      caseSensitive: false,
    ).firstMatch(plain);
    return m?.group(1)?.toUpperCase();
  }

  String? _extractCertificate(String plain) {
    final m = RegExp(
      r'\b(UA\d*\+?|U|A|S)\b',
    ).firstMatch(plain);
    return m?.group(1);
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

  /// Fallback if header/rating anchors are missing (bad OCR).
  String? _extractMovieNameFallback(List<OCRBlock> blocks) {
    final sorted = [...blocks]
      ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    for (final b in sorted) {
      final t = b.text.trim();
      if (t.length < 3) continue;
      if (_isNoiseOrBrand(t) || _looksLikeMetaLine(t)) continue;
      if (_looksLikeTitle(t)) return t;
    }
    return null;
  }

  bool _isNoiseOrBrand(String t) {
    final compact = t.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    const brands = [
      'district',
      'distrizt',
      'distrikt',
      'distrit',
      'zomato',
      'byzomato',
    ];
    if (brands.any(compact.contains)) return true;

    final lower = t.toLowerCase();
    return lower.contains('scan this qr') ||
        lower.contains('see you there') ||
        lower.contains('#seeyouthere');
  }

  bool _looksLikeMetaLine(String t) {
    if (RegExp(r'\bAUDI\s*\d+', caseSensitive: false).hasMatch(t)) return true;
    if (RegExp(r'\b(PR|CL|EL)\s*[-–]').hasMatch(t)) return true;
    if (RegExp(r'\d{1,2}:\d{2}\s*(AM|PM)', caseSensitive: false).hasMatch(t)) {
      return true;
    }
    if (RegExp(
      r'\b(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))',
      caseSensitive: false,
    ).hasMatch(t)) {
      return true;
    }
    final lower = t.toLowerCase();
    return lower.contains('mall') ||
        lower.contains('nagar') ||
        lower.contains('chennai') ||
        lower.startsWith('booking');
  }

  bool _looksLikeTitle(String t) {
    return RegExp(r"^[A-Za-z0-9][A-Za-z0-9\s\-:&'.]+$").hasMatch(t);
  }
}
