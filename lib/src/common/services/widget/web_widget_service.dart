import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';

class WebWidgetService implements IWidgetService {
  WebWidgetService({required ILogger logger}) : _logger = logger;

  final ILogger _logger;

  @override
  Future<void> initialize() async {
    _logger.info('[WebWidgetService] Home widgets are not supported on web');
  }

  @override
  Future<void> updateWidgetWithTicket(Ticket ticket) async {
    return;
  }

  @override
  Future<Uri?> getInitialWidgetLaunchUri() async {
    return null;
  }

  @override
  Future<void> startBackgroundUpdates() async {
    return;
  }

  @override
  Future<void> stopBackgroundUpdates() async {
    return;
  }

  @override
  Future<bool> isRequestPinWidgetSupported() async {
    return false;
  }

  @override
  Future<void> requestPinWidget() async {
    throw UnsupportedError('Home widgets are not supported on web');
  }
}
