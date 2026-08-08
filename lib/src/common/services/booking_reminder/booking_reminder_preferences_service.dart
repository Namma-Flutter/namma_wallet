import 'dart:convert';

import 'package:namma_wallet/src/common/domain/models/booking_reminder_preferences.dart';
import 'package:namma_wallet/src/common/services/booking_reminder/booking_reminder_preferences_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingReminderPreferencesService
    implements IBookingReminderPreferencesService {
  BookingReminderPreferencesService({required ILogger logger})
    : _logger = logger {
    _initFuture = _init();
  }

  final ILogger _logger;
  SharedPreferences? _prefs;
  Future<void>? _initFuture;

  static const String _key = 'booking_reminder_preferences';

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } on Exception catch (e, s) {
      _logger.error('[BookingReminderPreferencesService] Init failed', e, s);
    }
  }

  Future<void> _ensureInitialized() async {
    _initFuture ??= _init();
    await _initFuture;
  }

  @override
  Future<List<BookingReminderPreferences>> getAllReminders() async {
    await _ensureInitialized();
    if (_prefs == null) return [];

    final jsonString = _prefs!.getString(_key);
    if (jsonString == null) return [];

    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map(
            (e) => BookingReminderPreferencesMapper.fromMap(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } on Exception catch (e, s) {
      _logger.error(
        '[BookingReminderPreferencesService] Failed to parse',
        e,
        s,
      );
      return [];
    }
  }

  @override
  Future<BookingReminderPreferences?> getReminder(String ticketId) async {
    final all = await getAllReminders();
    final index = all.indexWhere((r) => r.ticketId == ticketId);
    return index != -1 ? all[index] : null;
  }

  Future<void> _saveAll(List<BookingReminderPreferences> reminders) async {
    await _ensureInitialized();
    if (_prefs == null) return;

    final jsonString = jsonEncode(reminders.map((r) => r.toMap()).toList());
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<void> saveReminder(BookingReminderPreferences preferences) async {
    final all = await getAllReminders();
    all.removeWhere((r) => r.ticketId == preferences.ticketId);
    all.add(preferences);
    await _saveAll(all);
  }

  @override
  Future<void> deleteReminder(String ticketId) async {
    final all = await getAllReminders();
    all.removeWhere((r) => r.ticketId == ticketId);
    await _saveAll(all);
  }
}
