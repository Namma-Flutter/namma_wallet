import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/enums/model_configs.dart';
import 'package:path_provider/path_provider.dart';

/// Service class to interact with Gemma AI chat
class GemmaChatService {
  /// Factory constructor to return the singleton instance
  factory GemmaChatService() => _instance;

  /// Private named constructor
  GemmaChatService._internal();

  /// Current model to use
  Model _currentModel = Model.gemma3_1B;

  /// Set the active model
  void setModel(Model model) {
    _currentModel = model;
    _isInitialized = false;
  }

  /// Singleton Instance
  static final GemmaChatService _instance = GemmaChatService._internal();

  /// The Gemma AI inference model instance
  late InferenceModel _model;

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
          '${(await getApplicationDocumentsDirectory()).path}/${_currentModel.filename}';
      await gemma.modelManager.setModelPath(path);
    }

    /// Create the inference model with specified configuration
    _model = await gemma.createModel(
      modelType: _currentModel.modelType,

      /// Type of model to use
      preferredBackend: _currentModel.preferredBackend,

      /// Backend preference
      maxTokens: _currentModel.maxTokens,

      /// Maximum tokens per response
      loraRanks: [4, 8], // TODO(Keerthi): Make configurable in Model enum
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
      final session = await _model
          .createSession(
            temperature: _currentModel.temperature,

            /// Top-K and Top-P sampling parameter
            topK: _currentModel.topK,
            topP: _currentModel.topP,
          )
          .timeout(const Duration(seconds: 120));

      /// Add the user message to the session
      await session.addQueryChunk(
        Message.text(text: text, isUser: true),
      );

      /// Get AI response
      final response = await session.getResponse();

      /// Close the session to free resources
      await session.close();

      /// Validate and clean the response
      if (response.trim().isEmpty) {
        throw const FormatException('Empty response from AI');
      }

      /// Parse JSON response string into a Map
      final dataJson = jsonDecode(response);

      if (dataJson is! Map<String, dynamic>) {
        throw FormatException('Response is not a JSON object: $response');
      }
      return dataJson;
    } on Exception catch (e) {
      /// Catch errors and return a fallback error map
      if (kDebugMode) {
        print('Error: $e');
      }
      return {'error': 'unable to parse'};
    }
  }
}
