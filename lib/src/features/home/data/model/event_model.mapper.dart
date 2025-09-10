// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'event_model.dart';

class EventModelMapper extends ClassMapperBase<EventModel> {
  EventModelMapper._();

  static EventModelMapper? _instance;
  static EventModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EventModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EventModel';

  static String? _$ticketId(EventModel v) => v.ticketId;
  static const Field<EventModel, String> _f$ticketId = Field(
    'ticketId',
    _$ticketId,
    key: r'ticket_id',
    opt: true,
  );
  static String? _$eventName(EventModel v) => v.eventName;
  static const Field<EventModel, String> _f$eventName = Field(
    'eventName',
    _$eventName,
    key: r'event_name',
    opt: true,
  );
  static String? _$eventDescription(EventModel v) => v.eventDescription;
  static const Field<EventModel, String> _f$eventDescription = Field(
    'eventDescription',
    _$eventDescription,
    key: r'event_description',
    opt: true,
  );
  static String? _$venue(EventModel v) => v.venue;
  static const Field<EventModel, String> _f$venue = Field(
    'venue',
    _$venue,
    opt: true,
  );
  static DateTime? _$dateTime(EventModel v) => v.dateTime;
  static const Field<EventModel, DateTime> _f$dateTime = Field(
    'dateTime',
    _$dateTime,
    key: r'date_time',
    opt: true,
  );
  static String? _$organizerName(EventModel v) => v.organizerName;
  static const Field<EventModel, String> _f$organizerName = Field(
    'organizerName',
    _$organizerName,
    key: r'organizer_name',
    opt: true,
  );
  static String? _$status(EventModel v) => v.status;
  static const Field<EventModel, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static String? _$moreInfoURL(EventModel v) => v.moreInfoURL;
  static const Field<EventModel, String> _f$moreInfoURL = Field(
    'moreInfoURL',
    _$moreInfoURL,
    key: r'more_info_url',
    opt: true,
  );
  static IconData _$eventIcon(EventModel v) => v.eventIcon;
  static const Field<EventModel, IconData> _f$eventIcon = Field(
    'eventIcon',
    _$eventIcon,
    key: r'event_icon',
    opt: true,
    def: Icons.star_border_rounded,
  );

  @override
  final MappableFields<EventModel> fields = const {
    #ticketId: _f$ticketId,
    #eventName: _f$eventName,
    #eventDescription: _f$eventDescription,
    #venue: _f$venue,
    #dateTime: _f$dateTime,
    #organizerName: _f$organizerName,
    #status: _f$status,
    #moreInfoURL: _f$moreInfoURL,
    #eventIcon: _f$eventIcon,
  };

  static EventModel _instantiate(DecodingData data) {
    return EventModel(
      ticketId: data.dec(_f$ticketId),
      eventName: data.dec(_f$eventName),
      eventDescription: data.dec(_f$eventDescription),
      venue: data.dec(_f$venue),
      dateTime: data.dec(_f$dateTime),
      organizerName: data.dec(_f$organizerName),
      status: data.dec(_f$status),
      moreInfoURL: data.dec(_f$moreInfoURL),
      eventIcon: data.dec(_f$eventIcon),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EventModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EventModel>(map);
  }

  static EventModel fromJson(String json) {
    return ensureInitialized().decodeJson<EventModel>(json);
  }
}

mixin EventModelMappable {
  String toJson() {
    return EventModelMapper.ensureInitialized().encodeJson<EventModel>(
      this as EventModel,
    );
  }

  Map<String, dynamic> toMap() {
    return EventModelMapper.ensureInitialized().encodeMap<EventModel>(
      this as EventModel,
    );
  }

  EventModelCopyWith<EventModel, EventModel, EventModel> get copyWith =>
      _EventModelCopyWithImpl<EventModel, EventModel>(
        this as EventModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EventModelMapper.ensureInitialized().stringifyValue(
      this as EventModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return EventModelMapper.ensureInitialized().equalsValue(
      this as EventModel,
      other,
    );
  }

  @override
  int get hashCode {
    return EventModelMapper.ensureInitialized().hashValue(this as EventModel);
  }
}

extension EventModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EventModel, $Out> {
  EventModelCopyWith<$R, EventModel, $Out> get $asEventModel =>
      $base.as((v, t, t2) => _EventModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EventModelCopyWith<$R, $In extends EventModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? ticketId,
    String? eventName,
    String? eventDescription,
    String? venue,
    DateTime? dateTime,
    String? organizerName,
    String? status,
    String? moreInfoURL,
    IconData? eventIcon,
  });
  EventModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EventModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EventModel, $Out>
    implements EventModelCopyWith<$R, EventModel, $Out> {
  _EventModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EventModel> $mapper =
      EventModelMapper.ensureInitialized();
  @override
  $R call({
    Object? ticketId = $none,
    Object? eventName = $none,
    Object? eventDescription = $none,
    Object? venue = $none,
    Object? dateTime = $none,
    Object? organizerName = $none,
    Object? status = $none,
    Object? moreInfoURL = $none,
    IconData? eventIcon,
  }) => $apply(
    FieldCopyWithData({
      if (ticketId != $none) #ticketId: ticketId,
      if (eventName != $none) #eventName: eventName,
      if (eventDescription != $none) #eventDescription: eventDescription,
      if (venue != $none) #venue: venue,
      if (dateTime != $none) #dateTime: dateTime,
      if (organizerName != $none) #organizerName: organizerName,
      if (status != $none) #status: status,
      if (moreInfoURL != $none) #moreInfoURL: moreInfoURL,
      if (eventIcon != null) #eventIcon: eventIcon,
    }),
  );
  @override
  EventModel $make(CopyWithData data) => EventModel(
    ticketId: data.get(#ticketId, or: $value.ticketId),
    eventName: data.get(#eventName, or: $value.eventName),
    eventDescription: data.get(#eventDescription, or: $value.eventDescription),
    venue: data.get(#venue, or: $value.venue),
    dateTime: data.get(#dateTime, or: $value.dateTime),
    organizerName: data.get(#organizerName, or: $value.organizerName),
    status: data.get(#status, or: $value.status),
    moreInfoURL: data.get(#moreInfoURL, or: $value.moreInfoURL),
    eventIcon: data.get(#eventIcon, or: $value.eventIcon),
  );

  @override
  EventModelCopyWith<$R2, EventModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EventModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

