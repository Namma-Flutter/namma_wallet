// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user.dart';

class UserMapper extends ClassMapperBase<User> {
  UserMapper._();

  static UserMapper? _instance;
  static UserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'User';

  static int _$userId(User v) => v.userId;
  static const Field<User, int> _f$userId = Field('userId', _$userId);
  static String _$fullName(User v) => v.fullName;
  static const Field<User, String> _f$fullName = Field('fullName', _$fullName);
  static String _$email(User v) => v.email;
  static const Field<User, String> _f$email = Field('email', _$email);
  static String _$passwordHash(User v) => v.passwordHash;
  static const Field<User, String> _f$passwordHash = Field(
    'passwordHash',
    _$passwordHash,
  );
  static String? _$phone(User v) => v.phone;
  static const Field<User, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
  );
  static DateTime? _$createdAt(User v) => v.createdAt;
  static const Field<User, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
  );

  @override
  final MappableFields<User> fields = const {
    #userId: _f$userId,
    #fullName: _f$fullName,
    #email: _f$email,
    #passwordHash: _f$passwordHash,
    #phone: _f$phone,
    #createdAt: _f$createdAt,
  };

  static User _instantiate(DecodingData data) {
    return User(
      userId: data.dec(_f$userId),
      fullName: data.dec(_f$fullName),
      email: data.dec(_f$email),
      passwordHash: data.dec(_f$passwordHash),
      phone: data.dec(_f$phone),
      createdAt: data.dec(_f$createdAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static User fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<User>(map);
  }

  static User fromJson(String json) {
    return ensureInitialized().decodeJson<User>(json);
  }
}

mixin UserMappable {
  String toJson() {
    return UserMapper.ensureInitialized().encodeJson<User>(this as User);
  }

  Map<String, dynamic> toMap() {
    return UserMapper.ensureInitialized().encodeMap<User>(this as User);
  }

  UserCopyWith<User, User, User> get copyWith =>
      _UserCopyWithImpl<User, User>(this as User, $identity, $identity);
  @override
  String toString() {
    return UserMapper.ensureInitialized().stringifyValue(this as User);
  }

  @override
  bool operator ==(Object other) {
    return UserMapper.ensureInitialized().equalsValue(this as User, other);
  }

  @override
  int get hashCode {
    return UserMapper.ensureInitialized().hashValue(this as User);
  }
}

extension UserValueCopy<$R, $Out> on ObjectCopyWith<$R, User, $Out> {
  UserCopyWith<$R, User, $Out> get $asUser =>
      $base.as((v, t, t2) => _UserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserCopyWith<$R, $In extends User, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? userId,
    String? fullName,
    String? email,
    String? passwordHash,
    String? phone,
    DateTime? createdAt,
  });
  UserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, User, $Out>
    implements UserCopyWith<$R, User, $Out> {
  _UserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<User> $mapper = UserMapper.ensureInitialized();
  @override
  $R call({
    int? userId,
    String? fullName,
    String? email,
    String? passwordHash,
    Object? phone = $none,
    Object? createdAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (userId != null) #userId: userId,
      if (fullName != null) #fullName: fullName,
      if (email != null) #email: email,
      if (passwordHash != null) #passwordHash: passwordHash,
      if (phone != $none) #phone: phone,
      if (createdAt != $none) #createdAt: createdAt,
    }),
  );
  @override
  User $make(CopyWithData data) => User(
    userId: data.get(#userId, or: $value.userId),
    fullName: data.get(#fullName, or: $value.fullName),
    email: data.get(#email, or: $value.email),
    passwordHash: data.get(#passwordHash, or: $value.passwordHash),
    phone: data.get(#phone, or: $value.phone),
    createdAt: data.get(#createdAt, or: $value.createdAt),
  );

  @override
  UserCopyWith<$R2, User, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

