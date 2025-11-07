import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_ticket_parser.dart';

enum PDFParserContentType {
  travelTicket,
  unsupported,
}

class PDFParserResult {
  const PDFParserResult({
    required this.type,
    required this.isSuccess,
    this.content,
    this.travelTicket,
    this.errorMessage,
  });

  factory PDFParserResult.success(
    PDFParserContentType type,
    String content, {
    TravelTicketModel? travelTicket,
  }) {
    return PDFParserResult(
      type: type,
      content: content,
      travelTicket: travelTicket,
      isSuccess: true,
    );
  }

  factory PDFParserResult.error(String errorMessage) {
    return PDFParserResult(
      type: PDFParserContentType.unsupported,
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }

  final PDFParserContentType type;
  final String? content;
  final TravelTicketModel? travelTicket;
  final String? errorMessage;
  final bool isSuccess;
}

class PDFParserService {
  ILogger get _logger => getIt<ILogger>();

  /// Helper method to create a non-identifying summary of parsed ticket data
  /// for safe logging in dev/staging environments
  Map<String, dynamic> _createTicketSummary(TNSTCTicket ticket) {
    // Count non-null fields
    var fieldCount = 0;
    if (ticket.corporation != null) fieldCount++;
    if (ticket.pnrNumber != null) fieldCount++;
    if (ticket.journeyDate != null) fieldCount++;
    if (ticket.routeNo != null) fieldCount++;
    if (ticket.serviceStartPlace != null) fieldCount++;
    if (ticket.serviceEndPlace != null) fieldCount++;
    if (ticket.serviceStartTime != null) fieldCount++;
    if (ticket.passengerStartPlace != null) fieldCount++;
    if (ticket.passengerEndPlace != null) fieldCount++;
    if (ticket.passengerPickupPoint != null) fieldCount++;
    if (ticket.passengerPickupTime != null) fieldCount++;
    if (ticket.platformNumber != null) fieldCount++;
    if (ticket.classOfService != null) fieldCount++;
    if (ticket.tripCode != null) fieldCount++;
    if (ticket.obReferenceNumber != null) fieldCount++;
    if (ticket.numberOfSeats != null) fieldCount++;
    if (ticket.bankTransactionNumber != null) fieldCount++;
    if (ticket.busIdNumber != null) fieldCount++;
    if (ticket.passengerCategory != null) fieldCount++;
    if (ticket.passengerInfo != null) fieldCount++;
    if (ticket.idCardType != null) fieldCount++;
    if (ticket.idCardNumber != null) fieldCount++;
    if (ticket.totalFare != null) fieldCount++;

    return {
      'totalFieldsParsed': fieldCount,
      'ticketType': 'TNSTC',
      'hasCorporation': ticket.corporation != null,
      'hasPnrNumber': ticket.pnrNumber != null,
      'pnrLast4': ticket.pnrNumber != null && ticket.pnrNumber!.length >= 4
          ? '...${ticket.pnrNumber!.substring(ticket.pnrNumber!.length - 4)}'
          : null,
      'hasJourneyDate': ticket.journeyDate != null,
      'hasRouteInfo': ticket.routeNo != null,
      'hasServicePlaces':
          ticket.serviceStartPlace != null && ticket.serviceEndPlace != null,
      'hasPassengerPlaces':
          ticket.passengerStartPlace != null &&
          ticket.passengerEndPlace != null,
      'hasPickupInfo':
          ticket.passengerPickupPoint != null ||
          ticket.passengerPickupTime != null,
      'hasPlatformNumber': ticket.platformNumber != null,
      'hasClassOfService': ticket.classOfService != null,
      'hasTripCode': ticket.tripCode != null,
      'hasBookingReference': ticket.obReferenceNumber != null,
      'numberOfSeats': ticket.numberOfSeats,
      'hasBankTransaction': ticket.bankTransactionNumber != null,
      'hasBusIdNumber': ticket.busIdNumber != null,
      'hasPassengerCategory': ticket.passengerCategory != null,
      'hasPassengerInfo': ticket.passengerInfo != null,
      'hasIdCard': ticket.idCardType != null || ticket.idCardNumber != null,
      'idCardType': ticket.idCardType,
      'hasTotalFare': ticket.totalFare != null,
    };
  }

  Future<PDFParserResult> parseAndSavePDFTicket(File pdfFile) async {
    try {
      _logger.logService('PDF', 'Starting PDF ticket parsing');

      // Extract text from PDF
      final pdfService = PDFService();
      final extractedText = pdfService.extractTextFrom(pdfFile);

      _logger.logService(
        'PDF',
        'File size: ${pdfFile.lengthSync()} bytes, '
            'Extracted text length: ${extractedText.length}',
      );

      if (extractedText.trim().isEmpty) {
        _logger.warning('No text content found in PDF');
        return PDFParserResult.error('No text content found in PDF');
      }

      // Log text metadata only (no PII)
      final lineCount = extractedText.split('\n').length;
      final wordCount = extractedText.split(RegExp(r'\s+')).length;
      _logger.debug(
        'PDF text metadata: $lineCount lines, $wordCount words, '
        '${extractedText.length} chars',
      );

      // Check if any keywords are present
      final keywords = [
        'Corporation',
        'PNR',
        'Service',
        'Journey',
        'TNSTC',
        'SETC',
      ];
      final foundKeywords = keywords
          .where(
            (keyword) =>
                extractedText.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();

      _logger.debug('Found keywords: $foundKeywords');

      // Try to parse using TNSTC PDF parser first
      TravelTicketModel? parsedTicket;

      // Check if it's a TNSTC ticket
      if (foundKeywords.any(
        (k) => ['TNSTC', 'Corporation', 'PNR'].contains(k),
      )) {
        try {
          _logger.logTicketParsing(
            'PDF',
            'Attempting to parse as TNSTC ticket',
          );
          final tnstcTicket = TNSTCPDFParser.parseTicket(extractedText);

          // Log non-identifying summary of parsed ticket (safe for dev/staging)
          final ticketSummary = _createTicketSummary(tnstcTicket);
          _logger
            ..debug('=== PARSED TNSTC TICKET SUMMARY (Non-PII) ===')
            ..debug('Ticket Summary: $ticketSummary')
            ..debug('=== END PARSED TNSTC TICKET SUMMARY ===');

          parsedTicket = _convertTNSTCToTravelTicket(tnstcTicket);
          final pnrMasked =
              tnstcTicket.pnrNumber != null &&
                  tnstcTicket.pnrNumber!.length >= 4
              ? '...${tnstcTicket.pnrNumber!.substring(
                  tnstcTicket.pnrNumber!.length - 4,
                )}'
              : 'N/A';
          _logger.logTicketParsing(
            'PDF',
            'Parsed TNSTC ticket successfully (PNR: $pnrMasked)',
          );
        } on Object catch (e, stackTrace) {
          _logger.error(
            'Failed to parse as TNSTC ticket',
            e,
            stackTrace,
          );
        }
      }

      if (parsedTicket == null) {
        _logger.warning(
          'PDF content does not match any supported ticket format. '
          'Found keywords: $foundKeywords',
        );
        return PDFParserResult.error(
          'PDF content does not match any supported ticket format. '
          'Found keywords: $foundKeywords',
        );
      }

      // Save to database
      try {
        _logger.logDatabase('Insert', 'Saving parsed PDF ticket to database');
        final ticketId = await getIt<WalletDatabase>().insertTravelTicket(
          parsedTicket.toDatabase(),
        );
        final updatedTicket = parsedTicket.copyWith(id: ticketId);

        _logger.success('PDF ticket saved successfully with ID: $ticketId');
        return PDFParserResult.success(
          PDFParserContentType.travelTicket,
          extractedText,
          travelTicket: updatedTicket,
        );
      } on DuplicateTicketException catch (e) {
        _logger.warning('Duplicate PDF ticket detected: ${e.message}');
        return PDFParserResult.error(e.message);
      } on Object catch (e, stackTrace) {
        _logger.error(
          'Failed to save PDF ticket to database',
          e,
          stackTrace,
        );
        return PDFParserResult.error('Failed to save ticket: $e');
      }
    } on Object catch (e, stackTrace) {
      _logger.error(
        'Unexpected exception in PDF parser service',
        e,
        stackTrace,
      );
      return PDFParserResult.error('Error processing PDF: $e');
    }
  }

  void showResultMessage(BuildContext context, PDFParserResult result) {
    if (!context.mounted) return;

    String message;
    Color backgroundColor;

    if (result.isSuccess) {
      message = switch (result.type) {
        PDFParserContentType.travelTicket => 'PDF ticket saved successfully!',
        PDFParserContentType.unsupported => 'PDF format not supported',
      };
      backgroundColor = Colors.green;
      _logger.success('PDF parser operation succeeded: $message');
    } else {
      message = result.errorMessage ?? 'Unknown error occurred';
      backgroundColor = Colors.red;
      _logger.error('PDF parser operation failed: $message');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: result.isSuccess ? 2 : 3),
      ),
    );
  }

  TravelTicketModel _convertTNSTCToTravelTicket(TNSTCTicket tnstcTicket) {
    // Debug logging for TNSTC conversion (non-identifying summary)
    final hasServicePlaces =
        tnstcTicket.serviceStartPlace != null &&
        tnstcTicket.serviceEndPlace != null;
    final hasPassengerPlaces =
        tnstcTicket.passengerStartPlace != null &&
        tnstcTicket.passengerEndPlace != null;
    _logger.debug(
      'Converting TNSTC to TravelTicket: '
      'hasServicePlaces=$hasServicePlaces, '
      'hasPassengerPlaces=$hasPassengerPlaces, '
      'hasServiceStartTime=${tnstcTicket.serviceStartTime != null}, '
      'hasPnr=${tnstcTicket.pnrNumber != null}',
    );

    // Convert TNSTC ticket to TravelTicketModel
    return TravelTicketModel(
      ticketType: TicketType.bus,
      providerName: tnstcTicket.corporation ?? 'TNSTC',
      pnrNumber: tnstcTicket.pnrNumber,
      tripCode: tnstcTicket.tripCode,
      sourceLocation:
          tnstcTicket.serviceStartPlace ?? tnstcTicket.passengerStartPlace,
      destinationLocation:
          tnstcTicket.serviceEndPlace ?? tnstcTicket.passengerEndPlace,
      journeyDate: tnstcTicket.journeyDate?.toIso8601String(),
      departureTime: tnstcTicket.serviceStartTime,
      seatNumbers: tnstcTicket.passengerInfo?.seatNumber,
      classOfService: tnstcTicket.classOfService,
      boardingPoint: tnstcTicket.passengerPickupPoint,
      amount: tnstcTicket.totalFare,
      passengerName: tnstcTicket.passengerInfo?.name,
      passengerAge: tnstcTicket.passengerInfo?.age,
      passengerGender: tnstcTicket.passengerInfo?.gender,
      bookingReference: tnstcTicket.obReferenceNumber,
      coachNumber: tnstcTicket.busIdNumber,
      sourceType: SourceType.pdf,
      rawData: tnstcTicket.toString(),
    );
  }
}
