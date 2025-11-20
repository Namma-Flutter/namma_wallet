/// Abstract interface for User Data Access Object
abstract interface class IUserDao {
  /// Fetch all users from the database
  Future<List<Map<String, Object?>>> fetchAllUsers();
}
