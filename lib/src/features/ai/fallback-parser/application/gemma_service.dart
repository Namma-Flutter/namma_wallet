import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart'
    show GenericDetailsModel;

const prompt =
    'You are a highly efficient data extraction model. Your task is to analyze text and extract information according to a specific schema from `response`. You must only respond to user by calling `response` function, and nothing else.';

final List<Tool> _tools = [
  // const Tool(
  //   name: 'is_exist_in_db',
  //   description:
  //       'Checks weather a particular ticket data is already exist in database',
  //   parameters: {
  //     'type': 'object',
  //     'properties': {
  //       'id': {'type': 'string', 'description': 'unique ticket id'},
  //       // to-do: later try to add enum for the type
  //       'type': {'type': 'string', 'description': 'Type of ticket'},
  //     },
  //     'required': ['id'],
  //   },
  // ),
  const Tool(
    name: 'response',
    description:
        'To give response back to user after gathering the ticket data',
    parameters: {
      'type': 'object',
      'properties': {
        'primary_text': {
          'type': 'string',
          'description': 'Transport name or Event name with date and time',
        },
        'secondary_text': {
          'type': 'string',
          'description': 'unique ticket id (PNR, ticket number etc)',
        },
      },
      'required': ['primary_text', 'secondary_text'],
    },
  ),
];

/// Service class to interact with Gemma AI chat
class GemmaChatService {
  GemmaChatService({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;
  int? _lastLoggedProgress;
  //https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_block128_ekv4096.task

  Future<void> init() async {
    const token = String.fromEnvironment('HUGGINGFACE_TOKEN');
    if (token.isEmpty) {
      _logger.warning('HUGGINGFACE_TOKEN not found in env');
      return;
    }
    await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
        )
        .fromNetwork(
          // 'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv2048.task',
          'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q8_ekv4096.task',
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

  // single or batch process both handled here

  Future<List<GenericDetailsModel>?> parseBatch(List<String> data) async {
    // get the current model
    final model = await FlutterGemma.getActiveModel(maxTokens: 2048);

    // Use model
    final chat = await model.createChat(
      supportsFunctionCalls: true,
      tools: _tools,
    );
    List<GenericDetailsModel> _response = [];

    /// function handling
    Future<void> _handleFunctionCall(FunctionCallResponse functionCall) async {
      // Execute the requested function
      Map<String, dynamic> toolResponse;

      switch (functionCall.name) {
        case 'change_background_color':
          final color = functionCall.args['color'] as String?;
          // Your implementation here
          toolResponse = {
            'status': 'success',
            'message': 'Color changed to $color',
          };
          break;
        case 'show_alert':
          final title = functionCall.args['title'] as String?;
          final message = functionCall.args['message'] as String?;
          // Show alert dialog
          toolResponse = {'status': 'success', 'message': 'Alert shown'};
          break;
        default:
          toolResponse = {'error': 'Unknown function: ${functionCall.name}'};
      }

      // Send the tool response back to the model
      final toolMessage = Message.toolResponse(
        toolName: functionCall.name,
        response: toolResponse,
      );
      await chat.addQueryChunk(toolMessage);

      // The model will then generate a final response explaining what it did
      final finalResponse = await chat.generateChatResponse();
      if (finalResponse is TextResponse) {
        print('Model: ${finalResponse.token}');
      }
    }

    await Future.forEach(data, (msg) async {
      print(" processing message : ${msg.substring(0, 10)}");
      await chat.addQueryChunk(
        Message.text(
          text: prompt, //TODO: prompt
        ),
      );
      await chat.addQueryChunk(
        Message.text(text: msg, isUser: true),
      );
      final response = await chat.generateChatResponse();
      // todo : handle function here
      print(" ============================= > ${response}");
      if (response is TextResponse) {
        print("normal res " + response.token + " end");
      } else if (response is FunctionCallResponse) {
        print('Function call: ${response.name}  params ${response.args}');
        _handleFunctionCall(response);
      } else if (response is ThinkingResponse) {
        print('Thinking: ${response.content}');
      }
      await chat.clearHistory();
    });

    // await model.close();
  }
}
