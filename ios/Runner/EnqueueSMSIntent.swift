import AppIntents
import Foundation
import os

@available(iOS 16.0, *)
struct EnqueueSMSIntent: AppIntent {
  static var title: LocalizedStringResource = "Add SMS to Namma Wallet"
  static var description: IntentDescription =
    "Queues an SMS text message to be parsed by Namma Wallet the next time it opens."

  private var logger: Logger {
    Logger(subsystem: "com.nammaflutter.nammawallet", category: "EnqueueSMSIntent")
  }

  @Parameter(
    title: "SMS Text",
    description: "The full text of the SMS message to queue.",
    inputOptions: String.IntentInputOptions(multiline: true)
  )
  var smsText: String

  func perform() async throws -> some IntentResult {
    logger.info("Executing EnqueueSMSIntent...")
    guard !smsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      logger.error("SMS text is empty, throwing IntentError.emptyText")
      throw IntentError.emptyText
    }

    let success = enqueueSMS(smsText)

    if success {
      logger.info("EnqueueSMSIntent completed successfully")
      return .result()
    } else {
      logger.error("enqueueSMS returned false, throwing IntentError.queueFailed")
      throw IntentError.queueFailed
    }
  }

  enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case emptyText
    case queueFailed

    var localizedStringResource: LocalizedStringResource {
      switch self {
      case .emptyText:
        return "The SMS text cannot be empty."
      case .queueFailed:
        return "Failed to save the SMS to the queue."
      }
    }
  }

  // Reuse the queue logic from AppDelegate
  private func enqueueSMS(_ text: String) -> Bool {
    logger.debug("Attempting to enqueue SMS into App Group UserDefaults")
    let appGroupSuite = "group.com.nammaflutter.nammawallet"
    let smsQueueKey = "sms_queue"

    guard let defaults = UserDefaults(suiteName: appGroupSuite) else {
      logger.error("Failed to access App Group UserDefaults with suite: \(appGroupSuite)")
      return false
    }

    var queue: [String] = []
    if let data = defaults.data(forKey: smsQueueKey),
      let existing = try? JSONDecoder().decode([String].self, from: data)
    {
      queue = existing
    }

    queue.append(text)
    guard let encoded = try? JSONEncoder().encode(queue) else {
      logger.error("Failed to encode SMS queue to JSON")
      return false
    }

    defaults.set(encoded, forKey: smsQueueKey)
    logger.info("Successfully enqueued SMS. Total items in queue: \(queue.count)")
    return true
  }
}
