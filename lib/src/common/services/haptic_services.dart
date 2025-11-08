import 'package:gaimon/gaimon.dart';
import 'package:namma_wallet/src/common/services/haptic_service_interface.dart';

/// Implementation of [IHapticService] using the `gaimon` package.
///
/// This class provides a centralized interface for triggering different types
/// of haptic feedback. All methods are safe to call on all devices, as the
/// underlying implementation gracefully handles devices that don't support
/// haptic feedback.
///
/// Usage example:
/// ```dart
/// // With dependency injection
/// final hapticService = getIt<IHapticService>();
/// hapticService.selection();
///
/// // Or using static convenience methods
/// HapticServices.selection();
/// ```
class HapticService implements IHapticService {
  /// Creates a new instance of [HapticService].
  const HapticService();

  @override
  Future<bool> canSupportHaptic() async {
    return Gaimon.canSupportsHaptic;
  }

  @override
  void selection() {
    Gaimon.selection();
  }

  @override
  void success() {
    // Use medium impact for success feedback (positive, moderate)
    Gaimon.medium();
  }

  @override
  void error() {
    // Use rigid impact for error feedback (sharp, negative)
    Gaimon.rigid();
  }

  @override
  void warning() {
    // Use light impact for warning feedback (gentle alert)
    Gaimon.light();
  }

  @override
  void rigid() {
    Gaimon.rigid();
  }

  @override
  void soft() {
    Gaimon.soft();
  }
}

/// Static convenience wrapper for [HapticService].
///
/// This class provides static methods as a convenience wrapper around
/// [HapticService]. For dependency injection, use [IHapticService] instead.
///
/// Usage example:
/// ```dart
/// // Static convenience methods
/// HapticServices.selection();
/// ```
class HapticServices {
  /// Private constructor to prevent instantiation.
  HapticServices._();

  static const _service = HapticService();

  /// Checks if the device supports haptic feedback.
  ///
  /// Returns a [Future] that resolves to `true` if the device supports haptic
  /// feedback, `false` otherwise.
  static Future<bool> canSupportHaptic() async {
    return _service.canSupportHaptic();
  }

  /// Triggers a selection haptic feedback.
  static void selection() {
    _service.selection();
  }

  /// Triggers a success haptic feedback.
  static void success() {
    _service.success();
  }

  /// Triggers an error haptic feedback.
  static void error() {
    _service.error();
  }

  /// Triggers a warning haptic feedback.
  static void warning() {
    _service.warning();
  }

  /// Triggers a rigid impact haptic feedback.
  static void rigid() {
    _service.rigid();
  }

  /// Triggers a soft impact haptic feedback.
  static void soft() {
    _service.soft();
  }
}
