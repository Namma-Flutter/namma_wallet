import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_ticket_model.dart';

enum IRCTCScannerContentType {
  irctcTicket,
  invalid,
}

class IRCTCScannerResult {
  const IRCTCScannerResult({
    required this.type,
    required this.isSuccess,
    this.content,
    this.irctcTicket,
    this.travelTicket,
    this.errorMessage,
  });

  factory IRCTCScannerResult.success(
    IRCTCScannerContentType type,
    String content, {
    IRCTCTicket? irctcTicket,
    Ticket? travelTicket,
  }) {
    return IRCTCScannerResult(
      type: type,
      content: content,
      irctcTicket: irctcTicket,
      travelTicket: travelTicket,
      isSuccess: true,
    );
  }

  factory IRCTCScannerResult.error(String errorMessage) {
    return IRCTCScannerResult(
      type: IRCTCScannerContentType.invalid,
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }

  final IRCTCScannerContentType type;
  final String? content;
  final IRCTCTicket? irctcTicket;
  final Ticket? travelTicket;
  final String? errorMessage;
  final bool isSuccess;
}

class IRCTCScannerService {
  IRCTCScannerService({ILogger? logger, IRCTCQRParser? qrParser})
    : _logger = logger ?? getIt<ILogger>(),
      _qrParser = qrParser ?? getIt<IRCTCQRParser>();
  final ILogger _logger;
  final IRCTCQRParser _qrParser;

  Future<IRCTCScannerResult> parseAndSaveIRCTCTicket(String qrData) async {
    try {
      // Check if this is IRCTC QR data
      if (!_qrParser.isIRCTCQRCode(qrData)) {
        return IRCTCScannerResult.error('Not a valid IRCTC QR code');
      }

      // Parse IRCTC ticket
      final irctcTicket = _qrParser.parseQRCode(qrData);
      if (irctcTicket == null) {
        return IRCTCScannerResult.error('Failed to parse IRCTC ticket data');
      }

      // Convert to travel ticket model for database storage
      final travelTicket = Ticket.fromIRCTC(irctcTicket);

      // Save to database
      try {
        final _ = await getIt<ITicketDAO>().insertTicket(
          travelTicket,
        );
        final updatedTicket = travelTicket.copyWith(
          ticketId: travelTicket.ticketId,
        );

        return IRCTCScannerResult.success(
          IRCTCScannerContentType.irctcTicket,
          qrData,
          irctcTicket: irctcTicket,
          travelTicket: updatedTicket,
        );
      } on Exception catch (e, stackTrace) {
        _logger.error('Error saving IRCTC ticket', e, stackTrace);
        return IRCTCScannerResult.error('Failed to save ticket: $e');
      } on Object catch (e, stackTrace) {
        _logger.error('Failed to save IRCTC ticket to database', e, stackTrace);
        return IRCTCScannerResult.error('Failed to save ticket: $e');
      }
    } on Exception catch (e) {
      _logger.error('Unexpected exception in IRCTC scanner service: $e');
      return IRCTCScannerResult.error('Unexpected error occurred: $e');
    }
  }

  void showResultMessage(BuildContext context, IRCTCScannerResult result) {
    if (!context.mounted) return;

    String message;
    Color backgroundColor;

    if (result.isSuccess) {
      message = switch (result.type) {
        IRCTCScannerContentType.irctcTicket =>
          'IRCTC ticket saved successfully!',
        IRCTCScannerContentType.invalid => 'Invalid content',
      };
      backgroundColor = Theme.of(context).colorScheme.primary;

      _logger.success('IRCTC scanner operation succeeded: $message');
    } else {
      message = result.errorMessage ?? 'Unknown error occurred';
      backgroundColor = Colors.red;

      _logger.error('IRCTC scanner operation failed: $message');
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
