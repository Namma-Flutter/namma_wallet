import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/prompts/fallback_prompt.dart';

/// Stateful widget for testing AI Parser interactions
class AIParserTestScreen extends StatefulWidget {
  const AIParserTestScreen({super.key});

  @override
  State<AIParserTestScreen> createState() => _AIParserTestScreenState();
}

/// State class for AIParserTestScreen
class _AIParserTestScreenState extends State<AIParserTestScreen> {
  /// Stores AI response text
  String _response = 'AI is Ready...';

  /// Controller for the input TextField
  final TextEditingController _controller = TextEditingController();

  /// Instance of the Gemma AI service
  final _gemmaService = GemmaChatService();

  /// Sends user input to the AI service and updates the response
  Future<void> _sendMessage() async {
    /// Trim input text from TextField
    final userTextFromField = _controller.text.trim();

    /// Prepare prompt using fallback prompt logic
    final userText = FallBackPrompt.getPrompt2(message: userTextFromField);

    /// Do nothing if input is empty
    if (userText.isEmpty) return;

    /// Update UI to show thinking state
    setState(() {
      _response = 'Thinking...';
    });

    try {
      /// Send message to Gemma AI service and wait for the reply
      final reply = await _gemmaService.sendMessage(userText);

      /// Update UI with AI's reply
      setState(() => _response = reply.toString());
    } on Exception catch (e) {
      /// Update UI with Error if failed
      setState(() => _response = 'Error: $e');
    }
  }

  @override
  void dispose() {
    /// Dispose the TextEditingController to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemma AI Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Expanded widget to show AI responses in a scrollable view
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            /// Input TextField for user messages
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter your message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            /// Button to send message to AI
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Testing
/// Entry point of the Flutter application
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   /// Ensures that widget binding is initialized before running the app
//   runApp(const AIParserTestScreen());
//
//   /// Launches the AIParserTestScreen widget as the root of the app
// }
