//
//  AppIntent.swift
//  TicketWidget
//
//  Created by Harish on 14/01/26.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Ticket Widget" }
    static var description: IntentDescription { "Display your pinned ticket on the home screen." }

    // No configurable parameters needed for now
    // The widget displays the ticket that was pinned from the app
}
