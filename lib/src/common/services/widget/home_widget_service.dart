import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:workmanager/workmanager.dart';

/// Implementation of widget service using home_widget package
class HomeWidgetService implements IWidgetService {
  HomeWidgetService({
    required ILogger logger,
    required ITicketDAO ticketDAO,
  }) : _logger = logger,
       _ticketDAO = ticketDAO;

  final ILogger _logger;
  final ITicketDAO _ticketDAO;

  static const String _androidWidgetName = 'TicketHomeWidget';
  static const String _iOSWidgetName = 'TicketHomeWidget';
  static const String _dataKey = 'ticket_data';
  static const String _backgroundTaskName = 'widgetBackgroundUpdate';
  static const String _backgroundTaskId = 'ticket_widget_update';

  // Android qualified name for the widget receiver
  static const String _androidQualifiedName =
      'com.nammaflutter.nammawallet.TicketHomeWidget';

  @override
  Future<void> initialize() async {
    try {
      // Register interactivity callback for handling widget clicks
      await HomeWidget.registerInteractivityCallback(
        _interactiveCallback,
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
  Future<void> updateWidgetWithTicket(Ticket ticket) async {
    try {
      // Convert ticket to JSON format for the widget
      final ticketData = ticket.toJson();
      final jsonString = jsonEncode(ticketData);

      _logger.info(
        '[HomeWidgetService] Updating widget with ticket: ${ticket.ticketId}',
      );

      // Save ticket data
      await HomeWidget.saveWidgetData<String>(_dataKey, jsonString);

      // Update widget on both platforms
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
        qualifiedAndroidName: _androidQualifiedName,
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
      if (Platform.isAndroid)
        HomeWidget.updateWidget(
          qualifiedAndroidName: _androidQualifiedName,
        ),
    ]);
  }

  /// Callback for interactive widget clicks
  static Future<void> _interactiveCallback(Uri? data) async {
    // Handle widget interactions here
    // For now, just log the interaction
    if (kDebugMode) {
      print('[HomeWidgetService] Widget interaction: $data');
    }
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
          androidName: 'TicketHomeWidget',
          iOSName: 'TicketHomeWidget',
        ),
        if (Platform.isAndroid)
          HomeWidget.updateWidget(
            qualifiedAndroidName:
                'com.nammaflutter.nammawallet.TicketHomeWidget',
          ),
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
