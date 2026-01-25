import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:workmanager/workmanager.dart';

/// Callback for interactive widget clicks
@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? data) async {
  // Handle widget interactions here
  // For now, just log the interaction
  if (kDebugMode) {
    print('[HomeWidgetService] Widget interaction: $data');
  }
}

/// Implementation of widget service using home_widget package
// Used via dependency injection, not directly called from entry points
// ignore: unreachable_from_main
class HomeWidgetService implements IWidgetService {
  // Constructor is called via GetIt dependency injection
  // ignore: unreachable_from_main
  HomeWidgetService({
    required ILogger logger,
  }) : _logger = logger;

  final ILogger _logger;

  final String _androidWidgetName = 'TicketListWidgetProvider';
  final String _iOSWidgetName = 'TicketListWidgetProvider';
  final String _dataKey = 'ticket_list';
  // work manager variables
  final String _backgroundTaskName = 'widgetBackgroundUpdate';
  final String _backgroundTaskId = 'ticket_widget_update';

  // Android qualified name for the widget receiver
  final String _androidListWidgetName =
      'com.nammaflutter.nammawallet.TicketListWidgetProvider';
  final String _androidMainWidgetName =
      'com.nammaflutter.nammawallet.MainTicketWidgetProvider';
  // Used for date formatting in updateWidgetWithTicket method
  // ignore: unreachable_from_main
  final DateTimeConverter dateTimeCon = DateTimeConverter.instance;

  @override
  Future<void> initialize() async {
    try {
      // Register interactivity callback for handling widget clicks
      await HomeWidget.registerInteractivityCallback(
        interactiveCallback,
      );

      _logger.info('[HomeWidgetService] Widget service initialized');
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to initialize widget service',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<void> updateWidgetWithTicket(Ticket t) async {
    try {
      _logger.debug(
        'NEW ticket (raw): ${jsonEncode(t.toMap())}',
      );

      // Convert Ticket model to map
      final ticketMap = Map<String, dynamic>.from(t.toMap());

      // Format dates
      if (t.startTime != null) {
        ticketMap['start_time'] = dateTimeCon.formatFullDateTime(
          t.startTime!,
        );
      }
      if (t.endTime != null) {
        ticketMap['end_time'] = dateTimeCon.formatFullDateTime(
          t.endTime!,
        );
      }

      _logger.debug('Processed ticket map: $ticketMap');

      // --- LOAD EXISTING LIST ---
      final existingJson = await HomeWidget.getWidgetData<String>(_dataKey);

      var ticketList = <Map<String, dynamic>>[];
      if (existingJson != null && existingJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(existingJson);

          if (decoded is List) {
            ticketList = List<Map<String, dynamic>>.from(
              decoded.whereType<Map<String, dynamic>>(),
            );
          }
        } on Object catch (e, stackTrace) {
          _logger.error(
            '[HomeWidgetService] Failed to parse widget JSON data. '
            'Malformed JSON: $existingJson',
            e,
            stackTrace,
          );
          rethrow;
        }
      }

      // --- Prevent duplicates by ticket_id ---
      ticketList
        ..removeWhere((element) {
          return element['ticket_id'] == ticketMap['ticket_id'];
        })
        // Add new ticket
        ..add(ticketMap);

      // Save updated list
      await HomeWidget.saveWidgetData(
        _dataKey,
        jsonEncode(ticketList),
      );

      // for future development
      // var installedWidgetResult = await HomeWidget.getInstalledWidgets();
      // var getWidgetData = HomeWidget.getWidgetData("1");
      // _logger.debug("installedWidgetResult: $installedWidgetResult");
      // _logger.debug("getWidgetData: $getWidgetData");

      await _updateWidget();

      _logger.info('[HomeWidgetService] Widget updated successfully');
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to update widget',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Uri?> getInitialWidgetLaunchUri() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to check widget launch',
        e,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> startBackgroundUpdates() async {
    if (!Platform.isAndroid) {
      _logger.info(
        '[HomeWidgetService] Background updates only supported on Android',
      );
      return;
    }

    try {
      await Workmanager().initialize(_callbackDispatcher);

      await Workmanager().registerPeriodicTask(
        _backgroundTaskId,
        _backgroundTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );

      _logger.info('[HomeWidgetService] Background updates started');
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to start background updates',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<void> stopBackgroundUpdates() async {
    if (!Platform.isAndroid) return;

    try {
      await Workmanager().cancelByUniqueName(_backgroundTaskId);
      _logger.info('[HomeWidgetService] Background updates stopped');
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to stop background updates',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<bool> isRequestPinWidgetSupported() async {
    if (!Platform.isAndroid) return false;

    try {
      final isSupported = await HomeWidget.isRequestPinWidgetSupported();
      return isSupported ?? false;
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to check pin widget support',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> requestPinWidget() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Pin widget only supported on Android');
    }

    try {
      await HomeWidget.requestPinWidget(
        qualifiedAndroidName: _androidListWidgetName,
      );
      _logger.info('[HomeWidgetService] Widget pin requested');
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to request pin widget',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Internal method to update widget on all platforms
  Future<void> _updateWidget() async {
    await Future.wait([
      HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      ),
      if (Platform.isAndroid) ...[
        HomeWidget.updateWidget(
          qualifiedAndroidName: _androidListWidgetName,
        ),
        HomeWidget.updateWidget(
          qualifiedAndroidName: _androidMainWidgetName,
        ),
      ],
    ]);
  }
}

/// Background callback for periodic widget updates
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // In a real implementation, you would:
      // 1. Get the latest ticket from the database
      // 2. Update the widget with that ticket data

      // For now, just update with timestamp
      final now = DateTime.now();
      await HomeWidget.saveWidgetData<String>(
        'last_update',
        now.toIso8601String(),
      );

      // Update the widget
      await Future.wait([
        HomeWidget.updateWidget(
          androidName: 'TicketListWidgetProvider',
          iOSName: 'TicketListWidgetProvider',
        ),
        if (Platform.isAndroid) ...[
          HomeWidget.updateWidget(
            qualifiedAndroidName:
                'com.nammaflutter.nammawallet.TicketListWidgetProvider',
          ),
          HomeWidget.updateWidget(
            qualifiedAndroidName:
                'com.nammaflutter.nammawallet.MainTicketWidgetProvider',
          ),
        ],
      ]);

      return true;
    } on Object catch (e) {
      if (kDebugMode) {
        print('[HomeWidgetService] Background task failed: $e');
      }
      return false;
    }
  });
}
