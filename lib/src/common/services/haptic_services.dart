import 'package:gaimon/gaimon.dart';
import 'package:namma_wallet/src/common/services/haptic_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// Creates a new [HapticService] with haptics enabled by default.
  /// Call [loadPreference] to load the user's saved preference.
  HapticService() {
    _initFuture = loadPreference();
  }
  // default true or choose false if desired
  HapticService._();

  static Future<HapticService> create() async {
    final service = HapticService._();
    await service.loadPreference();
    return service;
  }

  /// Creates a new instance of [HapticService].
  static const _prefKey = 'isHapticEnabled';
  bool _isEnabled = true;
  Future<void>? _initFuture;
  @override
  Future<bool> canSupportHaptic() async {
    return Gaimon.canSupportsHaptic;
  }

  @override
  void selection() {
    _initFuture?.ignore(); // Ensure init started
    if (!_isEnabled) return;

    Gaimon.selection();
  }

  @override
  void success() {
    if (!_isEnabled) return;

    // Use medium impact for success feedback (positive, moderate)
    Gaimon.medium();
  }

  @override
  void error() {
    if (!_isEnabled) return;

    // Use rigid impact for error feedback (sharp, negative)
    Gaimon.rigid();
  }

  @override
  void warning() {
    if (!_isEnabled) return;

    // Use light impact for warning feedback (gentle alert)
    Gaimon.light();
  }

  @override
  void rigid() {
    if (!_isEnabled) return;

    Gaimon.rigid();
  }

  @override
  void soft() {
    if (!_isEnabled) return;

    Gaimon.soft();
  }

  @override
  Future<void> loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_prefKey) ?? _isEnabled;
    } on Exception catch (_) {
      // Log error or fallback to default
      // _isEnabled remains at default value
    }
  }

  @override
  Future<void> setEnabled({required bool enabled}) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } on Exception catch (_) {
      // Log error - in-memory value is already updated
    }
  }

  @override
  bool get isEnabled => _isEnabled;
}

/// Static convenience wrapper for [HapticService].
///
/// **Important:** Call [HapticServices.loadPreference] during app initialization
/// before using any haptic methods, otherwise the saved user preference will be ignored.
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

  static final _service = HapticService();
  // existing static methods...
  static Future<void> loadPreference() => _service.loadPreference();
  static Future<void> setEnabled({required bool enabled}) =>
      _service.setEnabled(enabled: enabled);
  static bool get isEnabled => _service.isEnabled;

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
