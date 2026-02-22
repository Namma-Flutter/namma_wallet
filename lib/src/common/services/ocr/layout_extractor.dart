import 'dart:ui';
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
    'class', // Retained 'class' as it's a valid keyword, assuming 'classOfService' was an example value.
    'service', // Retained 'service' as it's a valid keyword, assuming 'classOfService' was an example value.
    'time',
    'passenger',
    'pickup',
    'point',
    'boarding',
    'date',
    'place',
    'seat',
    'seats',
    'age',
    'gender',
    'fare',
    'total',
    'platform',
    'name',
    'adult',
    'child',
    'route',
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
    double sameRowTolerance = 12.0,
    double maxDistance = 500.0,
  }) {
    final keyBlock = _findKeyBlock(keyLabel);
    if (keyBlock == null) {
      return null;
    }

    final lowerKey = keyLabel.toLowerCase();
    final lowerText = keyBlock.text.toLowerCase();
    final keyStartIndex = lowerText.indexOf(lowerKey);

    // Identify start of the value part (after the colon)
    var colonIndex = -1;
    if (keyStartIndex != -1) {
      colonIndex = keyBlock.text.indexOf(':', keyStartIndex + lowerKey.length);
    }

    // Collect all potential value components on the same row
    final candidates = <OCRBlock>[];

    // Component 1: Inline value in the key block itself
    if (colonIndex != -1 && colonIndex < keyBlock.text.length) {
      var valueText = keyBlock.text.substring(colonIndex + 1).trim();
      final originalValueText = valueText; // Save for empty check

      if (valueText.isNotEmpty) {
        // Handle inline multi-key blocks like "From: VAL1 To: VAL2"
        // Look for the next recognized field label within valueText
        if (valueText.contains(':')) {
          // Find the next colon (which marks the start of the next key-value pair)
          final nextColonIndex = valueText.indexOf(':');
          final potentialKeyPart = valueText
              .substring(0, nextColonIndex)
              .trim();

          // Find which keyword appears EARLIEST in potentialKeyPart (after the value)
          // and truncate before that keyword
          int earliestKeywordStart = -1;

          // First, look for multi-word field labels (more specific)
          final multiWordLabels = [
            'passenger pickup',
            'pickup point',
            'pickup time',
            'service start',
            'service end',
            'boarding point',
          ];

          for (final label in multiWordLabels) {
            final labelIndex = potentialKeyPart.toLowerCase().indexOf(label);
            if (labelIndex > 0 &&
                (earliestKeywordStart == -1 ||
                    labelIndex < earliestKeywordStart)) {
              earliestKeywordStart = labelIndex;
            }
          }

          // Then check for single-word keywords if no multi-word found
          if (earliestKeywordStart == -1) {
            for (final keyword in _fieldLabelKeywords) {
              // Check for keyword with leading space (middle of string)
              final keywordIndex = potentialKeyPart.toLowerCase().indexOf(
                ' $keyword',
              );
              if (keywordIndex > 0 &&
                  (earliestKeywordStart == -1 ||
                      keywordIndex < earliestKeywordStart)) {
                earliestKeywordStart = keywordIndex;
              }
              // Also check for keyword at the start of the string
              final keywordIndexStart = potentialKeyPart.toLowerCase().indexOf(
                keyword,
              );
              if (keywordIndexStart == 0 &&
                  keywordIndexStart > 0 &&
                  (earliestKeywordStart == -1 ||
                      keywordIndexStart < earliestKeywordStart)) {
                earliestKeywordStart = keywordIndexStart;
              }
            }
          }

          if (earliestKeywordStart > 0) {
            valueText = potentialKeyPart
                .substring(0, earliestKeywordStart)
                .trim();
          }
        }

        if (valueText.isNotEmpty) {
          // Estimate the X position of where the value starts
          final labelEndRatio = (colonIndex + 1) / keyBlock.text.length;
          final valueLeft =
              keyBlock.boundingBox.left +
              (keyBlock.boundingBox.width * labelEndRatio);

          candidates.add(
            OCRBlock(
              text: valueText,
              boundingBox: Rect.fromLTWH(
                valueLeft,
                keyBlock.boundingBox.top,
                keyBlock.boundingBox.width * (1 - labelEndRatio),
                keyBlock.boundingBox.height,
              ),
              page: keyBlock.page,
            ),
          );
        }
      } else if (originalValueText.isEmpty) {
        // Inline value is empty (e.g., "Route No :"), don't fall through to spatial search
        return null;
      }
    }

    // Component 2: Other blocks on the same row
    final sameRowBlocks = blocks.where((b) {
      if (b == keyBlock) return false;
      final isSameRow = b.isSameRowAs(keyBlock, tolerance: sameRowTolerance);
      final isMinRight = b.centerX > keyBlock.boundingBox.left;
      final isWithinMaxDist =
          (b.boundingBox.left - keyBlock.boundingBox.right) < maxDistance;

      return b.page == keyBlock.page &&
          isSameRow &&
          isMinRight &&
          isWithinMaxDist;
    }).toList();
    candidates.addAll(sameRowBlocks);

    // If we found any components on the same row, process them
    if (candidates.isNotEmpty) {
      // Sort by horizontal position (left-to-right)
      candidates.sort((a, b) {
        final diff = a.boundingBox.left - b.boundingBox.left;
        if (diff.abs() < 1.0) {
          return a.boundingBox.top.compareTo(b.boundingBox.top);
        }
        return diff < 0 ? -1 : 1;
      });

      final sameRowValue = _extractValueFromCandidates(candidates, maxSkips: 1);
      if (sameRowValue != null && sameRowValue.isNotEmpty) {
        return sameRowValue;
      }

      // If we found a colon but the value was empty/rejected, don't fall back to "below"
      // unless it was purely a standalone label "Key:".
      if (colonIndex != -1 && colonIndex < keyBlock.text.length - 1) {
        return null;
      }
    }

    // Strategy 2: Look for value on next row (below)
    final belowValue = _findValueBelow(
      keyBlock,
      maxDistance: maxDistance,
    );
    return belowValue;
  }

  /// Finds the first block containing the key label (respects reading order).
  OCRBlock? _findKeyBlock(String label) {
    final lowerLabel = label.toLowerCase();
    OCRBlock? bestMatch;
    var bestScore = -1;

    for (final block in blocks) {
      final text = block.text.trim();
      final lowerText = text.toLowerCase();

      var score = -1;
      if (lowerText == lowerLabel) {
        score = 100;
      } else if (lowerText == '$lowerLabel:') {
        score = 90;
      } else if (lowerText.startsWith('$lowerLabel:')) {
        score = 80;
      } else if (lowerText.startsWith(lowerLabel) &&
          text.length < lowerLabel.length + 5) {
        score = 70;
      } else if (lowerText.contains(lowerLabel) && lowerText.endsWith(':')) {
        score = 60;
      } else if (lowerText.startsWith(lowerLabel)) {
        score = 50;
      } else if (lowerText.contains(lowerLabel)) {
        score = 40;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = block;
        if (score == 100) break; // Perfect match
      }
    }
    return bestMatch;
  }

  /// Extracts value from a list of candidate blocks based on heuristics.
  ///
  /// This logic is shared between same-row and below searches.
  String? _extractValueFromCandidates(
    List<OCRBlock> candidates, {
    int maxSkips = 2,
  }) {
    final matchedParts = <String>[];
    var skippedCount = 0;

    for (final candidate in candidates) {
      final candidateText = candidate.text.trim();

      // HEURISTIC: Check for field label FIRST, even if it contains a date/time.
      if (candidateText.contains(':')) {
        final colonIndex = candidateText.indexOf(':');
        final keyPart = candidateText.substring(0, colonIndex).trim();
        final valuePart = candidateText.substring(colonIndex + 1).trim();

        final isDateOrTimePattern =
            RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(candidateText) ||
            RegExp(r'\d{1,2}:\d{2}').hasMatch(candidateText);

        final hasFieldKeyword = _fieldLabelKeywords.any(
          (k) => keyPart.toLowerCase().contains(k),
        );
        final hasEnoughWords = keyPart.split(' ').length >= 2;

        final looksLikeFieldLabel =
            (hasFieldKeyword || hasEnoughWords) && !isDateOrTimePattern;

        // SPECIAL CASE: If it has a field keyword AND a colon, it's almost always a field label
        // even if it contains a date (e.g., "Passenger Pickup Time: 20/01/2026...")
        final isStrongFieldLabel = hasFieldKeyword;

        if (looksLikeFieldLabel || isStrongFieldLabel) {
          // If we already started collecting value, stop at next label
          if (matchedParts.isNotEmpty) break;

          // Skip this block entirely - it's a field label block
          // even if it has a value after the colon, we shouldn't use it
          // for spatial search fallback (test case: Route No : with Passenger Pickup Time below)
          skippedCount++;
          if (skippedCount > maxSkips) return null;
          continue;
        }
      }

      // Standalone text (might be a label or a value)
      final isDateOrTimePattern =
          RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(candidateText) ||
          RegExp(r'\d{1,2}:\d{2}').hasMatch(candidateText);

      final lowerText = candidateText.toLowerCase().replaceAll(
        RegExp(r'[:.!?\s]+$'),
        '',
      );

      final isSectionHeader =
          !isDateOrTimePattern &&
          lowerText.split(' ').length >= 2 &&
          _sectionHeaderKeywords.any(lowerText.contains);

      final isFieldLabel =
          !isDateOrTimePattern &&
          (lowerText.contains('/') ||
              _fieldLabelKeywords.any(
                (k) => lowerText.endsWith(' $k') || lowerText == k,
              ));

      if (isSectionHeader || isFieldLabel) {
        if (matchedParts.isNotEmpty) break;
        skippedCount++;
        if (skippedCount > maxSkips) return null;
        continue;
      }

      // Plain value, add it cleaned
      final cleaned = _cleanValue(candidateText);
      if (cleaned != null && cleaned.isNotEmpty) {
        matchedParts.add(cleaned);
      }
    }

    return matchedParts.isEmpty ? null : matchedParts.join(' ');
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

    // Sort by vertical distance from key block (closest first)
    candidates.sort((a, b) {
      final yDiffA = a.boundingBox.top - keyBlock.boundingBox.bottom;
      final yDiffB = b.boundingBox.top - keyBlock.boundingBox.bottom;

      if ((yDiffA - yDiffB).abs() < 5) {
        final xDiffA = (a.centerX - keyBlock.centerX).abs();
        final xDiffB = (b.centerX - keyBlock.centerX).abs();
        return xDiffA.compareTo(xDiffB);
      }
      return yDiffA.compareTo(yDiffB);
    });

    return _extractValueFromCandidates(candidates);
  }

  /// Cleans up extracted values by removing common OCR artifacts.
  String? _cleanValue(String value) {
    var cleaned = value.trim();

    // Remove leading punctuation (often from "Key : value" patterns)
    cleaned = cleaned.replaceFirst(RegExp(r'^[:\-.\s]+'), '');

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
      // Include blocks that are on the same line as or below the start block.
      // Use top boundary of start block as reference.
      if (b.boundingBox.bottom <= startBlock.boundingBox.top) return false;
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
