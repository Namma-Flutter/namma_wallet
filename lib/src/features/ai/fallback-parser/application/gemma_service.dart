import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';

/// Service class to interact with Gemma AI chat
class GemmaChatService {
  //https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_block128_ekv4096.task

  Future<void> init() async {
    const token = String.fromEnvironment('HUGGINGFACE_TOKEN');
    if (token.isEmpty) {
      throw Exception(
        'HuggingFace token is not set. Please provide a valid token.',
      );
    }
    await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
        )
        .fromNetwork(
          'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv2048.task',
          token: token,
        )
        .withProgress((progress) {
          print('Downloading: ${progress}%');
        })
        .install();
  }
}
