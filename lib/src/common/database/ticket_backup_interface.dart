/// Abstract interface for Ticket Backup & Restore
abstract interface class ITicketBackup {
  /// Creates a backup and opens file save dialog
  /// Returns the saved file path (or null if cancelled)
  Future<String?> createBackup();

  /// Opens file picker and restores backup
  /// Returns true if restore was successful
  Future<bool> restoreBackup();
}