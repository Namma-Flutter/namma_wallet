//
//  TicketWidget.swift
//  TicketWidget
//
//  Created by Harish on 14/01/26.
//

import SwiftUI
import WidgetKit

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
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
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
            print("Failed to decode ticket data: \(error)")
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
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let ticket = entry.ticketData {
            ticketView(ticket: ticket)
        } else {
            placeholderView
        }
    }

    @ViewBuilder
    private func ticketView(ticket: TicketData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Ticket type icon and route
            HStack(spacing: 6) {
                Image(systemName: ticket.type?.uppercased() == "BUS" ? "bus.fill" : "tram.fill")
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
                    if let startTime = ticket.startTime {
                        Text(formatDateTime(startTime))
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

    private func formatDateTime(_ isoString: String) -> String {
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

        // Return original if parsing fails
        return isoString
    }

    private func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, h:mm a"
        return displayFormatter.string(from: date)
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
        .description("Display your pinned ticket on the home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
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
            type: "train",
            ticketId: "PNR123456"
        )
    )
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        ticketData: nil
    )
}
