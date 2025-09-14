import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/inference_repo.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/enums/model_configs.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/prompts/fallback_prompt.dart';

/// Inference screen for fallback event/ticket parsing - [Testing only]
class InferenceScreen extends StatefulWidget {
  const InferenceScreen({super.key});

  @override
  State<InferenceScreen> createState() => _InferenceScreenState();
}

class _InferenceScreenState extends State<InferenceScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  StreamSubscription<ModelResponse>? _streamSubscription;

  /// Accumulates the streaming response
  var _currentMessage = const Message(text: '', isUser: false);
  bool _processing = false;
  String _finalResponse = '';

  @override
  void dispose() {
    debugPrint('InferenceScreen: dispose() called');
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Handles stream updates from Gemma
  void _handleStreamResponse(ModelResponse response) {
    setState(() {
      if (response is String) {
        _currentMessage =
            Message(text: '${_currentMessage.text}$response', isUser: false);
      } else if (response is TextResponse) {
        _currentMessage = Message(
          text: '${_currentMessage.text}${response.token}',
          isUser: false,
        );
        debugPrint(
            '📝 Streaming: "${response.token}" → total "${_currentMessage.text}"');
      }
    });
  }

  /// Handles stream completion
  void _handleStreamDone() {
    debugPrint('🏁 Stream completed');
    final text = _currentMessage.text.isNotEmpty ? _currentMessage.text : '...';

    setState(() {
      _finalResponse = text;
      _messages.add(Message(text: text, isUser: false));
      _processing = false;
    });
  }

  /// Handles errors in the stream
  void _handleStreamError(Object error) {
    debugPrint('❌ Stream error: $error');
    final text = _currentMessage.text.isNotEmpty ? _currentMessage.text : '...';

    setState(() {
      _finalResponse = text;
      _processing = false;
    });
  }

  /// Process user input with fallback prompt
  Future<void> _performFallbackOperation(String userInput) async {
    if (_processing) return; // prevent re-entry

    final prompt = FallBackPrompt.getPrompt(message: userInput);

    // final prompt = userInput;

    InferenceChat? chat;
    try {
      chat = await GemmaInferenceService().initializeModel(Model.gemma3_270M);
    } catch (e) {
      debugPrint("🚨 Failed to initialize model: $e");
    }

    if (chat == null || prompt.trim().isEmpty) return;

    setState(() {
      _processing = true;
      _currentMessage = const Message(text: '', isUser: false);
      _messages.add(Message(text: prompt, isUser: true));
    });

    try {
      final gemma = GemmaLocalService(chat);
      final responseStream = await gemma.processMessage(_messages.last);

      _streamSubscription = responseStream.listen(
        _handleStreamResponse,
        onError: _handleStreamError,
        onDone: _handleStreamDone,
      );

      debugPrint('🔵 StreamSubscription created and listening');
    } catch (e) {
      debugPrint('Gemma error: $e');
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inference Parser")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Paste QR/event text here",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _processing
                  ? null
                  : () async => _performFallbackOperation(_controller.text),
              child: Text(_processing ? 'Processing...' : 'Parse it'),
            ),
            const SizedBox(height: 24),

            // Show live streaming text
            if (_processing && _currentMessage.text.isNotEmpty) ...[
              const Text("Streaming response:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_currentMessage.text),
              const SizedBox(height: 16),
            ],

            // Show final result
            if (!_processing && _finalResponse.trim().isNotEmpty) ...[
              const Divider(),
              const Text("Final Parsed Output:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_finalResponse),
            ],
          ],
        ),
      ),
    );
  }
}
