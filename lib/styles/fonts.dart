part of 'styles.dart';

class AppFonts {
  static TextStyle getAppFont(
      {FontWeight? fontWeight,
      double? fontSize,
      Color? color,
      TextDecoration? decoration}) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            decoration: decoration));
  }
}

//--------------------------------------------------------------------------------------------------------------------------------

/// This Dart file, is part of the 'styles.dart' collection and focuses on defining font styles used throughout the application.
/// It leverages the Google Fonts package, specifically the Inter font family, to create consistent text styling.
///
/// Classes:
/// - `InterFonts` provides a static method `getAppFont` to generate `TextStyle` objects with customizable properties such as
///   font weight, size, color, line height, and letter spacing. This method centralizes font styling, ensuring consistency.

class InterFonts {
  static TextStyle getAppFont(
      {FontWeight? fontWeight,
      double? fontSize,
      Color? color,
      double? height,
      double? letterSpacing,
      Color? decorationColor,
      TextDecoration? decoration}) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            decoration: decoration,
            decorationColor: decorationColor));
  }
}

class Display01 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  Display01({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 72,
      fontWeight: FontWeight.w600,
      height: 80 / 72,
      letterSpacing: -2.88,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 80 / 72,
      letterSpacing: -2.88,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 72,
      fontWeight: FontWeight.w800,
      height: 80 / 72,
      letterSpacing: -2.88,
      color: color,
    );
  }
}

class Display02 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  Display02({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 60,
      fontWeight: FontWeight.w600,
      height: 72 / 60,
      letterSpacing: -2.4,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 60,
      fontWeight: FontWeight.w700,
      height: 72 / 60,
      letterSpacing: -2.4,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 60,
      fontWeight: FontWeight.w800,
      height: 72 / 60,
      letterSpacing: -2.4,
      color: color,
    );
  }
}

class HeadingH1 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH1({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 56 / 48,
      letterSpacing: -1.92,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 56 / 48,
      letterSpacing: -1.92,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      height: 56 / 48,
      letterSpacing: -1.92,
      color: color,
    );
  }
}

class HeadingH1Small {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH1Small({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      height: 40 / 34,
      letterSpacing: -1.36,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 40 / 34,
      letterSpacing: -1.36,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 40 / 34,
      letterSpacing: -1.36,
      color: color,
    );
  }
}

class HeadingH2 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH2({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 39,
      fontWeight: FontWeight.w600,
      height: 47 / 39,
      letterSpacing: -0.78,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 39,
      fontWeight: FontWeight.w700,
      height: 47 / 39,
      letterSpacing: -0.78,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 39,
      fontWeight: FontWeight.w800,
      height: 47 / 39,
      letterSpacing: -0.78,
      color: color,
    );
  }
}

class HeadingH2Small {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH2Small({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 33,
      fontWeight: FontWeight.w600,
      height: 40 / 33,
      letterSpacing: -0.66,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 33,
      fontWeight: FontWeight.w700,
      height: 40 / 33,
      letterSpacing: -0.66,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 33,
      fontWeight: FontWeight.w800,
      height: 40 / 33,
      letterSpacing: -0.66,
      color: color,
    );
  }
}

class HeadingH3 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH3({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 33,
      fontWeight: FontWeight.w600,
      height: 40 / 33,
      letterSpacing: -0.66,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 33,
      fontWeight: FontWeight.w700,
      height: 40 / 33,
      letterSpacing: -0.66,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 33,
      fontWeight: FontWeight.w800,
      height: 40 / 33,
      letterSpacing: -0.66,
      color: color,
    );
  }
}

class HeadingH3Small {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH3Small({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 34 / 28,
      letterSpacing: -0.56,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 34 / 28,
      letterSpacing: -0.56,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 34 / 28,
      letterSpacing: -0.56,
      color: color,
    );
  }
}

class HeadingH4 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH4({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 34 / 28,
      letterSpacing: -0.56,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 34 / 28,
      letterSpacing: -0.56,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 34 / 28,
      letterSpacing: -0.56,
      color: color,
    );
  }
}

class HeadingH4Small {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH4Small({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 23,
      fontWeight: FontWeight.w600,
      height: 28 / 23,
      letterSpacing: -0.46,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      height: 28 / 23,
      letterSpacing: -0.46,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 23,
      fontWeight: FontWeight.w800,
      height: 28 / 23,
      letterSpacing: -0.46,
      color: color,
    );
  }
}

class HeadingH5 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH5({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 23,
      fontWeight: FontWeight.w600,
      height: 28 / 23,
      letterSpacing: -0.46,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      height: 28 / 23,
      letterSpacing: -0.46,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 23,
      fontWeight: FontWeight.w800,
      height: 28 / 23,
      letterSpacing: -0.46,
      color: color,
    );
  }
}

class HeadingH5Small {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH5Small({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w700,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
  }
}

class HeadingH6 {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;
  late TextStyle regular;

  HeadingH6({required this.color}) {
    regular = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w400,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
    semiBold = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w700,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 23 / 19,
      letterSpacing: -0.38,
      color: color,
    );
  }
}

class HeadingH6Small {
  Color color;
  late TextStyle semiBold;
  late TextStyle bold;
  late TextStyle extraBold;

  HeadingH6Small({required this.color}) {
    semiBold = InterFonts.getAppFont(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 21 / 16,
      letterSpacing: -0.32,
      color: color,
    );
    bold = InterFonts.getAppFont(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 21 / 16,
      letterSpacing: -0.32,
      color: color,
    );
    extraBold = InterFonts.getAppFont(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 21 / 16,
      letterSpacing: -0.32,
      color: color,
    );
  }
}

class SubHeading {
  Color color;
  late TextStyle regular;
  late TextStyle semiBold;

  SubHeading({required this.color}) {
    regular = InterFonts.getAppFont(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 27 / 20,
      color: color,
    );
    semiBold = InterFonts.getAppFont(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 27 / 20,
      color: color,
    );
  }
}

class Paragraph01 {
  Color color;
  late TextStyle regular;
  late TextStyle semiBold;

  Paragraph01({required this.color}) {
    regular = InterFonts.getAppFont(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 24 / 18,
      color: color,
    );
    semiBold = InterFonts.getAppFont(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 21 / 18,
      color: color,
    );
  }
}

class Paragraph02 {
  Color color;
  late TextStyle regular;
  late TextStyle semiBold;

  Paragraph02({required this.color}) {
    regular = InterFonts.getAppFont(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 22 / 16,
      color: color,
    );
    semiBold = InterFonts.getAppFont(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 22 / 16,
      color: color,
    );
  }
}

class Paragraph03 {
  Color color;
  late TextStyle regular;
  late TextStyle semiBold;
  TextDecoration? decoration;
  Color? decorationColor;

  Paragraph03({required this.color, this.decoration, this.decorationColor}) {
    regular = InterFonts.getAppFont(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 18 / 14,
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
    );
    semiBold = InterFonts.getAppFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18 / 14,
        color: color,
        decoration: decoration);
  }
}

class Caption {
  Color color;
  late TextStyle regular;
  late TextStyle semiBold;
  late TextStyle semiBoldCaps;

  Caption({required this.color}) {
    regular = InterFonts.getAppFont(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      color: color,
    );
    semiBold = InterFonts.getAppFont(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      color: color,
    );
    semiBoldCaps = InterFonts.getAppFont(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 15.996 / 12,
      letterSpacing: 0.96,
      color: color,
    );
  }
}

class Footer {
  Color color;
  late TextStyle regular;
  late TextStyle semiBold;

  Footer({required this.color}) {
    regular = InterFonts.getAppFont(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 13 / 10,
      letterSpacing: 0.2,
      color: color,
    );
    semiBold = InterFonts.getAppFont(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      height: 13 / 10,
      letterSpacing: 0.2,
      color: color,
    );
  }
}
