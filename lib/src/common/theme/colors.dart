part of 'styles.dart';

class AppColor {
  static const Color primaryColor = Color.fromARGB(255, 255, 255, 255);
  static const Color secondaryColor = Color.fromARGB(255, 14, 25, 52);
  static const Color quaternaryColor = Color.fromARGB(255, 239, 243, 246);
  static const Color ternaryColor = Color.fromARGB(255, 16, 52, 115);
  static const Color specialColor = Color.fromARGB(255, 236, 241, 248);
  static const Color periwinkleBlue = Color.fromRGBO(112, 135, 248, 1);

  /// Primary blue color used throughout the app
  /// This is the actual blue color (0xff3067FE), previously
  /// misnamed as lime yellow
  static const Color primaryBlue = Color(0xff3067FE);

  /// @deprecated Use [primaryBlue] instead. This was misnamed
  /// - it's blue, not yellow.
  @Deprecated('Use primaryBlue instead. This constant is misnamed.')
  static const Color limeYellowColor = primaryBlue;

  /// @deprecated Use [primaryBlue] instead. This was misnamed
  /// - it's blue, not yellow.
  @Deprecated('Use primaryBlue instead. This constant is misnamed.')
  static const Color limeYellowThinkColor = primaryBlue;

  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  // Ticket type colors
  static const Color busTicketColor = primaryBlue;
  static const Color trainTicketColor = Colors.blue;
  static const Color flightTicketColor = Colors.red;
  static const Color eventTicketColor = Colors.purple;
  static const Color metroTicketColor = Colors.orange;
}

class Shades {
  static const Color s06 = Color.fromRGBO(255, 255, 255, 0.6);
  static const Color s0 = Color.fromRGBO(255, 255, 255, 1);
  static const Color s100 = Color.fromRGBO(0, 0, 0, 1);
}
