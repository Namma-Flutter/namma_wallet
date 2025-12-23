import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
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
    required IImportService importService,
  }) : _logger = logger,
       _travelParserService = travelParser,
       _ticketDao = ticketDao,
       _importService = importService;

  final ILogger _logger;
  final ITravelParser _travelParserService;
  final ITicketDAO _ticketDao;
  final IImportService _importService;

  @override
  Future<SharedContentResult> processContent(
    String content,
    SharedContentType contentType,
  ) async {
    try {
      _logger.info('Processing shared content');

      if (contentType == SharedContentType.pkpass) {
        _logger.info('Processing PKPass file via SharedContentProcessor');
        final ticket = await _importService.importAndSavePKPassFile(
          XFile(content),
        );
        if (ticket == null) {
          return const ProcessingErrorResult(
            message: 'Failed to process PKPass file',
            error: 'Parser returned null',
          );
        }
        return TicketCreatedResult(
          pnrNumber: ticket.pnrOrId ?? 'Unknown',
          from: ticket.fromLocation ?? 'Unknown',
          to: ticket.toLocation ?? 'Unknown',
          fare: ticket.fare ?? 'Unknown',
          date: ticket.date,
        );
      }

      if (contentType == SharedContentType.sms) {
        final updateInfo = _travelParserService.parseUpdateSMS(content);
        if (updateInfo != null) {
          _logger.info('Update found for PNR: ${updateInfo.pnrNumber}');

          // Create a partial ticket with the updates for merging
          final updateTicket = Ticket(
            ticketId: updateInfo.pnrNumber,
            primaryText: '', // Empty values ignored by merge
            secondaryText: '',
            location: '',
            extras: updateInfo.updates.entries
                .map<ExtrasModel>(
                  (e) => ExtrasModel(title: e.key, value: e.value?.toString()),
                )
                .toList(),
          );

          // Check if ticket exists before updating
          final existing = await _ticketDao.getTicketById(updateInfo.pnrNumber);
          if (existing == null) {
            _logger.warning(
              'Ticket not found for update: ${updateInfo.pnrNumber}',
            );
            return TicketNotFoundResult(pnrNumber: updateInfo.pnrNumber);
          }

          final result = await _ticketDao.handleTicket(updateTicket);

          if (result > 0) {
            _logger.success('Ticket updated successfully');
            return TicketUpdatedResult(
              pnrNumber: updateInfo.pnrNumber,
              updateType: updateInfo.updates.keys.contains('conductorContact')
                  ? 'Conductor Details'
                  : 'Ticket Update',
            );
          } else {
            _logger.warning(
              'Ticket not found for update: ${updateInfo.pnrNumber}',
            );
            return TicketNotFoundResult(pnrNumber: updateInfo.pnrNumber);
          }
        }
      }

      final sourceType = contentType == SharedContentType.pdf
          ? SourceType.pdf
          : SourceType.sms;

      final ticket = _travelParserService.parseTicketFromText(
        content,
        sourceType: sourceType,
      );

      if (ticket == null) {
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
}
