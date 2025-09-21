import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namma_wallet/src/common/services/database_helper.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';

enum ClipboardContentType {
  text,
  travelTicket,
  invalid,
}

class ClipboardResult {
  const ClipboardResult({
    required this.type,
    required this.isSuccess,
    this.content,
    this.ticket,
    this.errorMessage,
  });

  factory ClipboardResult.success(ClipboardContentType type, String content,
      {TravelTicketModel? ticket}) {
    return ClipboardResult(
      type: type,
      content: content,
      ticket: ticket,
      isSuccess: true,
    );
  }

  factory ClipboardResult.error(String errorMessage) {
    return ClipboardResult(
      type: ClipboardContentType.invalid,
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }

  final ClipboardContentType type;
  final String? content;
  final TravelTicketModel? ticket;
  final String? errorMessage;
  final bool isSuccess;
}

class ClipboardService {
  Future<ClipboardResult> readAndParseClipboard() async {
    try {
      // First check if clipboard has any content
      final hasStrings = await Clipboard.hasStrings();
      if (!hasStrings) {
        return ClipboardResult.error('No content found in clipboard');
      }

      // Try to get text content
      final textData = await Clipboard.getData('text/plain');

      if (textData?.text != null && textData!.text!.trim().isNotEmpty) {
        final content = textData.text!.trim();

        // Only allow plain text content
        if (!_isValidTextContent(content)) {
          return ClipboardResult.error(
            'Only plain text content is allowed from clipboard.',
          );
        }

        // Try to parse as travel ticket
        final parsedTicket = TravelParserService.parseTicketFromText(
          content,
          sourceType: SourceType.clipboard,
        );

        if (parsedTicket != null) {
          // Save to database
          try {
            final ticketId = await DatabaseHelper.instance.insertTravelTicket(
              parsedTicket.toDatabase(),
            );
            final updatedTicket = parsedTicket.copyWith(id: ticketId);
            return ClipboardResult.success(
              ClipboardContentType.travelTicket,
              content,
              ticket: updatedTicket,
            );
          } on DuplicateTicketException catch (e) {
            developer.log('Duplicate ticket detected',
                name: 'ClipboardService', error: e);
            print('⚠️ CLIPBOARD DUPLICATE: ${e.message}');
            return ClipboardResult.error(e.message);
          } catch (e) {
            developer.log('Failed to save ticket to database',
                name: 'ClipboardService', error: e);
            print('🔴 CLIPBOARD ERROR: Failed to save ticket: $e');
            return ClipboardResult.error('Failed to save ticket: $e');
          }
        }

        // If not a travel ticket, return as plain text
        return ClipboardResult.success(ClipboardContentType.text, content);
      }

      // If no text data found
      return ClipboardResult.error(
        'No text content found in clipboard. Please copy plain text.',
      );
    } on PlatformException catch (e) {
      developer.log('Platform exception in clipboard service',
          name: 'ClipboardService', error: e);
      print('🔴 CLIPBOARD PLATFORM ERROR: ${e.code} - ${e.message}');

      if (e.code == 'clipboard_error' ||
          (e.message?.contains('URI') ?? false)) {
        return ClipboardResult.error(
          'Unable to access clipboard content. Please copy plain text only.',
        );
      }
      return ClipboardResult.error('Error accessing clipboard: ${e.message}');
    } on Exception catch (e) {
      developer.log('Unexpected exception in clipboard service',
          name: 'ClipboardService', error: e);
      print('🔴 CLIPBOARD UNEXPECTED ERROR: $e');
      return ClipboardResult.error('Unexpected error occurred: $e');
    }
  }

  Future<ClipboardResult> readClipboard() async {
    return readAndParseClipboard();
  }

  bool _isValidTextContent(String text) {
    if (text.trim().isEmpty) return false;

    // Allow reasonable text length (not too long to prevent spam)
    if (text.length > 10000) return false;

    return true;
  }

  void showResultMessage(BuildContext context, ClipboardResult result) {
    if (!context.mounted) return;

    String message;
    Color backgroundColor;

    if (result.isSuccess) {
      message = switch (result.type) {
        ClipboardContentType.text => 'Text content read successfully',
        ClipboardContentType.travelTicket =>
          'Travel ticket saved successfully!',
        ClipboardContentType.invalid => 'Invalid content',
      };
      backgroundColor = Colors.green;

      // Log success to console
      developer.log('Clipboard operation succeeded: $message',
          name: 'ClipboardService');
      print('✅ CLIPBOARD SUCCESS: $message');
    } else {
      message = result.errorMessage ?? 'Unknown error occurred';
      backgroundColor = Colors.red;

      // Log error to console
      developer.log('Clipboard operation failed: $message',
          name: 'ClipboardService');
      print('🔴 CLIPBOARD FAILED: $message');
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
