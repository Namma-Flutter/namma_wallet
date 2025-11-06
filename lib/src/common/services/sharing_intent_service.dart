import 'dart:async';
import 'dart:io';

import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

/// Service to handle sharing intents from other apps
class SharingIntentService {
  SharingIntentService();

  ILogger get _logger => getIt<ILogger>();

  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;

  void initialize({
    required void Function(String) onFileReceived,
    required void Function(String) onError,
  }) {
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> files) {
            _handleSharedFiles(files, onFileReceived, onError);
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
            _logger.info('App launched with shared files: ${files.length}');
            _handleSharedFiles(files, onFileReceived, onError);
          }
        })
        .catchError((Object error) {
          _logger.error('Error getting initial shared media: $error');
          onError('Error getting initial shared content: $error');
        });
  }

  void _handleSharedFiles(
    List<SharedMediaFile> files,
    void Function(String) onFileReceived,
    void Function(String) onError,
  ) {
    _logger.info('SHARING INTENT TRIGGERED');

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      try {
        _logger.info('SHARED FILE ${i + 1}/${files.length} DETAILS');
        _printFileDetails(file);

        final fileName = file.path.split('/').last;
        onFileReceived('File received: $fileName');
      } on Object catch (e) {
        _logger.error('Error handling shared file ${i + 1}: $e');
        onError('Error processing shared file: $e');
      }
    }

    _logger.info('END SHARING INTENT ANALYSIS');
  }

  /// Print detailed file information to console
  void _printFileDetails(SharedMediaFile file) {
    _logger
      ..info('File Path: ${file.path}')
      ..info('File Name: ${file.path.split('/').last}')
      ..info('File Extension: ${file.path.split('.').last.toLowerCase()}')
      ..info('MIME Type: ${file.type}');

    final fileObj = File(file.path);
    if (fileObj.existsSync()) {
      try {
        final stats = fileObj.statSync();
        _logger
          ..info(
            'File Size: ${stats.size} bytes (${_formatFileSize(stats.size)})',
          )
          ..info('Last Modified: ${stats.modified}')
          ..info('File Accessible: Yes');

        // Try to read text files for content preview (Copilot code)
        if (_isTextFile(file)) {
          try {
            final content = fileObj.readAsStringSync();
            final preview = content.length > 200
                ? '${content.substring(0, 200)}...'
                : content;
            _logger.info('Content Preview: $preview');
          } on Object catch (e) {
            _logger.error('Could not read text content: $e');
          }
        }
      } on Object catch (e) {
        _logger.error('Error reading file stats: $e');
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
