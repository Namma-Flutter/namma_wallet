// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ticket.dart';

class TicketMapper extends ClassMapperBase<Ticket> {
  TicketMapper._();

  static TicketMapper? _instance;
  static TicketMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketMapper._());
      TicketTypeMapper.ensureInitialized();
      TagModelMapper.ensureInitialized();
      ExtrasModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Ticket';

  static String _$primaryText(Ticket v) => v.primaryText;
  static const Field<Ticket, String> _f$primaryText = Field(
    'primaryText',
    _$primaryText,
    key: r'primary_text',
  );
  static String _$secondaryText(Ticket v) => v.secondaryText;
  static const Field<Ticket, String> _f$secondaryText = Field(
    'secondaryText',
    _$secondaryText,
    key: r'secondary_text',
  );
  static DateTime _$startTime(Ticket v) => v.startTime;
  static const Field<Ticket, DateTime> _f$startTime = Field(
    'startTime',
    _$startTime,
    key: r'start_time',
  );
  static String _$location(Ticket v) => v.location;
  static const Field<Ticket, String> _f$location = Field(
    'location',
    _$location,
  );
  static TicketType _$type(Ticket v) => v.type;
  static const Field<Ticket, TicketType> _f$type = Field(
    'type',
    _$type,
    opt: true,
    def: TicketType.train,
  );
  static DateTime? _$endTime(Ticket v) => v.endTime;
  static const Field<Ticket, DateTime> _f$endTime = Field(
    'endTime',
    _$endTime,
    key: r'end_time',
    opt: true,
  );
  static List<TagModel>? _$tags(Ticket v) => v.tags;
  static const Field<Ticket, List<TagModel>> _f$tags = Field(
    'tags',
    _$tags,
    opt: true,
  );
  static List<ExtrasModel>? _$extras(Ticket v) => v.extras;
  static const Field<Ticket, List<ExtrasModel>> _f$extras = Field(
    'extras',
    _$extras,
    opt: true,
  );
  static String? _$ticketId(Ticket v) => v.ticketId;
  static const Field<Ticket, String> _f$ticketId = Field(
    'ticketId',
    _$ticketId,
    key: r'ticket_id',
    opt: true,
  );

  @override
  final MappableFields<Ticket> fields = const {
    #primaryText: _f$primaryText,
    #secondaryText: _f$secondaryText,
    #startTime: _f$startTime,
    #location: _f$location,
    #type: _f$type,
    #endTime: _f$endTime,
    #tags: _f$tags,
    #extras: _f$extras,
    #ticketId: _f$ticketId,
  };

  static Ticket _instantiate(DecodingData data) {
    return Ticket(
      primaryText: data.dec(_f$primaryText),
      secondaryText: data.dec(_f$secondaryText),
      startTime: data.dec(_f$startTime),
      location: data.dec(_f$location),
      type: data.dec(_f$type),
      endTime: data.dec(_f$endTime),
      tags: data.dec(_f$tags),
      extras: data.dec(_f$extras),
      ticketId: data.dec(_f$ticketId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Ticket fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Ticket>(map);
  }

  static Ticket fromJson(String json) {
    return ensureInitialized().decodeJson<Ticket>(json);
  }
}

mixin TicketMappable {
  String toJson() {
    return TicketMapper.ensureInitialized().encodeJson<Ticket>(this as Ticket);
  }

  Map<String, dynamic> toMap() {
    return TicketMapper.ensureInitialized().encodeMap<Ticket>(this as Ticket);
  }

  TicketCopyWith<Ticket, Ticket, Ticket> get copyWith =>
      _TicketCopyWithImpl<Ticket, Ticket>(this as Ticket, $identity, $identity);
  @override
  String toString() {
    return TicketMapper.ensureInitialized().stringifyValue(this as Ticket);
  }

  @override
  bool operator ==(Object other) {
    return TicketMapper.ensureInitialized().equalsValue(this as Ticket, other);
  }

  @override
  int get hashCode {
    return TicketMapper.ensureInitialized().hashValue(this as Ticket);
  }
}

extension TicketValueCopy<$R, $Out> on ObjectCopyWith<$R, Ticket, $Out> {
  TicketCopyWith<$R, Ticket, $Out> get $asTicket =>
      $base.as((v, t, t2) => _TicketCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TicketCopyWith<$R, $In extends Ticket, $Out>
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
    String? ticketId,
  });
  TicketCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TicketCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Ticket, $Out>
    implements TicketCopyWith<$R, Ticket, $Out> {
  _TicketCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Ticket> $mapper = TicketMapper.ensureInitialized();
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
    }),
  );
  @override
  Ticket $make(CopyWithData data) => Ticket(
    primaryText: data.get(#primaryText, or: $value.primaryText),
    secondaryText: data.get(#secondaryText, or: $value.secondaryText),
    startTime: data.get(#startTime, or: $value.startTime),
    location: data.get(#location, or: $value.location),
    type: data.get(#type, or: $value.type),
    endTime: data.get(#endTime, or: $value.endTime),
    tags: data.get(#tags, or: $value.tags),
    extras: data.get(#extras, or: $value.extras),
    ticketId: data.get(#ticketId, or: $value.ticketId),
  );

  @override
  TicketCopyWith<$R2, Ticket, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TicketCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

