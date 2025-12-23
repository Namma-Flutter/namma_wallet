import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/travel/application/pkpass_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

class ImportService implements IImportService {
  ImportService({
    required ILogger logger,
    required IPDFService pdfService,
    required ITravelParser travelParser,
    required IIRCTCQRParser qrParser,
    required IIRCTCScannerService irctcScannerService,
    required IPKPassParser pkpassParser,
    required ITicketDAO ticketDao,
  }) : _logger = logger,
       _pdfService = pdfService,
       _travelParser = travelParser,
       _qrParser = qrParser,
       _irctcScannerService = irctcScannerService,
       _pkpassParser = pkpassParser,
       _ticketDao = ticketDao;

  final ILogger _logger;
  final IPDFService _pdfService;
  final ITravelParser _travelParser;
  final IIRCTCQRParser _qrParser;
  final IIRCTCScannerService _irctcScannerService;
  final IPKPassParser _pkpassParser;
  final ITicketDAO _ticketDao;

  @override
  List<String> get supportedExtensions => const ['pdf', 'pkpass'];

  @override
  bool isSupportedQRCode(String qrData) {
    return _qrParser.isIRCTCQRCode(qrData);
  }

  @override
  Future<Ticket?> importAndSavePDFFile(XFile pdfFile) async {
    try {
      // Use basename to avoid logging full path with sensitive directory info
      final filename = pdfFile.name;
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

      // Save the parsed ticket to the database
      await _ticketDao.handleTicket(parsedTicket);

      _logger.success(
        'Successfully imported and saved PDF ticket: ${parsedTicket.ticketId}',
      );
      return parsedTicket;
    } on Exception catch (e, stackTrace) {
      _logger.error('Error importing PDF file', e, stackTrace);
      return null;
    }
  }

  @override
  Future<Ticket?> importAndSavePKPassFile(XFile pkpassFile) async {
    try {
      final filename = pkpassFile.name;
      _logger.info('Importing pkpass file: $filename');

      final bytes = await pkpassFile.readAsBytes();
      final parsedTicket = await _pkpassParser.parsePKPass(bytes);

      if (parsedTicket == null) {
        _logger.warning('Failed to parse pkpass: $filename');
        return null;
      }

      await _ticketDao.handleTicket(parsedTicket);

      _logger.success(
        'Successfully imported and saved PKPass ticket: '
        '${parsedTicket.ticketId}',
      );
      return parsedTicket;
    } on Exception catch (e, stackTrace) {
      _logger.error('Error importing pkpass file', e, stackTrace);
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
    } on Exception catch (e, stackTrace) {
      _logger.error('Error importing QR code', e, stackTrace);
      return null;
    }
  }
}
