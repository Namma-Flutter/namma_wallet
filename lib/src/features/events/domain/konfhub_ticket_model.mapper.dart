// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'konfhub_ticket_model.dart';

class KonfHubTicketModelMapper extends ClassMapperBase<KonfHubTicketModel> {
  KonfHubTicketModelMapper._();

  static KonfHubTicketModelMapper? _instance;
  static KonfHubTicketModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KonfHubTicketModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'KonfHubTicketModel';

  static String? _$bookingId(KonfHubTicketModel v) => v.bookingId;
  static const Field<KonfHubTicketModel, String> _f$bookingId = Field(
    'bookingId',
    _$bookingId,
    opt: true,
  );
  static DateTime? _$bookingDate(KonfHubTicketModel v) => v.bookingDate;
  static const Field<KonfHubTicketModel, DateTime> _f$bookingDate = Field(
    'bookingDate',
    _$bookingDate,
    opt: true,
  );
  static String? _$attendeeName(KonfHubTicketModel v) => v.attendeeName;
  static const Field<KonfHubTicketModel, String> _f$attendeeName = Field(
    'attendeeName',
    _$attendeeName,
    opt: true,
  );
  static String? _$organization(KonfHubTicketModel v) => v.organization;
  static const Field<KonfHubTicketModel, String> _f$organization = Field(
    'organization',
    _$organization,
    opt: true,
  );
  static String? _$eventName(KonfHubTicketModel v) => v.eventName;
  static const Field<KonfHubTicketModel, String> _f$eventName = Field(
    'eventName',
    _$eventName,
    opt: true,
  );
  static DateTime? _$eventDate(KonfHubTicketModel v) => v.eventDate;
  static const Field<KonfHubTicketModel, DateTime> _f$eventDate = Field(
    'eventDate',
    _$eventDate,
    opt: true,
  );
  static DateTime? _$eventStartTime(KonfHubTicketModel v) => v.eventStartTime;
  static const Field<KonfHubTicketModel, DateTime> _f$eventStartTime = Field(
    'eventStartTime',
    _$eventStartTime,
    opt: true,
  );
  static DateTime? _$eventEndTime(KonfHubTicketModel v) => v.eventEndTime;
  static const Field<KonfHubTicketModel, DateTime> _f$eventEndTime = Field(
    'eventEndTime',
    _$eventEndTime,
    opt: true,
  );
  static String? _$ticketName(KonfHubTicketModel v) => v.ticketName;
  static const Field<KonfHubTicketModel, String> _f$ticketName = Field(
    'ticketName',
    _$ticketName,
    opt: true,
  );
  static String? _$location(KonfHubTicketModel v) => v.location;
  static const Field<KonfHubTicketModel, String> _f$location = Field(
    'location',
    _$location,
    opt: true,
  );
  static Map<String, String>? _$additionalDetails(KonfHubTicketModel v) =>
      v.additionalDetails;
  static const Field<KonfHubTicketModel, Map<String, String>>
  _f$additionalDetails = Field(
    'additionalDetails',
    _$additionalDetails,
    opt: true,
  );

  @override
  final MappableFields<KonfHubTicketModel> fields = const {
    #bookingId: _f$bookingId,
    #bookingDate: _f$bookingDate,
    #attendeeName: _f$attendeeName,
    #organization: _f$organization,
    #eventName: _f$eventName,
    #eventDate: _f$eventDate,
    #eventStartTime: _f$eventStartTime,
    #eventEndTime: _f$eventEndTime,
    #ticketName: _f$ticketName,
    #location: _f$location,
    #additionalDetails: _f$additionalDetails,
  };

  static KonfHubTicketModel _instantiate(DecodingData data) {
    return KonfHubTicketModel(
      bookingId: data.dec(_f$bookingId),
      bookingDate: data.dec(_f$bookingDate),
      attendeeName: data.dec(_f$attendeeName),
      organization: data.dec(_f$organization),
      eventName: data.dec(_f$eventName),
      eventDate: data.dec(_f$eventDate),
      eventStartTime: data.dec(_f$eventStartTime),
      eventEndTime: data.dec(_f$eventEndTime),
      ticketName: data.dec(_f$ticketName),
      location: data.dec(_f$location),
      additionalDetails: data.dec(_f$additionalDetails),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static KonfHubTicketModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KonfHubTicketModel>(map);
  }

  static KonfHubTicketModel fromJson(String json) {
    return ensureInitialized().decodeJson<KonfHubTicketModel>(json);
  }
}

mixin KonfHubTicketModelMappable {
  String toJson() {
    return KonfHubTicketModelMapper.ensureInitialized()
        .encodeJson<KonfHubTicketModel>(this as KonfHubTicketModel);
  }

  Map<String, dynamic> toMap() {
    return KonfHubTicketModelMapper.ensureInitialized()
        .encodeMap<KonfHubTicketModel>(this as KonfHubTicketModel);
  }

  KonfHubTicketModelCopyWith<
    KonfHubTicketModel,
    KonfHubTicketModel,
    KonfHubTicketModel
  >
  get copyWith =>
      _KonfHubTicketModelCopyWithImpl<KonfHubTicketModel, KonfHubTicketModel>(
        this as KonfHubTicketModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KonfHubTicketModelMapper.ensureInitialized().stringifyValue(
      this as KonfHubTicketModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return KonfHubTicketModelMapper.ensureInitialized().equalsValue(
      this as KonfHubTicketModel,
      other,
    );
  }

  @override
  int get hashCode {
    return KonfHubTicketModelMapper.ensureInitialized().hashValue(
      this as KonfHubTicketModel,
    );
  }
}

extension KonfHubTicketModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KonfHubTicketModel, $Out> {
  KonfHubTicketModelCopyWith<$R, KonfHubTicketModel, $Out>
  get $asKonfHubTicketModel => $base.as(
    (v, t, t2) => _KonfHubTicketModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class KonfHubTicketModelCopyWith<
  $R,
  $In extends KonfHubTicketModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get additionalDetails;
  $R call({
    String? bookingId,
    DateTime? bookingDate,
    String? attendeeName,
    String? organization,
    String? eventName,
    DateTime? eventDate,
    DateTime? eventStartTime,
    DateTime? eventEndTime,
    String? ticketName,
    String? location,
    Map<String, String>? additionalDetails,
  });
  KonfHubTicketModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _KonfHubTicketModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KonfHubTicketModel, $Out>
    implements KonfHubTicketModelCopyWith<$R, KonfHubTicketModel, $Out> {
  _KonfHubTicketModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KonfHubTicketModel> $mapper =
      KonfHubTicketModelMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get additionalDetails => $value.additionalDetails != null
      ? MapCopyWith(
          $value.additionalDetails!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(additionalDetails: v),
        )
      : null;
  @override
  $R call({
    Object? bookingId = $none,
    Object? bookingDate = $none,
    Object? attendeeName = $none,
    Object? organization = $none,
    Object? eventName = $none,
    Object? eventDate = $none,
    Object? eventStartTime = $none,
    Object? eventEndTime = $none,
    Object? ticketName = $none,
    Object? location = $none,
    Object? additionalDetails = $none,
  }) => $apply(
    FieldCopyWithData({
      if (bookingId != $none) #bookingId: bookingId,
      if (bookingDate != $none) #bookingDate: bookingDate,
      if (attendeeName != $none) #attendeeName: attendeeName,
      if (organization != $none) #organization: organization,
      if (eventName != $none) #eventName: eventName,
      if (eventDate != $none) #eventDate: eventDate,
      if (eventStartTime != $none) #eventStartTime: eventStartTime,
      if (eventEndTime != $none) #eventEndTime: eventEndTime,
      if (ticketName != $none) #ticketName: ticketName,
      if (location != $none) #location: location,
      if (additionalDetails != $none) #additionalDetails: additionalDetails,
    }),
  );
  @override
  KonfHubTicketModel $make(CopyWithData data) => KonfHubTicketModel(
    bookingId: data.get(#bookingId, or: $value.bookingId),
    bookingDate: data.get(#bookingDate, or: $value.bookingDate),
    attendeeName: data.get(#attendeeName, or: $value.attendeeName),
    organization: data.get(#organization, or: $value.organization),
    eventName: data.get(#eventName, or: $value.eventName),
    eventDate: data.get(#eventDate, or: $value.eventDate),
    eventStartTime: data.get(#eventStartTime, or: $value.eventStartTime),
    eventEndTime: data.get(#eventEndTime, or: $value.eventEndTime),
    ticketName: data.get(#ticketName, or: $value.ticketName),
    location: data.get(#location, or: $value.location),
    additionalDetails: data.get(
      #additionalDetails,
      or: $value.additionalDetails,
    ),
  );

  @override
  KonfHubTicketModelCopyWith<$R2, KonfHubTicketModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KonfHubTicketModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

