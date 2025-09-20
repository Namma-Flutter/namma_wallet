import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/services/database_helper.dart';
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
  Future<PDFParserResult> parseAndSavePDFTicket(File pdfFile) async {
    try {
      // Extract text from PDF
      final pdfService = PDFService();
      final extractedText = pdfService.extractTextFrom(pdfFile);

      developer.log('PDF file size: ${pdfFile.lengthSync()} bytes',
          name: 'PDFParserService');
      developer.log('Extracted text length: ${extractedText.length}',
          name: 'PDFParserService');

      if (extractedText.trim().isEmpty) {
        return PDFParserResult.error('No text content found in PDF');
      }

      // Log complete extracted text for debugging
      developer.log('=== FULL EXTRACTED PDF TEXT ===',
          name: 'PDFParserService');
      developer.log(extractedText, name: 'PDFParserService');
      developer.log('=== END EXTRACTED PDF TEXT ===', name: 'PDFParserService');

      // Also log preview for quick reference
      final textPreview = extractedText.length > 300
          ? '${extractedText.substring(0, 300)}...'
          : extractedText;
      developer.log('Extracted text preview: $textPreview',
          name: 'PDFParserService');

      // Check if any keywords are present
      final keywords = [
        'Corporation',
        'PNR',
        'Service',
        'Journey',
        'TNSTC',
        'SETC'
      ];
      final foundKeywords = keywords
          .where((keyword) =>
              extractedText.toLowerCase().contains(keyword.toLowerCase()))
          .toList();

      developer.log('Found keywords: $foundKeywords', name: 'PDFParserService');

      // Try to parse using TNSTC PDF parser first
      TravelTicketModel? parsedTicket;

      // Check if it's a TNSTC ticket
      if (foundKeywords
          .any((k) => ['TNSTC', 'Corporation', 'PNR'].contains(k))) {
        try {
          final tnstcTicket = TNSTCPDFParser.parseTicket(extractedText);

          // Log all parsed TNSTC ticket values
          developer.log('=== PARSED TNSTC TICKET VALUES ===',
              name: 'PDFParserService');
          developer.log('Corporation: "${tnstcTicket.corporation}"',
              name: 'PDFParserService');
          developer.log('PNR Number: "${tnstcTicket.pnrNumber}"',
              name: 'PDFParserService');
          developer.log('Journey Date: "${tnstcTicket.journeyDate}"',
              name: 'PDFParserService');
          developer.log('Route No: "${tnstcTicket.routeNo}"',
              name: 'PDFParserService');
          developer.log(
              'Service Start Place: "${tnstcTicket.serviceStartPlace}"',
              name: 'PDFParserService');
          developer.log('Service End Place: "${tnstcTicket.serviceEndPlace}"',
              name: 'PDFParserService');
          developer.log('Service Start Time: "${tnstcTicket.serviceStartTime}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger Start Place: "${tnstcTicket.passengerStartPlace}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger End Place: "${tnstcTicket.passengerEndPlace}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger Pickup Point: "${tnstcTicket.passengerPickupPoint}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger Pickup Time: "${tnstcTicket.passengerPickupTime}"',
              name: 'PDFParserService');
          developer.log('Platform Number: "${tnstcTicket.platformNumber}"',
              name: 'PDFParserService');
          developer.log('Class of Service: "${tnstcTicket.classOfService}"',
              name: 'PDFParserService');
          developer.log('Trip Code: "${tnstcTicket.tripCode}"',
              name: 'PDFParserService');
          developer.log(
              'OB Reference Number: "${tnstcTicket.obReferenceNumber}"',
              name: 'PDFParserService');
          developer.log('Number of Seats: "${tnstcTicket.numberOfSeats}"',
              name: 'PDFParserService');
          developer.log(
              'Bank Transaction Number: "${tnstcTicket.bankTransactionNumber}"',
              name: 'PDFParserService');
          developer.log('Bus ID Number: "${tnstcTicket.busIdNumber}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger Category: "${tnstcTicket.passengerCategory}"',
              name: 'PDFParserService');
          developer.log('Passenger Name: "${tnstcTicket.passengerInfo?.name}"',
              name: 'PDFParserService');
          developer.log('Passenger Age: "${tnstcTicket.passengerInfo?.age}"',
              name: 'PDFParserService');
          developer.log('Passenger Type: "${tnstcTicket.passengerInfo?.type}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger Gender: "${tnstcTicket.passengerInfo?.gender}"',
              name: 'PDFParserService');
          developer.log(
              'Passenger Seat Number: "${tnstcTicket.passengerInfo?.seatNumber}"',
              name: 'PDFParserService');
          developer.log('ID Card Type: "${tnstcTicket.idCardType}"',
              name: 'PDFParserService');
          developer.log('ID Card Number: "${tnstcTicket.idCardNumber}"',
              name: 'PDFParserService');
          developer.log('Total Fare: "${tnstcTicket.totalFare}"',
              name: 'PDFParserService');
          developer.log('=== END PARSED TNSTC TICKET VALUES ===',
              name: 'PDFParserService');

          parsedTicket = _convertTNSTCToTravelTicket(tnstcTicket);
          developer.log('Successfully parsed TNSTC ticket',
              name: 'PDFParserService');
        } on Exception catch (e) {
          developer.log('Failed to parse as TNSTC ticket: $e',
              name: 'PDFParserService');
        }
      }

      if (parsedTicket == null) {
        return PDFParserResult.error(
          'PDF content does not match any supported ticket format. '
          'Found keywords: $foundKeywords',
        );
      }

      // Save to database
      try {
        final ticketId = await DatabaseHelper.instance.insertTravelTicket(
          parsedTicket.toDatabase(),
        );
        final updatedTicket = parsedTicket.copyWith(id: ticketId);

        return PDFParserResult.success(
          PDFParserContentType.travelTicket,
          extractedText,
          travelTicket: updatedTicket,
        );
      } on DuplicateTicketException catch (e) {
        developer.log('Duplicate PDF ticket detected',
            name: 'PDFParserService', error: e);
        return PDFParserResult.error(e.message);
      } on Exception catch (e) {
        developer.log('Failed to save PDF ticket to database',
            name: 'PDFParserService', error: e);
        return PDFParserResult.error('Failed to save ticket: $e');
      }
    } on Exception catch (e) {
      developer.log('Unexpected exception in PDF parser service',
          name: 'PDFParserService', error: e);
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

      // Log success to console
      developer.log('PDF parser operation succeeded: $message',
          name: 'PDFParserService');
    } else {
      message = result.errorMessage ?? 'Unknown error occurred';
      backgroundColor = Colors.red;

      // Log error to console
      developer.log('PDF parser operation failed: $message',
          name: 'PDFParserService');
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
    developer.log('Converting TNSTC to TravelTicket:', name: 'PDFParser');
    developer.log('serviceStartPlace: "${tnstcTicket.serviceStartPlace}"',
        name: 'PDFParser');
    developer.log('serviceEndPlace: "${tnstcTicket.serviceEndPlace}"',
        name: 'PDFParser');
    developer.log('passengerStartPlace: "${tnstcTicket.passengerStartPlace}"',
        name: 'PDFParser');
    developer.log('passengerEndPlace: "${tnstcTicket.passengerEndPlace}"',
        name: 'PDFParser');
    developer.log('serviceStartTime: "${tnstcTicket.serviceStartTime}"',
        name: 'PDFParser');
    developer.log('pnrNumber: "${tnstcTicket.pnrNumber}"', name: 'PDFParser');

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
