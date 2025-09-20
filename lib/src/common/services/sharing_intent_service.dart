import 'dart:async';
import 'dart:io';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

/// Service to handle sharing intents from other apps
class SharingIntentService {
  static final SharingIntentService _instance =
      SharingIntentService._internal();
  factory SharingIntentService() => _instance;
  SharingIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;

  void initialize({
    required void Function(String) onFileReceived,
    required void Function(String) onError,
  }) {
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        _handleSharedFiles(files, onFileReceived, onError);
      },
      onError: (Object err) {
        print('❌ Error in sharing intent stream: $err');
        onError('Error receiving shared content: $err');
      },
    );

    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        print('=== App launched with shared files: ${files.length} ===');
        _handleSharedFiles(files, onFileReceived, onError);
      }
    }).catchError((Object error) {
      print('❌ Error getting initial shared media: $error');
      onError('Error getting initial shared content: $error');
    });
  }

  void _handleSharedFiles(
    List<SharedMediaFile> files,
    void Function(String) onFileReceived,
    void Function(String) onError,
  ) {
    print('\n === SHARING INTENT TRIGGERED ===');

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      try {
        print('\n=== SHARED FILE ${i + 1}/${files.length} DETAILS ===');
        _printFileDetails(file);

        final fileName = file.path.split('/').last;
        onFileReceived('File received: $fileName');
      } catch (e) {
        print('❌ Error handling shared file ${i + 1}: $e');
        onError('Error processing shared file: $e');
      }
    }

    print('\n === END SHARING INTENT ANALYSIS ===\n');
  }

  /// Print detailed file information to console
  void _printFileDetails(SharedMediaFile file) {
    print('File Path: ${file.path}');
    print('File Name: ${file.path.split('/').last}');
    print('File Extension: ${file.path.split('.').last.toLowerCase()}');
    print('MIME Type: ${file.type}');

    final fileObj = File(file.path);
    if (fileObj.existsSync()) {
      try {
        final stats = fileObj.statSync();
        print(
            'File Size: ${stats.size} bytes (${_formatFileSize(stats.size)})');
        print('Last Modified: ${stats.modified}');
        print('File Accessible: Yes');

        // Try to read text files for content preview (Copilot code)
        if (_isTextFile(file)) {
          try {
            final content = fileObj.readAsStringSync();
            final preview = content.length > 200
                ? '${content.substring(0, 200)}...'
                : content;
            print('Content Preview: $preview');
          } catch (e) {
            print('Could not read text content: $e');
          }
        }
      } catch (e) {
        print('❌ Error reading file stats: $e');
      }
    } else {
      print('❌ File Accessible: No - File not found at path');
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
    print('SharingIntentService disposed');
  }
}
