import 'dart:ui';

/// Represents a block of text extracted from OCR with its geometric location.
///
/// This is the foundation for layout-based field extraction - by preserving
/// bounding boxes, we can use spatial relationships (same row, below, to the
/// right) to map keys to values, which is far more reliable than regex alone.
class OCRBlock {
  OCRBlock({
    required this.text,
    required this.boundingBox,
    required this.page,
    this.confidence,
  });

  /// The extracted text content
  final String text;

  /// The bounding box of this text block in the page coordinate system
  final Rect boundingBox;

  /// The page number (0-indexed)
  final int page;

  /// Optional confidence score (0.0 to 1.0) if provided by OCR engine
  final double? confidence;

  /// Returns the vertical center of the bounding box
  double get centerY => boundingBox.center.dy;

  /// Returns the horizontal center of the bounding box
  double get centerX => boundingBox.center.dx;

  /// Returns true if this block is approximately on the same horizontal line
  /// as [other], within the given [tolerance] (in pixels).
  bool isSameRowAs(OCRBlock other, {double tolerance = 8.0}) {
    if (page != other.page) return false;
    return (centerY - other.centerY).abs() < tolerance;
  }

  /// Returns true if this block is to the right of [other]
  bool isRightOf(OCRBlock other) {
    if (page != other.page) return false;
    return boundingBox.left > other.boundingBox.right;
  }

  /// Returns true if this block is below [other]
  bool isBelow(OCRBlock other) {
    if (page != other.page) return false;
    return boundingBox.top > other.boundingBox.bottom;
  }

  @override
  String toString() =>
      'OCRBlock(text: "$text", box: $boundingBox, page: $page)';
}
