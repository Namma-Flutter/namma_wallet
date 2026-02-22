import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_provider.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/receive/domain/sharing_intent_service_interface.dart';
import 'package:path/path.dart' as path;
import 'package:share_handler/share_handler.dart';

/// Service to handle sharing intents from other apps
class SharingIntentService implements ISharingIntentService {
  SharingIntentService({
    required ILogger logger,
    required IPDFService pdfService,
    ISharingIntentProvider? sharingIntentProvider,
  }) : _logger = logger,
       _pdfService = pdfService,
       _sharingIntentProvider =
           sharingIntentProvider ?? SharingIntentProvider();

  final ILogger _logger;
  final IPDFService _pdfService;
  final ISharingIntentProvider _sharingIntentProvider;

  StreamSubscription<void>? _intentDataStreamSubscription;

  @override
  Future<void> initialize({
    required void Function(String content, SharedContentType type)
    onContentReceived,
    required void Function(String) onError,
  }) async {
    _intentDataStreamSubscription = _sharingIntentProvider
        .getMediaStream()
        .listen(
          (media) async {
            if (media != null) {
              await _handleSharedContent(media, onContentReceived, onError);
            }
          },
          onError: (Object err) {
            _logger.error('Error in sharing intent stream: $err');
            onError('Error receiving shared content: $err');
          },
        );

    try {
      final media = await _sharingIntentProvider.getInitialSharing();
      if (media != null) {
        _logger.info('App launched with shared content');
        await _handleSharedContent(media, onContentReceived, onError);
      }
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Error getting initial shared content: $error',
        error,
        stackTrace,
      );
      onError('Error getting initial shared content: $error');
    }
  }

  Future<void> _handleSharedContent(
    SharedMedia media,
    void Function(String content, SharedContentType type) onContentReceived,
    void Function(String) onError,
  ) async {
    _logger.info('SHARING INTENT TRIGGERED');

    try {
      // Handle text content if present
      if (media.content != null && media.content!.isNotEmpty) {
        _logger.info('Text content received: ${media.content}');
        onContentReceived(media.content!, SharedContentType.sms);
        return;
      }

      // Handle file attachments
      final attachments = media.attachments ?? [];
      if (attachments.isEmpty) {
        _logger.warning('No content or attachments found in shared media');
        return;
      }

      _logger.info('Processing ${attachments.length} attachment(s)');

      for (var i = 0; i < attachments.length; i++) {
        final attachment = attachments[i];
        if (attachment == null) continue;

        try {
          _logger
            ..info('ATTACHMENT ${i + 1}/${attachments.length} DETAILS')
            ..debug('Path: ${attachment.path}')
            ..debug('Type: ${attachment.type}');

          final filePath = attachment.path;
          if (filePath.isEmpty) {
            _logger.warning('Attachment has no path, skipping');
            continue;
          }

          final file = File(filePath);
          if (!file.existsSync()) {
            _logger.warning('File does not exist: $filePath');
            onError('Shared file not found: $filePath');
            continue;
          }

          // Determine content type based on file extension
          final fileExtension = path.extension(filePath).toLowerCase();

          // Check if file type is supported
          if (fileExtension != '.pdf' &&
              fileExtension != '.pkpass' &&
              !_isSupportedTextFile(fileExtension)) {
            _logger.warning(
              'Skipping unsupported file type: $fileExtension',
            );
            onError(
              'File type $fileExtension is not supported. '
              'Please share PDF, PKPASS or text files.',
            );
            continue;
          }

          final contentType = fileExtension == '.pdf'
              ? SharedContentType.pdf
              : (fileExtension == '.pkpass'
                    ? SharedContentType.pkpass
                    : SharedContentType.sms);

          final content = await extractContentFromFile(XFile(filePath));
          onContentReceived(content, contentType);
        } on Object catch (e, stackTrace) {
          _logger.error(
            'Error handling attachment ${i + 1}: $e',
            e,
            stackTrace,
          );
          onError('Error processing shared file: $e');
        }
      }
    } on Object catch (e, stackTrace) {
      _logger.error(
        'Error handling shared content: $e',
        e,
        stackTrace,
      );
      onError('Error processing shared content: $e');
    }

    _logger.info('END SHARING INTENT ANALYSIS');
  }

  /// Supported text file extensions (case-insensitive)
  static const _supportedTextExtensions = {
    '.txt',
    '.sms',
    '.text',
  };

  /// Check if a file extension is a supported text type
  /// Empty extensions are treated as text files (common for SMS content)
  bool _isSupportedTextFile(String extension) {
    return extension.isEmpty ||
        _supportedTextExtensions.contains(extension.toLowerCase());
  }

  /// Extract content from a file based on its type
  @override
  Future<String> extractContentFromFile(XFile file) async {
    final fileExtension = path.extension(file.path).toLowerCase();

    if (fileExtension == '.pdf') {
      // Extract text from PDF using PDFService
      _logger.info('Extracting text from PDF: ${file.path}');
      final content = await _pdfService.extractTextForDisplay(file);
      _logger.info('Successfully extracted text from PDF');
      return content;
    } else if (_isSupportedTextFile(fileExtension)) {
      // Read as text file
      _logger.info('Reading text file: ${file.path}');
      final content = await file.readAsString();
      _logger.info('Successfully read text file');
      return content;
    } else if (fileExtension == '.pkpass') {
      // For pkpass, we pass the file path as the content
      _logger.info('Returning file path for PKPass: ${file.path}');
      return file.path;
    } else {
      // Unsupported file type
      _logger.warning(
        'Unsupported file type: $fileExtension for file: ${file.path}',
      );
      throw UnsupportedError(
        'File type $fileExtension is not supported. '
        'Supported types: PDF, TXT, SMS',
      );
    }
  }

  /// Dispose resources

  @override
  Future<void> dispose() async {
    await _intentDataStreamSubscription?.cancel();
    _logger.info('SharingIntentService disposed');
  }
}
