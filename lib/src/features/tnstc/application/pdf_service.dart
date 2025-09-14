import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService {
  String extractTextFrom(File pdf) {
    // Load an existing PDF document.
    final document = PdfDocument(inputBytes: pdf.readAsBytesSync());
    // Extract the text from all the pages.
    final text = PdfTextExtractor(document).extractText();
    // Dispose the document.
    document.dispose();
    return text;
  }
}
