import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/ai_service_interface.dart';

/// Web implementation of AI service.
///
/// On web platform, Gemma AI is not supported, so this service
/// simply logs a warning but doesn't require any provider updates
/// as the state is managed elsewhere through Riverpod.
class WebGemmaService implements IAIService {
  @override
  Future<void> init() async {
    // On web, Gemma is not supported. The AI status is managed
    // through the aiStatusProvider in Riverpod.
    // This implementation is a no-op that allows the app to run
    // without AI features on web.
    debugPrint(
      'WebGemmaService: AI parsing with Gemma is not supported on web platform.',
    );
  }
}
