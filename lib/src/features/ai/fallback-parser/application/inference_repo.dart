import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/enums/model_configs.dart';
import 'package:path_provider/path_provider.dart';

///
class GemmaInferenceService {
  final FlutterGemmaPlugin _gemma = FlutterGemmaPlugin.instance;

  ///
  Future<InferenceChat> initializeModel(Model model) async {
    if (!await _gemma.modelManager.isModelInstalled) {
      final path =
          '${(await getApplicationDocumentsDirectory()).path}/${model.filename}';
      await _gemma.modelManager.setModelPath(path);
    }

    final inferenceModel = await _gemma.createModel(
      modelType: model.modelType,
      preferredBackend: PreferredBackend.cpu,
      maxTokens: 1024,
      supportImage: model.supportImage,
      maxNumImages:
          model.maxNumImages,
    );

    final chat = await inferenceModel.createChat(
      temperature: model.temperature,
      randomSeed: 1,
      topK: model.topK,
      topP: model.topP,
      tokenBuffer: 256,
      supportImage: model.supportImage,
      supportsFunctionCalls:
          model.supportsFunctionCalls,
      isThinking: model.isThinking,
      modelType: model.modelType,
    );

    return chat;
  }
}
