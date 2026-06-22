import AppIntents
import Foundation
import os
import UIKit

@available(iOS 16.0, *)
struct EnqueueSMSIntent: AppIntent {
  static var title: LocalizedStringResource = "Add SMS to Namma Wallet"
  static var description: IntentDescription =
    "Queues an SMS text message and opens Namma Wallet to parse it."
  static var openAppWhenRun: Bool = true

  private var logger: Logger {
    Logger(subsystem: "com.nammaflutter.nammawallet", category: "EnqueueSMSIntent")
  }

  @Parameter(
    title: "SMS Text",
    description: "The full SMS message to queue.",
    inputOptions: String.IntentInputOptions(multiline: true)
  )
  var smsText: String

  func perform() async throws -> some IntentResult {
    let trimmedText = smsText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty else {
      logger.error("SMS text is empty")
      throw IntentError.emptyText
    }

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      appDelegate.enqueueSMS(trimmedText)
    else {
      logger.error("Failed to enqueue SMS")
      throw IntentError.queueFailed
    }

    logger.info("Enqueued SMS successfully, opening app to drain queue")
    return .result()
  }
}

@available(iOS 16.0, *)
enum IntentError: Error, CustomLocalizedStringResourceConvertible {
  case emptyText
  case queueFailed

  var localizedStringResource: LocalizedStringResource {
    switch self {
    case .emptyText:
      return "The SMS text cannot be empty."
    case .queueFailed:
      return "Failed to save SMS to queue."
    }
  }
}
