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
                placeholderView
            }
        default:
            if let ticket = entry.ticketData {
                ticketView(ticket: ticket)
            } else {
                placeholderView
            }
        }
    }

    // MARK: Private

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "ticket")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No Ticket Pinned")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Pin a ticket from the app")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
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
                       let formatted = formatShortTime(startTime)
                    {
                        Text(formatted)
                            .font(.system(.caption2, design: .monospaced))
                            .minimumScaleFactor(0.8)
                    }
                }
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
                   let formatted = formatDateTime(startTime)
                {
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
        } else {
            HStack(spacing: 4) {
                Image(systemName: "ticket")
                Text("No Ticket")
            }
        }
    }

    private func formatShortTime(_ isoString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date?
        date = formatter.date(from: isoString)

        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }

        guard let parsedDate = date else {
            return nil
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"
        return displayFormatter.string(from: parsedDate)
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
               let (date, time) = formatDateTimeSeparate(startTime)
            {
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
    }

    private func formatCompactDateTime(_ isoString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date?
        date = formatter.date(from: isoString)

        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }

        guard let parsedDate = date else {
            return nil
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, HH:mm"
        return displayFormatter.string(from: parsedDate)
    }

    private func formatDateTimeSeparate(_ isoString: String) -> (date: String, time: String)? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date?
        date = formatter.date(from: isoString)

        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }

        guard let parsedDate = date else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        return (dateFormatter.string(from: parsedDate), timeFormatter.string(from: parsedDate))
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
                       let formatted = formatDateTime(startTime)
                    {
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
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Try with fractional seconds first
        if let date = formatter.date(from: isoString) {
            return formatDate(date)
        }

        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: isoString) {
            return formatDate(date)
        }

        // Return nil if parsing fails - let UI handle missing data
        return nil
    }

    private func formatDate(_ date: Date) -> String {
        return Self.displayFormatter.string(from: date)
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
            .accessoryInline,
        ])
    }
}

// MARK: - Preview

#Preview("System Small", as: .systemSmall) {
    TicketWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        ticketData: TicketData(
            primaryText: "Chennai → Mumbai",
            secondaryText: "Train 12345 • 3A",
            startTime: "2026-01-15T10:30:00.000",
            location: "Chennai Central",
            type: "TRAIN",
            ticketId: "PNR123456"
        )
    )
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        ticketData: nil
    )
}

#Preview("Circular", as: .accessoryCircular) {
    TicketWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        ticketData: TicketData(
            primaryText: "Chennai → Mumbai",
            secondaryText: "Train 12345 • 3A",
            startTime: "2026-01-15T10:30:00.000",
            location: "Chennai Central",
            type: "TRAIN",
            ticketId: "PNR123456"
        )
    )
}

#Preview("Rectangular", as: .accessoryRectangular) {
    TicketWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        ticketData: TicketData(
            primaryText: "Chennai → Mumbai",
            secondaryText: "Train 12345 • 3A",
            startTime: "2026-01-15T10:30:00.000",
            location: "Chennai Central",
            type: "TRAIN",
            ticketId: "PNR123456"
        )
    )
}

#Preview("Inline", as: .accessoryInline) {
    TicketWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        ticketData: TicketData(
            primaryText: "Chennai → Mumbai",
            secondaryText: "Train 12345 • 3A",
            startTime: "2026-01-15T10:30:00.000",
            location: "Chennai Central",
            type: "TRAIN",
            ticketId: "PNR123456"
        )
    )
}
