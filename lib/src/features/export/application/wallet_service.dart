import 'dart:io';

abstract class WalletService {
  Future<void> exportToWallet() async {}
}

class GoogleWalletService implements WalletService {
  @override
  Future<void> exportToWallet() async {}
}

class AppleWalletService implements WalletService {
  @override
  Future<void> exportToWallet() async {}
}

class WalletServiceFactory {
  /// Creates an instance of [WalletService] based on the given [walletType].
  ///
  /// Throws an [Exception] if the given [walletType] is invalid.
  static WalletService createWalletService() {
    if (Platform.isIOS) {
      return AppleWalletService();
    } else if (Platform.isAndroid) {
      return GoogleWalletService();
    } else {
      throw Exception('Invalid wallet type');
    }
  }
}

enum WalletType { google, apple }
