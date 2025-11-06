import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/namma_logger.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
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
    TravelTicketModel? travelTicket,
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
  final TravelTicketModel? travelTicket;
  final String? errorMessage;
  final bool isSuccess;
}

class IRCTCScannerService {
  final _logger = NammaLogger();

  Future<IRCTCScannerResult> parseAndSaveIRCTCTicket(String qrData) async {
    try {
      // Check if this is IRCTC QR data
      if (!IRCTCQRParser.isIRCTCQRCode(qrData)) {
        return IRCTCScannerResult.error('Not a valid IRCTC QR code');
      }

      // Parse IRCTC ticket
      final irctcTicket = IRCTCQRParser.parseQRCode(qrData);
      if (irctcTicket == null) {
        return IRCTCScannerResult.error('Failed to parse IRCTC ticket data');
      }

      // Convert to travel ticket model for database storage
      final travelTicket = _convertIRCTCToTravelTicket(irctcTicket);

      // Save to database
      try {
        final ticketId = await getIt<WalletDatabase>().insertTravelTicket(
          travelTicket.toDatabase(),
        );
        final updatedTicket = travelTicket.copyWith(id: ticketId);

        return IRCTCScannerResult.success(
          IRCTCScannerContentType.irctcTicket,
          qrData,
          irctcTicket: irctcTicket,
          travelTicket: updatedTicket,
        );
      } on DuplicateTicketException catch (e) {
        _logger.warning('Duplicate IRCTC ticket detected: ${e.message}');
        return IRCTCScannerResult.error(e.message);
      } catch (e) {
        _logger.error('Failed to save IRCTC ticket to database: $e');
        return IRCTCScannerResult.error('Failed to save ticket: $e');
      }
    } on Exception catch (e) {
      _logger.error('Unexpected exception in IRCTC scanner service: $e');
      return IRCTCScannerResult.error('Unexpected error occurred: $e');
    }
  }

  TravelTicketModel _convertIRCTCToTravelTicket(IRCTCTicket irctcTicket) {
    // Format dates as strings
    final journeyDateStr =
        '${irctcTicket.dateOfJourney.year}-'
        '${irctcTicket.dateOfJourney.month.toString().padLeft(2, '0')}-'
        '${irctcTicket.dateOfJourney.day.toString().padLeft(2, '0')}';

    final departureTimeStr =
        '${irctcTicket.scheduledDeparture.hour.toString().padLeft(2, '0')}:'
        '${irctcTicket.scheduledDeparture.minute.toString().padLeft(2, '0')}';

    // Convert status string to TicketStatus enum
    final ticketStatus = irctcTicket.status.toLowerCase().contains('cancelled')
        ? TicketStatus.cancelled
        : irctcTicket.status.toLowerCase().contains('pending')
        ? TicketStatus.pending
        : TicketStatus.confirmed;

    return TravelTicketModel(
      ticketType: TicketType.train,
      providerName: 'IRCTC',
      pnrNumber: irctcTicket.pnrNumber,
      passengerName: irctcTicket.passengerName,
      sourceLocation: irctcTicket.fromStation,
      destinationLocation: irctcTicket.toStation,
      boardingPoint: irctcTicket.boardingStation,
      departureTime: departureTimeStr,
      journeyDate: journeyDateStr,
      tripCode: irctcTicket.trainNumber,
      amount: irctcTicket.ticketFare + irctcTicket.irctcFee,
      sourceType: SourceType.scanner,
      rawData: irctcTicket.toReadableString(),
      classOfService: irctcTicket.travelClass,
      passengerAge: irctcTicket.age,
      passengerGender: irctcTicket.gender,
      status: ticketStatus,
      bookingReference: irctcTicket.transactionId,
    );
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
      backgroundColor = Colors.green;

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
