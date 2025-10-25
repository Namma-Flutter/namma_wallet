class AIConstants {
  /// Hugging Face API key loaded from environment or secure storage.
  /// This value should never be hardcoded in source control.
  static String get huggingFaceKey {
    // Load from environment variable, flutter_dotenv, or SharedPreferences
    // Example: dotenv.env['HUGGING_FACE_KEY'] ?? '';
    return ''; // Placeholder - implement proper loading
  }
}
