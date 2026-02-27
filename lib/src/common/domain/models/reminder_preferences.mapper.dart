// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'reminder_preferences.dart';

class ReminderPreferencesMapper extends ClassMapperBase<ReminderPreferences> {
  ReminderPreferencesMapper._();

  static ReminderPreferencesMapper? _instance;
  static ReminderPreferencesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReminderPreferencesMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ReminderPreferences';

  static List<int> _$selectedIntervals(ReminderPreferences v) =>
      v.selectedIntervals;
  static const Field<ReminderPreferences, List<int>> _f$selectedIntervals =
      Field('selectedIntervals', _$selectedIntervals);
  static List<int> _$customDateTimeMillis(ReminderPreferences v) =>
      v.customDateTimeMillis;
  static const Field<ReminderPreferences, List<int>> _f$customDateTimeMillis =
      Field(
        'customDateTimeMillis',
        _$customDateTimeMillis,
        opt: true,
        def: const [],
      );
  static bool _$isEnabled(ReminderPreferences v) => v.isEnabled;
  static const Field<ReminderPreferences, bool> _f$isEnabled = Field(
    'isEnabled',
    _$isEnabled,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<ReminderPreferences> fields = const {
    #selectedIntervals: _f$selectedIntervals,
    #customDateTimeMillis: _f$customDateTimeMillis,
    #isEnabled: _f$isEnabled,
  };

  static ReminderPreferences _instantiate(DecodingData data) {
    return ReminderPreferences(
      selectedIntervals: data.dec(_f$selectedIntervals),
      customDateTimeMillis: data.dec(_f$customDateTimeMillis),
      isEnabled: data.dec(_f$isEnabled),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ReminderPreferences fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ReminderPreferences>(map);
  }

  static ReminderPreferences fromJson(String json) {
    return ensureInitialized().decodeJson<ReminderPreferences>(json);
  }
}

mixin ReminderPreferencesMappable {
  String toJson() {
    return ReminderPreferencesMapper.ensureInitialized()
        .encodeJson<ReminderPreferences>(this as ReminderPreferences);
  }

  Map<String, dynamic> toMap() {
    return ReminderPreferencesMapper.ensureInitialized()
        .encodeMap<ReminderPreferences>(this as ReminderPreferences);
  }

  ReminderPreferencesCopyWith<
    ReminderPreferences,
    ReminderPreferences,
    ReminderPreferences
  >
  get copyWith =>
      _ReminderPreferencesCopyWithImpl<
        ReminderPreferences,
        ReminderPreferences
      >(this as ReminderPreferences, $identity, $identity);
  @override
  String toString() {
    return ReminderPreferencesMapper.ensureInitialized().stringifyValue(
      this as ReminderPreferences,
    );
  }

  @override
  bool operator ==(Object other) {
    return ReminderPreferencesMapper.ensureInitialized().equalsValue(
      this as ReminderPreferences,
      other,
    );
  }

  @override
  int get hashCode {
    return ReminderPreferencesMapper.ensureInitialized().hashValue(
      this as ReminderPreferences,
    );
  }
}

extension ReminderPreferencesValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ReminderPreferences, $Out> {
  ReminderPreferencesCopyWith<$R, ReminderPreferences, $Out>
  get $asReminderPreferences => $base.as(
    (v, t, t2) => _ReminderPreferencesCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ReminderPreferencesCopyWith<
  $R,
  $In extends ReminderPreferences,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get selectedIntervals;
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get customDateTimeMillis;
  $R call({
    List<int>? selectedIntervals,
    List<int>? customDateTimeMillis,
    bool? isEnabled,
  });
  ReminderPreferencesCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ReminderPreferencesCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ReminderPreferences, $Out>
    implements ReminderPreferencesCopyWith<$R, ReminderPreferences, $Out> {
  _ReminderPreferencesCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ReminderPreferences> $mapper =
      ReminderPreferencesMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get selectedIntervals =>
      ListCopyWith(
        $value.selectedIntervals,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(selectedIntervals: v),
      );
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>>
  get customDateTimeMillis => ListCopyWith(
    $value.customDateTimeMillis,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(customDateTimeMillis: v),
  );
  @override
  $R call({
    List<int>? selectedIntervals,
    List<int>? customDateTimeMillis,
    bool? isEnabled,
  }) => $apply(
    FieldCopyWithData({
      if (selectedIntervals != null) #selectedIntervals: selectedIntervals,
      if (customDateTimeMillis != null)
        #customDateTimeMillis: customDateTimeMillis,
      if (isEnabled != null) #isEnabled: isEnabled,
    }),
  );
  @override
  ReminderPreferences $make(CopyWithData data) => ReminderPreferences(
    selectedIntervals: data.get(
      #selectedIntervals,
      or: $value.selectedIntervals,
    ),
    customDateTimeMillis: data.get(
      #customDateTimeMillis,
      or: $value.customDateTimeMillis,
    ),
    isEnabled: data.get(#isEnabled, or: $value.isEnabled),
  );

  @override
  ReminderPreferencesCopyWith<$R2, ReminderPreferences, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ReminderPreferencesCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

