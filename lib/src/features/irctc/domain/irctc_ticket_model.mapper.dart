// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'irctc_ticket_model.dart';

class IRCTCTicketMapper extends ClassMapperBase<IRCTCTicket> {
  IRCTCTicketMapper._();

  static IRCTCTicketMapper? _instance;
  static IRCTCTicketMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IRCTCTicketMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'IRCTCTicket';

  static String _$pnrNumber(IRCTCTicket v) => v.pnrNumber;
  static const Field<IRCTCTicket, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
  );
  static String _$passengerName(IRCTCTicket v) => v.passengerName;
  static const Field<IRCTCTicket, String> _f$passengerName = Field(
    'passengerName',
    _$passengerName,
  );
  static int? _$age(IRCTCTicket v) => v.age;
  static const Field<IRCTCTicket, int> _f$age = Field('age', _$age);
  static String _$status(IRCTCTicket v) => v.status;
  static const Field<IRCTCTicket, String> _f$status = Field('status', _$status);
  static String _$trainNumber(IRCTCTicket v) => v.trainNumber;
  static const Field<IRCTCTicket, String> _f$trainNumber = Field(
    'trainNumber',
    _$trainNumber,
  );
  static String _$trainName(IRCTCTicket v) => v.trainName;
  static const Field<IRCTCTicket, String> _f$trainName = Field(
    'trainName',
    _$trainName,
  );
  static String _$boardingStation(IRCTCTicket v) => v.boardingStation;
  static const Field<IRCTCTicket, String> _f$boardingStation = Field(
    'boardingStation',
    _$boardingStation,
  );
  static String _$fromStation(IRCTCTicket v) => v.fromStation;
  static const Field<IRCTCTicket, String> _f$fromStation = Field(
    'fromStation',
    _$fromStation,
  );
  static String _$toStation(IRCTCTicket v) => v.toStation;
  static const Field<IRCTCTicket, String> _f$toStation = Field(
    'toStation',
    _$toStation,
  );
  static double? _$ticketFare(IRCTCTicket v) => v.ticketFare;
  static const Field<IRCTCTicket, double> _f$ticketFare = Field(
    'ticketFare',
    _$ticketFare,
    opt: true,
  );
  static double? _$irctcFee(IRCTCTicket v) => v.irctcFee;
  static const Field<IRCTCTicket, double> _f$irctcFee = Field(
    'irctcFee',
    _$irctcFee,
    opt: true,
  );
  static String? _$transactionId(IRCTCTicket v) => v.transactionId;
  static const Field<IRCTCTicket, String> _f$transactionId = Field(
    'transactionId',
    _$transactionId,
    opt: true,
  );
  static String? _$gender(IRCTCTicket v) => v.gender;
  static const Field<IRCTCTicket, String> _f$gender = Field(
    'gender',
    _$gender,
    opt: true,
  );
  static String? _$quota(IRCTCTicket v) => v.quota;
  static const Field<IRCTCTicket, String> _f$quota = Field(
    'quota',
    _$quota,
    opt: true,
  );
  static String? _$travelClass(IRCTCTicket v) => v.travelClass;
  static const Field<IRCTCTicket, String> _f$travelClass = Field(
    'travelClass',
    _$travelClass,
    opt: true,
  );
  static DateTime? _$scheduledDeparture(IRCTCTicket v) => v.scheduledDeparture;
  static const Field<IRCTCTicket, DateTime> _f$scheduledDeparture = Field(
    'scheduledDeparture',
    _$scheduledDeparture,
    opt: true,
  );
  static DateTime? _$dateOfJourney(IRCTCTicket v) => v.dateOfJourney;
  static const Field<IRCTCTicket, DateTime> _f$dateOfJourney = Field(
    'dateOfJourney',
    _$dateOfJourney,
    opt: true,
  );

  @override
  final MappableFields<IRCTCTicket> fields = const {
    #pnrNumber: _f$pnrNumber,
    #passengerName: _f$passengerName,
    #age: _f$age,
    #status: _f$status,
    #trainNumber: _f$trainNumber,
    #trainName: _f$trainName,
    #boardingStation: _f$boardingStation,
    #fromStation: _f$fromStation,
    #toStation: _f$toStation,
    #ticketFare: _f$ticketFare,
    #irctcFee: _f$irctcFee,
    #transactionId: _f$transactionId,
    #gender: _f$gender,
    #quota: _f$quota,
    #travelClass: _f$travelClass,
    #scheduledDeparture: _f$scheduledDeparture,
    #dateOfJourney: _f$dateOfJourney,
  };

  static IRCTCTicket _instantiate(DecodingData data) {
    return IRCTCTicket(
      pnrNumber: data.dec(_f$pnrNumber),
      passengerName: data.dec(_f$passengerName),
      age: data.dec(_f$age),
      status: data.dec(_f$status),
      trainNumber: data.dec(_f$trainNumber),
      trainName: data.dec(_f$trainName),
      boardingStation: data.dec(_f$boardingStation),
      fromStation: data.dec(_f$fromStation),
      toStation: data.dec(_f$toStation),
      ticketFare: data.dec(_f$ticketFare),
      irctcFee: data.dec(_f$irctcFee),
      transactionId: data.dec(_f$transactionId),
      gender: data.dec(_f$gender),
      quota: data.dec(_f$quota),
      travelClass: data.dec(_f$travelClass),
      scheduledDeparture: data.dec(_f$scheduledDeparture),
      dateOfJourney: data.dec(_f$dateOfJourney),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static IRCTCTicket fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IRCTCTicket>(map);
  }

  static IRCTCTicket fromJson(String json) {
    return ensureInitialized().decodeJson<IRCTCTicket>(json);
  }
}

mixin IRCTCTicketMappable {
  String toJson() {
    return IRCTCTicketMapper.ensureInitialized().encodeJson<IRCTCTicket>(
      this as IRCTCTicket,
    );
  }

  Map<String, dynamic> toMap() {
    return IRCTCTicketMapper.ensureInitialized().encodeMap<IRCTCTicket>(
      this as IRCTCTicket,
    );
  }

  IRCTCTicketCopyWith<IRCTCTicket, IRCTCTicket, IRCTCTicket> get copyWith =>
      _IRCTCTicketCopyWithImpl<IRCTCTicket, IRCTCTicket>(
        this as IRCTCTicket,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IRCTCTicketMapper.ensureInitialized().stringifyValue(
      this as IRCTCTicket,
    );
  }

  @override
  bool operator ==(Object other) {
    return IRCTCTicketMapper.ensureInitialized().equalsValue(
      this as IRCTCTicket,
      other,
    );
  }

  @override
  int get hashCode {
    return IRCTCTicketMapper.ensureInitialized().hashValue(this as IRCTCTicket);
  }
}

extension IRCTCTicketValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IRCTCTicket, $Out> {
  IRCTCTicketCopyWith<$R, IRCTCTicket, $Out> get $asIRCTCTicket =>
      $base.as((v, t, t2) => _IRCTCTicketCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IRCTCTicketCopyWith<$R, $In extends IRCTCTicket, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? pnrNumber,
    String? passengerName,
    int? age,
    String? status,
    String? trainNumber,
    String? trainName,
    String? boardingStation,
    String? fromStation,
    String? toStation,
    double? ticketFare,
    double? irctcFee,
    String? transactionId,
    String? gender,
    String? quota,
    String? travelClass,
    DateTime? scheduledDeparture,
    DateTime? dateOfJourney,
  });
  IRCTCTicketCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IRCTCTicketCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IRCTCTicket, $Out>
    implements IRCTCTicketCopyWith<$R, IRCTCTicket, $Out> {
  _IRCTCTicketCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IRCTCTicket> $mapper =
      IRCTCTicketMapper.ensureInitialized();
  @override
  $R call({
    String? pnrNumber,
    String? passengerName,
    Object? age = $none,
    String? status,
    String? trainNumber,
    String? trainName,
    String? boardingStation,
    String? fromStation,
    String? toStation,
    Object? ticketFare = $none,
    Object? irctcFee = $none,
    Object? transactionId = $none,
    Object? gender = $none,
    Object? quota = $none,
    Object? travelClass = $none,
    Object? scheduledDeparture = $none,
    Object? dateOfJourney = $none,
  }) => $apply(
    FieldCopyWithData({
      if (pnrNumber != null) #pnrNumber: pnrNumber,
      if (passengerName != null) #passengerName: passengerName,
      if (age != $none) #age: age,
      if (status != null) #status: status,
      if (trainNumber != null) #trainNumber: trainNumber,
      if (trainName != null) #trainName: trainName,
      if (boardingStation != null) #boardingStation: boardingStation,
      if (fromStation != null) #fromStation: fromStation,
      if (toStation != null) #toStation: toStation,
      if (ticketFare != $none) #ticketFare: ticketFare,
      if (irctcFee != $none) #irctcFee: irctcFee,
      if (transactionId != $none) #transactionId: transactionId,
      if (gender != $none) #gender: gender,
      if (quota != $none) #quota: quota,
      if (travelClass != $none) #travelClass: travelClass,
      if (scheduledDeparture != $none) #scheduledDeparture: scheduledDeparture,
      if (dateOfJourney != $none) #dateOfJourney: dateOfJourney,
    }),
  );
  @override
  IRCTCTicket $make(CopyWithData data) => IRCTCTicket(
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
    passengerName: data.get(#passengerName, or: $value.passengerName),
    age: data.get(#age, or: $value.age),
    status: data.get(#status, or: $value.status),
    trainNumber: data.get(#trainNumber, or: $value.trainNumber),
    trainName: data.get(#trainName, or: $value.trainName),
    boardingStation: data.get(#boardingStation, or: $value.boardingStation),
    fromStation: data.get(#fromStation, or: $value.fromStation),
    toStation: data.get(#toStation, or: $value.toStation),
    ticketFare: data.get(#ticketFare, or: $value.ticketFare),
    irctcFee: data.get(#irctcFee, or: $value.irctcFee),
    transactionId: data.get(#transactionId, or: $value.transactionId),
    gender: data.get(#gender, or: $value.gender),
    quota: data.get(#quota, or: $value.quota),
    travelClass: data.get(#travelClass, or: $value.travelClass),
    scheduledDeparture: data.get(
      #scheduledDeparture,
      or: $value.scheduledDeparture,
    ),
    dateOfJourney: data.get(#dateOfJourney, or: $value.dateOfJourney),
  );

  @override
  IRCTCTicketCopyWith<$R2, IRCTCTicket, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IRCTCTicketCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

