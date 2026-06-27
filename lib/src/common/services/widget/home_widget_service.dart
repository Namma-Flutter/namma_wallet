// coverage:ignore-file
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:namma_wallet/src/home_widget/main_ticket.home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Callback for interactive widget clicks
@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? data) async {
  if (kDebugMode) {
    print('[HomeWidgetService] Widget interaction: $data');
  }
}

/// Implementation of widget service using home_widget package
/// with generated MainTicketHomeWidget helper.
class HomeWidgetService implements IWidgetService {
  HomeWidgetService({
    required this._logger,
  });

  final ILogger _logger;
  final DateTimeConverter _dateTimeCon = DateTimeConverter.instance;

  final String _backgroundTaskName = 'widgetBackgroundUpdate';
  final String _backgroundTaskId = 'ticket_widget_update';

  @override
  Future<void> initialize() async {
    try {
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
        'Saving ticket to widget: ${t.ticketId}',
      );

      // Format dates
      String? formattedStart;
      if (t.startTime != null) {
        formattedStart = _dateTimeCon.formatFullDateTime(t.startTime!);
      }

      // Save individual fields using generated helper
      await MainTicketHomeWidget.saveData(
        ticketId: t.ticketId,
        type: t.type?.name.toUpperCase(),
        primaryText: t.primaryText,
        secondaryText: t.secondaryText,
        startTime: formattedStart,
        location: t.location,
      );

      await MainTicketHomeWidget.updateWidget();

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
  Future<void> clearWidgetData() async {
    try {
      await MainTicketHomeWidget.deleteData(
        ticketId: true,
        type: true,
        primaryText: true,
        secondaryText: true,
        startTime: true,
        location: true,
      );

      await MainTicketHomeWidget.updateWidget();

      _logger.info('[HomeWidgetService] Widget data cleared');
    } on Object catch (e, stackTrace) {
      _logger.error(
        '[HomeWidgetService] Failed to clear widget data',
        e,
        stackTrace,
      );
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
        qualifiedAndroidName:
            'com.nammaflutter.nammawallet.MainTicketHomeWidgetReceiver',
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
}

/// Background callback for periodic widget updates
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await MainTicketHomeWidget.updateWidget();
      return true;
    } on Object catch (e) {
      if (kDebugMode) {
        print('[HomeWidgetService] Background task failed: $e');
      }
      return false;
    }
  });
}
