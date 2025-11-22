import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

/// Extension to provide non-PII summary generation for TNSTCTicket
extension TNSTCTicketSummary on TNSTCTicketModel {
  /// Create a non-identifying summary map for safe logging
  Map<String, dynamic> toNonPiiSummary() {
    // List of all nullable fields to count
    final nullableFields = <dynamic Function()?>[
      () => corporation,
      () => pnrNumber,
      () => journeyDate,
      () => routeNo,
      () => serviceStartPlace,
      () => serviceEndPlace,
      () => serviceStartTime,
      () => passengerStartPlace,
      () => passengerEndPlace,
      () => passengerPickupPoint,
      () => passengerPickupTime,
      () => platformNumber,
      () => classOfService,
      () => tripCode,
      () => obReferenceNumber,
      () => numberOfSeats,
      () => bankTransactionNumber,
      () => busIdNumber,
      () => passengerCategory,
      () => passengers,
      () => idCardType,
      () => idCardNumber,
      () => totalFare,
    ];

    // Count non-null fields
    final fieldCount = nullableFields
        .where((getter) => getter?.call() != null)
        .length;

    return {
      'totalFieldsParsed': fieldCount,
      'ticketType': 'TNSTC',
      'hasCorporation': corporation != null,
      'hasPnrNumber': pnrNumber != null,
      'pnrLast4': pnrNumber != null && pnrNumber!.length >= 4
          ? '...${pnrNumber!.substring(pnrNumber!.length - 4)}'
          : null,
      'hasJourneyDate': journeyDate != null,
      'hasRouteInfo': routeNo != null,
      'hasServicePlaces': serviceStartPlace != null && serviceEndPlace != null,
      'hasPassengerPlaces':
          passengerStartPlace != null && passengerEndPlace != null,
      'hasPickupInfo':
          passengerPickupPoint != null || passengerPickupTime != null,
      'hasPlatformNumber': platformNumber != null,
      'hasClassOfService': classOfService != null,
      'hasTripCode': tripCode != null,
      'hasBookingReference': obReferenceNumber != null,
      'numberOfSeats': numberOfSeats,
      'hasBankTransaction': bankTransactionNumber != null,
      'hasBusIdNumber': busIdNumber != null,
      'hasPassengerCategory': passengerCategory != null,
      'hasPassengerInfo': passengers.isNotEmpty,
      'hasIdCard': idCardType != null || idCardNumber != null,
      'idCardType': idCardType,
      'hasTotalFare': totalFare != null,
    };
  }
}

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
    Ticket? travelTicket,
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
  final Ticket? travelTicket;
  final String? errorMessage;
  final bool isSuccess;
}

class PDFParserService {
  PDFParserService({
    ILogger? logger,
    TNSTCPDFParser? tnstcPdfParser,
    IRCTCPDFParser? irctcPdfParser,
  }) : _logger = logger ?? getIt<ILogger>(),
       _tnstcPdfParser = tnstcPdfParser ?? getIt<TNSTCPDFParser>(),
       _irctcPdfParser = irctcPdfParser ?? getIt<IRCTCPDFParser>();

  final ILogger _logger;
  final TNSTCPDFParser _tnstcPdfParser;
  final IRCTCPDFParser _irctcPdfParser;

  Future<PDFParserResult> parseAndSavePDFTicket(File pdfFile) async {
    try {
      _logger.logService('PDF', 'Starting PDF ticket parsing');

      // Extract text from PDF
      final pdfService = PDFService();
      final extractedText = await pdfService.extractTextFrom(pdfFile);

      _logger.logService(
        'PDF',
        'File size: ${pdfFile.lengthSync()} bytes, '
            'Extracted text length: ${extractedText.length}',
      );

      if (extractedText.trim().isEmpty) {
        _logger.warning(
          'No text content found in PDF - PDF may be image-based '
          'or unsupported',
        );
        return PDFParserResult.error(
          'Unable to read text from this PDF. '
          'This ticket may be in image format. '
          'Try importing using SMS/clipboard.',
        );
      }

      // Metadata only
      final lineCount = extractedText.split('\n').length;
      final wordCount = extractedText.split(RegExp(r'\s+')).length;

      _logger.debug(
        'PDF text metadata: $lineCount lines, $wordCount words, '
        '${extractedText.length} chars',
      );

      final tnstcKeywords = [
        'TNSTC',
        'SETC',
        'Corporation',
        'Service Start Place',
        'Service End Place',
        'OB Reference',
        'Passenger Pickup',
      ];

      final foundTNSTC = tnstcKeywords
          .where((k) => extractedText.toLowerCase().contains(k.toLowerCase()))
          .toList();

      _logger.debug('Found tnstcKeywords: $foundTNSTC');

      final irctcKeywords = [
        'Electronic Reservation Slip',
        'IRCTC',
        'ERS',
        'Train No',
        'Boarding From',
        'Passenger Details',
        'Acronyms',
        'Agent Details',
        'Departure',
        'Arrival',
        'Class',
        'Quota',
      ];

      final foundIRCTC = irctcKeywords
          .where((k) => extractedText.toLowerCase().contains(k.toLowerCase()))
          .toList();

      _logger.debug('Found irctcKeywords: $foundIRCTC');

      Ticket? parsedTicket;

      if (foundTNSTC.isNotEmpty &&
          foundTNSTC.any((k) => ['TNSTC', 'SETC', 'Corporation'].contains(k))) {
        try {
          _logger.logTicketParsing('PDF', 'Parsing as TNSTC ticket');

          final tnstcTicket = _tnstcPdfParser.parseTicket(extractedText);
          parsedTicket = tnstcTicket;

          final pnrMasked =
              (tnstcTicket.ticketId != null &&
                  tnstcTicket.ticketId!.length >= 4)
              ? '...${tnstcTicket.ticketId!.substring(
                  tnstcTicket.ticketId!.length - 4,
                )}'
              : 'N/A';

          _logger.logTicketParsing(
            'PDF',
            'Parsed TNSTC PDF successfully (PNR: $pnrMasked)',
          );
        } on Exception catch (e, st) {
          _logger.error('TNSTC parsing error', e, st);
        }
      }
      // IRCTC detection
      else if (foundIRCTC.isNotEmpty &&
          foundIRCTC.any(
            (k) => [
              'IRCTC',
              'Electronic Reservation Slip',
              'Train No',
              'Boarding From',
            ].contains(k),
          )) {
        try {
          _logger.logTicketParsing('PDF', 'Parsing as IRCTC ticket');

          final irctcTicket = _irctcPdfParser.parseTicket(extractedText);
          parsedTicket = irctcTicket;

          final pnrMasked =
              (irctcTicket.ticketId != null &&
                  irctcTicket.ticketId!.length >= 4)
              ? '...${irctcTicket.ticketId!.substring(
                  irctcTicket.ticketId!.length - 4,
                )}'
              : 'N/A';

          _logger.logTicketParsing(
            'PDF',
            'Parsed IRCTC PDF successfully (PNR: $pnrMasked)',
          );
        } on Exception catch (e, st) {
          _logger.error('IRCTC parsing error', e, st);
        }
      }

      if (parsedTicket == null) {
        _logger.warning(
          'PDF does not match TNSTC/IRCTC formats. '
          'foundTNSTC=$foundTNSTC foundIRCTC=$foundIRCTC',
        );

        return PDFParserResult.error(
          'PDF does not match TNSTC or IRCTC ticket format.',
        );
      }

      // Save to database
      try {
        _logger.logDatabase('Insert', 'Saving parsed PDF ticket to database');
        await getIt<ITicketDAO>().insertTicket(parsedTicket);

        _logger.success('PDF ticket saved successfully');
        return PDFParserResult.success(
          PDFParserContentType.travelTicket,
          extractedText,
          travelTicket: parsedTicket,
        );
      } on Exception catch (e, st) {
        _logger.error('Ticket DB save failed', e, st);
        return PDFParserResult.error(
          'Failed to save ticket. Please try again.',
        );
      }
    } on Exception catch (e, st) {
      _logger.error('Unexpected exception in PDF parser', e, st);
      return PDFParserResult.error('Error processing PDF. Please try again.');
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
      backgroundColor = Theme.of(context).colorScheme.primary;
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
}
