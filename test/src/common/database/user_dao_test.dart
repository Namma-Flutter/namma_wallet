import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/user_dao.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';

import '../../../helpers/fake_database.dart';
import '../../../helpers/fake_logger.dart';
import '../../../helpers/fake_wallet_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserDao', () {
    final getIt = GetIt.instance;
    late FakeDatabase fakeDb;
    late IWalletDatabase database;
    late UserDao userDao;
    late ILogger logger;

    setUp(() async {
      logger = FakeLogger();
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(logger);
      }
      fakeDb = FakeDatabase();
      database = FakeWalletDatabase(fakeDb: fakeDb, logger: logger);
      await database.database;
      userDao = UserDao(database: database, logger: logger);
    });

    tearDown(() async {
      try {
        final db = await fakeDb.database;
        await db.delete('users');
        await fakeDb.close();
        FakeDatabase.reset();
      } on Exception {
        // ignore
      }
      await getIt.reset();
    });

    test('fetchAllUsers returns empty list when no rows', () async {
      final users = await userDao.fetchAllUsers();
      expect(users, isEmpty);
    });

    test(
      'fetchAllUsers rethrows when row data does not match the User mapper',
      () async {
        // The users table uses snake_case columns while the User mapper
        // expects camelCase keys, so a populated row trips a MapperException.
        // This guards the catch/rethrow path.
        final db = await database.database;
        await db.insert('users', {
          'full_name': 'Alice',
          'email': 'alice@example.com',
          'phone': '111',
          'password_hash': 'hash1',
        });

        await expectLater(userDao.fetchAllUsers(), throwsA(isA<Object>()));
      },
    );

    test('fetchAllUsers rethrows when the database query fails', () async {
      // Drop the users table to force a failure.
      final db = await database.database;
      await db.execute('DROP TABLE users;');

      await expectLater(userDao.fetchAllUsers(), throwsA(isA<Object>()));
    });
  });
}
