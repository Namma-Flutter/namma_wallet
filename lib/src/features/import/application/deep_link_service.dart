import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/import/application/deep_link_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';
import 'package:share_handler/share_handler.dart' as sh;

class DeepLinkService implements IDeepLinkService {
  DeepLinkService({
    required IImportService importService,
    required ILogger logger,
  }) : _importService = importService,
       _logger = logger;

  final IImportService _importService;
  final ILogger _logger;

  StreamSubscription<sh.SharedMedia?>? _subscription;
  void Function(Object error)? _onError;
  void Function(String warning)? _onWarning;

  @override
  Future<void> initialize({
    void Function(Object error)? onError,
    void Function(String message)? onWarning,
  }) async {
    _onError = onError;
    _onWarning = onWarning;
    try {
      final handler = sh.ShareHandler.instance;

      // Handle Cold Start (App launch from file)
      final initialMedia = await handler.getInitialSharedMedia();
      if (initialMedia != null) {
        _logger.info('DeepLinkService: Handling initial shared media');
        await _handleMedia(initialMedia);
      }

      // Handle Warm/Hot Start (App resume from file)
      _subscription = handler.sharedMediaStream.listen(
        (media) async {
          _logger.info('DeepLinkService: Handling shared media stream event');
          await _handleMedia(media);
        },
        onError: (Object error) {
          _logger.error('Deep link error: $error');
          _onError?.call(error);
        },
      );

      _logger.info('DeepLinkService initialized');
    } on Object catch (e, stackTrace) {
      _logger.error('Failed to initialize DeepLinkService', e, stackTrace);
      _onError?.call(e);
    }
  }

  Future<void> _handleMedia(sh.SharedMedia media) async {
    final attachments = media.attachments;
    if (attachments == null || attachments.isEmpty) {
      _logger.info('DeepLinkService: No attachments found in shared media');
      return;
    }

    for (final attachment in attachments) {
      if (attachment == null) continue;

      final path = attachment.path;
      _logger.info('DeepLinkService: Attachment path: $path');

      if (!File(path).existsSync()) {
        _logger.warning('DeepLinkService: File not found at $path');
        continue;
      }

      if (path.toLowerCase().endsWith('.pkpass')) {
        _logger.info('DeepLinkService: Detected .pkpass file, importing...');
        try {
          final result = await _importService.importAndSavePKPassFile(
            XFile(path),
          );

          if (result.ticket == null) {
            _logger.warning(
              'DeepLinkService: Failed to parse PKPass file: $path',
            );
            _onError?.call(Exception('Failed to parse PKPass file: $path'));
            continue;
          }

          if (result.warning != null) {
            _onWarning?.call(result.warning!);
          }
        } on Object catch (e, st) {
          _logger.error('DeepLinkService: Error importing PKPass file', e, st);
          _onError?.call(e);
        }
      } else {
        _logger.warning(
          'DeepLinkService: Received unsupported file via deep link: $path',
        );
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _logger.info('DeepLinkService disposed');
  }
}
