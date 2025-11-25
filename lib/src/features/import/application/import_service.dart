import 'dart:io';

import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

class ImportService implements IImportService {
  ImportService({
    required ILogger logger,
    required IPDFService pdfService,
    required ITravelParser travelParser,
    required IIRCTCQRParser qrParser,
    required IIRCTCScannerService irctcScannerService,
  }) : _logger = logger,
       _pdfService = pdfService,
       _travelParser = travelParser,
       _qrParser = qrParser,
       _irctcScannerService = irctcScannerService;

  final ILogger _logger;
  final IPDFService _pdfService;
  final ITravelParser _travelParser;
  final IIRCTCQRParser _qrParser;
  final IIRCTCScannerService _irctcScannerService;

  @override
  List<String> get supportedExtensions => const ['pdf'];

  @override
  bool isSupportedQRCode(String qrData) {
    return _qrParser.isIRCTCQRCode(qrData);
  }

  @override
  Future<Ticket?> importPDFFile(File pdfFile) async {
    try {
      // Use basename to avoid logging full path with sensitive directory info
      final filename = pdfFile.uri.pathSegments.last;
      _logger.info('Importing PDF file: $filename');

      // Extract text from PDF
      final extractedText = await _pdfService.extractTextFrom(pdfFile);

      if (extractedText.trim().isEmpty) {
        _logger.warning('No text extracted from PDF: $filename');
        return null;
      }

      // Parse the extracted text as a travel ticket
      final parsedTicket = _travelParser.parseTicketFromText(
        extractedText,
        sourceType: SourceType.pdf,
      );

      if (parsedTicket == null) {
        _logger.warning(
          'PDF content does not match any supported ticket format',
        );
        return null;
      }

      _logger.success(
        'Successfully imported PDF ticket: ${parsedTicket.ticketId}',
      );
      return parsedTicket;
    } on Object catch (e, stackTrace) {
      _logger.error('Error importing PDF file', e, stackTrace);
      return null;
    }
  }

  @override
  Future<Ticket?> importQRCode(String qrData) async {
    try {
      _logger.info('Importing QR code data');

      // Check if it's an IRCTC QR code
      if (!isSupportedQRCode(qrData)) {
        _logger.warning('QR code format not supported');
        return null;
      }

      // Use IRCTC scanner service to parse and save
      final result = await _irctcScannerService.parseAndSaveIRCTCTicket(qrData);

      if (result.isSuccess && result.travelTicket != null) {
        _logger.success(
          'Successfully imported QR ticket: ${result.travelTicket!.ticketId}',
        );
        return result.travelTicket!;
      } else {
        _logger.warning('Failed to import QR code: ${result.errorMessage}');
        return null;
      }
    } on Object catch (e, stackTrace) {
      _logger.error('Error importing QR code', e, stackTrace);
      return null;
    }
  }
}
