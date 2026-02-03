import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';

/// Result of a ticket import operation
class TicketImportResult {
  const TicketImportResult({
    this.ticket,
    this.warning,
  });

  final Ticket? ticket;
  final String? warning;
}

abstract interface class IImportService {
  /// Import a PDF file and parse it as a travel ticket
  ///
  /// Returns the parsed ticket if successful, null otherwise
  Future<Ticket?> importAndSavePDFFile(XFile pdfFile);

  /// Import a pkpass file and parse it as a travel ticket
  ///
  /// Returns the parsed ticket result
  Future<TicketImportResult> importAndSavePKPassFile(XFile pkpassFile);

  /// Import QR code data and parse it as a travel ticket
  ///
  /// Returns the parsed ticket if successful, null otherwise
  Future<Ticket?> importQRCode(String qrData);

  /// Import TNSTC ticket using PNR number
  ///
  /// Fetches ticket details from TNSTC website and saves it.
  /// Returns the parsed ticket if successful, null otherwise.
  Future<Ticket?> importTNSTCByPNR(String pnr);

  /// Check if QR code data represents a supported ticket format
  bool isSupportedQRCode(String qrData);

  /// Get list of supported file extensions for import
  List<String> get supportedExtensions;
}
