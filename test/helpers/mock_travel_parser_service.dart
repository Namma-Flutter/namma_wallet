import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';

/// Mock TravelParserService for testing purposes
class MockTravelParserService extends TravelParserService {
  MockTravelParserService({
    this.mockUpdateInfo,
  });

  /// Update info to return from parseUpdateSMS
  final TicketUpdateInfo? mockUpdateInfo;

  @override
  TicketUpdateInfo? parseUpdateSMS(String content) {
    return mockUpdateInfo;
  }
}
