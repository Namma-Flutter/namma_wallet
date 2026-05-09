// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ticket_update_info.dart';

class TicketUpdateInfoMapper extends ClassMapperBase<TicketUpdateInfo> {
  TicketUpdateInfoMapper._();

  static TicketUpdateInfoMapper? _instance;
  static TicketUpdateInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketUpdateInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TicketUpdateInfo';

  static String _$pnrNumber(TicketUpdateInfo v) => v.pnrNumber;
  static const Field<TicketUpdateInfo, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
  );
  static String _$providerName(TicketUpdateInfo v) => v.providerName;
  static const Field<TicketUpdateInfo, String> _f$providerName = Field(
    'providerName',
    _$providerName,
  );
  static Map<String, Object?> _$updates(TicketUpdateInfo v) => v.updates;
  static const Field<TicketUpdateInfo, Map<String, Object?>> _f$updates = Field(
    'updates',
    _$updates,
  );

  @override
  final MappableFields<TicketUpdateInfo> fields = const {
    #pnrNumber: _f$pnrNumber,
    #providerName: _f$providerName,
    #updates: _f$updates,
  };

  static TicketUpdateInfo _instantiate(DecodingData data) {
    return TicketUpdateInfo(
      pnrNumber: data.dec(_f$pnrNumber),
      providerName: data.dec(_f$providerName),
      updates: data.dec(_f$updates),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TicketUpdateInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TicketUpdateInfo>(map);
  }

  static TicketUpdateInfo fromJson(String json) {
    return ensureInitialized().decodeJson<TicketUpdateInfo>(json);
  }
}

mixin TicketUpdateInfoMappable {
  String toJson() {
    return TicketUpdateInfoMapper.ensureInitialized()
        .encodeJson<TicketUpdateInfo>(this as TicketUpdateInfo);
  }

  Map<String, dynamic> toMap() {
    return TicketUpdateInfoMapper.ensureInitialized()
        .encodeMap<TicketUpdateInfo>(this as TicketUpdateInfo);
  }

  TicketUpdateInfoCopyWith<TicketUpdateInfo, TicketUpdateInfo, TicketUpdateInfo>
  get copyWith =>
      _TicketUpdateInfoCopyWithImpl<TicketUpdateInfo, TicketUpdateInfo>(
        this as TicketUpdateInfo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TicketUpdateInfoMapper.ensureInitialized().stringifyValue(
      this as TicketUpdateInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return TicketUpdateInfoMapper.ensureInitialized().equalsValue(
      this as TicketUpdateInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return TicketUpdateInfoMapper.ensureInitialized().hashValue(
      this as TicketUpdateInfo,
    );
  }
}

extension TicketUpdateInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TicketUpdateInfo, $Out> {
  TicketUpdateInfoCopyWith<$R, TicketUpdateInfo, $Out>
  get $asTicketUpdateInfo =>
      $base.as((v, t, t2) => _TicketUpdateInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TicketUpdateInfoCopyWith<$R, $In extends TicketUpdateInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>
  get updates;
  $R call({
    String? pnrNumber,
    String? providerName,
    Map<String, Object?>? updates,
  });
  TicketUpdateInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TicketUpdateInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TicketUpdateInfo, $Out>
    implements TicketUpdateInfoCopyWith<$R, TicketUpdateInfo, $Out> {
  _TicketUpdateInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TicketUpdateInfo> $mapper =
      TicketUpdateInfoMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>
  get updates => MapCopyWith(
    $value.updates,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(updates: v),
  );
  @override
  $R call({
    String? pnrNumber,
    String? providerName,
    Map<String, Object?>? updates,
  }) => $apply(
    FieldCopyWithData({
      if (pnrNumber != null) #pnrNumber: pnrNumber,
      if (providerName != null) #providerName: providerName,
      if (updates != null) #updates: updates,
    }),
  );
  @override
  TicketUpdateInfo $make(CopyWithData data) => TicketUpdateInfo(
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
    providerName: data.get(#providerName, or: $value.providerName),
    updates: data.get(#updates, or: $value.updates),
  );

  @override
  TicketUpdateInfoCopyWith<$R2, TicketUpdateInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TicketUpdateInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

