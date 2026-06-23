// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Placeholder SwiftUI widget.
//
// App Group ID used here: group.com.nammaflutter.nammawallet

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> MainTicketHomeWidgetEntry {
    MainTicketHomeWidgetEntry(date: Date(), data: MainTicketData.fromUserDefaults(nil))
  }

  func getSnapshot(in context: Context, completion: @escaping (MainTicketHomeWidgetEntry) -> Void) {
    let prefs = UserDefaults(suiteName: "group.com.nammaflutter.nammawallet")
    let data = MainTicketData.fromUserDefaults(prefs)

    completion(MainTicketHomeWidgetEntry(date: Date(), data: data))

  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let prefs = UserDefaults(suiteName: "group.com.nammaflutter.nammawallet")
    let data = MainTicketData.fromUserDefaults(prefs)

    completion(Timeline(entries: [MainTicketHomeWidgetEntry(date: Date(), data: data)], policy: .atEnd))

  }
}

struct MainTicketHomeWidgetEntry: TimelineEntry {
  let date: Date
  let data: MainTicketData
}


struct MainTicketHomeWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
        Group {
            if entry.data.ticketId != nil {
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.data.type ?? "")
                        .font(.system(size: 14.0, weight: .bold)).foregroundColor(Color.accentColor)
                    Text(entry.data.primaryText ?? "")
                        .font(.system(size: 22.0, weight: .bold)).foregroundColor(Color.primary)
                        .padding(.top, 4)
                    Text(entry.data.secondaryText ?? "")
                        .font(.system(size: 14.0)).foregroundColor(Color.secondary)
                        .padding(.top, 2)
                    Text(entry.data.startTime ?? "")
                        .font(.system(size: 14.0, weight: .bold)).foregroundColor(Color.primary)
                        .padding(.top, 12)
                    Text(entry.data.location ?? "")
                        .font(.system(size: 13.0)).foregroundColor(Color.secondary)
                        .padding(.top, 2)
                }
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    Text("No Ticket Pinned")
                        .font(.system(size: 16.0, weight: .bold)).foregroundColor(Color.secondary)
                    Text("Pin a ticket from the app")
                        .font(.system(size: 12.0)).foregroundColor(Color.secondary)
                    Spacer()
                }
            }
        }
        .padding(EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    .applyContainerBackground()
  }
}

struct MainTicketHomeWidget: Widget {
  let kind: String = "MainTicketHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      MainTicketHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("MainTicket")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

extension View {
  @ViewBuilder
  func applyContainerBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      self.containerBackground(.fill.tertiary, for: .widget)
    } else if #available(iOSApplicationExtension 15.0, *) {
      self.background()
    } else {
      self
    }
  }
}

struct MainTicketData {
  let ticketId: String?
  let type: String?
  let primaryText: String?
  let secondaryText: String?
  let startTime: String?
  let location: String?

  static let paramPrefix = "home_widget.MainTicket"

  static func fromUserDefaults(_ defaults: UserDefaults?) -> MainTicketData {
    return MainTicketData(
      ticketId: defaults?.string(forKey: "\(paramPrefix).ticketId"),
      type: (defaults?.string(forKey: "\(paramPrefix).type") ?? ""),
      primaryText: (defaults?.string(forKey: "\(paramPrefix).primaryText") ?? ""),
      secondaryText: (defaults?.string(forKey: "\(paramPrefix).secondaryText") ?? ""),
      startTime: (defaults?.string(forKey: "\(paramPrefix).startTime") ?? ""),
      location: (defaults?.string(forKey: "\(paramPrefix).location") ?? ""),
    )
  }
}

