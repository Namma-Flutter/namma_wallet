import 'dart:async';
import 'dart:io';

import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

/// Service to handle sharing intents from other apps
class SharingIntentService {
  SharingIntentService({ILogger? logger})
    : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;

  void initialize({
    required void Function(String) onContentReceived,
    required void Function(String) onError,
  }) {
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> files) {
            _handleSharedContent(files, onContentReceived, onError);
          },
          onError: (Object err) {
            _logger.error('Error in sharing intent stream: $err');
            onError('Error receiving shared content: $err');
          },
        );

    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> files) {
          if (files.isNotEmpty) {
            _logger.info('App launched with shared content: ${files.length}');
            _handleSharedContent(files, onContentReceived, onError);
          }
        })
        .catchError((Object error) {
          _logger.error('Error getting initial shared content: $error');
          onError('Error getting initial shared content: $error');
        });
  }

  void _handleSharedContent(
    List<SharedMediaFile> files,
    void Function(String) onContentReceived,
    void Function(String) onError,
  ) {
    _logger.info('SHARING INTENT TRIGGERED');

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      try {
        _logger.info('SHARED CONTENT ${i + 1}/${files.length} DETAILS');
        _printFileDetails(file);

        // Check if this is actually a file or text content
        File fileObj;
        if (file.path.startsWith('file://') ||
            (Uri.tryParse(file.path)?.hasScheme ?? false)) {
          fileObj = File.fromUri(Uri.parse(file.path));
        } else {
          fileObj = File(file.path);
        }

        if (fileObj.existsSync()) {
          // It's a real file, pass the file path
          _logger.info(
            'File received: ${fileObj.path.split(Platform.pathSeparator).last}',
          );
          onContentReceived(fileObj.path);
        } else {
          // It's text content (like SMS), pass the text directly
          _logger.info('Text content received');
          onContentReceived(file.path);
        }
      } on Object catch (e, stackTrace) {
        _logger.error(
          'Error handling shared content ${i + 1}: $e',
          e,
          stackTrace,
        );
        onError('Error processing shared content: $e');
      }
    }

    _logger.info('END SHARING INTENT ANALYSIS');
  }

  /// Print detailed file information to console
  void _printFileDetails(SharedMediaFile file) {
    _logger
      ..debug('File Path: ${file.path}')
      ..debug('File Name: ${file.path.split('/').last}')
      ..debug('File Extension: ${file.path.split('.').last.toLowerCase()}')
      ..debug('MIME Type: ${file.type}');

    final fileObj = File(file.path);
    if (fileObj.existsSync()) {
      try {
        final stats = fileObj.statSync();
        _logger
          ..debug(
            'File Size: ${stats.size} bytes (${_formatFileSize(stats.size)})',
          )
          ..debug('Last Modified: ${stats.modified}')
          ..debug('File Accessible: Yes');

        // Try to read text files for content preview (Copilot code)
        if (_isTextFile(file)) {
          try {
            final content = fileObj.readAsStringSync();
            final preview = content.length > 200
                ? '${content.substring(0, 200)}...'
                : content;
            _logger.debug('Content Preview: $preview');
          } on Object catch (e, stackTrace) {
            _logger.error('Could not read text content: $e', e, stackTrace);
          }
        }
      } on Object catch (e, stackTrace) {
        _logger.error('Error reading file stats: $e', e, stackTrace);
      }
    } else {
      _logger.error('File Accessible: No - File not found at path');
    }
  }

  /// Check if file is a text file
  bool _isTextFile(SharedMediaFile file) {
    final extension = file.path.toLowerCase().split('.').last;
    return file.type.toString().contains('text') ||
        extension == 'txt' ||
        extension == 'sms';
  }

  /// Format file size in readable format (Copilot code)
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Dispose resources
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _logger.info('SharingIntentService disposed');
  }
}
