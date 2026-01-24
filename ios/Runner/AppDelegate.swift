import Flutter
import home_widget
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle deep links from widgets
        if url.scheme == "nammawallet" {
            // Extract the ticket ID from the URL path
            // URL format: nammawallet://ticket/{ticketId}
            let components = url.pathComponents
            if components.count >= 2, components[1] == "ticket", components.count >= 3 {
                let ticketId = components[2]

                // Send the deep link to Flutter
                if let controller = window?.rootViewController as? FlutterViewController {
                    let channel = FlutterMethodChannel(
                        name: "com.nammaflutter.nammawallet/deeplink",
                        binaryMessenger: controller.binaryMessenger
                    )
                    channel.invokeMethod("openTicket", arguments: ["ticketId": ticketId])
                }
            }
            return true
        }

        return super.application(app, open: url, options: options)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        if #available(iOS 17.0, *) {
            HomeWidgetPlugin.setConfigurationLookup(to: [
                "TicketWidget": ConfigurationAppIntent.self
            ])
        }
    }
}
