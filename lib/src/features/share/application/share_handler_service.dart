import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/share/presentation/share_content_view.dart';

enum SharedContentType { text, image, pdf, unknown }

class SharedContent {
  SharedContent({
    required this.type,
    required this.data,
    this.filePath,
    this.mimeType,
  });

  final SharedContentType type;
  final String data;
  final String? filePath;
  final String? mimeType;
}

class ShareHandlerService {
  ShareHandlerService({required ILogger logger}) : _logger = logger;

  final ILogger _logger;
  
  // Maximum file size: 10 MB
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Process shared file and determine its type
  Future<SharedContent> processSharedFile(String filePath) async {
    _logger.info('Processing shared file: $filePath');

    final fileObj = File(filePath);
    if (!fileObj.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    // Validate file size
    final fileSize = await fileObj.length();
    _logger.info('File size: $fileSize bytes');
    
    if (fileSize > maxFileSizeBytes) {
      final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      final maxMB = (maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0);
      throw Exception(
        'File too large: $sizeMB MB (maximum: $maxMB MB)',
      );
    }

    final extension = _extractFileExtension(filePath);
    final mimeType = _getMimeTypeFromExtension(extension);

    // Determine content type
    if (_isPdfFile(extension, mimeType ?? '')) {
      return SharedContent(
        type: SharedContentType.pdf,
        data: filePath,
        filePath: filePath,
        mimeType: mimeType,
      );
    } else if (_isImageFile(extension, mimeType ?? '')) {
      return SharedContent(
        type: SharedContentType.image,
        data: filePath,
        filePath: filePath,
        mimeType: mimeType,
      );
    } else if (_isTextFile(extension, mimeType ?? '')) {
      try {
        final content = await fileObj.readAsString();
        return SharedContent(
          type: SharedContentType.text,
          data: content,
          filePath: filePath,
          mimeType: mimeType,
        );
      } on FileSystemException catch (e) {
        _logger.error(
          'FileSystemException reading file: $filePath - ${e.message}',
        );
        return SharedContent(
          type: SharedContentType.text,
          data: '',
          filePath: filePath,
          mimeType: mimeType,
        );
      } on Exception catch (e) {
        _logger.error(
          'Exception reading file: $filePath - $e',
        );
        return SharedContent(
          type: SharedContentType.text,
          data: '',
          filePath: filePath,
          mimeType: mimeType,
        );
      }
    }

    return SharedContent(
      type: SharedContentType.unknown,
      data: filePath,
      filePath: filePath,
      mimeType: mimeType,
    );
  }

  /// Process shared text content
  SharedContent processSharedText(String text) {
    final preview = text.length <= 50 ? text : '${text.substring(0, 50)}...';
    _logger.info('Processing shared text: $preview');
    return SharedContent(
      type: SharedContentType.text,
      data: text,
    );
  }

  /// Show share content modal and handle user selection
  Future<void> handleSharedContent({
    required BuildContext context,
    required SharedContent content,
    required Future<void> Function(
      ShareContentType type,
      SharedContent content,
    ) onContentProcessed,
  }) async {
    showShareContentModal(
      context,
      onShare: (type, title) async {
        _logger.info('User selected: $title (${type.name})');
        try {
          await onContentProcessed(type, content);
        } on Object catch (e, stackTrace) {
          _logger.error('Error processing shared content', e, stackTrace);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to share content right now. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      },
    );
  }

  /// Extract file extension robustly handling edge cases
  String _extractFileExtension(String filePath) {
    // Find the last path separator (handle both / and \)
    final lastSlash = filePath.lastIndexOf('/');
    final lastBackslash = filePath.lastIndexOf(r'\');
    final lastSeparator = lastSlash > lastBackslash ? lastSlash : lastBackslash;
    
    // Get basename (everything after last separator)
    final basename = lastSeparator >= 0 
        ? filePath.substring(lastSeparator + 1) 
        : filePath;
    
    // Find last dot in basename
    final lastDot = basename.lastIndexOf('.');
    
    // No extension if:
    // - No dot found
    // - Dot is first character (hidden file like .gitignore)
    // - Dot is last character (trailing dot)
    if (lastDot <= 0 || lastDot == basename.length - 1) {
      return '';
    }
    
    return basename.substring(lastDot + 1).toLowerCase();
  }

  /// Get MIME type from file extension
  String? _getMimeTypeFromExtension(String extension) {
    if (extension == 'pdf') {
      return 'application/pdf';
    }
    
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    if (imageExtensions.contains(extension)) {
      return 'image/*';
    }
    
    const textExtensions = ['txt', 'sms', 'text'];
    if (textExtensions.contains(extension)) {
      return 'text/plain';
    }
    
    return null;
  }

  bool _isPdfFile(String extension, String mimeType) {
    return extension == 'pdf' || mimeType.contains('pdf');
  }

  bool _isImageFile(String extension, String mimeType) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(extension) || mimeType.contains('image');
  }

  bool _isTextFile(String extension, String mimeType) {
    const textExtensions = ['txt', 'sms', 'text'];
    return textExtensions.contains(extension) || mimeType.contains('text');
  }
}

