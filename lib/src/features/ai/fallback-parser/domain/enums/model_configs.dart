import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart';

/// Enum [Model] used to save the model meta-data for development
enum Model {
  /// Gemma 3 1B model
  gemma3_1B(
    url:
        'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv2048.task',
    filename: 'Gemma3-1B-IT_multi-prefill-seq_q4_ekv2048.task',
    displayName: 'Gemma 3 1B IT',
    size: '0.5GB',
    licenseUrl: 'https://huggingface.co/litert-community/Gemma3-1B-IT',
    needsAuth: true,
    preferredBackend: PreferredBackend.cpu,
    modelType: ModelType.gemmaIt,
    temperature: 1,
    topK: 64,
    topP: 0.95,
  ),

  /// Gemma 3 270M (Ultra-compact text-only model)
  gemma3_270M(
    url:
        'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.task',
    filename: 'gemma3-270m-it-q8.task',
    displayName: 'Gemma 3 270M IT',
    size: '0.3GB',
    licenseUrl: 'https://huggingface.co/litert-community/gemma-3-270m-it',
    needsAuth: true,
    preferredBackend: PreferredBackend.cpu,
    modelType: ModelType.gemmaIt,
    temperature: 1,
    topK: 64,
    topP: 0.95,
  );

  /// Constructor
  const Model({
    required this.url,
    required this.filename,
    required this.displayName,
    required this.size,
    required this.licenseUrl,
    required this.needsAuth,
    required this.preferredBackend,
    required this.modelType,
    required this.temperature,
    required this.topK,
    required this.topP,
    this.localModel = false,
    this.supportImage = false,
    this.maxTokens = 1024,
    this.maxNumImages = 1,
    this.supportsFunctionCalls = false,
    this.isThinking = false,
  });

  /// URL where the model can be downloaded or accessed.
  final String url;

  /// The filename used when storing the model locally.
  final String filename;

  /// A human-readable display name for the model.
  final String displayName;

  /// Model file size (as a string, e.g., "2.3 GB").
  final String size;

  /// URL of the license under which the model is distributed.
  final String licenseUrl;

  /// Whether the model requires authentication to access.
  final bool needsAuth;

  /// Whether the model is already stored locally on the device.
  final bool localModel;

  /// The preferred backend for running this model.
  final PreferredBackend preferredBackend;

  /// The type of model (e.g., text, image, multimodal).
  final ModelType modelType;

  /// Sampling temperature controlling randomness in generation.
  final double temperature;

  /// Top-K sampling parameter for generation.
  final int topK;

  /// Top-P (nucleus) sampling parameter for generation.
  final double topP;

  /// Whether the model supports image input.
  final bool supportImage;

  /// Maximum number of tokens this model can generate.
  final int maxTokens;

  /// Maximum number of images supported, if applicable.
  final int? maxNumImages;

  /// Whether the model supports function calling (tool use).
  final bool supportsFunctionCalls;

  /// Whether this model supports "thinking" style responses.
  final bool isThinking;
}
