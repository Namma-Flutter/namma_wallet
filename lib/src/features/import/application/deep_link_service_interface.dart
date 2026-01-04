abstract interface class IDeepLinkService {
  Future<void> initialize({
    void Function(Object error)? onError,
    void Function(String message)? onWarning,
  });
  Future<void> dispose();
}
