import 'dart:async';
import 'dart:convert';

import 'package:namma_wallet/src/common/domain/models/reminder_preferences.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for reminder preferences storage
abstract interface class IReminderPreferencesService {
  /// Get reminder preferences for a ticket
  Future<ReminderPreferences> getRemainderPreferences(String ticketId);

  /// Save reminder preferences for a ticket
  Future<void> saveRemainderPreferences(
    String ticketId,
    ReminderPreferences preferences,
  );

  /// Delete reminder preferences for a ticket
  Future<void> deleteRemainderPreferences(String ticketId);

  /// Get global default reminder preferences
  Future<ReminderPreferences> getDefaultRemainderPreferences();

  /// Save global default reminder preferences
  Future<void> saveDefaultRemainderPreferences(ReminderPreferences preferences);
}

/// Service for managing reminder preferences with SharedPreferences
class ReminderPreferencesService implements IReminderPreferencesService {
  ReminderPreferencesService({required ILogger logger}) : _logger = logger {
    unawaited(_init());
  }

  final ILogger _logger;
  late SharedPreferences _prefs;
  Future<void>? _initFuture;

  static const String _defaultPreferencesKey = 'reminder_preferences_default';
  static const String _ticketPreferencesPrefix = 'reminder_preferences_ticket_';

  String _getTicketPreferencesKey(String ticketId) =>
      '$_ticketPreferencesPrefix$ticketId';

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.info('[ReminderPreferencesService] Initialized successfully');
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Failed to initialize SharedPreferences',
        e,
        stackTrace,
      );
    }
  }

  Future<void> _ensureInitialized() async {
    try {
      _initFuture ??= _init();
      await _initFuture;
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Error ensuring initialization',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<ReminderPreferences> getRemainderPreferences(String ticketId) async {
    try {
      await _ensureInitialized();
      final key = _getTicketPreferencesKey(ticketId);
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        _logger.info(
          '[ReminderPreferencesService] No preferences for ticket $ticketId, '
          'returning default',
        );
        return ReminderPreferences.defaultPreferences;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final preferences = ReminderPreferencesMapper.fromMap(json);

      _logger.info(
        '[ReminderPreferencesService] Retrieved preferences for ticket '
        '$ticketId',
      );

      return preferences;
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Error retrieving preferences for '
        'ticket $ticketId',
        e,
        stackTrace,
      );
      return ReminderPreferences.defaultPreferences;
    }
  }

  @override
  Future<void> saveRemainderPreferences(
    String ticketId,
    ReminderPreferences preferences,
  ) async {
    try {
      await _ensureInitialized();
      final key = _getTicketPreferencesKey(ticketId);
      final jsonString = jsonEncode(preferences.toMap());
      await _prefs.setString(key, jsonString);

      _logger.info(
        '[ReminderPreferencesService] Saved preferences for ticket $ticketId',
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Error saving preferences for ticket '
        '$ticketId',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteRemainderPreferences(String ticketId) async {
    try {
      await _ensureInitialized();
      final key = _getTicketPreferencesKey(ticketId);
      await _prefs.remove(key);

      _logger.info(
        '[ReminderPreferencesService] Deleted preferences for ticket $ticketId',
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Error deleting preferences for ticket '
        '$ticketId',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<ReminderPreferences> getDefaultRemainderPreferences() async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs.getString(_defaultPreferencesKey);

      if (jsonString == null) {
        _logger.info(
          '[ReminderPreferencesService] No default preferences found, '
          'using hardcoded default',
        );
        return ReminderPreferences.defaultPreferences;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final preferences = ReminderPreferencesMapper.fromMap(json);

      _logger.info(
        '[ReminderPreferencesService] Retrieved default preferences',
      );

      return preferences;
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Error retrieving default preferences',
        e,
        stackTrace,
      );
      return ReminderPreferences.defaultPreferences;
    }
  }

  @override
  Future<void> saveDefaultRemainderPreferences(
    ReminderPreferences preferences,
  ) async {
    try {
      await _ensureInitialized();
      final jsonString = jsonEncode(preferences.toMap());
      await _prefs.setString(_defaultPreferencesKey, jsonString);

      _logger.info(
        '[ReminderPreferencesService] Saved default preferences',
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        '[ReminderPreferencesService] Error saving default preferences',
        e,
        stackTrace,
      );
    }
  }
}
