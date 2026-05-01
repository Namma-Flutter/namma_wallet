import 'package:dart_mappable/dart_mappable.dart';

part 'reminder_preferences.mapper.dart';

@MappableClass()
class ReminderPreferences with ReminderPreferencesMappable {
  const ReminderPreferences({
    required this.selectedIntervals,
    this.customDateTimeMillis = const [],
    this.isEnabled = true,
    this.isCustomized = false,
  });

  /// List of hours before journey start time to show reminders
  /// Default values are [24, 4, 2] (24 hours, 4 hours, 2 hours)
  final List<int> selectedIntervals;

  /// Custom date-times for reminders stored as milliseconds since epoch
  /// (timezone-independent format)
  final List<int> customDateTimeMillis;

  /// Whether reminders are enabled for this ticket
  final bool isEnabled;

  /// Whether the user has explicitly customized this ticket's preferences
  /// (as opposed to using defaults because no preferences were ever saved).
  /// This flag allows distinguishing 'never customized' from 'explicitly saved
  /// preferences that happen to match the hardcoded defaults'.
  final bool isCustomized;

  /// Convert milliseconds to DateTime objects (in local timezone)
  List<DateTime> get customDateTimes => customDateTimeMillis
      .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms).toLocal())
      .toList();

  /// Create a copy with updated custom date times
  ReminderPreferences copyWithDateTimes(List<DateTime> dateTimes) =>
      ReminderPreferences(
        selectedIntervals: selectedIntervals,
        customDateTimeMillis: dateTimes
            .map((dt) => dt.millisecondsSinceEpoch)
            .toList(),
        isEnabled: isEnabled,
        isCustomized: isCustomized,
      );

  /// Default reminder preferences (24hr, 4hr, 2hr) with isCustomized=false
  /// (indicating these are the hardcoded defaults, never saved by the user)
  static const ReminderPreferences defaultPreferences = ReminderPreferences(
    selectedIntervals: [24, 4, 2],
  );
}
