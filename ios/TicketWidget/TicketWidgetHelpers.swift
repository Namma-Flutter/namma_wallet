//
//  TicketWidgetHelpers.swift
//  TicketWidget
//
//  Extracted from TicketWidget.swift to reduce file/type length.
//

import SwiftUI
import WidgetKit

// MARK: - Date Formatting Helpers

enum TicketDateFormatters {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()

    static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static let compactDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter
    }()

    static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let isoFormatterNoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func parseISODate(_ isoString: String) -> Date? {
        if let date = isoFormatter.date(from: isoString) {
            return date
        }
        return isoFormatterNoFractional.date(from: isoString)
    }

    static func formatDateTime(_ isoString: String) -> String? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return displayFormatter.string(from: parsedDate)
    }

    static func formatShortTime(_ isoString: String) -> String? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return shortTimeFormatter.string(from: parsedDate)
    }

    static func formatCompactDateTime(_ isoString: String) -> String? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return compactDateTimeFormatter.string(from: parsedDate)
    }

    static func formatDateTimeSeparate(_ isoString: String) -> (date: String, time: String)? {
        guard let parsedDate = parseISODate(isoString) else {
            return nil
        }
        return (dateOnlyFormatter.string(from: parsedDate), timeOnlyFormatter.string(from: parsedDate))
    }
}

// MARK: - Ticket Helpers

enum TicketHelpers {
    static func iconName(for type: String?) -> String {
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

    static func widgetURL(for ticket: TicketData) -> URL? {
        guard let ticketId = ticket.ticketId, !ticketId.isEmpty else {
            return nil
        }
        return URL(string: "nammawallet://ticket/\(ticketId)")
    }
}
