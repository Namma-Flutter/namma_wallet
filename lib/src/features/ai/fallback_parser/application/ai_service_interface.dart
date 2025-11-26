/// Interface for AI service operations.
///
/// Defines the contract for AI services that can be initialized
/// and used for various AI-powered features.
// More methods will be added as needed.
// ignore: one_member_abstracts
abstract interface class IAIService {
  /// Initializes the AI model.
  ///
  /// This may involve downloading the model, loading it into memory,
  /// or setting up necessary configurations.
  Future<void> init();
}
