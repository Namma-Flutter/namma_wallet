// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'tnstc_model.dart';

class TNSTCTicketModelMapper extends ClassMapperBase<TNSTCTicketModel> {
  TNSTCTicketModelMapper._();

  static TNSTCTicketModelMapper? _instance;
  static TNSTCTicketModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TNSTCTicketModelMapper._());
      PassengerInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TNSTCTicketModel';

  static String? _$corporation(TNSTCTicketModel v) => v.corporation;
  static const Field<TNSTCTicketModel, String> _f$corporation = Field(
    'corporation',
    _$corporation,
    opt: true,
  );
  static String? _$pnrNumber(TNSTCTicketModel v) => v.pnrNumber;
  static const Field<TNSTCTicketModel, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
    opt: true,
  );
  static DateTime? _$journeyDate(TNSTCTicketModel v) => v.journeyDate;
  static const Field<TNSTCTicketModel, DateTime> _f$journeyDate = Field(
    'journeyDate',
    _$journeyDate,
    opt: true,
  );
  static String? _$routeNo(TNSTCTicketModel v) => v.routeNo;
  static const Field<TNSTCTicketModel, String> _f$routeNo = Field(
    'routeNo',
    _$routeNo,
    opt: true,
  );
  static String? _$serviceStartPlace(TNSTCTicketModel v) => v.serviceStartPlace;
  static const Field<TNSTCTicketModel, String> _f$serviceStartPlace = Field(
    'serviceStartPlace',
    _$serviceStartPlace,
    opt: true,
  );
  static String? _$serviceEndPlace(TNSTCTicketModel v) => v.serviceEndPlace;
  static const Field<TNSTCTicketModel, String> _f$serviceEndPlace = Field(
    'serviceEndPlace',
    _$serviceEndPlace,
    opt: true,
  );
  static String? _$serviceStartTime(TNSTCTicketModel v) => v.serviceStartTime;
  static const Field<TNSTCTicketModel, String> _f$serviceStartTime = Field(
    'serviceStartTime',
    _$serviceStartTime,
    opt: true,
  );
  static String? _$passengerStartPlace(TNSTCTicketModel v) =>
      v.passengerStartPlace;
  static const Field<TNSTCTicketModel, String> _f$passengerStartPlace = Field(
    'passengerStartPlace',
    _$passengerStartPlace,
    opt: true,
  );
  static String? _$passengerEndPlace(TNSTCTicketModel v) => v.passengerEndPlace;
  static const Field<TNSTCTicketModel, String> _f$passengerEndPlace = Field(
    'passengerEndPlace',
    _$passengerEndPlace,
    opt: true,
  );
  static String? _$passengerPickupPoint(TNSTCTicketModel v) =>
      v.passengerPickupPoint;
  static const Field<TNSTCTicketModel, String> _f$passengerPickupPoint = Field(
    'passengerPickupPoint',
    _$passengerPickupPoint,
    opt: true,
  );
  static DateTime? _$passengerPickupTime(TNSTCTicketModel v) =>
      v.passengerPickupTime;
  static const Field<TNSTCTicketModel, DateTime> _f$passengerPickupTime = Field(
    'passengerPickupTime',
    _$passengerPickupTime,
    opt: true,
  );
  static String? _$platformNumber(TNSTCTicketModel v) => v.platformNumber;
  static const Field<TNSTCTicketModel, String> _f$platformNumber = Field(
    'platformNumber',
    _$platformNumber,
    opt: true,
  );
  static String? _$classOfService(TNSTCTicketModel v) => v.classOfService;
  static const Field<TNSTCTicketModel, String> _f$classOfService = Field(
    'classOfService',
    _$classOfService,
    opt: true,
  );
  static String? _$tripCode(TNSTCTicketModel v) => v.tripCode;
  static const Field<TNSTCTicketModel, String> _f$tripCode = Field(
    'tripCode',
    _$tripCode,
    opt: true,
  );
  static String? _$obReferenceNumber(TNSTCTicketModel v) => v.obReferenceNumber;
  static const Field<TNSTCTicketModel, String> _f$obReferenceNumber = Field(
    'obReferenceNumber',
    _$obReferenceNumber,
    opt: true,
  );
  static int? _$numberOfSeats(TNSTCTicketModel v) => v.numberOfSeats;
  static const Field<TNSTCTicketModel, int> _f$numberOfSeats = Field(
    'numberOfSeats',
    _$numberOfSeats,
    opt: true,
  );
  static String? _$bankTransactionNumber(TNSTCTicketModel v) =>
      v.bankTransactionNumber;
  static const Field<TNSTCTicketModel, String> _f$bankTransactionNumber = Field(
    'bankTransactionNumber',
    _$bankTransactionNumber,
    opt: true,
  );
  static String? _$busIdNumber(TNSTCTicketModel v) => v.busIdNumber;
  static const Field<TNSTCTicketModel, String> _f$busIdNumber = Field(
    'busIdNumber',
    _$busIdNumber,
    opt: true,
  );
  static String? _$passengerCategory(TNSTCTicketModel v) => v.passengerCategory;
  static const Field<TNSTCTicketModel, String> _f$passengerCategory = Field(
    'passengerCategory',
    _$passengerCategory,
    opt: true,
  );
  static List<PassengerInfo> _$passengers(TNSTCTicketModel v) => v.passengers;
  static const Field<TNSTCTicketModel, List<PassengerInfo>> _f$passengers =
      Field('passengers', _$passengers, opt: true, def: const []);
  static String? _$idCardType(TNSTCTicketModel v) => v.idCardType;
  static const Field<TNSTCTicketModel, String> _f$idCardType = Field(
    'idCardType',
    _$idCardType,
    opt: true,
  );
  static String? _$idCardNumber(TNSTCTicketModel v) => v.idCardNumber;
  static const Field<TNSTCTicketModel, String> _f$idCardNumber = Field(
    'idCardNumber',
    _$idCardNumber,
    opt: true,
  );
  static double? _$totalFare(TNSTCTicketModel v) => v.totalFare;
  static const Field<TNSTCTicketModel, double> _f$totalFare = Field(
    'totalFare',
    _$totalFare,
    opt: true,
  );
  static String? _$boardingPoint(TNSTCTicketModel v) => v.boardingPoint;
  static const Field<TNSTCTicketModel, String> _f$boardingPoint = Field(
    'boardingPoint',
    _$boardingPoint,
    opt: true,
  );

  @override
  final MappableFields<TNSTCTicketModel> fields = const {
    #corporation: _f$corporation,
    #pnrNumber: _f$pnrNumber,
    #journeyDate: _f$journeyDate,
    #routeNo: _f$routeNo,
    #serviceStartPlace: _f$serviceStartPlace,
    #serviceEndPlace: _f$serviceEndPlace,
    #serviceStartTime: _f$serviceStartTime,
    #passengerStartPlace: _f$passengerStartPlace,
    #passengerEndPlace: _f$passengerEndPlace,
    #passengerPickupPoint: _f$passengerPickupPoint,
    #passengerPickupTime: _f$passengerPickupTime,
    #platformNumber: _f$platformNumber,
    #classOfService: _f$classOfService,
    #tripCode: _f$tripCode,
    #obReferenceNumber: _f$obReferenceNumber,
    #numberOfSeats: _f$numberOfSeats,
    #bankTransactionNumber: _f$bankTransactionNumber,
    #busIdNumber: _f$busIdNumber,
    #passengerCategory: _f$passengerCategory,
    #passengers: _f$passengers,
    #idCardType: _f$idCardType,
    #idCardNumber: _f$idCardNumber,
    #totalFare: _f$totalFare,
    #boardingPoint: _f$boardingPoint,
  };

  static TNSTCTicketModel _instantiate(DecodingData data) {
    return TNSTCTicketModel(
      corporation: data.dec(_f$corporation),
      pnrNumber: data.dec(_f$pnrNumber),
      journeyDate: data.dec(_f$journeyDate),
      routeNo: data.dec(_f$routeNo),
      serviceStartPlace: data.dec(_f$serviceStartPlace),
      serviceEndPlace: data.dec(_f$serviceEndPlace),
      serviceStartTime: data.dec(_f$serviceStartTime),
      passengerStartPlace: data.dec(_f$passengerStartPlace),
      passengerEndPlace: data.dec(_f$passengerEndPlace),
      passengerPickupPoint: data.dec(_f$passengerPickupPoint),
      passengerPickupTime: data.dec(_f$passengerPickupTime),
      platformNumber: data.dec(_f$platformNumber),
      classOfService: data.dec(_f$classOfService),
      tripCode: data.dec(_f$tripCode),
      obReferenceNumber: data.dec(_f$obReferenceNumber),
      numberOfSeats: data.dec(_f$numberOfSeats),
      bankTransactionNumber: data.dec(_f$bankTransactionNumber),
      busIdNumber: data.dec(_f$busIdNumber),
      passengerCategory: data.dec(_f$passengerCategory),
      passengers: data.dec(_f$passengers),
      idCardType: data.dec(_f$idCardType),
      idCardNumber: data.dec(_f$idCardNumber),
      totalFare: data.dec(_f$totalFare),
      boardingPoint: data.dec(_f$boardingPoint),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TNSTCTicketModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TNSTCTicketModel>(map);
  }

  static TNSTCTicketModel fromJson(String json) {
    return ensureInitialized().decodeJson<TNSTCTicketModel>(json);
  }
}

mixin TNSTCTicketModelMappable {
  String toJson() {
    return TNSTCTicketModelMapper.ensureInitialized()
        .encodeJson<TNSTCTicketModel>(this as TNSTCTicketModel);
  }

  Map<String, dynamic> toMap() {
    return TNSTCTicketModelMapper.ensureInitialized()
        .encodeMap<TNSTCTicketModel>(this as TNSTCTicketModel);
  }

  TNSTCTicketModelCopyWith<TNSTCTicketModel, TNSTCTicketModel, TNSTCTicketModel>
  get copyWith =>
      _TNSTCTicketModelCopyWithImpl<TNSTCTicketModel, TNSTCTicketModel>(
        this as TNSTCTicketModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TNSTCTicketModelMapper.ensureInitialized().stringifyValue(
      this as TNSTCTicketModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TNSTCTicketModelMapper.ensureInitialized().equalsValue(
      this as TNSTCTicketModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TNSTCTicketModelMapper.ensureInitialized().hashValue(
      this as TNSTCTicketModel,
    );
  }
}

extension TNSTCTicketModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TNSTCTicketModel, $Out> {
  TNSTCTicketModelCopyWith<$R, TNSTCTicketModel, $Out>
  get $asTNSTCTicketModel =>
      $base.as((v, t, t2) => _TNSTCTicketModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TNSTCTicketModelCopyWith<$R, $In extends TNSTCTicketModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    PassengerInfo,
    PassengerInfoCopyWith<$R, PassengerInfo, PassengerInfo>
  >
  get passengers;
  $R call({
    String? corporation,
    String? pnrNumber,
    DateTime? journeyDate,
    String? routeNo,
    String? serviceStartPlace,
    String? serviceEndPlace,
    String? serviceStartTime,
    String? passengerStartPlace,
    String? passengerEndPlace,
    String? passengerPickupPoint,
    DateTime? passengerPickupTime,
    String? platformNumber,
    String? classOfService,
    String? tripCode,
    String? obReferenceNumber,
    int? numberOfSeats,
    String? bankTransactionNumber,
    String? busIdNumber,
    String? passengerCategory,
    List<PassengerInfo>? passengers,
    String? idCardType,
    String? idCardNumber,
    double? totalFare,
    String? boardingPoint,
  });
  TNSTCTicketModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TNSTCTicketModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TNSTCTicketModel, $Out>
    implements TNSTCTicketModelCopyWith<$R, TNSTCTicketModel, $Out> {
  _TNSTCTicketModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TNSTCTicketModel> $mapper =
      TNSTCTicketModelMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    PassengerInfo,
    PassengerInfoCopyWith<$R, PassengerInfo, PassengerInfo>
  >
  get passengers => ListCopyWith(
    $value.passengers,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(passengers: v),
  );
  @override
  $R call({
    Object? corporation = $none,
    Object? pnrNumber = $none,
    Object? journeyDate = $none,
    Object? routeNo = $none,
    Object? serviceStartPlace = $none,
    Object? serviceEndPlace = $none,
    Object? serviceStartTime = $none,
    Object? passengerStartPlace = $none,
    Object? passengerEndPlace = $none,
    Object? passengerPickupPoint = $none,
    Object? passengerPickupTime = $none,
    Object? platformNumber = $none,
    Object? classOfService = $none,
    Object? tripCode = $none,
    Object? obReferenceNumber = $none,
    Object? numberOfSeats = $none,
    Object? bankTransactionNumber = $none,
    Object? busIdNumber = $none,
    Object? passengerCategory = $none,
    List<PassengerInfo>? passengers,
    Object? idCardType = $none,
    Object? idCardNumber = $none,
    Object? totalFare = $none,
    Object? boardingPoint = $none,
  }) => $apply(
    FieldCopyWithData({
      if (corporation != $none) #corporation: corporation,
      if (pnrNumber != $none) #pnrNumber: pnrNumber,
      if (journeyDate != $none) #journeyDate: journeyDate,
      if (routeNo != $none) #routeNo: routeNo,
      if (serviceStartPlace != $none) #serviceStartPlace: serviceStartPlace,
      if (serviceEndPlace != $none) #serviceEndPlace: serviceEndPlace,
      if (serviceStartTime != $none) #serviceStartTime: serviceStartTime,
      if (passengerStartPlace != $none)
        #passengerStartPlace: passengerStartPlace,
      if (passengerEndPlace != $none) #passengerEndPlace: passengerEndPlace,
      if (passengerPickupPoint != $none)
        #passengerPickupPoint: passengerPickupPoint,
      if (passengerPickupTime != $none)
        #passengerPickupTime: passengerPickupTime,
      if (platformNumber != $none) #platformNumber: platformNumber,
      if (classOfService != $none) #classOfService: classOfService,
      if (tripCode != $none) #tripCode: tripCode,
      if (obReferenceNumber != $none) #obReferenceNumber: obReferenceNumber,
      if (numberOfSeats != $none) #numberOfSeats: numberOfSeats,
      if (bankTransactionNumber != $none)
        #bankTransactionNumber: bankTransactionNumber,
      if (busIdNumber != $none) #busIdNumber: busIdNumber,
      if (passengerCategory != $none) #passengerCategory: passengerCategory,
      if (passengers != null) #passengers: passengers,
      if (idCardType != $none) #idCardType: idCardType,
      if (idCardNumber != $none) #idCardNumber: idCardNumber,
      if (totalFare != $none) #totalFare: totalFare,
      if (boardingPoint != $none) #boardingPoint: boardingPoint,
    }),
  );
  @override
  TNSTCTicketModel $make(CopyWithData data) => TNSTCTicketModel(
    corporation: data.get(#corporation, or: $value.corporation),
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
    journeyDate: data.get(#journeyDate, or: $value.journeyDate),
    routeNo: data.get(#routeNo, or: $value.routeNo),
    serviceStartPlace: data.get(
      #serviceStartPlace,
      or: $value.serviceStartPlace,
    ),
    serviceEndPlace: data.get(#serviceEndPlace, or: $value.serviceEndPlace),
    serviceStartTime: data.get(#serviceStartTime, or: $value.serviceStartTime),
    passengerStartPlace: data.get(
      #passengerStartPlace,
      or: $value.passengerStartPlace,
    ),
    passengerEndPlace: data.get(
      #passengerEndPlace,
      or: $value.passengerEndPlace,
    ),
    passengerPickupPoint: data.get(
      #passengerPickupPoint,
      or: $value.passengerPickupPoint,
    ),
    passengerPickupTime: data.get(
      #passengerPickupTime,
      or: $value.passengerPickupTime,
    ),
    platformNumber: data.get(#platformNumber, or: $value.platformNumber),
    classOfService: data.get(#classOfService, or: $value.classOfService),
    tripCode: data.get(#tripCode, or: $value.tripCode),
    obReferenceNumber: data.get(
      #obReferenceNumber,
      or: $value.obReferenceNumber,
    ),
    numberOfSeats: data.get(#numberOfSeats, or: $value.numberOfSeats),
    bankTransactionNumber: data.get(
      #bankTransactionNumber,
      or: $value.bankTransactionNumber,
    ),
    busIdNumber: data.get(#busIdNumber, or: $value.busIdNumber),
    passengerCategory: data.get(
      #passengerCategory,
      or: $value.passengerCategory,
    ),
    passengers: data.get(#passengers, or: $value.passengers),
    idCardType: data.get(#idCardType, or: $value.idCardType),
    idCardNumber: data.get(#idCardNumber, or: $value.idCardNumber),
    totalFare: data.get(#totalFare, or: $value.totalFare),
    boardingPoint: data.get(#boardingPoint, or: $value.boardingPoint),
  );

  @override
  TNSTCTicketModelCopyWith<$R2, TNSTCTicketModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TNSTCTicketModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PassengerInfoMapper extends ClassMapperBase<PassengerInfo> {
  PassengerInfoMapper._();

  static PassengerInfoMapper? _instance;
  static PassengerInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PassengerInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PassengerInfo';

  static String _$name(PassengerInfo v) => v.name;
  static const Field<PassengerInfo, String> _f$name = Field('name', _$name);
  static int _$age(PassengerInfo v) => v.age;
  static const Field<PassengerInfo, int> _f$age = Field('age', _$age);
  static String _$type(PassengerInfo v) => v.type;
  static const Field<PassengerInfo, String> _f$type = Field('type', _$type);
  static String _$gender(PassengerInfo v) => v.gender;
  static const Field<PassengerInfo, String> _f$gender = Field(
    'gender',
    _$gender,
  );
  static String _$seatNumber(PassengerInfo v) => v.seatNumber;
  static const Field<PassengerInfo, String> _f$seatNumber = Field(
    'seatNumber',
    _$seatNumber,
  );

  @override
  final MappableFields<PassengerInfo> fields = const {
    #name: _f$name,
    #age: _f$age,
    #type: _f$type,
    #gender: _f$gender,
    #seatNumber: _f$seatNumber,
  };

  static PassengerInfo _instantiate(DecodingData data) {
    return PassengerInfo(
      name: data.dec(_f$name),
      age: data.dec(_f$age),
      type: data.dec(_f$type),
      gender: data.dec(_f$gender),
      seatNumber: data.dec(_f$seatNumber),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PassengerInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PassengerInfo>(map);
  }

  static PassengerInfo fromJson(String json) {
    return ensureInitialized().decodeJson<PassengerInfo>(json);
  }
}

mixin PassengerInfoMappable {
  String toJson() {
    return PassengerInfoMapper.ensureInitialized().encodeJson<PassengerInfo>(
      this as PassengerInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return PassengerInfoMapper.ensureInitialized().encodeMap<PassengerInfo>(
      this as PassengerInfo,
    );
  }

  PassengerInfoCopyWith<PassengerInfo, PassengerInfo, PassengerInfo>
  get copyWith => _PassengerInfoCopyWithImpl<PassengerInfo, PassengerInfo>(
    this as PassengerInfo,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PassengerInfoMapper.ensureInitialized().stringifyValue(
      this as PassengerInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return PassengerInfoMapper.ensureInitialized().equalsValue(
      this as PassengerInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return PassengerInfoMapper.ensureInitialized().hashValue(
      this as PassengerInfo,
    );
  }
}

extension PassengerInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PassengerInfo, $Out> {
  PassengerInfoCopyWith<$R, PassengerInfo, $Out> get $asPassengerInfo =>
      $base.as((v, t, t2) => _PassengerInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PassengerInfoCopyWith<$R, $In extends PassengerInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? name,
    int? age,
    String? type,
    String? gender,
    String? seatNumber,
  });
  PassengerInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PassengerInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PassengerInfo, $Out>
    implements PassengerInfoCopyWith<$R, PassengerInfo, $Out> {
  _PassengerInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PassengerInfo> $mapper =
      PassengerInfoMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    int? age,
    String? type,
    String? gender,
    String? seatNumber,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (age != null) #age: age,
      if (type != null) #type: type,
      if (gender != null) #gender: gender,
      if (seatNumber != null) #seatNumber: seatNumber,
    }),
  );
  @override
  PassengerInfo $make(CopyWithData data) => PassengerInfo(
    name: data.get(#name, or: $value.name),
    age: data.get(#age, or: $value.age),
    type: data.get(#type, or: $value.type),
    gender: data.get(#gender, or: $value.gender),
    seatNumber: data.get(#seatNumber, or: $value.seatNumber),
  );

  @override
  PassengerInfoCopyWith<$R2, PassengerInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PassengerInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

