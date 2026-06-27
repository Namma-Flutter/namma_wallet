import 'package:home_widget_generator/home_widget_generator.dart';

@HomeWidget(
  name: 'MainTicket',
  android: HomeWidgetAndroidConfiguration(
    minWidth: 260,
    minHeight: 180,
    targetCellWidth: 3,
    targetCellHeight: 2,
    resizeMode: HWAndroidResizeMode.horizontal,
    widgetCategory: HWAndroidWidgetCategory.homeScreen,
  ),
  iOS: HomeWidgetIOSConfiguration(
    groupId: 'group.com.nammaflutter.nammawallet',
    supportedFamilies: [
      HWWidgetFamily.systemSmall,
      HWWidgetFamily.systemMedium,
    ],
  ),
  widget: HWFill(
    child: HWPadding(
      padding: HWEdgeInsets.all(16),
      child: HWDataExists(
        data: HWString('ticketId'),
        whenPresent: HWColumn(
          crossAxisAlignment: HWCrossAxisAlignment.start,
          children: [
            // Type badge
            HWText(
              HWString('type', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 14,
                fontWeight: HWFontWeight.bold,
                color: HWDefaultColor(HWColorRole.contentAccent),
              ),
            ),
            // Route
            HWText(
              HWString('primaryText', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 22,
                fontWeight: HWFontWeight.bold,
                color: HWDefaultColor(HWColorRole.contentPrimary),
              ),
            ),
            // Service info
            HWText(
              HWString('secondaryText', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 14,
                color: HWDefaultColor(HWColorRole.contentSecondary),
              ),
            ),
            // Time
            HWText(
              HWString('startTime', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 14,
                fontWeight: HWFontWeight.bold,
                color: HWDefaultColor(HWColorRole.contentPrimary),
              ),
            ),
            // Location
            HWText(
              HWString('location', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 13,
                color: HWDefaultColor(HWColorRole.contentSecondary),
              ),
            ),
          ],
        ),
        whenAbsent: HWColumn(
          mainAxisAlignment: HWMainAxisAlignment.center,
          crossAxisAlignment: HWCrossAxisAlignment.center,
          children: [
            HWText.fixed(
              'No Ticket Pinned',
              style: HWTextStyle(
                fontSize: 16,
                fontWeight: HWFontWeight.bold,
                color: HWDefaultColor(HWColorRole.contentSecondary),
              ),
            ),
            HWText.fixed(
              'Pin a ticket from the app',
              style: HWTextStyle(
                fontSize: 12,
                color: HWDefaultColor(HWColorRole.contentTertiary),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
class MainTicket {}
