/// Abstract interface for the Archive Service
// ignore: one_member_abstracts
abstract interface class IArchiveService {
  /// Run archiving: archive past tickets and purge old archived ones.
  ///
  /// This should be called on app startup and is safe to call multiple times.
  Future<void> runArchiveMaintenance();
}
