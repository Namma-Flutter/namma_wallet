abstract interface class ITicketBackupService {
  Future<String?> createBackup();
  Future<bool> restoreBackup();
}
