// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'booking_reminder_preferences.dart';

class BookingReminderPreferencesMapper
    extends ClassMapperBase<BookingReminderPreferences> {
  BookingReminderPreferencesMapper._();

  static BookingReminderPreferencesMapper? _instance;
  static BookingReminderPreferencesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = BookingReminderPreferencesMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'BookingReminderPreferences';

  static String _$ticketId(BookingReminderPreferences v) => v.ticketId;
  static const Field<BookingReminderPreferences, String> _f$ticketId = Field(
    'ticketId',
    _$ticketId,
  );
  static int? _$bookingOpenDateMillis(BookingReminderPreferences v) =>
      v.bookingOpenDateMillis;
  static const Field<BookingReminderPreferences, int> _f$bookingOpenDateMillis =
      Field('bookingOpenDateMillis', _$bookingOpenDateMillis, opt: true);
  static bool _$isTatkal(BookingReminderPreferences v) => v.isTatkal;
  static const Field<BookingReminderPreferences, bool> _f$isTatkal = Field(
    'isTatkal',
    _$isTatkal,
    opt: true,
    def: false,
  );
  static bool _$enabled(BookingReminderPreferences v) => v.enabled;
  static const Field<BookingReminderPreferences, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<BookingReminderPreferences> fields = const {
    #ticketId: _f$ticketId,
    #bookingOpenDateMillis: _f$bookingOpenDateMillis,
    #isTatkal: _f$isTatkal,
    #enabled: _f$enabled,
  };

  static BookingReminderPreferences _instantiate(DecodingData data) {
    return BookingReminderPreferences(
      ticketId: data.dec(_f$ticketId),
      bookingOpenDateMillis: data.dec(_f$bookingOpenDateMillis),
      isTatkal: data.dec(_f$isTatkal),
      enabled: data.dec(_f$enabled),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BookingReminderPreferences fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BookingReminderPreferences>(map);
  }

  static BookingReminderPreferences fromJson(String json) {
    return ensureInitialized().decodeJson<BookingReminderPreferences>(json);
  }
}

mixin BookingReminderPreferencesMappable {
  String toJson() {
    return BookingReminderPreferencesMapper.ensureInitialized()
        .encodeJson<BookingReminderPreferences>(
          this as BookingReminderPreferences,
        );
  }

  Map<String, dynamic> toMap() {
    return BookingReminderPreferencesMapper.ensureInitialized()
        .encodeMap<BookingReminderPreferences>(
          this as BookingReminderPreferences,
        );
  }

  BookingReminderPreferencesCopyWith<
    BookingReminderPreferences,
    BookingReminderPreferences,
    BookingReminderPreferences
  >
  get copyWith =>
      _BookingReminderPreferencesCopyWithImpl<
        BookingReminderPreferences,
        BookingReminderPreferences
      >(this as BookingReminderPreferences, $identity, $identity);
  @override
  String toString() {
    return BookingReminderPreferencesMapper.ensureInitialized().stringifyValue(
      this as BookingReminderPreferences,
    );
  }

  @override
  bool operator ==(Object other) {
    return BookingReminderPreferencesMapper.ensureInitialized().equalsValue(
      this as BookingReminderPreferences,
      other,
    );
  }

  @override
  int get hashCode {
    return BookingReminderPreferencesMapper.ensureInitialized().hashValue(
      this as BookingReminderPreferences,
    );
  }
}

extension BookingReminderPreferencesValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BookingReminderPreferences, $Out> {
  BookingReminderPreferencesCopyWith<$R, BookingReminderPreferences, $Out>
  get $asBookingReminderPreferences => $base.as(
    (v, t, t2) => _BookingReminderPreferencesCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class BookingReminderPreferencesCopyWith<
  $R,
  $In extends BookingReminderPreferences,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? ticketId,
    int? bookingOpenDateMillis,
    bool? isTatkal,
    bool? enabled,
  });
  BookingReminderPreferencesCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BookingReminderPreferencesCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BookingReminderPreferences, $Out>
    implements
        BookingReminderPreferencesCopyWith<
          $R,
          BookingReminderPreferences,
          $Out
        > {
  _BookingReminderPreferencesCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BookingReminderPreferences> $mapper =
      BookingReminderPreferencesMapper.ensureInitialized();
  @override
  $R call({
    String? ticketId,
    Object? bookingOpenDateMillis = $none,
    bool? isTatkal,
    bool? enabled,
  }) => $apply(
    FieldCopyWithData({
      if (ticketId != null) #ticketId: ticketId,
      if (bookingOpenDateMillis != $none)
        #bookingOpenDateMillis: bookingOpenDateMillis,
      if (isTatkal != null) #isTatkal: isTatkal,
      if (enabled != null) #enabled: enabled,
    }),
  );
  @override
  BookingReminderPreferences $make(CopyWithData data) =>
      BookingReminderPreferences(
        ticketId: data.get(#ticketId, or: $value.ticketId),
        bookingOpenDateMillis: data.get(
          #bookingOpenDateMillis,
          or: $value.bookingOpenDateMillis,
        ),
        isTatkal: data.get(#isTatkal, or: $value.isTatkal),
        enabled: data.get(#enabled, or: $value.enabled),
      );

  @override
  BookingReminderPreferencesCopyWith<$R2, BookingReminderPreferences, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _BookingReminderPreferencesCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

