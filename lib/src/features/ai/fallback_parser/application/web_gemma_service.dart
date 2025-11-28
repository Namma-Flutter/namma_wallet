import 'package:namma_wallet/src/features/ai/fallback_parser/application/ai_service_interface.dart';

class WebGemmaService implements IAIService {
  @override
  Future<void> init() async {
    // Gemma is not supported on web due to hosting headers requirements
    return;
  }
}
