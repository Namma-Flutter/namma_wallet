// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'event_model.dart';

class EventMapper extends ClassMapperBase<Event> {
  EventMapper._();

  static EventMapper? _instance;
  static EventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EventMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Event';

  static String _$iconName(Event v) => v.iconName;
  static const Field<Event, String> _f$iconName = Field(
    'iconName',
    _$iconName,
    key: r'icon_name',
  );
  static String _$title(Event v) => v.title;
  static const Field<Event, String> _f$title = Field('title', _$title);
  static String _$subtitle(Event v) => v.subtitle;
  static const Field<Event, String> _f$subtitle = Field('subtitle', _$subtitle);
  static DateTime _$date(Event v) => v.date;
  static const Field<Event, DateTime> _f$date = Field('date', _$date);
  static String _$price(Event v) => v.price;
  static const Field<Event, String> _f$price = Field('price', _$price);

  @override
  final MappableFields<Event> fields = const {
    #iconName: _f$iconName,
    #title: _f$title,
    #subtitle: _f$subtitle,
    #date: _f$date,
    #price: _f$price,
  };

  static Event _instantiate(DecodingData data) {
    return Event(
      iconName: data.dec(_f$iconName),
      title: data.dec(_f$title),
      subtitle: data.dec(_f$subtitle),
      date: data.dec(_f$date),
      price: data.dec(_f$price),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Event fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Event>(map);
  }

  static Event fromJson(String json) {
    return ensureInitialized().decodeJson<Event>(json);
  }
}

mixin EventMappable {
  String toJson() {
    return EventMapper.ensureInitialized().encodeJson<Event>(this as Event);
  }

  Map<String, dynamic> toMap() {
    return EventMapper.ensureInitialized().encodeMap<Event>(this as Event);
  }

  EventCopyWith<Event, Event, Event> get copyWith =>
      _EventCopyWithImpl<Event, Event>(this as Event, $identity, $identity);
  @override
  String toString() {
    return EventMapper.ensureInitialized().stringifyValue(this as Event);
  }

  @override
  bool operator ==(Object other) {
    return EventMapper.ensureInitialized().equalsValue(this as Event, other);
  }

  @override
  int get hashCode {
    return EventMapper.ensureInitialized().hashValue(this as Event);
  }
}

extension EventValueCopy<$R, $Out> on ObjectCopyWith<$R, Event, $Out> {
  EventCopyWith<$R, Event, $Out> get $asEvent =>
      $base.as((v, t, t2) => _EventCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EventCopyWith<$R, $In extends Event, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? iconName,
    String? title,
    String? subtitle,
    DateTime? date,
    String? price,
  });
  EventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EventCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Event, $Out>
    implements EventCopyWith<$R, Event, $Out> {
  _EventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Event> $mapper = EventMapper.ensureInitialized();
  @override
  $R call({
    String? iconName,
    String? title,
    String? subtitle,
    DateTime? date,
    String? price,
  }) => $apply(
    FieldCopyWithData({
      if (iconName != null) #iconName: iconName,
      if (title != null) #title: title,
      if (subtitle != null) #subtitle: subtitle,
      if (date != null) #date: date,
      if (price != null) #price: price,
    }),
  );
  @override
  Event $make(CopyWithData data) => Event(
    iconName: data.get(#iconName, or: $value.iconName),
    title: data.get(#title, or: $value.title),
    subtitle: data.get(#subtitle, or: $value.subtitle),
    date: data.get(#date, or: $value.date),
    price: data.get(#price, or: $value.price),
  );

  @override
  EventCopyWith<$R2, Event, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

