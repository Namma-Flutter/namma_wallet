extension StringExtensions on String? {
  /// Returns true if the string is null, empty, or contains only whitespace
  bool get isNullOrEmpty {
    return this == null || this!.trim().isEmpty;
  }

  /// Returns true if the string is NOT null and contains actual text
  bool get isNotNullOrEmpty {
    return this != null && this!.trim().isNotEmpty;
  }
}
