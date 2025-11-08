/// Abstract interface for haptic feedback service.
///
/// This interface allows for dependency injection and testing of haptic
/// feedback functionality throughout the application.
abstract class IHapticService {
  /// Checks if the device supports haptic feedback.
  ///
  /// Returns a [Future] that resolves to `true` if the device supports haptic
  /// feedback, `false` otherwise.
  Future<bool> canSupportHaptic();

  /// Triggers a selection haptic feedback.
  ///
  /// Typically used for button taps, selection changes, and toggle switches.
  void selection();

  /// Triggers a success haptic feedback.
  ///
  /// Used to indicate successful operations or completions.
  /// Uses medium impact for positive feedback.
  void success();

  /// Triggers an error haptic feedback.
  ///
  /// Used to indicate errors or failure conditions.
  /// Uses rigid impact for sharp negative feedback.
  void error();

  /// Triggers a warning haptic feedback.
  ///
  /// Used to indicate warnings or cautionary conditions.
  /// Uses light impact for gentle alert feedback.
  void warning();

  /// Triggers a rigid impact haptic feedback.
  ///
  /// Represents a sharp, rigid physical impact for precise interactions.
  void rigid();

  /// Triggers a soft impact haptic feedback.
  ///
  /// Represents a soft, gentle physical impact for smooth interactions.
  void soft();
}
