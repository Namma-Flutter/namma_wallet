import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart'
    show GenericDetailsModel;

final List<Tool> _tools = [
  const Tool(
    name: 'is_exist_in_db',
    description:
        'Checks weather a particular ticket data is already exist in database',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string', 'description': 'unique ticket id'},
      },
      'required': ['id'],
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

  // single or batch process both handled here

  Future<List<GenericDetailsModel>> _parseBatch(List<String> data) async {
    // get the current model
    final model = await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.gpu,
    );

    // Use model
    final chat = await model.createChat(
      supportsFunctionCalls: true,
    );
    List<GenericDetailsModel> _response = [];
    await Future.forEach(data, (msg) async {
      await chat.addQueryChunk(
        Message.text(
          text: '', //TODO: prompt
        ),
      );
      await chat.addQueryChunk(
        Message.text(text: msg, isUser: true),
      );
      final response = await chat.generateChatResponse();
     // todo : handle function here
      await chat.clearHistory();
    });

    await model.close();
  }
}
