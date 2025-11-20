// More functions will be added here in the future
// ignore_for_file: one_member_abstracts

abstract interface class IUserDao {
  /// Fetch all users from the database
  Future<List<Map<String, Object?>>> fetchAllUsers();
}
