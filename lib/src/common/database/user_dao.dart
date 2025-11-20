import 'package:namma_wallet/src/common/database/i_user_dao.dart';
import 'package:namma_wallet/src/common/database/i_wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

/// Data Access Object for User operations
class UserDao implements IUserDao {
  UserDao({IWalletDatabase? database, ILogger? logger})
      : _database = database ?? getIt<IWalletDatabase>(),
        _logger = logger ?? getIt<ILogger>();

  final IWalletDatabase _database;
  final ILogger _logger;

  /// Fetch all users from the database
  @override
  Future<List<Map<String, Object?>>> fetchAllUsers() async {
    try {
      _logger.logDatabase('Query', 'Fetching all users');
      final db = await _database.database;
      final users = await db.query('users', orderBy: 'user_id DESC');
      _logger.logDatabase('Success', 'Fetched ${users.length} users');
      return users;
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch all users', e, stackTrace);
      rethrow;
    }
  }
}
