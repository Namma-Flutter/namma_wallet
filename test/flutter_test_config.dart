// test/flutter_test_config.dart
import 'dart:async';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A custom main wrapper for running tests that initializes
/// the sqflite FFI factory.
///
/// This is necessary for running tests on the host (e.g., in a
/// CI environment or on your local machine) where native
/// platform bindings are not available.
///
/// This file is automatically discovered by `flutter_test` and
/// used to wrap all test executions.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // --- GLOBAL TEST SETUP ---

  // Initialize FFI
  sqfliteFfiInit();

  // Set the global factory to the FFI factory.
  // This must be done *once* for the entire test run.
  databaseFactory = databaseFactoryFfi;

  // --- RUN ALL TESTS ---

  // This executes the `main` function of all test files.
  await testMain();

  // --- GLOBAL TEST TEARDOWN ---
  // (if needed)
}
