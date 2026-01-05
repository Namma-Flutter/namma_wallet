// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'tag_model.dart';

class TagModelMapper extends ClassMapperBase<TagModel> {
  TagModelMapper._();

  static TagModelMapper? _instance;
  static TagModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TagModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TagModel';

  static String? _$icon(TagModel v) => v.icon;
  static const Field<TagModel, String> _f$icon = Field('icon', _$icon);
  static String? _$value(TagModel v) => v.value;
  static const Field<TagModel, String> _f$value = Field('value', _$value);

  @override
  final MappableFields<TagModel> fields = const {
    #icon: _f$icon,
    #value: _f$value,
  };

  static TagModel _instantiate(DecodingData data) {
    return TagModel(icon: data.dec(_f$icon), value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static TagModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TagModel>(map);
  }

  static TagModel fromJson(String json) {
    return ensureInitialized().decodeJson<TagModel>(json);
  }
}

mixin TagModelMappable {
  String toJson() {
    return TagModelMapper.ensureInitialized().encodeJson<TagModel>(
      this as TagModel,
    );
  }

  Map<String, dynamic> toMap() {
    return TagModelMapper.ensureInitialized().encodeMap<TagModel>(
      this as TagModel,
    );
  }

  TagModelCopyWith<TagModel, TagModel, TagModel> get copyWith =>
      _TagModelCopyWithImpl<TagModel, TagModel>(
        this as TagModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TagModelMapper.ensureInitialized().stringifyValue(this as TagModel);
  }

  @override
  bool operator ==(Object other) {
    return TagModelMapper.ensureInitialized().equalsValue(
      this as TagModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TagModelMapper.ensureInitialized().hashValue(this as TagModel);
  }
}

extension TagModelValueCopy<$R, $Out> on ObjectCopyWith<$R, TagModel, $Out> {
  TagModelCopyWith<$R, TagModel, $Out> get $asTagModel =>
      $base.as((v, t, t2) => _TagModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TagModelCopyWith<$R, $In extends TagModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? icon, String? value});
  TagModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TagModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TagModel, $Out>
    implements TagModelCopyWith<$R, TagModel, $Out> {
  _TagModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TagModel> $mapper =
      TagModelMapper.ensureInitialized();
  @override
  $R call({Object? icon = $none, Object? value = $none}) => $apply(
    FieldCopyWithData({
      if (icon != $none) #icon: icon,
      if (value != $none) #value: value,
    }),
  );
  @override
  TagModel $make(CopyWithData data) => TagModel(
    icon: data.get(#icon, or: $value.icon),
    value: data.get(#value, or: $value.value),
  );

  @override
  TagModelCopyWith<$R2, TagModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TagModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

