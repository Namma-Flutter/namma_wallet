import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

/// User domain model representing a user in the system.
@MappableClass()
class User with UserMappable {
  /// Creates a new User instance.
  const User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    this.phone,
    this.createdAt,
  });

  /// Unique identifier for the user.
  final int userId;

  /// Full name of the user.
  final String fullName;

  /// Email address of the user.
  final String email;

  /// Phone number of the user (optional).
  final String? phone;

  /// Hashed password for authentication.
  final String passwordHash;

  /// Timestamp when the user was created.
  final DateTime? createdAt;
}
