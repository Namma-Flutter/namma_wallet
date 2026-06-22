import Flutter
import UIKit
import home_widget
import os

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let appGroupSuite = "group.com.nammaflutter.nammawallet"
  private static let smsQueueKey = "sms_queue"

  private let queueLog = OSLog(
    subsystem: "com.nammaflutter.nammawallet",
    category: "SMSQueue"
  )

  private let queueLock = NSLock()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureHomeWidget()

    if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannels(binaryMessenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleIncomingURL(url) {
      return true
    }

    return super.application(app, open: url, options: options)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureHomeWidget()

    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SMSQueue")
    if let messenger = registrar?.messenger() {
      setupMethodChannels(binaryMessenger: messenger)
    }
  }

  func handleIncomingURL(
    _ url: URL,
    rootViewController: UIViewController? = nil
  ) -> Bool {
    guard url.scheme == "nammawallet" else {
      return false
    }

    let components = url.pathComponents
    guard components.count >= 3, components[1] == "ticket" else {
      return false
    }

    let ticketId = components[2]
    guard !ticketId.isEmpty else {
      return false
    }

    let controller = rootViewController ?? window?.rootViewController
    guard let flutterController = controller as? FlutterViewController else {
      return false
    }

    let channel = FlutterMethodChannel(
      name: "com.nammaflutter.nammawallet/deeplink",
      binaryMessenger: flutterController.binaryMessenger
    )
    channel.invokeMethod("openTicket", arguments: ["ticketId": ticketId])
    return true
  }

  private func configureHomeWidget() {
    if #available(iOS 17.0, *) {
      HomeWidgetPlugin.setConfigurationLookup(to: [
        "TicketWidget": ConfigurationAppIntent.self
      ])
    }
  }

  private func setupMethodChannels(binaryMessenger: FlutterBinaryMessenger) {
    let smsQueueChannel = FlutterMethodChannel(
      name: "com.nammaflutter.nammawallet/sms_queue",
      binaryMessenger: binaryMessenger
    )

    smsQueueChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        return
      }

      switch call.method {
      case "readSMSQueue":
        result(self.readSMSQueue())
      case "clearSMSQueue":
        self.clearSMSQueue()
        result(nil)
      case "replaceSMSQueue":
        guard let texts = call.arguments as? [String] else {
          result(
            FlutterError(
              code: "INVALID_ARGUMENT",
              message: "replaceSMSQueue requires a String array argument",
              details: nil
            )
          )
          return
        }

        if self.replaceSMSQueue(texts) {
          result(nil)
        } else {
          result(
            FlutterError(
              code: "QUEUE_WRITE_FAILED",
              message: "Failed to replace SMS queue",
              details: nil
            )
          )
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func readSMSQueue() -> [String] {
    os_log("Reading SMS queue from App Group", log: queueLog, type: .info)

    guard
      let defaults = UserDefaults(suiteName: AppDelegate.appGroupSuite),
      let data = defaults.data(forKey: AppDelegate.smsQueueKey),
      let queue = try? JSONDecoder().decode([String].self, from: data)
    else {
      os_log("SMS queue is empty or unreadable", log: queueLog, type: .info)
      return []
    }

    os_log(
      "Read %d SMS queue item(s)",
      log: queueLog,
      type: .info,
      queue.count
    )
    return queue
  }

  private func clearSMSQueue() {
    queueLock.lock()
    defer { queueLock.unlock() }
    os_log("Clearing SMS queue", log: queueLog, type: .info)
    UserDefaults(suiteName: AppDelegate.appGroupSuite)?
      .removeObject(forKey: AppDelegate.smsQueueKey)
  }

  @discardableResult
  private func replaceSMSQueue(_ queue: [String]) -> Bool {
    queueLock.lock()
    defer { queueLock.unlock() }
    if queue.isEmpty {
      UserDefaults(suiteName: AppDelegate.appGroupSuite)?
        .removeObject(forKey: AppDelegate.smsQueueKey)
      return true
    }

    return writeSMSQueue(queue)
  }

  @discardableResult
  func enqueueSMS(_ text: String) -> Bool {
    queueLock.lock()
    defer { queueLock.unlock() }
    var queue = readSMSQueue()
    queue.append(text)
    return writeSMSQueue(queue)
  }

  private func writeSMSQueue(_ queue: [String]) -> Bool {
    guard let defaults = UserDefaults(suiteName: AppDelegate.appGroupSuite) else {
      os_log("Failed to access App Group UserDefaults", log: queueLog, type: .error)
      return false
    }

    guard let encoded = try? JSONEncoder().encode(queue) else {
      os_log("Failed to encode SMS queue", log: queueLog, type: .error)
      return false
    }

    defaults.set(encoded, forKey: AppDelegate.smsQueueKey)
    os_log(
      "Stored %d SMS queue item(s)",
      log: queueLog,
      type: .info,
      queue.count
    )
    return true
  }
}
