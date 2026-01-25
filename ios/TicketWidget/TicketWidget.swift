//
//  TicketWidget.swift
//  TicketWidget
//
//  Created by Harish on 14/01/26.
//

import os
import SwiftUI
import WidgetKit

private let logger = Logger(subsystem: "com.nammaflutter.nammawallet", category: "TicketWidget")

// MARK: - TicketData

struct TicketData: Codable {
    enum CodingKeys: String, CodingKey {
        case primaryText = "primary_text"
        case secondaryText = "secondary_text"
        case startTime = "start_time"
        case location
        case type
        case ticketId = "ticket_id"
    }

    let primaryText: String?
    let secondaryText: String?
    let startTime: String?
    let location: String?
    let type: String?
    let ticketId: String?
}

// MARK: - Provider

struct Provider: AppIntentTimelineProvider {
    // MARK: Internal

    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), ticketData: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) async -> SimpleEntry {
        let ticketData = loadTicketData()
        return SimpleEntry(date: Date(), configuration: configuration, ticketData: ticketData)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) async -> Timeline<SimpleEntry> {
        let ticketData = loadTicketData()
        let entry = SimpleEntry(date: Date(), configuration: configuration, ticketData: ticketData)

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())
            ?? Date().addingTimeInterval(15 * 60)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    // MARK: Private

    private let appGroupId = "group.com.nammaflutter.nammawallet"
    private let dataKey = "ticket_data"

    private func loadTicketData() -> TicketData? {
        guard let userDefaults = UserDefaults(suiteName: appGroupId),
              let jsonString = userDefaults.string(forKey: dataKey),
              let data = jsonString.data(using: .utf8)
        else {
            return nil
        }

        do {
            return try JSONDecoder().decode(TicketData.self, from: data)
        } catch {
            logger.error("Failed to decode ticket data: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - SimpleEntry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let ticketData: TicketData?
}

// MARK: - TicketWidgetEntryView

struct TicketWidgetEntryView: View {
    // MARK: Internal

    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        case .systemSmall:
            if let ticket = entry.ticketData {
                smallTicketView(ticket: ticket)
            } else {
                squareWidgetPlaceholder
            }
        default:
            if let ticket = entry.ticketData {
                ticketView(ticket: ticket)
            } else {
                squareWidgetPlaceholder
            }
        }
    }

    // MARK: Private

    // MARK: - Cached Formatters

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private static let compactDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatterNoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private var squareWidgetPlaceholder: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "ticket")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No Ticket Pinned")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Pin a ticket from the app")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Lock Screen Accessory Views

    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let ticket = entry.ticketData {
                VStack(spacing: 2) {
                    Image(systemName: iconName(for: ticket.type))
                        .font(.title3)
                    if let startTime = ticket.startTime,
                       let formatted = formatShortTime(startTime) {
                        Text(formatted)
                            .font(.system(.caption2, design: .monospaced))
                            .minimumScaleFactor(0.8)
                    }
                }
                .widgetURL(widgetURL(for: ticket))
            } else {
                Image(systemName: "ticket")
                    .font(.title2)
            }
        }
    }

    @ViewBuilder
    private var accessoryRectangularView: some View {
        if let ticket = entry.ticketData {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: iconName(for: ticket.type))
                        .font(.caption)
                    if let pnr = ticket.ticketId, !pnr.isEmpty {
                        Text(pnr)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                if let startTime = ticket.startTime,
                   let formatted = formatDateTime(startTime) {
                    Text(formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let location = ticket.location, !location.isEmpty {
                    Text(location)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .widgetURL(widgetURL(for: ticket))
        } else {
            HStack(spacing: 4) {
                Image(systemName: "ticket")
                Text("No Ticket Pinned")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var accessoryInlineView: some View {
        if let ticket = entry.ticketData {
            HStack(spacing: 4) {
                Image(systemName: iconName(for: ticket.type))
                Text(ticket.primaryText ?? "No Route")
            }
            .widgetURL(widgetURL(for: ticket))
        } else {
            HStack(spacing: 4) {
                Image(systemName: "ticket")
                Text("No Ticket")
            }
        }
    }

    private func parseISODate(_ isoString: String) -> Date? {
        if let date = Self.isoFormatter.date(from: isoString) {
            return date
        }
        return Self.isoFormatterNoFractional.date(from: isoString)
    }

    private func formatShortTime(_ isoString: String) -> String? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return Self.shortTimeFormatter.string(from: parsedDate)
    }

    @ViewBuilder
    private func smallTicketView(ticket: TicketData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // PNR badge at top
            if let pnr = ticket.ticketId, !pnr.isEmpty {
                Text(pnr)
                    .font(.system(.title3, design: .monospaced, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            Spacer()

            // Date and Time on separate lines
            if let startTime = ticket.startTime,
               let (date, time) = formatDateTimeSeparate(startTime) {
                Text(date)
                    .font(.system(.footnote, design: .monospaced, weight: .medium))
                    .foregroundColor(.blue)
                    .lineLimit(1)
                Text(time)
                    .font(.system(.title2, design: .monospaced, weight: .semibold))
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }

            // Boarding point
            if let location = ticket.location, !location.isEmpty {
                Text(location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(12)
        .widgetURL(widgetURL(for: ticket))
    }

    private func formatCompactDateTime(_ isoString: String) -> String? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return Self.compactDateTimeFormatter.string(from: parsedDate)
    }

    private func formatDateTimeSeparate(_ isoString: String) -> (date: String, time: String)? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return (Self.dateOnlyFormatter.string(from: parsedDate), Self.timeOnlyFormatter.string(from: parsedDate))
    }

    @ViewBuilder
    private func ticketView(ticket: TicketData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Ticket type icon and route
            HStack(spacing: 6) {
                Image(systemName: iconName(for: ticket.type))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(ticket.primaryText ?? "No Route")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            // Secondary info (train/bus number)
            if let secondary = ticket.secondaryText, !secondary.isEmpty {
                Text(secondary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Time and location
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let startTime = ticket.startTime,
                       let formatted = formatDateTime(startTime) {
                        Text(formatted)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.blue)
                    }

                    if let location = ticket.location, !location.isEmpty {
                        Text(location)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // PNR badge
                if let pnr = ticket.ticketId, !pnr.isEmpty {
                    Text(pnr)
                        .font(.system(.caption2, design: .monospaced, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(4)
                }
            }
        }
        .padding(12)
        .widgetURL(widgetURL(for: ticket))
    }

    private func iconName(for type: String?) -> String {
        switch type?.uppercased() {
        case "BUS":
            return "bus.fill"
        case "TRAIN":
            return "train.side.front.car"
        case "METRO",
             "TRAM":
            return "tram.fill"
        case "FLIGHT":
            return "airplane"
        default:
            return "ticket.fill"
        }
    }

    private func formatDateTime(_ isoString: String) -> String? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return Self.displayFormatter.string(from: parsedDate)
    }

    private func widgetURL(for ticket: TicketData) -> URL? {
        guard let ticketId = ticket.ticketId, !ticketId.isEmpty else {
            return nil
        }
        return URL(string: "nammawallet://ticket/\(ticketId)")
    }
}

// MARK: - TicketWidget

struct TicketWidget: Widget {
    let kind: String = "TicketWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TicketWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ticket Widget")
        .description("Display your pinned ticket on the home screen or lock screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Preview

private let sampleTicket = TicketData(
    primaryText: "Chennai → Mumbai", secondaryText: "Train 12345 • 3A",
    startTime: "2026-01-15T10:30:00.000Z", location: "Chennai Central",
    type: "TRAIN", ticketId: "PNR123456"
)

#Preview("System Small", as: .systemSmall) {
    TicketWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), ticketData: sampleTicket)
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), ticketData: nil)
}

#Preview("Circular", as: .accessoryCircular) {
    TicketWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), ticketData: sampleTicket)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    TicketWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), ticketData: sampleTicket)
}

#Preview("Inline", as: .accessoryInline) {
    TicketWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), ticketData: sampleTicket)
}
