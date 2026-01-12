import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/receive/application/shared_content_processor_interface.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

/// Service to process shared content (SMS, PDF text) into tickets
///
/// Handles:
/// - Parsing ticket information from text
/// - Checking for ticket updates (conductor details, etc.)
/// - Updating existing tickets in database
/// - Creating new tickets in database
class SharedContentProcessor implements ISharedContentProcessor {
  SharedContentProcessor({
    required ILogger logger,
    required ITravelParser travelParser,
    required ITicketDAO ticketDao,
  }) : _logger = logger,
       _travelParserService = travelParser,
       _ticketDao = ticketDao;

  final ILogger _logger;
  final ITravelParser _travelParserService;
  final ITicketDAO _ticketDao;

  @override
  Future<SharedContentResult> processContent(
    String content,
    SharedContentType contentType,
  ) async {
    try {
      _logger.info('Processing shared content');

      final sourceType = contentType == SharedContentType.pdf
          ? SourceType.pdf
          : SourceType.sms;

      final ticket = _travelParserService.parseTicketFromText(
        content,
        sourceType: sourceType,
      );

      if (ticket == null) {
        // Try parsing as update SMS
        final updateInfo = _travelParserService.parseUpdateSMS(content);
        if (updateInfo != null) {
          return await _handleTicketUpdate(updateInfo);
        }

        _logger.warning('Failed to parse shared content as travel ticket');
        return const ProcessingErrorResult(
          message: 'Failed to parse content as travel ticket',
          error: 'No supported ticket format found',
        );
      }

      // Validate ticket has ID before inserting
      if (ticket.ticketId == null || ticket.ticketId!.trim().isEmpty) {
        _logger.error('Ticket parsed without ticketId');
        return const ProcessingErrorResult(
          message: 'Failed to process shared content',
          error: 'Missing ticketId for shared content',
        );
      }

      // Validate essential fields before insert
      if (ticket.pnrOrId == null ||
          ticket.fromLocation == null ||
          ticket.toLocation == null) {
        _logger.warning(
          'Ticket parsed with missing fields: pnr=${ticket.pnrOrId}, '
          'from=${ticket.fromLocation}, to=${ticket.toLocation}',
        );
      }

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
    } on Exception catch (e, stackTrace) {
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
    // Delegate to DAO's upsert logic
    // handleTicket handles both insert and update based on ticketId
    await _ticketDao.handleTicket(ticket);
  }

  /// Handle ticket update from SMS
  Future<SharedContentResult> _handleTicketUpdate(
    TicketUpdateInfo updateInfo,
  ) async {
    final existingTicket = await _ticketDao.getTicketById(updateInfo.pnrNumber);

    if (existingTicket == null) {
      _logger.warning('Ticket update received for non-existent PNR');
      return TicketNotFoundResult(pnrNumber: updateInfo.pnrNumber);
    }

    // Merge updates into existing ticket
    // TNSTC updates usually contain Conductor Mobile No or Vehicle No
    final updateType =
        updateInfo.updates.containsKey('conductorMobileNo') ||
            updateInfo.updates.containsKey('conductorContact') ||
            updateInfo.updates.containsKey('Conductor Mobile No')
        ? 'Conductor Details'
        : 'Bus Info';

    // Convert updates Map to Ticket with extras
    final updateTicket = Ticket(
      ticketId: updateInfo.pnrNumber,
      primaryText: existingTicket.primaryText,
      secondaryText: existingTicket.secondaryText,
      location: existingTicket.location,
      extras: updateInfo.updates.entries
          .map(
            (entry) => ExtrasModel(
              title: entry.key,
              value: entry.value.toString(),
            ),
          )
          .toList(),
    );

    // Merge the update ticket with existing ticket
    final mergedTicket = Ticket.mergeTickets(existingTicket, updateTicket);

    await _ticketDao.updateTicketById(
      updateInfo.pnrNumber,
      mergedTicket,
    );

    return TicketUpdatedResult(
      pnrNumber: updateInfo.pnrNumber,
      updateType: updateType,
    );
  }
}
