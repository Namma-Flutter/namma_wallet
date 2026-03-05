import 'package:dart_mappable/dart_mappable.dart';

part 'reminder_preferences.mapper.dart';

@MappableClass()
class ReminderPreferences with ReminderPreferencesMappable {
  const ReminderPreferences({
    required this.selectedIntervals,
    this.customDateTimeMillis = const [],
    this.isEnabled = true,
  });

  /// List of hours before journey start time to show reminders
  /// Default values are [24, 4, 2] (24 hours, 4 hours, 2 hours)
  final List<int> selectedIntervals;

  /// Custom date-times for reminders stored as milliseconds since epoch
  /// (timezone-independent format)
  final List<int> customDateTimeMillis;

  /// Whether reminders are enabled for this ticket
  final bool isEnabled;

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
      );

  /// Default reminder preferences (24hr, 4hr, 2hr)
  static const ReminderPreferences defaultPreferences = ReminderPreferences(
    selectedIntervals: [24, 4, 2],
  );
}
