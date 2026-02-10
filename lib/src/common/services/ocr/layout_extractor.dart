import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

/// Utility for extracting structured data from OCR blocks using layout
/// analysis.
///
/// This class uses geometric relationships (same row, below, to the right)
/// to map field labels to their values. This is far more reliable than regex
/// alone, especially for tickets with inconsistent formatting or OCR errors.
///
/// Example usage:
/// ```dart
/// final extractor = LayoutExtractor(ocrBlocks);
/// final pnr = extractor.findValueForKey('PNR Number');
/// final date = extractor.findValueForKey('Date of Journey');
/// ```
class LayoutExtractor {
  LayoutExtractor(this.blocks);

  final List<OCRBlock> blocks;

  /// Finds the value associated with a given key label.
  ///
  /// Strategy:
  /// 1. Find block(s) containing [keyLabel]
  /// 2. Look for value on same row (to the right)
  /// 3. If not found, look on next row (below)
  ///
  /// [keyLabel] can be a partial match (case-insensitive)
  /// [sameRowTolerance] controls how strict "same row" matching is (in pixels)
  /// [maxDistance] limits how far to search for values (prevents wrong matches)
  String? findValueForKey(
    String keyLabel, {
    double sameRowTolerance = 8.0,
    double maxDistance = 500.0,
  }) {
    final keyBlock = _findKeyBlock(keyLabel);
    if (keyBlock == null) return null;

    // Strategy 0: Check if the key block itself contains the value
    // (common in pseudo-blocks where "Key : Value" is on one line)
    final inlineValue = _extractInlineValue(keyBlock, keyLabel);
    if (inlineValue != null) return inlineValue;

    // Strategy 1: Look for value on same row, to the right
    final sameRowValue = _findValueOnSameRow(
      keyBlock,
      tolerance: sameRowTolerance,
      maxDistance: maxDistance,
    );
    if (sameRowValue != null) return sameRowValue;

    // Strategy 2: Look for value on next row (below)
    final belowValue = _findValueBelow(
      keyBlock,
      maxDistance: maxDistance,
    );
    return belowValue;
  }

  /// Extracts value from a block that contains both key and value.
  ///
  /// Example: "Service End Place : CHENNAI-PT DR. M.G.R. BS"
  /// Returns: "CHENNAI-PT DR. M.G.R. BS"
  String? _extractInlineValue(OCRBlock block, String keyLabel) {
    // Check if block contains a colon (indicates key : value format)
    if (!block.text.contains(':')) return null;

    final lowerKey = keyLabel.toLowerCase();
    final lowerText = block.text.toLowerCase();

    // Verify this block actually contains the key we're looking for
    if (!lowerText.contains(lowerKey)) return null;

    // Split on colon and take everything after it
    final colonIndex = block.text.indexOf(':');
    if (colonIndex == -1 || colonIndex >= block.text.length - 1) return null;

    final valueText = block.text.substring(colonIndex + 1).trim();
    return valueText.isNotEmpty ? valueText : null;
  }

  /// Finds all blocks that match the key label pattern.
  ///
  /// Returns blocks where text contains [pattern] (case-insensitive).
  /// Sorted by reading order (top-to-bottom, left-to-right).
  List<OCRBlock> findBlocksMatching(String pattern) {
    final lowerPattern = pattern.toLowerCase();
    final matching = blocks.where((b) {
      return b.text.toLowerCase().contains(lowerPattern);
    }).toList();

    // Sort by reading order: top to bottom, then left to right
    return matching..sort((a, b) {
      final yDiff = a.boundingBox.top - b.boundingBox.top;
      if (yDiff.abs() > 10) {
        // Different rows
        return yDiff.sign.toInt();
      } else {
        // Same row, sort by left position
        return (a.boundingBox.left - b.boundingBox.left).sign.toInt();
      }
    });
  }

  /// Finds the first block containing the key label.
  OCRBlock? _findKeyBlock(String keyLabel) {
    final lowerKey = keyLabel.toLowerCase();
    final result = blocks.where(
      (b) => b.text.toLowerCase().contains(lowerKey),
    );
    return result.isEmpty ? null : result.first;
  }

  /// Finds value blocks on the same horizontal row, to the right of [keyBlock].
  String? _findValueOnSameRow(
    OCRBlock keyBlock, {
    required double tolerance,
    required double maxDistance,
  }) {
    final candidates = blocks.where((b) {
      return b.page == keyBlock.page &&
          b.isSameRowAs(keyBlock, tolerance: tolerance) &&
          b.isRightOf(keyBlock) &&
          (b.boundingBox.left - keyBlock.boundingBox.right) < maxDistance;
    }).toList();

    if (candidates.isEmpty) return null;

    // Sort by distance from key block (closest first)
    candidates.sort(
      (a, b) => (a.boundingBox.left - keyBlock.boundingBox.right).compareTo(
        b.boundingBox.left - keyBlock.boundingBox.right,
      ),
    );

    // Try to extract value from the closest candidate
    // Skip blocks that are clearly other field labels,
    // but limit how many we skip
    var skippedCount = 0;
    const maxSkips = 2;  // Give up after skipping 2 field labels

    for (final candidate in candidates) {
      final candidateText = candidate.text.trim();

      // If block contains inline format (key : value),
      // check if it's another field
      if (candidateText.contains(':')) {
        final colonIndex = candidateText.indexOf(':');
        final keyPart = candidateText.substring(0, colonIndex).trim();
        final valuePart = candidateText.substring(colonIndex + 1).trim();

        // Check if this looks like a field label
        final looksLikeFieldLabel =
            keyPart.split(' ').length >= 2 ||
            keyPart.toLowerCase().contains('number') ||
            keyPart.toLowerCase().contains('code') ||
            keyPart.toLowerCase().contains('service') ||
            keyPart.toLowerCase().contains('class') ||
            keyPart.toLowerCase().contains('time') ||
            keyPart.toLowerCase().contains('date') ||
            keyPart.toLowerCase().contains('place');

        if (looksLikeFieldLabel) {
          // This is another field label, not a value for our key
          skippedCount++;
          if (skippedCount > maxSkips) return null;  // Searched too far
          continue;
        }

        // Not a field label, return the value part
        if (valuePart.isEmpty) continue;
        return valuePart;
      }

      // No colon - check if it's a standalone section header or field label
      // Remove trailing punctuation for better matching
      final lowerText = candidateText
          .toLowerCase()
          .replaceAll(RegExp(r'[:.!?\s]+$'), '');

      // Check for section headers (multi-word with common keywords)
      final isSectionHeader =
          lowerText.split(' ').length >= 2 &&
          (lowerText.contains('information') ||
              lowerText.contains('details') ||
              lowerText.contains('passenger') ||
              lowerText.contains('booking') ||
              lowerText.contains('journey') ||
              lowerText.contains('section'));

      // Check for field labels (common patterns)
      final isFieldLabel =
          lowerText.contains('/') ||  // "Adult/Child", "Yes/No", etc.
          lowerText.endsWith(' no') ||  // "Seat No", "Bus No", etc.
          lowerText.endsWith(' number') ||  // "Platform Number", etc.
          lowerText.endsWith(' time') ||  // "Pickup Time", etc.
          lowerText.endsWith(' date') ||  // "Journey Date", etc.
          lowerText.endsWith(' ref') ||  // "Booking Ref", etc.
          lowerText.endsWith(' class') ||  // "Service Class", etc.
          lowerText.endsWith(' name') ||  // "Passenger Name", etc.
          lowerText.endsWith(' id') ||  // "Bus ID", etc.
          lowerText.endsWith(' code') ||  // "Trip Code", etc.
          lowerText == 'seat' ||
          lowerText == 'seats' ||
          lowerText == 'age' ||
          lowerText == 'gender' ||
          lowerText == 'fare' ||
          lowerText == 'platform' ||
          lowerText == 'name' ||
          lowerText == 'time' ||
          lowerText == 'date' ||
          lowerText == 'code' ||
          lowerText == 'adult' ||
          lowerText == 'child';

      if (isSectionHeader || isFieldLabel) {
        // This is a section header or field label, skip it
        skippedCount++;
        if (skippedCount > maxSkips) return null;  // Searched too far
        continue;
      }

      // Plain value, return it cleaned
      final cleaned = _cleanValue(candidateText);
      if (cleaned != null && cleaned.isNotEmpty) return cleaned;
    }

    // No valid value found
    return null;
  }

  /// Finds value blocks below [keyBlock].
  String? _findValueBelow(
    OCRBlock keyBlock, {
    required double maxDistance,
  }) {
    final candidates = blocks.where((b) {
      return b.page == keyBlock.page &&
          // Use >= to handle pseudo-blocks with exact boundaries
          b.boundingBox.top >= keyBlock.boundingBox.bottom &&
          (b.boundingBox.top - keyBlock.boundingBox.bottom) < maxDistance;
    }).toList();

    if (candidates.isEmpty) return null;

    // Sort by distance from key block (closest first)
    candidates.sort(
      (a, b) => (a.boundingBox.top - keyBlock.boundingBox.bottom).compareTo(
        b.boundingBox.top - keyBlock.boundingBox.bottom,
      ),
    );

    // Try to extract value from the closest candidate
    // Skip blocks that are clearly other field labels,
    // but limit how many we skip
    var skippedCount = 0;
    const maxSkips = 2;  // Give up after skipping 2 field labels

    for (final candidate in candidates) {
      final candidateText = candidate.text.trim();

      // If block contains inline format (key : value),
      // check if it's another field
      if (candidateText.contains(':')) {
        final colonIndex = candidateText.indexOf(':');
        final keyPart = candidateText.substring(0, colonIndex).trim();
        final valuePart = candidateText.substring(colonIndex + 1).trim();

        // Check if this looks like a field label
        // (has multiple words before colon)
        // Examples: "Trip Code", "Class of Service", "Platform Number"
        final looksLikeFieldLabel =
            keyPart.split(' ').length >= 2 ||
            keyPart.toLowerCase().contains('number') ||
            keyPart.toLowerCase().contains('code') ||
            keyPart.toLowerCase().contains('service') ||
            keyPart.toLowerCase().contains('class') ||
            keyPart.toLowerCase().contains('time') ||
            keyPart.toLowerCase().contains('date') ||
            keyPart.toLowerCase().contains('place');

        if (looksLikeFieldLabel) {
          // This is another field label, not a value for our key
          skippedCount++;
          if (skippedCount > maxSkips) return null;  // Searched too far
          continue;
        }

        // Not a field label, return the value part
        if (valuePart.isEmpty) continue;
        return valuePart;
      }

      // No colon - check if it's a standalone section header or field label
      // Remove trailing punctuation for better matching
      final lowerText = candidateText
          .toLowerCase()
          .replaceAll(RegExp(r'[:.!?\s]+$'), '');

      // Check for section headers (multi-word with common keywords)
      final isSectionHeader =
          lowerText.split(' ').length >= 2 &&
          (lowerText.contains('information') ||
              lowerText.contains('details') ||
              lowerText.contains('passenger') ||
              lowerText.contains('booking') ||
              lowerText.contains('journey') ||
              lowerText.contains('section'));

      // Check for field labels (common patterns)
      final isFieldLabel =
          lowerText.contains('/') ||  // "Adult/Child", "Yes/No", etc.
          lowerText.endsWith(' no') ||  // "Seat No", "Bus No", etc.
          lowerText.endsWith(' number') ||  // "Platform Number", etc.
          lowerText.endsWith(' time') ||  // "Pickup Time", etc.
          lowerText.endsWith(' date') ||  // "Journey Date", etc.
          lowerText.endsWith(' ref') ||  // "Booking Ref", etc.
          lowerText.endsWith(' class') ||  // "Service Class", etc.
          lowerText.endsWith(' name') ||  // "Passenger Name", etc.
          lowerText.endsWith(' id') ||  // "Bus ID", etc.
          lowerText.endsWith(' code') ||  // "Trip Code", etc.
          lowerText == 'seat' ||
          lowerText == 'seats' ||
          lowerText == 'age' ||
          lowerText == 'gender' ||
          lowerText == 'fare' ||
          lowerText == 'platform' ||
          lowerText == 'name' ||
          lowerText == 'time' ||
          lowerText == 'date' ||
          lowerText == 'code' ||
          lowerText == 'adult' ||
          lowerText == 'child';

      if (isSectionHeader || isFieldLabel) {
        // This is a section header or field label, skip it
        skippedCount++;
        if (skippedCount > maxSkips) return null;  // Searched too far
        continue;
      }

      // No colon means it's a plain value, return it cleaned
      final cleaned = _cleanValue(candidateText);
      if (cleaned != null && cleaned.isNotEmpty) return cleaned;
    }

    // No valid value found
    return null;
  }

  /// Cleans up extracted values by removing common OCR artifacts.
  String? _cleanValue(String value) {
    var cleaned = value.trim();

    // Remove leading punctuation (often from "Key : value" patterns)
    cleaned = cleaned.replaceFirst(RegExp(r'^[:\-.\s]+'), '');

    // Remove trailing time suffixes (e.g., "13:15 Hrs." → "13:15")
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*hrs?\.?\s*$', caseSensitive: false),
      '',
    );

    // Remove trailing punctuation and dots (fixes "735.00 Rs." → "735.00.")
    cleaned = cleaned.replaceFirst(RegExp(r'[:\-.\s]+$'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'\.+$'), ''); // Remove trailing dots

    return cleaned.isEmpty ? null : cleaned;
  }

  /// Extracts a table section from OCR blocks.
  ///
  /// Useful for passenger information tables. Returns blocks between
  /// [startPattern] and [endPattern] (exclusive).
  List<OCRBlock> extractTableSection({
    required String startPattern,
    required String endPattern,
  }) {
    final startBlock = _findKeyBlock(startPattern);
    final endBlock = _findKeyBlock(endPattern);

    if (startBlock == null) return [];

    final sectionBlocks = blocks.where((b) {
      if (b.page != startBlock.page) return false;
      if (b.boundingBox.top <= startBlock.boundingBox.bottom) return false;
      if (endBlock != null && b.boundingBox.top >= endBlock.boundingBox.top) {
        return false;
      }
      return true;
    }).toList();

    // Sort by reading order
    return sectionBlocks..sort((a, b) {
      final yDiff = a.boundingBox.top - b.boundingBox.top;
      if (yDiff.abs() > 10) {
        return yDiff.sign.toInt();
      } else {
        return (a.boundingBox.left - b.boundingBox.left).sign.toInt();
      }
    });
  }

  /// Returns all text as a single string (for fallback regex matching).
  ///
  /// Use this only when layout-based extraction fails.
  /// Preserves reading order.
  String toPlainText() {
    // Sort blocks by reading order
    final sortedBlocks = List<OCRBlock>.from(blocks)
      ..sort((a, b) {
        // Sort by page first
        if (a.page != b.page) return a.page.compareTo(b.page);

        // Then by vertical position
        final yDiff = a.boundingBox.top - b.boundingBox.top;
        if (yDiff.abs() > 10) {
          return yDiff.sign.toInt();
        } else {
          // Same row, sort by horizontal position
          return (a.boundingBox.left - b.boundingBox.left).sign.toInt();
        }
      });

    return sortedBlocks.map((b) => b.text).join('\n');
  }
}
