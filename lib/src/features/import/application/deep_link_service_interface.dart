abstract interface class IDeepLinkService {
  Future<void> initialize({void Function(Object error)? onError});
  Future<void> dispose();
}
