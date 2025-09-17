import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// Service to handle local Gemma model chat operations
class GemmaLocalService {
  /// Create service with an [InferenceChat] instance
  GemmaLocalService(this._chat);

  /// Chat engine instance
  final InferenceChat _chat;

  /// Add a user message to the chat history
  Future<void> addQuery(Message message) => _chat.addQuery(message);

  /// Add message and get a stream of responses from the model
  Future<Stream<ModelResponse>> processMessage(Message message) async {
    debugPrint('GemmaLocalService: processing "${message.text}"');
    await _chat.addQuery(message);
    return _chat.generateChatResponseAsync();
  }

  /// Legacy version of [processMessage], kept for compatibility
  Stream<ModelResponse> processMessageAsync(Message message) async* {
    await _chat.addQuery(message);
    yield* _chat.generateChatResponseAsync();
  }
}
