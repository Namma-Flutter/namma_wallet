// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'generic_details_model.dart';

class GenericDetailsModelMapper extends ClassMapperBase<GenericDetailsModel> {
  GenericDetailsModelMapper._();

  static GenericDetailsModelMapper? _instance;
  static GenericDetailsModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GenericDetailsModelMapper._());
      TicketTypeMapper.ensureInitialized();
      TagModelMapper.ensureInitialized();
      ExtrasModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GenericDetailsModel';

  static String _$primaryText(GenericDetailsModel v) => v.primaryText;
  static const Field<GenericDetailsModel, String> _f$primaryText = Field(
    'primaryText',
    _$primaryText,
    key: r'primary_text',
  );
  static String _$secondaryText(GenericDetailsModel v) => v.secondaryText;
  static const Field<GenericDetailsModel, String> _f$secondaryText = Field(
    'secondaryText',
    _$secondaryText,
    key: r'secondary_text',
  );
  static DateTime _$startTime(GenericDetailsModel v) => v.startTime;
  static const Field<GenericDetailsModel, DateTime> _f$startTime = Field(
    'startTime',
    _$startTime,
    key: r'start_time',
  );
  static String _$location(GenericDetailsModel v) => v.location;
  static const Field<GenericDetailsModel, String> _f$location = Field(
    'location',
    _$location,
  );
  static TicketType _$type(GenericDetailsModel v) => v.type;
  static const Field<GenericDetailsModel, TicketType> _f$type = Field(
    'type',
    _$type,
    opt: true,
    def: TicketType.bus,
  );
  static DateTime? _$endTime(GenericDetailsModel v) => v.endTime;
  static const Field<GenericDetailsModel, DateTime> _f$endTime = Field(
    'endTime',
    _$endTime,
    key: r'end_time',
    opt: true,
  );
  static List<TagModel>? _$tags(GenericDetailsModel v) => v.tags;
  static const Field<GenericDetailsModel, List<TagModel>> _f$tags = Field(
    'tags',
    _$tags,
    opt: true,
  );
  static List<ExtrasModel>? _$extras(GenericDetailsModel v) => v.extras;
  static const Field<GenericDetailsModel, List<ExtrasModel>> _f$extras = Field(
    'extras',
    _$extras,
    opt: true,
  );
  static int? _$ticketId(GenericDetailsModel v) => v.ticketId;
  static const Field<GenericDetailsModel, int> _f$ticketId = Field(
    'ticketId',
    _$ticketId,
    key: r'ticket_id',
    opt: true,
  );
  static String? _$contactMobile(GenericDetailsModel v) => v.contactMobile;
  static const Field<GenericDetailsModel, String> _f$contactMobile = Field(
    'contactMobile',
    _$contactMobile,
    opt: true,
  );

  @override
  final MappableFields<GenericDetailsModel> fields = const {
    #primaryText: _f$primaryText,
    #secondaryText: _f$secondaryText,
    #startTime: _f$startTime,
    #location: _f$location,
    #type: _f$type,
    #endTime: _f$endTime,
    #tags: _f$tags,
    #extras: _f$extras,
    #ticketId: _f$ticketId,
    #contactMobile: _f$contactMobile,
  };

  static GenericDetailsModel _instantiate(DecodingData data) {
    return GenericDetailsModel(
      primaryText: data.dec(_f$primaryText),
      secondaryText: data.dec(_f$secondaryText),
      startTime: data.dec(_f$startTime),
      location: data.dec(_f$location),
      type: data.dec(_f$type),
      endTime: data.dec(_f$endTime),
      tags: data.dec(_f$tags),
      extras: data.dec(_f$extras),
      ticketId: data.dec(_f$ticketId),
      contactMobile: data.dec(_f$contactMobile),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GenericDetailsModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GenericDetailsModel>(map);
  }

  static GenericDetailsModel fromJson(String json) {
    return ensureInitialized().decodeJson<GenericDetailsModel>(json);
  }
}

mixin GenericDetailsModelMappable {
  String toJson() {
    return GenericDetailsModelMapper.ensureInitialized()
        .encodeJson<GenericDetailsModel>(this as GenericDetailsModel);
  }

  Map<String, dynamic> toMap() {
    return GenericDetailsModelMapper.ensureInitialized()
        .encodeMap<GenericDetailsModel>(this as GenericDetailsModel);
  }

  GenericDetailsModelCopyWith<
    GenericDetailsModel,
    GenericDetailsModel,
    GenericDetailsModel
  >
  get copyWith =>
      _GenericDetailsModelCopyWithImpl<
        GenericDetailsModel,
        GenericDetailsModel
      >(this as GenericDetailsModel, $identity, $identity);
  @override
  String toString() {
    return GenericDetailsModelMapper.ensureInitialized().stringifyValue(
      this as GenericDetailsModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return GenericDetailsModelMapper.ensureInitialized().equalsValue(
      this as GenericDetailsModel,
      other,
    );
  }

  @override
  int get hashCode {
    return GenericDetailsModelMapper.ensureInitialized().hashValue(
      this as GenericDetailsModel,
    );
  }
}

extension GenericDetailsModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GenericDetailsModel, $Out> {
  GenericDetailsModelCopyWith<$R, GenericDetailsModel, $Out>
  get $asGenericDetailsModel => $base.as(
    (v, t, t2) => _GenericDetailsModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class GenericDetailsModelCopyWith<
  $R,
  $In extends GenericDetailsModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, TagModel, TagModelCopyWith<$R, TagModel, TagModel>>?
  get tags;
  ListCopyWith<
    $R,
    ExtrasModel,
    ExtrasModelCopyWith<$R, ExtrasModel, ExtrasModel>
  >?
  get extras;
  $R call({
    String? primaryText,
    String? secondaryText,
    DateTime? startTime,
    String? location,
    TicketType? type,
    DateTime? endTime,
    List<TagModel>? tags,
    List<ExtrasModel>? extras,
    int? ticketId,
    String? contactMobile,
  });
  GenericDetailsModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GenericDetailsModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GenericDetailsModel, $Out>
    implements GenericDetailsModelCopyWith<$R, GenericDetailsModel, $Out> {
  _GenericDetailsModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GenericDetailsModel> $mapper =
      GenericDetailsModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, TagModel, TagModelCopyWith<$R, TagModel, TagModel>>?
  get tags => $value.tags != null
      ? ListCopyWith(
          $value.tags!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(tags: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    ExtrasModel,
    ExtrasModelCopyWith<$R, ExtrasModel, ExtrasModel>
  >?
  get extras => $value.extras != null
      ? ListCopyWith(
          $value.extras!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(extras: v),
        )
      : null;
  @override
  $R call({
    String? primaryText,
    String? secondaryText,
    DateTime? startTime,
    String? location,
    TicketType? type,
    Object? endTime = $none,
    Object? tags = $none,
    Object? extras = $none,
    Object? ticketId = $none,
    Object? contactMobile = $none,
  }) => $apply(
    FieldCopyWithData({
      if (primaryText != null) #primaryText: primaryText,
      if (secondaryText != null) #secondaryText: secondaryText,
      if (startTime != null) #startTime: startTime,
      if (location != null) #location: location,
      if (type != null) #type: type,
      if (endTime != $none) #endTime: endTime,
      if (tags != $none) #tags: tags,
      if (extras != $none) #extras: extras,
      if (ticketId != $none) #ticketId: ticketId,
      if (contactMobile != $none) #contactMobile: contactMobile,
    }),
  );
  @override
  GenericDetailsModel $make(CopyWithData data) => GenericDetailsModel(
    primaryText: data.get(#primaryText, or: $value.primaryText),
    secondaryText: data.get(#secondaryText, or: $value.secondaryText),
    startTime: data.get(#startTime, or: $value.startTime),
    location: data.get(#location, or: $value.location),
    type: data.get(#type, or: $value.type),
    endTime: data.get(#endTime, or: $value.endTime),
    tags: data.get(#tags, or: $value.tags),
    extras: data.get(#extras, or: $value.extras),
    ticketId: data.get(#ticketId, or: $value.ticketId),
    contactMobile: data.get(#contactMobile, or: $value.contactMobile),
  );

  @override
  GenericDetailsModelCopyWith<$R2, GenericDetailsModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _GenericDetailsModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

