import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/enums/model_configs.dart';
import 'package:path_provider/path_provider.dart';

/// Service class to interact with Gemma AI chat
class GemmaChatService {
  /// Factory constructor to return the singleton instance
  factory GemmaChatService() => _instance;

  /// Private named constructor
  GemmaChatService._internal();

  /// Singleton Instance
  static final GemmaChatService _instance = GemmaChatService._internal();

  /// The Gemma AI inference model instance
  InferenceModel? _model;

  /// Flag to indicate if Gemma has been initialized
  bool _isInitialized = false;

  /// Initialize Gemma model and session (only once)
  Future<void> initialize() async {
    /// Prevent multiple initializations
    if (_isInitialized) return;

    /// Get the Gemma plugin instance
    final gemma = FlutterGemmaPlugin.instance;

    /// Check if the model is already installed
    if (!await gemma.modelManager.isModelInstalled) {
      /// If not installed, set model path
      final path =
          '${(await getApplicationDocumentsDirectory()).path}/${Model.gemma3_1B.filename}';
      await gemma.modelManager.setModelPath(path);
    }

    /// Create the inference model with specified configuration
    _model = await gemma.createModel(
      modelType: ModelType.gemmaIt,

      /// Type of model to use
      preferredBackend: PreferredBackend.cpu,

      /// Backend preference
      maxTokens: 1024,

      /// Maximum tokens per response
      loraRanks: [4, 8],

      /// Lora fine-tuning ranks
    );

    /// Mark initialization complete
    _isInitialized = true;
  }

  /// Send a chat message to Gemma AI and return the parsed response
  Future<Map<String, dynamic>> sendMessage(String text) async {
    /// Ensure Gemma is initialized before sending messages
    if (!_isInitialized) {
      await initialize();
    }

    try {
      /// Create a new session with custom settings
      final session = await _model!.createSession(
        temperature: 1.0,

        /// Controls randomness of AI responses
        randomSeed: 1,

        /// Fixed seed for reproducibility
        topK: 1,

        /// Top-K sampling parameter
      );

      /// Add the user message to the session
      await session.addQueryChunk(
        Message.text(text: text, isUser: true),
      );

      /// Get AI response
      final response = await session.getResponse();

      /// Close the session to free resources
      await session.close();

      /// Parse JSON response string into a Map
      final dataJson = jsonDecode(response);
      return dataJson as Map<String, dynamic>;
    } on Exception catch (e) {
      /// Catch errors and return a fallback error map
      if (kDebugMode) {
        print('Error: $e');
      }
      return {'error': 'unable to parse'};
    }
  }
}
