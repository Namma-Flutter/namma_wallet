import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_content_type.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_result.dart';
import 'package:namma_wallet/src/features/clipboard/domain/i_clipboard_repository.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/common/enums/source_type.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Application service for clipboard operations.
///
/// Orchestrates clipboard reading, content validation, parsing,
/// and ticket storage. Acts as a use case coordinator between
/// the clipboard repository, parser service, and database.
///
/// Never throws - all errors are returned as [ClipboardResult.error].
class ClipboardService {
  /// Creates a clipboard service.
  ///
  /// [repository] - Repository for clipboard access
  /// [logger] - Logger for debugging
  /// [parserService] - Service for parsing travel tickets
  /// [database] - Database for storing tickets
  ///
  /// Uses GetIt to resolve dependencies if not provided.
  ClipboardService({
    IClipboardRepository? repository,
    ILogger? logger,
    TravelParserService? parserService,
    WalletDatabase? database,
  })  : _repository = repository ?? getIt<IClipboardRepository>(),
        _logger = logger ?? getIt<ILogger>(),
        _parserService = parserService ?? getIt<TravelParserService>(),
        _database = database ?? getIt<WalletDatabase>();

  final IClipboardRepository _repository;
  final ILogger _logger;
  final TravelParserService _parserService;
  final WalletDatabase _database;

  /// Maximum allowed text length to prevent spam/abuse
  static const int maxTextLength = 10000;

  /// Reads clipboard content and attempts to parse it as a travel ticket.
  ///
  /// Workflow:
  /// 1. Check if clipboard has text content
  /// 2. Read and validate text content
  /// 3. Check if it's an update SMS (conductor details, etc.)
  /// 4. If update SMS, apply updates to existing ticket
  /// 5. Otherwise, attempt to parse as new ticket
  /// 6. Save new ticket to database
  /// 7. Return result with ticket or error
  ///
  /// Returns [ClipboardResult] with:
  /// - Success: Content type, raw text, and optional parsed ticket
  /// - Error: Error message describing what went wrong
  Future<ClipboardResult> readAndParseClipboard() async {
    try {
      // Step 1: Check if clipboard has content
      final hasContent = await _repository.hasTextContent();
      if (!hasContent) {
        return ClipboardResult.error('No content found in clipboard');
      }

      // Step 2: Read text content
      final content = await _repository.readText();
      if (content == null || content.isEmpty) {
        return ClipboardResult.error(
          'No text content found in clipboard. Please copy plain text.',
        );
      }

      // Step 3: Validate content
      if (!_isValidTextContent(content)) {
        return ClipboardResult.error(
          'Only plain text content is allowed from clipboard.',
        );
      }

      // Step 4: Check if this is an update SMS (conductor details, etc.)
      final updateInfo = _parserService.parseUpdateSMS(content);
      if (updateInfo != null) {
        return await _handleUpdateSMS(updateInfo, content);
      }

      // Step 5: Attempt to parse as new ticket
      final parsedTicket = _parserService.parseTicketFromText(
        content,
        sourceType: SourceType.clipboard,
      );

      if (parsedTicket != null) {
        return await _saveNewTicket(parsedTicket, content);
      }

      // Step 6: If not a travel ticket, return as plain text
      return ClipboardResult.success(ClipboardContentType.text, content);
    } on Exception catch (e) {
      _logger.error('Unexpected exception in clipboard service: $e');
      return ClipboardResult.error('Unexpected error occurred: $e');
    }
  }

  /// Alias for [readAndParseClipboard] for backward compatibility.
  Future<ClipboardResult> readClipboard() async {
    return readAndParseClipboard();
  }

  /// Handles update SMS by applying updates to existing ticket.
  ///
  /// Returns success if ticket was found and updated,
  /// error if no matching ticket was found.
  Future<ClipboardResult> _handleUpdateSMS(
    TicketUpdateInfo updateInfo,
    String content,
  ) async {
    final count = await _database.updateTicketById(
      updateInfo.pnrNumber,
      updateInfo.updates,
    );

    if (count > 0) {
      _logger.success('Ticket updated successfully via SMS');
      return ClipboardResult.success(
        ClipboardContentType.travelTicket,
        content,
      );
    } else {
      _logger.warning(
        'Update SMS received, but no matching ticket found',
      );
      return ClipboardResult.error(
        'Update SMS received, but the original ticket was not found in the '
        'wallet.',
      );
    }
  }

  /// Saves a new ticket to the database.
  ///
  /// Returns success with the saved ticket,
  /// or error if saving failed (e.g., duplicate ticket).
  Future<ClipboardResult> _saveNewTicket(
    Ticket parsedTicket,
    String content,
  ) async {
    try {
      await _database.insertTicket(parsedTicket);
      final updatedTicket = parsedTicket.copyWith(
        ticketId: parsedTicket.ticketId,
      );

      return ClipboardResult.success(
        ClipboardContentType.travelTicket,
        content,
        ticket: updatedTicket,
      );
    } on DuplicateTicketException catch (_) {
      final ticketId = parsedTicket.ticketId ?? '';
      final maskedPnr = ticketId.length >= 4
          ? '...${ticketId.substring(ticketId.length - 4)}'
          : '***';

      _logger.warning(
        'Duplicate ticket detected while saving clipboard import '
        '(PNR: $maskedPnr)',
      );
      return ClipboardResult.error('Duplicate ticket detected');
    } on Object catch (e) {
      _logger.error('Failed to save ticket to database: $e');
      return ClipboardResult.error('Failed to save ticket: $e');
    }
  }

  /// Validates text content length and format.
  ///
  /// Returns `true` if content is valid, `false` otherwise.
  bool _isValidTextContent(String text) {
    if (text.trim().isEmpty) return false;

    // Prevent spam/abuse with unreasonably long text
    if (text.length > maxTextLength) return false;

    return true;
  }

  /// Shows a snackbar message based on the clipboard result.
  ///
  /// Displays success message in primary color or error in red.
  /// Only shows if context is still mounted.
  void showResultMessage(BuildContext context, ClipboardResult result) {
    if (!context.mounted) return;

    String message;
    Color backgroundColor;

    if (result.isSuccess) {
      message = switch (result.type) {
        ClipboardContentType.text => 'Text content read successfully',
        ClipboardContentType.travelTicket =>
          result.ticket != null
              ? 'Travel ticket saved successfully!'
              : 'Ticket updated with conductor details!',
        ClipboardContentType.invalid => 'Invalid content',
      };
      backgroundColor = Theme.of(context).colorScheme.primary;

      _logger.success('Clipboard operation succeeded: $message');
    } else {
      message = result.errorMessage ?? 'Unknown error occurred';
      backgroundColor = Colors.red;

      _logger.error('Clipboard operation failed: $message');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: result.isSuccess ? 2 : 3),
      ),
    );
  }
}
