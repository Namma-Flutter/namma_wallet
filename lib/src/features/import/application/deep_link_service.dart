import 'dart:async';

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

  @override
  Future<void> initialize() async {
    try {
      final handler = sh.ShareHandler.instance;

      // Handle Cold Start (App launch from file)
      final initialMedia = await handler.getInitialSharedMedia();
      if (initialMedia != null) {
        _logger.info('DeepLinkService: Handling initial shared media');
        _handleMedia(initialMedia);
      }

      // Handle Warm/Hot Start (App resume from file)
      _subscription = handler.sharedMediaStream.listen((media) {
        _logger.info('DeepLinkService: Handling shared media stream event');
        _handleMedia(media);
      });

      _logger.info('DeepLinkService initialized');
    } on Object catch (e, stackTrace) {
      _logger.error('Failed to initialize DeepLinkService', e, stackTrace);
    }
  }

  void _handleMedia(sh.SharedMedia media) {
    final attachments = media.attachments;
    if (attachments == null || attachments.isEmpty) {
      _logger.info('DeepLinkService: No attachments found in shared media');
      return;
    }

    for (final attachment in attachments) {
      if (attachment == null) continue;

      final path = attachment.path;
      _logger.info('DeepLinkService: Attachment path: $path');

      if (path.toLowerCase().endsWith('.pkpass')) {
        _logger.info('DeepLinkService: Detected .pkpass file, importing...');
        unawaited(_importService.importAndSavePKPassFile(XFile(path)));
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
