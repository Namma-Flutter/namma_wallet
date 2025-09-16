import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ClipboardContentType {
  text,
  invalid,
}

class ClipboardResult {
  const ClipboardResult({
    required this.type,
    required this.isSuccess,
    this.content,
    this.errorMessage,
  });

  factory ClipboardResult.success(ClipboardContentType type, String content) {
    return ClipboardResult(
      type: type,
      content: content,
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
  final String? errorMessage;
  final bool isSuccess;
}

class ClipboardService {

  Future<ClipboardResult> readClipboard() async {
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
        if (_isValidTextContent(content)) {
          return ClipboardResult.success(ClipboardContentType.text, content);
        } else {
          return ClipboardResult.error(
            'Only plain text content is allowed from clipboard.',
          );
        }
      }

      // If no text data found
      return ClipboardResult.error(
        'No text content found in clipboard. Please copy plain text.',
      );

    } on PlatformException catch (e) {
      if (e.code == 'clipboard_error' || (e.message?.contains('URI') ?? false)) {
        return ClipboardResult.error(
          'Unable to access clipboard content. Please copy plain text only.',
        );
      }
      return ClipboardResult.error('Error accessing clipboard: ${e.message}');
    } on Exception catch (e) {
      return ClipboardResult.error('Unexpected error occurred: $e');
    }
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
        ClipboardContentType.invalid => 'Invalid content',
      };
      backgroundColor = Colors.green;
    } else {
      message = result.errorMessage ?? 'Unknown error occurred';
      backgroundColor = Colors.red;
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
