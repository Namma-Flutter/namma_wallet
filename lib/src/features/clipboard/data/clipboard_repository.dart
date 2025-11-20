import 'package:flutter/services.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/clipboard/domain/i_clipboard_repository.dart';

/// Implementation of [IClipboardRepository] using Flutter's Clipboard API.
///
/// Handles platform-specific clipboard access and error handling.
/// Never throws - all errors are logged and return safe defaults.
class ClipboardRepository implements IClipboardRepository {
  /// Creates a clipboard repository.
  ///
  /// [logger] - Optional logger for debugging. Uses GetIt instance if not
  /// provided.
  ClipboardRepository({ILogger? logger})
      : _logger = logger ?? getIt<ILogger>();

  final ILogger _logger;

  @override
  Future<bool> hasTextContent() async {
    try {
      return await Clipboard.hasStrings();
    } on PlatformException catch (e) {
      _logger.error(
        'Platform exception checking clipboard content: ${e.code} - '
        '${e.message}',
      );
      return false;
    } on Exception catch (e) {
      _logger.error('Unexpected exception checking clipboard content: $e');
      return false;
    }
  }

  @override
  Future<String?> readText() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final text = clipboardData?.text?.trim();

      if (text == null || text.isEmpty) {
        return null;
      }

      return text;
    } on PlatformException catch (e) {
      _logger.error(
        'Platform exception reading clipboard: ${e.code} - ${e.message}',
      );
      return null;
    } on Exception catch (e) {
      _logger.error('Unexpected exception reading clipboard: $e');
      return null;
    }
  }
}
