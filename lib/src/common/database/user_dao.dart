import 'package:namma_wallet/src/common/database/user_dao_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/domain/user.dart';

/// Data Access Object for User operations
class UserDao implements IUserDAO {
  UserDao({IWalletDatabase? database, ILogger? logger})
    : _database = database ?? getIt<IWalletDatabase>(),
      _logger = logger ?? getIt<ILogger>();

  final IWalletDatabase _database;
  final ILogger _logger;

  /// Fetch all users from the database
  @override
  Future<List<User>> fetchAllUsers() async {
    try {
      _logger.logDatabase('Query', 'Fetching all users');
      final db = await _database.database;
      final results = await db.query('users', orderBy: 'user_id DESC');
      _logger.logDatabase('Success', 'Fetched ${results.length} users');

      return results.map(UserMapper.fromMap).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch all users', e, stackTrace);
      rethrow;
    }
  }
}
