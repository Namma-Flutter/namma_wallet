import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

void logCriticalError(Object e, StackTrace stackTrace) {
  stderr
    ..writeln('=' * 80)
    ..writeln('CRITICAL: Initialization failed and logger unavailable')
    ..writeln('=' * 80)
    ..writeln('Error: $e')
    ..writeln('Stack trace:')
    ..writeln(Trace.format(stackTrace))
    ..writeln('=' * 80);
}

String getPlatformInfo() {
  final platform = Platform.operatingSystem;
  final osVersion = Platform.operatingSystemVersion;
  return 'on Platform: $platform, OS: $osVersion';
}
