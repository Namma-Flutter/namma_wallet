import 'package:sqflite/sqflite.dart';

/// Abstract interface for WalletDatabase
/// Provides access to the underlying database instance
abstract interface class IWalletDatabase {
  /// Get the database instance
  Future<Database> get database;

  /// Close the database connection
  Future<void> close();
}
