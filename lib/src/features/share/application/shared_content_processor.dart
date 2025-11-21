import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/share/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

/// Content type for shared content
enum SharedContentType {
  /// SMS text content
  sms,

  /// PDF file content (text extracted from PDF)
  pdf,
}

/// Service to process shared content (SMS, PDF text) into tickets
///
/// Handles:
/// - Parsing ticket information from text
/// - Checking for ticket updates (conductor details, etc.)
/// - Updating existing tickets in database
/// - Creating new tickets in database
class SharedContentProcessor {
  SharedContentProcessor({
    ILogger? logger,
    TravelParserService? travelParser,
    SMSService? smsService,
    TNSTCPDFParser? pdfParser,
    ITicketDAO? ticketDao,
  }) : _logger = logger ?? getIt<ILogger>(),
       _travelParserService = travelParser ?? getIt<TravelParserService>(),
       _smsService = smsService ?? getIt<SMSService>(),
       _pdfParser = pdfParser ?? getIt<TNSTCPDFParser>(),
       _ticketDao = ticketDao ?? getIt<ITicketDAO>();

  final ILogger _logger;
  final TravelParserService _travelParserService;
  final SMSService _smsService;
  final TNSTCPDFParser _pdfParser;
  final ITicketDAO _ticketDao;

  /// Process shared content and return the result
  ///
  /// Attempts to:
  /// 1. Check if content is an update SMS (conductor details, etc.)
  /// 2. If update: apply to existing ticket in DB
  /// 3. If not update: parse as new ticket and save to DB
  ///
  /// [contentType] specifies whether the content is from SMS or PDF
  ///
  /// Returns a [SharedContentResult] indicating success or failure
  Future<SharedContentResult> processContent(
    String content,
    SharedContentType contentType,
  ) async {
    try {
      _logger.info('Processing shared content');

      // First, check if this is an update SMS (e.g., conductor details)
      final updateInfo = _travelParserService.parseUpdateSMS(content);

      if (updateInfo != null) {
        // This is an update SMS. Attempt to apply the update.
        final count = await _ticketDao.updateTicketById(
          updateInfo.pnrNumber,
          updateInfo.updates,
        );

        if (count > 0) {
          _logger.success(
            'Ticket updated successfully via shared content',
          );

          return TicketUpdatedResult(
            pnrNumber: updateInfo.pnrNumber,
            updateType: 'Conductor Details',
          );
        } else {
          _logger.warning(
            'Update SMS received via sharing, but no matching ticket found',
          );

          return TicketNotFoundResult(
            pnrNumber: updateInfo.pnrNumber,
          );
        }
      }

      // If it's not an update SMS, proceed with parsing as a new ticket.
      // Use the appropriate parser based on content type
      final ticket = contentType == SharedContentType.pdf
          ? _pdfParser.parseTicket(content)
          : _smsService.parseTicket(content);
      await _insertOrUpdateTicket(ticket);

      final contentSource = contentType == SharedContentType.pdf
          ? 'PDF'
          : 'SMS';
      _logger.success(
        'Shared $contentSource processed successfully for '
        'PNR: ${ticket.ticketId}',
      );

      return TicketCreatedResult(
        pnrNumber: ticket.pnrOrId ?? 'Unknown',
        from: ticket.fromLocation ?? 'Unknown',
        to: ticket.toLocation ?? 'Unknown',
        fare: ticket.fare ?? 'Unknown',
        date: ticket.date,
      );
    } on Object catch (e, stackTrace) {
      _logger.error(
        'Error processing shared content',
        e,
        stackTrace,
      );

      return ProcessingErrorResult(
        message: 'Failed to process shared content',
        error: e.toString(),
      );
    }
  }

  /// Insert or update a ticket in the database
  Future<void> _insertOrUpdateTicket(Ticket ticket) async {
    final id = ticket.ticketId;
    if (id == null || id.trim().isEmpty) {
      // Skip tickets with null or empty/whitespace ticketId
      return;
    }

    // Delegate to DAO's upsert logic
    // insertTicket handles both insert and update based on ticketId
    await _ticketDao.insertTicket(ticket);
  }
}
