import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';

/// Enum representing different types of haptic feedback.
enum HapticType {
  /// Light feedback for selections, button taps, and toggle switches.
  selection,

  /// Feedback for successful operations or completions.
  success,

  /// Feedback for errors or failure conditions.
  error,

  /// Feedback for warnings or cautionary conditions.
  warning,

  /// Sharp, rigid physical impact for precise interactions.
  rigid,

  /// Soft, gentle physical impact for smooth interactions.
  soft,
}

/// Extension on [IHapticService] to provide a convenience method
/// for triggering haptic feedback by type using an enum.
extension HapticServiceExtension on IHapticService {
  /// Triggers haptic feedback of the specified type.
  ///
  /// This method uses a switch case to handle all haptic feedback types.
  /// The underlying implementation gracefully handles devices that don't
  /// support haptic feedback, so this method is safe to call on all devices.
  ///
  /// [type] - The type of haptic feedback to trigger.
  ///
  /// Usage example:c
  /// ```dart
  /// final hapticService = getIt<IHapticService>();
  /// hapticService.triggerHaptic(HapticType.selection);
  ///
  /// // In a button callback
  /// ElevatedButton(
  ///   onPressed: () => hapticService.triggerHaptic(HapticType.success),
  ///   child: Text('Save'),
  /// )
  /// ```
  void triggerHaptic(HapticType type) {
    switch (type) {
      case HapticType.selection:
        selection();
      case HapticType.success:
        success();
      case HapticType.error:
        error();
      case HapticType.warning:
        warning();
      case HapticType.rigid:
        rigid();
      case HapticType.soft:
        soft();
    }
  }
}
