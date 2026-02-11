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

  /// Keywords that identify a block as a field label.
  static const _fieldLabelKeywords = [
    'number',
    'code',
    'service',
    'class',
    'time',
    'date',
    'place',
    'seat',
    'seats',
    'age',
    'gender',
    'fare',
    'platform',
    'name',
    'adult',
    'child',
  ];

  /// Keywords that identify a block as a section header.
  static const _sectionHeaderKeywords = [
    'information',
    'details',
    'passenger',
    'booking',
    'journey',
    'section',
  ];

  /// Standard reading order comparator: top-to-bottom, then left-to-right.
  static int readingOrderComparator(OCRBlock a, OCRBlock b) {
    if (a.page != b.page) return a.page.compareTo(b.page);

    final yDiff = a.boundingBox.top - b.boundingBox.top;
    if (yDiff.abs() > 10) {
      // Different rows
      return yDiff.sign.toInt();
    } else {
      // Same row, sort by left position
      return (a.boundingBox.left - b.boundingBox.left).sign.toInt();
    }
  }

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

  List<OCRBlock> findBlocksMatching(String pattern) {
    final lowerPattern = pattern.toLowerCase();
    final matching = blocks.where((b) {
      return b.text.toLowerCase().contains(lowerPattern);
    }).toList();

    // Sort by reading order: top to bottom, then left to right
    return matching..sort(readingOrderComparator);
  }

  /// Finds the first block containing the key label (respects reading order).
  OCRBlock? _findKeyBlock(String keyLabel) {
    final matches = findBlocksMatching(keyLabel);
    return matches.isEmpty ? null : matches.first;
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

    return _extractValueFromCandidates(candidates);
  }

  /// Extracts value from a list of candidate blocks based on heuristics.
  ///
  /// This logic is shared between same-row and below searches.
  String? _extractValueFromCandidates(List<OCRBlock> candidates) {
    // Try to extract value from the closest candidate
    // Skip blocks that are clearly other field labels,
    // but limit how many we skip
    var skippedCount = 0;
    const maxSkips = 2; // Give up after skipping 2 field labels

    for (final candidate in candidates) {
      final candidateText = candidate.text.trim();

      // If block contains inline format (key : value),
      // check if it's another field
      if (candidateText.contains(':')) {
        final colonIndex = candidateText.indexOf(':');
        final keyPart = candidateText.substring(0, colonIndex).trim();
        final valuePart = candidateText.substring(colonIndex + 1).trim();

        // Check if this looks like a field label
        // NOTE: The two-word key-part heuristic may over-classify values as
        // field labels for some document types. Works well for TNSTC tickets
        // where multi-word values rarely contain colons, but may need
        // refinement for other formats.
        final looksLikeFieldLabel =
            keyPart.split(' ').length >= 2 ||
            _fieldLabelKeywords.any(
              (k) => keyPart.toLowerCase().contains(k),
            );

        if (looksLikeFieldLabel) {
          // This is another field label, not a value for our key
          skippedCount++;
          if (skippedCount > maxSkips) return null; // Searched too far
          continue;
        }

        // Not a field label, return the value part
        if (valuePart.isEmpty) continue;
        return valuePart;
      }

      // No colon - check if it's a standalone section header or field label
      // Remove trailing punctuation for better matching
      final lowerText = candidateText.toLowerCase().replaceAll(
        RegExp(r'[:.!?\s]+$'),
        '',
      );

      // Check for section headers (multi-word with common keywords)
      final isSectionHeader =
          lowerText.split(' ').length >= 2 &&
          _sectionHeaderKeywords.any(lowerText.contains);

      // Check for field labels (common patterns)
      final isFieldLabel =
          lowerText.contains('/') || // "Adult/Child", "Yes/No", etc.
          _fieldLabelKeywords.any(
            (k) =>
                lowerText.endsWith(' $k') ||
                lowerText == k, // Exact match or Ends with
          );

      if (isSectionHeader || isFieldLabel) {
        // This is a section header or field label, skip it
        skippedCount++;
        if (skippedCount > maxSkips) return null; // Searched too far
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
          (b.boundingBox.top - keyBlock.boundingBox.bottom) < maxDistance &&
          // Require horizontal overlap with the key block
          b.boundingBox.left < keyBlock.boundingBox.right &&
          b.boundingBox.right > keyBlock.boundingBox.left;
    }).toList();

    if (candidates.isEmpty) return null;

    // Sort by distance from key block (closest first)
    candidates.sort(
      (a, b) => (a.boundingBox.top - keyBlock.boundingBox.bottom).compareTo(
        b.boundingBox.top - keyBlock.boundingBox.bottom,
      ),
    );

    return _extractValueFromCandidates(candidates);
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
    return sectionBlocks..sort(readingOrderComparator);
  }

  /// Returns all text as a single string (for fallback regex matching).
  ///
  /// Use this only when layout-based extraction fails.
  /// Preserves reading order.
  String toPlainText() {
    // Sort blocks by reading order
    final sortedBlocks = List<OCRBlock>.from(blocks)
      ..sort(readingOrderComparator);

    return sortedBlocks.map((b) => b.text).join('\n');
  }
}
