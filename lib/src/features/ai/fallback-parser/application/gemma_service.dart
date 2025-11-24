import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/ai_service_interface.dart';

/// Service class to interact with Gemma AI chat
class GemmaChatService implements IAIService {
  GemmaChatService({required ILogger logger}) : _logger = logger;
  final ILogger _logger;
  int? _lastLoggedProgress;
  //https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_block128_ekv4096.task

  @override
  Future<void> init() async {
    const token = String.fromEnvironment('HUGGINGFACE_TOKEN');
    if (token.isEmpty) {
      return;
    }
    await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
        )
        .fromNetwork(
          'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv2048.task',
          token: token,
        )
        .withProgress((progress) {
          if (_lastLoggedProgress == null ||
              progress - _lastLoggedProgress! >= 10 ||
              progress >= 100) {
            _logger.info('Downloading: $progress%');
            _lastLoggedProgress = progress;
          }
        })
        .install();
  }
}
