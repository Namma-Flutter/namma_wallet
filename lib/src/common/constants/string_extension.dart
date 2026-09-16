import 'package:namma_wallet/src/common/constants/station_code.dart';

extension StringExtensions on String? {
  /// Returns true if the string is null, empty, or contains only whitespace
  bool get isNullOrEmpty {
    final self = this;
    return self == null || self.trim().isEmpty;
  }

  /// Returns true if the string is NOT null and contains actual text
  bool get isNotNullOrEmpty {
    final self = this;
    return self != null && self.trim().isNotEmpty;
  }

  /// Converts a station or city name to its short code abbreviation (e.g., "Chennai Central" -> "MAS").
  String get toStationAbbreviation {
    return StationRegistry.getCode(this);
  }
}
