import 'package:namma_wallet/src/features/ai/fallback_parser/application/ai_service_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/settings/application/ai_service_status.dart';

class WebGemmaService implements IAIService {
  @override
  Future<void> init() async {
    final status = getIt<AIServiceStatus>();
    status.setGemmaSupport(
      false,
      error: 'AI parsing with Gemma is not supported on web platform.',
    );
  }
}
