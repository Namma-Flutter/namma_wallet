// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'travel_model.dart';

class TravelModelMapper extends ClassMapperBase<TravelModel> {
  TravelModelMapper._();

  static TravelModelMapper? _instance;
  static TravelModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TravelModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TravelModel';

  static String _$corporation(TravelModel v) => v.corporation;
  static const Field<TravelModel, String> _f$corporation = Field(
    'corporation',
    _$corporation,
  );
  static String _$service(TravelModel v) => v.service;
  static const Field<TravelModel, String> _f$service = Field(
    'service',
    _$service,
  );
  static String _$pnrNo(TravelModel v) => v.pnrNo;
  static const Field<TravelModel, String> _f$pnrNo = Field(
    'pnrNo',
    _$pnrNo,
    key: r'pnr_no',
  );
  static String _$from(TravelModel v) => v.from;
  static const Field<TravelModel, String> _f$from = Field('from', _$from);
  static String _$to(TravelModel v) => v.to;
  static const Field<TravelModel, String> _f$to = Field('to', _$to);
  static String _$tripCode(TravelModel v) => v.tripCode;
  static const Field<TravelModel, String> _f$tripCode = Field(
    'tripCode',
    _$tripCode,
    key: r'trip_code',
  );
  static String _$journeyDate(TravelModel v) => v.journeyDate;
  static const Field<TravelModel, String> _f$journeyDate = Field(
    'journeyDate',
    _$journeyDate,
    key: r'journey_date',
  );
  static String _$time(TravelModel v) => v.time;
  static const Field<TravelModel, String> _f$time = Field('time', _$time);
  static List<String> _$seatNumbers(TravelModel v) => v.seatNumbers;
  static const Field<TravelModel, List<String>> _f$seatNumbers = Field(
    'seatNumbers',
    _$seatNumbers,
    key: r'seat_numbers',
  );
  static String _$ticketClass(TravelModel v) => v.ticketClass;
  static const Field<TravelModel, String> _f$ticketClass = Field(
    'ticketClass',
    _$ticketClass,
    key: r'class',
  );
  static String _$boardingAt(TravelModel v) => v.boardingAt;
  static const Field<TravelModel, String> _f$boardingAt = Field(
    'boardingAt',
    _$boardingAt,
    key: r'boarding_at',
  );

  @override
  final MappableFields<TravelModel> fields = const {
    #corporation: _f$corporation,
    #service: _f$service,
    #pnrNo: _f$pnrNo,
    #from: _f$from,
    #to: _f$to,
    #tripCode: _f$tripCode,
    #journeyDate: _f$journeyDate,
    #time: _f$time,
    #seatNumbers: _f$seatNumbers,
    #ticketClass: _f$ticketClass,
    #boardingAt: _f$boardingAt,
  };

  static TravelModel _instantiate(DecodingData data) {
    return TravelModel(
      corporation: data.dec(_f$corporation),
      service: data.dec(_f$service),
      pnrNo: data.dec(_f$pnrNo),
      from: data.dec(_f$from),
      to: data.dec(_f$to),
      tripCode: data.dec(_f$tripCode),
      journeyDate: data.dec(_f$journeyDate),
      time: data.dec(_f$time),
      seatNumbers: data.dec(_f$seatNumbers),
      ticketClass: data.dec(_f$ticketClass),
      boardingAt: data.dec(_f$boardingAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TravelModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TravelModel>(map);
  }

  static TravelModel fromJson(String json) {
    return ensureInitialized().decodeJson<TravelModel>(json);
  }
}

mixin TravelModelMappable {
  String toJson() {
    return TravelModelMapper.ensureInitialized().encodeJson<TravelModel>(
      this as TravelModel,
    );
  }

  Map<String, dynamic> toMap() {
    return TravelModelMapper.ensureInitialized().encodeMap<TravelModel>(
      this as TravelModel,
    );
  }

  TravelModelCopyWith<TravelModel, TravelModel, TravelModel> get copyWith =>
      _TravelModelCopyWithImpl<TravelModel, TravelModel>(
        this as TravelModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TravelModelMapper.ensureInitialized().stringifyValue(
      this as TravelModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TravelModelMapper.ensureInitialized().equalsValue(
      this as TravelModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TravelModelMapper.ensureInitialized().hashValue(this as TravelModel);
  }
}

extension TravelModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TravelModel, $Out> {
  TravelModelCopyWith<$R, TravelModel, $Out> get $asTravelModel =>
      $base.as((v, t, t2) => _TravelModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TravelModelCopyWith<$R, $In extends TravelModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get seatNumbers;
  $R call({
    String? corporation,
    String? service,
    String? pnrNo,
    String? from,
    String? to,
    String? tripCode,
    String? journeyDate,
    String? time,
    List<String>? seatNumbers,
    String? ticketClass,
    String? boardingAt,
  });
  TravelModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TravelModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TravelModel, $Out>
    implements TravelModelCopyWith<$R, TravelModel, $Out> {
  _TravelModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TravelModel> $mapper =
      TravelModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get seatNumbers => ListCopyWith(
    $value.seatNumbers,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(seatNumbers: v),
  );
  @override
  $R call({
    String? corporation,
    String? service,
    String? pnrNo,
    String? from,
    String? to,
    String? tripCode,
    String? journeyDate,
    String? time,
    List<String>? seatNumbers,
    String? ticketClass,
    String? boardingAt,
  }) => $apply(
    FieldCopyWithData({
      if (corporation != null) #corporation: corporation,
      if (service != null) #service: service,
      if (pnrNo != null) #pnrNo: pnrNo,
      if (from != null) #from: from,
      if (to != null) #to: to,
      if (tripCode != null) #tripCode: tripCode,
      if (journeyDate != null) #journeyDate: journeyDate,
      if (time != null) #time: time,
      if (seatNumbers != null) #seatNumbers: seatNumbers,
      if (ticketClass != null) #ticketClass: ticketClass,
      if (boardingAt != null) #boardingAt: boardingAt,
    }),
  );
  @override
  TravelModel $make(CopyWithData data) => TravelModel(
    corporation: data.get(#corporation, or: $value.corporation),
    service: data.get(#service, or: $value.service),
    pnrNo: data.get(#pnrNo, or: $value.pnrNo),
    from: data.get(#from, or: $value.from),
    to: data.get(#to, or: $value.to),
    tripCode: data.get(#tripCode, or: $value.tripCode),
    journeyDate: data.get(#journeyDate, or: $value.journeyDate),
    time: data.get(#time, or: $value.time),
    seatNumbers: data.get(#seatNumbers, or: $value.seatNumbers),
    ticketClass: data.get(#ticketClass, or: $value.ticketClass),
    boardingAt: data.get(#boardingAt, or: $value.boardingAt),
  );

  @override
  TravelModelCopyWith<$R2, TravelModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TravelModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

