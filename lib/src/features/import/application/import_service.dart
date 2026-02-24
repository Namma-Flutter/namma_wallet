import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_api_ticket_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pnr_fetcher_interface.dart';
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
    required ITNSTCPNRFetcher tnstcPnrFetcher,
    required ITicketDAO ticketDao,
    TNSTCApiTicketParser? tnstcApiTicketParser,
  }) : _logger = logger,
       _pdfService = pdfService,
       _travelParser = travelParser,
       _qrParser = qrParser,
       _irctcScannerService = irctcScannerService,
       _pkpassParser = pkpassParser,
       _tnstcPnrFetcher = tnstcPnrFetcher,
       _tnstcApiTicketParser = tnstcApiTicketParser ?? TNSTCApiTicketParser(),
       _ticketDao = ticketDao;

  final ILogger _logger;
  final IPDFService _pdfService;
  final ITravelParser _travelParser;
  final IIRCTCQRParser _qrParser;
  final IIRCTCScannerService _irctcScannerService;
  final IPKPassParser _pkpassParser;
  final ITNSTCPNRFetcher _tnstcPnrFetcher;
  final TNSTCApiTicketParser _tnstcApiTicketParser;
  final ITicketDAO _ticketDao;

  @override
  List<String> get supportedExtensions => const ['pdf', 'pkpass'];

  @override
  bool isSupportedQRCode(String qrData) {
    return _qrParser.isIRCTCQRCode(qrData);
  }

  @override
  Future<Ticket?> importAndSavePDFFile(XFile pdfFile) async {
    // Use basename to avoid logging full path with sensitive directory info
    final filename = pdfFile.name;

    try {
      _logger.info('Importing PDF file: $filename');

      // Extract OCR blocks with geometry from PDF
      final extractedBlocks = await _pdfService.extractBlocks(pdfFile);

      if (extractedBlocks.isEmpty) {
        _logger.warning('No OCR blocks extracted from PDF: $filename');
        return null;
      }

      // Parse using OCR blocks (preserves geometry for layout extraction)
      final parsedTicket = _travelParser.parseTicketFromBlocks(
        extractedBlocks,
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
    } on Object catch (e, stackTrace) {
      if (e is UnsupportedError) {
        _logger.warning(
          'PDF import is not supported on web for this file: $filename. '
          'Web currently supports SMS extraction only.',
        );
        return null;
      }

      _logger.error('Error importing PDF file', e, stackTrace);
      return null;
    }
  }

  @override
  Future<TicketImportResult> importAndSavePKPassFile(XFile pkpassFile) async {
    try {
      final filename = pkpassFile.name;
      _logger.info('Importing pkpass file: $filename');

      final bytes = await pkpassFile.readAsBytes();
      final parsedTicket = await _pkpassParser.parsePKPass(bytes);

      if (parsedTicket == null) {
        _logger.warning('Failed to parse pkpass: $filename');
        return const TicketImportResult();
      }

      await _ticketDao.handleTicket(parsedTicket);

      _logger.success(
        'Successfully imported and saved PKPass ticket: '
        '${parsedTicket.ticketId}',
      );

      // Check provider for warning
      String? warning;
      final provider = parsedTicket.extras?.firstWhere(
        (e) => e.title?.toLowerCase() == 'provider',
        orElse: () => ExtrasModel(title: '', value: ''),
      );

      if (provider?.value?.toLowerCase().contains('luma') != true) {
        warning = 'Imported pass is not from Luma';
      }

      return TicketImportResult(ticket: parsedTicket, warning: warning);
    } on Exception catch (e, stackTrace) {
      _logger.error('Error importing pkpass file', e, stackTrace);
      return const TicketImportResult();
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

  @override
  Future<Ticket?> importTNSTCByPNR(String pnr, String phoneNumber) async {
    try {
      _logger.info('Importing TNSTC ticket by PNR');

      // Fetch ticket from TNSTC website
      final tnstcTicket = await _tnstcPnrFetcher.fetchTicketByPNR(
        pnr,
        phoneNumber,
      );

      if (tnstcTicket == null) {
        _logger.warning('Failed to fetch TNSTC ticket for PNR: $pnr');
        return null;
      }

      // Convert to generic Ticket model
      final ticket = _tnstcApiTicketParser.parse(tnstcTicket);

      // Save to database
      await _ticketDao.handleTicket(ticket);

      _logger.success(
        'Successfully imported and saved TNSTC ticket: ${ticket.ticketId}',
      );
      return ticket;
    } on Exception catch (e, stackTrace) {
      _logger.error('Error importing TNSTC ticket by PNR', e, stackTrace);
      return null;
    }
  }
}
