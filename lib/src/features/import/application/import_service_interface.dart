import 'dart:io';

import 'package:namma_wallet/src/common/domain/models/ticket.dart';

abstract interface class IImportService {
  /// Import a PDF file and parse it as a travel ticket
  ///
  /// Returns the parsed ticket if successful, null otherwise
  Future<Ticket?> importAndSavePDFFile(File pdfFile);

  /// Import QR code data and parse it as a travel ticket
  ///
  /// Returns the parsed ticket if successful, null otherwise
  Future<Ticket?> importQRCode(String qrData);

  /// Check if QR code data represents a supported ticket format
  bool isSupportedQRCode(String qrData);

  /// Get list of supported file extensions for import
  List<String> get supportedExtensions;
}
