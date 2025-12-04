void logCriticalError(Object e, StackTrace stackTrace) {
  // stderr is not available on web, printing to console is done separately
}

String getPlatformInfo() {
  // on web, we can't get platform info from dart:io
  return 'on Web';
}
