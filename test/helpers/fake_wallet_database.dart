import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:sqflite/sqflite.dart';

import 'fake_database.dart';

/// Test wrapper that uses real WalletDatabase with FakeDatabase.
///
/// Requires explicit logger to avoid relying on global state in tests.
class FakeWalletDatabase implements IWalletDatabase {
  FakeWalletDatabase({required this.fakeDb, required ILogger logger})
    : _walletDb = _TestWalletDatabase(fakeDb, logger);

  final FakeDatabase fakeDb;
  final _TestWalletDatabase _walletDb;

  @override
  Future<Database> get database => _walletDb.database;

  @override
  Future<void> close() => _walletDb.close();
}

/// Internal WalletDatabase that uses FakeDatabase
class _TestWalletDatabase extends WalletDatabase {
  _TestWalletDatabase(this.fakeDb, ILogger logger) : super(logger: logger);

  final FakeDatabase fakeDb;

  @override
  Future<Database> get database => fakeDb.database;
}
