import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/import/application/deep_link_service_interface.dart';

class WebDeepLinkService implements IDeepLinkService {
  WebDeepLinkService({required ILogger logger}) : _logger = logger;

  final ILogger _logger;

  @override
  Future<void> initialize({
    void Function(Object error)? onError,
    void Function(String message)? onWarning,
  }) async {
    _logger.info('[WebDeepLinkService] Deep links are not supported on web');
  }

  @override
  Future<void> dispose() async {
    return;
  }
}
