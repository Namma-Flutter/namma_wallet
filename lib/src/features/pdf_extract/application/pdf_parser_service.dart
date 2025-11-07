import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/namma_logger.dart';
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
  NammaLogger get _logger => getIt<NammaLogger>();

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

      // Log complete extracted text for debugging
      _logger
        ..debug('=== FULL EXTRACTED PDF TEXT ===')
        ..debug(extractedText)
        ..debug('=== END EXTRACTED PDF TEXT ===');

      // Also log preview for quick reference
      final textPreview = extractedText.length > 300
          ? '${extractedText.substring(0, 300)}...'
          : extractedText;
      _logger.debug('Extracted text preview: $textPreview');

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

          // Log all parsed TNSTC ticket values
          _logger
            ..debug('=== PARSED TNSTC TICKET VALUES ===')
            ..debug('Corporation: "${tnstcTicket.corporation}"')
            ..debug('PNR Number: "${tnstcTicket.pnrNumber}"')
            ..debug('Journey Date: "${tnstcTicket.journeyDate}"')
            ..debug('Route No: "${tnstcTicket.routeNo}"')
            ..debug(
              'Service Start Place: "${tnstcTicket.serviceStartPlace}"',
            )
            ..debug('Service End Place: "${tnstcTicket.serviceEndPlace}"')
            ..debug(
              'Service Start Time: "${tnstcTicket.serviceStartTime}"',
            )
            ..debug(
              'Passenger Start Place: "${tnstcTicket.passengerStartPlace}"',
            )
            ..debug(
              'Passenger End Place: "${tnstcTicket.passengerEndPlace}"',
            )
            ..debug(
              'Passenger Pickup Point: "${tnstcTicket.passengerPickupPoint}"',
            )
            ..debug(
              'Passenger Pickup Time: "${tnstcTicket.passengerPickupTime}"',
            )
            ..debug('Platform Number: "${tnstcTicket.platformNumber}"')
            ..debug('Class of Service: "${tnstcTicket.classOfService}"')
            ..debug('Trip Code: "${tnstcTicket.tripCode}"')
            ..debug(
              'OB Reference Number: "${tnstcTicket.obReferenceNumber}"',
            )
            ..debug('Number of Seats: "${tnstcTicket.numberOfSeats}"')
            ..debug(
              'Bank Transaction Number: "${tnstcTicket.bankTransactionNumber}"',
            )
            ..debug('Bus ID Number: "${tnstcTicket.busIdNumber}"')
            ..debug(
              'Passenger Category: "${tnstcTicket.passengerCategory}"',
            )
            ..debug('Passenger Name: "${tnstcTicket.passengerInfo?.name}"')
            ..debug('Passenger Age: "${tnstcTicket.passengerInfo?.age}"')
            ..debug('Passenger Type: "${tnstcTicket.passengerInfo?.type}"')
            ..debug(
              'Passenger Gender: "${tnstcTicket.passengerInfo?.gender}"',
            )
            ..debug(
              'Passenger Seat No: "${tnstcTicket.passengerInfo?.seatNumber}"',
            )
            ..debug('ID Card Type: "${tnstcTicket.idCardType}"')
            ..debug('ID Card Number: "${tnstcTicket.idCardNumber}"')
            ..debug('Total Fare: "${tnstcTicket.totalFare}"')
            ..debug('=== END PARSED TNSTC TICKET VALUES ===');

          parsedTicket = _convertTNSTCToTravelTicket(tnstcTicket);
          _logger.logTicketParsing(
            'PDF',
            'Parsed TNSTC ticket with PNR: ${tnstcTicket.pnrNumber}',
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
    // Debug logging for TNSTC conversion
    _logger
      ..debug('Converting TNSTC to TravelTicket')
      ..debug('serviceStartPlace: "${tnstcTicket.serviceStartPlace}"')
      ..debug('serviceEndPlace: "${tnstcTicket.serviceEndPlace}"')
      ..debug('passengerStartPlace: "${tnstcTicket.passengerStartPlace}"')
      ..debug('passengerEndPlace: "${tnstcTicket.passengerEndPlace}"')
      ..debug('serviceStartTime: "${tnstcTicket.serviceStartTime}"')
      ..debug('pnrNumber: "${tnstcTicket.pnrNumber}"');

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
