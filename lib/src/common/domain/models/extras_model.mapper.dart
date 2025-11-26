// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'extras_model.dart';

class ExtrasModelMapper extends ClassMapperBase<ExtrasModel> {
  ExtrasModelMapper._();

  static ExtrasModelMapper? _instance;
  static ExtrasModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ExtrasModelMapper._());
      ExtrasModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ExtrasModel';

  static String _$value(ExtrasModel v) => v.value;
  static const Field<ExtrasModel, String> _f$value = Field('value', _$value);
  static List<ExtrasModel>? _$child(ExtrasModel v) => v.child;
  static const Field<ExtrasModel, List<ExtrasModel>> _f$child = Field(
    'child',
    _$child,
    opt: true,
  );
  static String? _$title(ExtrasModel v) => v.title;
  static const Field<ExtrasModel, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
  );

  @override
  final MappableFields<ExtrasModel> fields = const {
    #value: _f$value,
    #child: _f$child,
    #title: _f$title,
  };

  static ExtrasModel _instantiate(DecodingData data) {
    return ExtrasModel(
      value: data.dec(_f$value),
      child: data.dec(_f$child),
      title: data.dec(_f$title),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ExtrasModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ExtrasModel>(map);
  }

  static ExtrasModel fromJson(String json) {
    return ensureInitialized().decodeJson<ExtrasModel>(json);
  }
}

mixin ExtrasModelMappable {
  String toJson() {
    return ExtrasModelMapper.ensureInitialized().encodeJson<ExtrasModel>(
      this as ExtrasModel,
    );
  }

  Map<String, dynamic> toMap() {
    return ExtrasModelMapper.ensureInitialized().encodeMap<ExtrasModel>(
      this as ExtrasModel,
    );
  }

  ExtrasModelCopyWith<ExtrasModel, ExtrasModel, ExtrasModel> get copyWith =>
      _ExtrasModelCopyWithImpl<ExtrasModel, ExtrasModel>(
        this as ExtrasModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ExtrasModelMapper.ensureInitialized().stringifyValue(
      this as ExtrasModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return ExtrasModelMapper.ensureInitialized().equalsValue(
      this as ExtrasModel,
      other,
    );
  }

  @override
  int get hashCode {
    return ExtrasModelMapper.ensureInitialized().hashValue(this as ExtrasModel);
  }
}

extension ExtrasModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ExtrasModel, $Out> {
  ExtrasModelCopyWith<$R, ExtrasModel, $Out> get $asExtrasModel =>
      $base.as((v, t, t2) => _ExtrasModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ExtrasModelCopyWith<$R, $In extends ExtrasModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ExtrasModel,
    ExtrasModelCopyWith<$R, ExtrasModel, ExtrasModel>
  >?
  get child;
  $R call({String? value, List<ExtrasModel>? child, String? title});
  ExtrasModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ExtrasModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ExtrasModel, $Out>
    implements ExtrasModelCopyWith<$R, ExtrasModel, $Out> {
  _ExtrasModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ExtrasModel> $mapper =
      ExtrasModelMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ExtrasModel,
    ExtrasModelCopyWith<$R, ExtrasModel, ExtrasModel>
  >?
  get child => $value.child != null
      ? ListCopyWith(
          $value.child!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(child: v),
        )
      : null;
  @override
  $R call({String? value, Object? child = $none, Object? title = $none}) =>
      $apply(
        FieldCopyWithData({
          if (value != null) #value: value,
          if (child != $none) #child: child,
          if (title != $none) #title: title,
        }),
      );
  @override
  ExtrasModel $make(CopyWithData data) => ExtrasModel(
    value: data.get(#value, or: $value.value),
    child: data.get(#child, or: $value.child),
    title: data.get(#title, or: $value.title),
  );

  @override
  ExtrasModelCopyWith<$R2, ExtrasModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ExtrasModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

