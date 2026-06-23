// dart format off
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:home_widget/home_widget.dart';

class MainTicketHomeWidget {
  const MainTicketHomeWidget._();

  static const String _$appGroupId = 'group.com.nammaflutter.nammawallet';

  static const String _$paramPrefix = 'home_widget.MainTicket';

  static Future<void> saveData({
    String? ticketId,
    String? type,
    String? primaryText,
    String? secondaryText,
    String? startTime,
    String? location,
  }) {
    return Future.wait([
      if (ticketId != null) HomeWidget.saveWidgetData<String>('${_$paramPrefix}.ticketId', ticketId, appGroupId: _$appGroupId),
      if (type != null) HomeWidget.saveWidgetData<String>('${_$paramPrefix}.type', type, appGroupId: _$appGroupId),
      if (primaryText != null) HomeWidget.saveWidgetData<String>('${_$paramPrefix}.primaryText', primaryText, appGroupId: _$appGroupId),
      if (secondaryText != null) HomeWidget.saveWidgetData<String>('${_$paramPrefix}.secondaryText', secondaryText, appGroupId: _$appGroupId),
      if (startTime != null) HomeWidget.saveWidgetData<String>('${_$paramPrefix}.startTime', startTime, appGroupId: _$appGroupId),
      if (location != null) HomeWidget.saveWidgetData<String>('${_$paramPrefix}.location', location, appGroupId: _$appGroupId),
    ]);
  }

  static Future<void> deleteData({
    bool ticketId = false,
    bool type = false,
    bool primaryText = false,
    bool secondaryText = false,
    bool startTime = false,
    bool location = false,
  }) {
    return Future.wait([
      if (ticketId) HomeWidget.saveWidgetData('${_$paramPrefix}.ticketId', null, appGroupId: _$appGroupId),
      if (type) HomeWidget.saveWidgetData('${_$paramPrefix}.type', null, appGroupId: _$appGroupId),
      if (primaryText) HomeWidget.saveWidgetData('${_$paramPrefix}.primaryText', null, appGroupId: _$appGroupId),
      if (secondaryText) HomeWidget.saveWidgetData('${_$paramPrefix}.secondaryText', null, appGroupId: _$appGroupId),
      if (startTime) HomeWidget.saveWidgetData('${_$paramPrefix}.startTime', null, appGroupId: _$appGroupId),
      if (location) HomeWidget.saveWidgetData('${_$paramPrefix}.location', null, appGroupId: _$appGroupId),
    ]);
  }

  static Future<({String? ticketId, String? type, String? primaryText, String? secondaryText, String? startTime, String? location})> getData() async {
    return (
      ticketId: await HomeWidget.getWidgetData<String>('${_$paramPrefix}.ticketId', appGroupId: _$appGroupId),
      type: await HomeWidget.getWidgetData<String>('${_$paramPrefix}.type', defaultValue: '', appGroupId: _$appGroupId),
      primaryText: await HomeWidget.getWidgetData<String>('${_$paramPrefix}.primaryText', defaultValue: '', appGroupId: _$appGroupId),
      secondaryText: await HomeWidget.getWidgetData<String>('${_$paramPrefix}.secondaryText', defaultValue: '', appGroupId: _$appGroupId),
      startTime: await HomeWidget.getWidgetData<String>('${_$paramPrefix}.startTime', defaultValue: '', appGroupId: _$appGroupId),
      location: await HomeWidget.getWidgetData<String>('${_$paramPrefix}.location', defaultValue: '', appGroupId: _$appGroupId),
    );
  }


  static Future<bool?> updateWidget() {
    return HomeWidget.updateWidget(
      androidName: 'MainTicketHomeWidgetReceiver',
      iOSName: 'MainTicketHomeWidget',
    );
  }
}
