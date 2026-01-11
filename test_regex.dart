// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final pdfText = File(
    'test/assets/tnstc/ocr_text_T75229209.txt',
  ).readAsStringSync();

  // Test the regex
  final match = RegExp(
    r'Passenger Pickup Point\s*:\s*([\s\S]+?)(?=Platform Number|Passenger Pickup Time|Trip Code|$)',
  ).firstMatch(pdfText);

  print('Raw match: "${match?.group(1)}"');

  final raw = match?.group(1) ?? '';
  var cleaned = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  print('Cleaned: "$cleaned"');

  // Test reversed pattern
  final reversedPattern = RegExp(r'^([A-Z]+\))\s+([A-Z]+\([A-Z]+)$');
  final reversedMatch = reversedPattern.firstMatch(cleaned);
  print('Reversed match: ${reversedMatch != null}');
  if (reversedMatch != null) {
    print('Group 1: ${reversedMatch.group(1)}');
    print('Group 2: ${reversedMatch.group(2)}');
    cleaned = '${reversedMatch.group(2)} ${reversedMatch.group(1)}'.trim();
    print('Fixed: "$cleaned"');
  }
}
