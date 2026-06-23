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
          mainAxisAlignment: HWMainAxisAlignment.spaceBetween,
          crossAxisAlignment: HWCrossAxisAlignment.start,
          children: [
            // Header row: app name + ticket type
            HWRow(
              mainAxisAlignment: HWMainAxisAlignment.spaceBetween,
              children: [
                HWText.fixed(
                  'Namma Wallet',
                  style: HWTextStyle(
                    fontSize: 12,
                    fontWeight: HWFontWeight.bold,
                    color: HWDefaultColor(HWColorRole.contentSecondary),
                  ),
                ),
                HWText(
                  HWString('type', defaultValue: ''),
                  style: HWTextStyle(
                    fontSize: 11,
                    fontWeight: HWFontWeight.bold,
                    color: HWDefaultColor(HWColorRole.contentAccent),
                  ),
                ),
              ],
            ),
            // Primary text (route)
            HWText(
              HWString('primaryText', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 20,
                fontWeight: HWFontWeight.bold,
                color: HWDefaultColor(HWColorRole.contentPrimary),
              ),
            ),
            // Secondary text (service info)
            HWText(
              HWString('secondaryText', defaultValue: ''),
              style: HWTextStyle(
                fontSize: 13,
                color: HWDefaultColor(HWColorRole.contentSecondary),
              ),
            ),
            // Departure time
            HWRow(
              children: [
                HWText.fixed(
                  'Departure  ',
                  style: HWTextStyle(
                    fontSize: 10,
                    color: HWDefaultColor(HWColorRole.contentTertiary),
                  ),
                ),
                HWText(
                  HWString('startTime', defaultValue: ''),
                  style: HWTextStyle(
                    fontSize: 13,
                    fontWeight: HWFontWeight.bold,
                    color: HWDefaultColor(HWColorRole.contentPrimary),
                  ),
                ),
              ],
            ),
            // Location
            HWRow(
              children: [
                HWText.fixed(
                  'Location  ',
                  style: HWTextStyle(
                    fontSize: 10,
                    color: HWDefaultColor(HWColorRole.contentTertiary),
                  ),
                ),
                HWText(
                  HWString('location', defaultValue: ''),
                  style: HWTextStyle(
                    fontSize: 13,
                    fontWeight: HWFontWeight.bold,
                    color: HWDefaultColor(HWColorRole.contentPrimary),
                  ),
                ),
              ],
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
