// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'tnstc_model.dart';

class TNSTCModelMapper extends ClassMapperBase<TNSTCModel> {
  TNSTCModelMapper._();

  static TNSTCModelMapper? _instance;
  static TNSTCModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TNSTCModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TNSTCModel';

  static String _$corporation(TNSTCModel v) => v.corporation;
  static const Field<TNSTCModel, String> _f$corporation = Field(
    'corporation',
    _$corporation,
  );
  static String _$service(TNSTCModel v) => v.service;
  static const Field<TNSTCModel, String> _f$service = Field(
    'service',
    _$service,
  );
  static String _$pnrNo(TNSTCModel v) => v.pnrNo;
  static const Field<TNSTCModel, String> _f$pnrNo = Field(
    'pnrNo',
    _$pnrNo,
    key: r'pnr_no',
  );
  static String _$from(TNSTCModel v) => v.from;
  static const Field<TNSTCModel, String> _f$from = Field('from', _$from);
  static String _$to(TNSTCModel v) => v.to;
  static const Field<TNSTCModel, String> _f$to = Field('to', _$to);
  static String _$tripCode(TNSTCModel v) => v.tripCode;
  static const Field<TNSTCModel, String> _f$tripCode = Field(
    'tripCode',
    _$tripCode,
    key: r'trip_code',
  );
  static String _$journeyDate(TNSTCModel v) => v.journeyDate;
  static const Field<TNSTCModel, String> _f$journeyDate = Field(
    'journeyDate',
    _$journeyDate,
    key: r'journey_date',
  );
  static String _$time(TNSTCModel v) => v.time;
  static const Field<TNSTCModel, String> _f$time = Field('time', _$time);
  static List<String> _$seatNumbers(TNSTCModel v) => v.seatNumbers;
  static const Field<TNSTCModel, List<String>> _f$seatNumbers = Field(
    'seatNumbers',
    _$seatNumbers,
    key: r'seat_numbers',
  );
  static String _$ticketClass(TNSTCModel v) => v.ticketClass;
  static const Field<TNSTCModel, String> _f$ticketClass = Field(
    'ticketClass',
    _$ticketClass,
    key: r'class',
  );
  static String _$boardingAt(TNSTCModel v) => v.boardingAt;
  static const Field<TNSTCModel, String> _f$boardingAt = Field(
    'boardingAt',
    _$boardingAt,
    key: r'boarding_at',
  );

  @override
  final MappableFields<TNSTCModel> fields = const {
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

  static TNSTCModel _instantiate(DecodingData data) {
    return TNSTCModel(
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

  static TNSTCModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TNSTCModel>(map);
  }

  static TNSTCModel fromJson(String json) {
    return ensureInitialized().decodeJson<TNSTCModel>(json);
  }
}

mixin TNSTCModelMappable {
  String toJson() {
    return TNSTCModelMapper.ensureInitialized().encodeJson<TNSTCModel>(
      this as TNSTCModel,
    );
  }

  Map<String, dynamic> toMap() {
    return TNSTCModelMapper.ensureInitialized().encodeMap<TNSTCModel>(
      this as TNSTCModel,
    );
  }

  TNSTCModelCopyWith<TNSTCModel, TNSTCModel, TNSTCModel> get copyWith =>
      _TNSTCModelCopyWithImpl<TNSTCModel, TNSTCModel>(
        this as TNSTCModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TNSTCModelMapper.ensureInitialized().stringifyValue(
      this as TNSTCModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TNSTCModelMapper.ensureInitialized().equalsValue(
      this as TNSTCModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TNSTCModelMapper.ensureInitialized().hashValue(this as TNSTCModel);
  }
}

extension TNSTCModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TNSTCModel, $Out> {
  TNSTCModelCopyWith<$R, TNSTCModel, $Out> get $asTNSTCModel =>
      $base.as((v, t, t2) => _TNSTCModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TNSTCModelCopyWith<$R, $In extends TNSTCModel, $Out>
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
  TNSTCModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TNSTCModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TNSTCModel, $Out>
    implements TNSTCModelCopyWith<$R, TNSTCModel, $Out> {
  _TNSTCModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TNSTCModel> $mapper =
      TNSTCModelMapper.ensureInitialized();
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
  }) =>
      $apply(
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
  TNSTCModel $make(CopyWithData data) => TNSTCModel(
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
  TNSTCModelCopyWith<$R2, TNSTCModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _TNSTCModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
