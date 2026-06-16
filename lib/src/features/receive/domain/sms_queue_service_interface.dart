import 'package:flutter/widgets.dart';

/// Interface for the iOS App Group SMS queue service.
///
/// Responsible for reading pending SMS texts written by iOS Shortcuts
/// into the shared App Group UserDefaults queue, processing each through
/// the travel parser pipeline, and clearing the queue on success.
abstract class ISMSQueueService implements WidgetsBindingObserver {
  /// Initialises the local notification plugin.
  ///
  /// Must be called once before [drainQueue] to ensure notifications
  /// can be posted after a successful drain.
  Future<void> initialize();

  /// Reads, processes and clears all pending SMS entries from the
  /// App Group queue.
  ///
  /// - No-ops on non-iOS platforms.
  /// - No-ops if a drain is already in progress (`_isDraining` guard).
  /// - Posts a local notification when one or more tickets are parsed.
  Future<void> drainQueue();

  /// Disposes any resources held by the service.
  Future<void> dispose();

  /// A notifier that is true while the queue is being drained/parsed.
  ValueNotifier<bool> get isParsing;
}
