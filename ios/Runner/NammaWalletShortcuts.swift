import AppIntents

@available(iOS 16.0, *)
struct NammaWalletShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: EnqueueSMSIntent(),
      phrases: [
        "Add SMS to \(.applicationName)",
        "Queue SMS in \(.applicationName)",
        "Parse SMS in \(.applicationName)"
      ],
      shortTitle: "Add SMS to Namma Wallet",
      systemImageName: "message.fill"
    )
  }
}
