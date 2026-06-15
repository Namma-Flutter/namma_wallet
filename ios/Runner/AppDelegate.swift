import Flutter
import home_widget
import UIKit
import os

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  // MARK: - SMS Queue MethodChannel

  /// App Group suite name shared across Runner, Share Extension and TicketWidget targets.
  private static let appGroupSuite = "group.com.nammaflutter.nammawallet"
  /// UserDefaults key for the pending SMS queue (JSON-encoded [String]).
  private static let smsQueueKey = "sms_queue"
  /// Logger for SMS Queue operations
  private let queueLog = OSLog(subsystem: "com.nammaflutter.nammawallet", category: "SMSQueue")

  // MARK: - URL Scheme / Deep Link

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Handle deep links from widgets
    if url.scheme == "nammawallet" {
      let components = url.pathComponents

      // nammawallet://ticket/{ticketId}
      if components.count >= 3, components[1] == "ticket" {
        let ticketId = components[2]
        if let controller = window?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(
            name: "com.nammaflutter.nammawallet/deeplink",
            binaryMessenger: controller.binaryMessenger
          )
          channel.invokeMethod("openTicket", arguments: ["ticketId": ticketId])
        }
        return true
      }

      // nammawallet://enqueue?sms=<text>
      // Recommended Shortcut action: Open URL with this scheme so Shortcuts can
      // enqueue an SMS without needing Scriptable or a script action.
      if components.count >= 2, components[1] == "enqueue",
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
        let smsText = queryItems.first(where: { $0.name == "sms" })?.value,
        !smsText.isEmpty
      {
        enqueueSMS(smsText)
        return true
      }
    }

    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 17.0, *) {
      HomeWidgetPlugin.setConfigurationLookup(to: [
        "TicketWidget": ConfigurationAppIntent.self
      ])
    }

    if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannels(binaryMessenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if #available(iOS 17.0, *) {
      HomeWidgetPlugin.setConfigurationLookup(to: [
        "TicketWidget": ConfigurationAppIntent.self
      ])
    }

    if let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "SMSQueue")?.messenger() {
      setupMethodChannels(binaryMessenger: messenger)
    }
  }

  private func setupMethodChannels(binaryMessenger: FlutterBinaryMessenger) {
    let smsQueueChannel = FlutterMethodChannel(
      name: "com.nammaflutter.nammawallet/sms_queue",
      binaryMessenger: binaryMessenger
    )
    smsQueueChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      switch call.method {
      case "readSMSQueue":
        result(self.readSMSQueue())
      case "clearSMSQueue":
        self.clearSMSQueue()
        result(nil)
      case "enqueueSMS":
        if let text = call.arguments as? String, !text.isEmpty {
          self.enqueueSMS(text)
          result(nil)
        } else {
          result(
            FlutterError(
              code: "INVALID_ARGUMENT",
              message: "enqueueSMS requires a non-empty String argument",
              details: nil
            )
          )
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // MARK: - Queue Helpers

  /// Returns all pending SMS texts from the App Group UserDefaults queue.
  /// Returns an empty array if the queue is empty or unreadable.
  private func readSMSQueue() -> [String] {
    os_log("Attempting to read SMS queue from App Group", log: queueLog, type: .info)
    guard
      let defaults = UserDefaults(suiteName: AppDelegate.appGroupSuite),
      let data = defaults.data(forKey: AppDelegate.smsQueueKey),
      let queue = try? JSONDecoder().decode([String].self, from: data)
    else {
      os_log("SMS queue is empty or unreadable", log: queueLog, type: .info)
      return []
    }
    os_log("Successfully read %d items from SMS queue", log: queueLog, type: .info, queue.count)
    return queue
  }

  /// Removes the SMS queue key from the App Group UserDefaults.
  private func clearSMSQueue() {
    os_log("Clearing SMS queue from App Group", log: queueLog, type: .info)
    UserDefaults(suiteName: AppDelegate.appGroupSuite)?.removeObject(
      forKey: AppDelegate.smsQueueKey
    )
  }

  /// Appends `text` to the SMS queue in App Group UserDefaults.
  /// Creates the queue if it does not yet exist.
  @discardableResult
  private func enqueueSMS(_ text: String) -> Bool {
    os_log("Enqueuing new SMS text", log: queueLog, type: .info)
    guard let defaults = UserDefaults(suiteName: AppDelegate.appGroupSuite) else {
      os_log("Failed to access App Group UserDefaults", log: queueLog, type: .error)
      return false
    }
    var queue: [String] = []
    if let data = defaults.data(forKey: AppDelegate.smsQueueKey),
      let existing = try? JSONDecoder().decode([String].self, from: data)
    {
      queue = existing
    }
    queue.append(text)
    guard let encoded = try? JSONEncoder().encode(queue) else {
      os_log("Failed to encode SMS queue", log: queueLog, type: .error)
      return false
    }
    defaults.set(encoded, forKey: AppDelegate.smsQueueKey)
    os_log("Successfully enqueued SMS. Total items in queue: %d", log: queueLog, type: .info, queue.count)
    return true
  }
}
