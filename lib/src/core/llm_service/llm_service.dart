import 'package:flutter_gemma/flutter_gemma.dart';

class LLMService {
   init() async {
    final gemma = FlutterGemmaPlugin.instance;
    final modelManager = gemma.modelManager;
    print("inside init llm");
    if (!(await modelManager.isModelInstalled)) {
      print("downloading");
      modelManager.downloadModelFromNetworkWithProgress('https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8-web.task?download=true').listen(
    (progress) {
      print('Loading progress: $progress%');
    },
    onDone: () {
      print('Model loading complete.');
    },
    onError: (error) {
      print('Error loading model: $error');
    },
);
    }
  }
}
