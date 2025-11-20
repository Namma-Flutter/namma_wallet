// More functions will be added here in the future
// ignore_for_file: one_member_abstracts

import 'package:namma_wallet/src/features/common/domain/user.dart';

abstract interface class IUserDAO {
  /// Fetch all users from the database
  Future<List<User>> fetchAllUsers();
}
