// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'travel_ticket_model.dart';

class TicketTypeMapper extends EnumMapper<TicketType> {
  TicketTypeMapper._();

  static TicketTypeMapper? _instance;
  static TicketTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketTypeMapper._());
    }
    return _instance!;
  }

  static TicketType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TicketType decode(dynamic value) {
    switch (value) {
      case 'BUS':
        return TicketType.bus;
      case 'TRAIN':
        return TicketType.train;
      case 'EVENT':
        return TicketType.event;
      case 'FLIGHT':
        return TicketType.flight;
      case 'METRO':
        return TicketType.metro;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TicketType self) {
    switch (self) {
      case TicketType.bus:
        return 'BUS';
      case TicketType.train:
        return 'TRAIN';
      case TicketType.event:
        return 'EVENT';
      case TicketType.flight:
        return 'FLIGHT';
      case TicketType.metro:
        return 'METRO';
    }
  }
}

extension TicketTypeMapperExtension on TicketType {
  dynamic toValue() {
    TicketTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TicketType>(this);
  }
}

class TicketStatusMapper extends EnumMapper<TicketStatus> {
  TicketStatusMapper._();

  static TicketStatusMapper? _instance;
  static TicketStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketStatusMapper._());
    }
    return _instance!;
  }

  static TicketStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TicketStatus decode(dynamic value) {
    switch (value) {
      case 'CONFIRMED':
        return TicketStatus.confirmed;
      case 'CANCELLED':
        return TicketStatus.cancelled;
      case 'PENDING':
        return TicketStatus.pending;
      case 'COMPLETED':
        return TicketStatus.completed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TicketStatus self) {
    switch (self) {
      case TicketStatus.confirmed:
        return 'CONFIRMED';
      case TicketStatus.cancelled:
        return 'CANCELLED';
      case TicketStatus.pending:
        return 'PENDING';
      case TicketStatus.completed:
        return 'COMPLETED';
    }
  }
}

extension TicketStatusMapperExtension on TicketStatus {
  dynamic toValue() {
    TicketStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TicketStatus>(this);
  }
}

class SourceTypeMapper extends EnumMapper<SourceType> {
  SourceTypeMapper._();

  static SourceTypeMapper? _instance;
  static SourceTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SourceTypeMapper._());
    }
    return _instance!;
  }

  static SourceType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SourceType decode(dynamic value) {
    switch (value) {
      case 'SMS':
        return SourceType.sms;
      case 'PDF':
        return SourceType.pdf;
      case 'MANUAL':
        return SourceType.manual;
      case 'CLIPBOARD':
        return SourceType.clipboard;
      case 'QR':
        return SourceType.qr;
      case 'SCANNER':
        return SourceType.scanner;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SourceType self) {
    switch (self) {
      case SourceType.sms:
        return 'SMS';
      case SourceType.pdf:
        return 'PDF';
      case SourceType.manual:
        return 'MANUAL';
      case SourceType.clipboard:
        return 'CLIPBOARD';
      case SourceType.qr:
        return 'QR';
      case SourceType.scanner:
        return 'SCANNER';
    }
  }
}

extension SourceTypeMapperExtension on SourceType {
  dynamic toValue() {
    SourceTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SourceType>(this);
  }
}

class TravelTicketModelMapper extends ClassMapperBase<TravelTicketModel> {
  TravelTicketModelMapper._();

  static TravelTicketModelMapper? _instance;
  static TravelTicketModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TravelTicketModelMapper._());
      TicketTypeMapper.ensureInitialized();
      TicketStatusMapper.ensureInitialized();
      SourceTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TravelTicketModel';

  static TicketType _$ticketType(TravelTicketModel v) => v.ticketType;
  static const Field<TravelTicketModel, TicketType> _f$ticketType = Field(
    'ticketType',
    _$ticketType,
    key: r'ticket_type',
  );
  static String _$providerName(TravelTicketModel v) => v.providerName;
  static const Field<TravelTicketModel, String> _f$providerName = Field(
    'providerName',
    _$providerName,
    key: r'provider_name',
  );
  static int? _$id(TravelTicketModel v) => v.id;
  static const Field<TravelTicketModel, int> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static int _$userId(TravelTicketModel v) => v.userId;
  static const Field<TravelTicketModel, int> _f$userId = Field(
    'userId',
    _$userId,
    key: r'user_id',
    opt: true,
    def: 1,
  );
  static String? _$bookingReference(TravelTicketModel v) => v.bookingReference;
  static const Field<TravelTicketModel, String> _f$bookingReference = Field(
    'bookingReference',
    _$bookingReference,
    key: r'booking_reference',
    opt: true,
  );
  static String? _$pnrNumber(TravelTicketModel v) => v.pnrNumber;
  static const Field<TravelTicketModel, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
    key: r'pnr_number',
    opt: true,
  );
  static String? _$tripCode(TravelTicketModel v) => v.tripCode;
  static const Field<TravelTicketModel, String> _f$tripCode = Field(
    'tripCode',
    _$tripCode,
    key: r'trip_code',
    opt: true,
  );
  static String? _$sourceLocation(TravelTicketModel v) => v.sourceLocation;
  static const Field<TravelTicketModel, String> _f$sourceLocation = Field(
    'sourceLocation',
    _$sourceLocation,
    key: r'source_location',
    opt: true,
  );
  static String? _$destinationLocation(TravelTicketModel v) =>
      v.destinationLocation;
  static const Field<TravelTicketModel, String> _f$destinationLocation = Field(
    'destinationLocation',
    _$destinationLocation,
    key: r'destination_location',
    opt: true,
  );
  static String? _$journeyDate(TravelTicketModel v) => v.journeyDate;
  static const Field<TravelTicketModel, String> _f$journeyDate = Field(
    'journeyDate',
    _$journeyDate,
    key: r'journey_date',
    opt: true,
  );
  static String? _$journeyTime(TravelTicketModel v) => v.journeyTime;
  static const Field<TravelTicketModel, String> _f$journeyTime = Field(
    'journeyTime',
    _$journeyTime,
    key: r'journey_time',
    opt: true,
  );
  static String? _$departureTime(TravelTicketModel v) => v.departureTime;
  static const Field<TravelTicketModel, String> _f$departureTime = Field(
    'departureTime',
    _$departureTime,
    key: r'departure_time',
    opt: true,
  );
  static String? _$arrivalTime(TravelTicketModel v) => v.arrivalTime;
  static const Field<TravelTicketModel, String> _f$arrivalTime = Field(
    'arrivalTime',
    _$arrivalTime,
    key: r'arrival_time',
    opt: true,
  );
  static String? _$passengerName(TravelTicketModel v) => v.passengerName;
  static const Field<TravelTicketModel, String> _f$passengerName = Field(
    'passengerName',
    _$passengerName,
    key: r'passenger_name',
    opt: true,
  );
  static int? _$passengerAge(TravelTicketModel v) => v.passengerAge;
  static const Field<TravelTicketModel, int> _f$passengerAge = Field(
    'passengerAge',
    _$passengerAge,
    key: r'passenger_age',
    opt: true,
  );
  static String? _$passengerGender(TravelTicketModel v) => v.passengerGender;
  static const Field<TravelTicketModel, String> _f$passengerGender = Field(
    'passengerGender',
    _$passengerGender,
    key: r'passenger_gender',
    opt: true,
  );
  static String? _$seatNumbers(TravelTicketModel v) => v.seatNumbers;
  static const Field<TravelTicketModel, String> _f$seatNumbers = Field(
    'seatNumbers',
    _$seatNumbers,
    key: r'seat_numbers',
    opt: true,
  );
  static String? _$coachNumber(TravelTicketModel v) => v.coachNumber;
  static const Field<TravelTicketModel, String> _f$coachNumber = Field(
    'coachNumber',
    _$coachNumber,
    key: r'coach_number',
    opt: true,
  );
  static String? _$classOfService(TravelTicketModel v) => v.classOfService;
  static const Field<TravelTicketModel, String> _f$classOfService = Field(
    'classOfService',
    _$classOfService,
    key: r'class_of_service',
    opt: true,
  );
  static String? _$bookingDate(TravelTicketModel v) => v.bookingDate;
  static const Field<TravelTicketModel, String> _f$bookingDate = Field(
    'bookingDate',
    _$bookingDate,
    key: r'booking_date',
    opt: true,
  );
  static double? _$amount(TravelTicketModel v) => v.amount;
  static const Field<TravelTicketModel, double> _f$amount = Field(
    'amount',
    _$amount,
    opt: true,
  );
  static String _$currency(TravelTicketModel v) => v.currency;
  static const Field<TravelTicketModel, String> _f$currency = Field(
    'currency',
    _$currency,
    opt: true,
    def: 'INR',
  );
  static TicketStatus _$status(TravelTicketModel v) => v.status;
  static const Field<TravelTicketModel, TicketStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: TicketStatus.confirmed,
  );
  static String? _$boardingPoint(TravelTicketModel v) => v.boardingPoint;
  static const Field<TravelTicketModel, String> _f$boardingPoint = Field(
    'boardingPoint',
    _$boardingPoint,
    key: r'boarding_point',
    opt: true,
  );
  static String? _$pickupLocation(TravelTicketModel v) => v.pickupLocation;
  static const Field<TravelTicketModel, String> _f$pickupLocation = Field(
    'pickupLocation',
    _$pickupLocation,
    key: r'pickup_location',
    opt: true,
  );
  static String? _$eventName(TravelTicketModel v) => v.eventName;
  static const Field<TravelTicketModel, String> _f$eventName = Field(
    'eventName',
    _$eventName,
    key: r'event_name',
    opt: true,
  );
  static String? _$venueName(TravelTicketModel v) => v.venueName;
  static const Field<TravelTicketModel, String> _f$venueName = Field(
    'venueName',
    _$venueName,
    key: r'venue_name',
    opt: true,
  );
  static String? _$contactMobile(TravelTicketModel v) => v.contactMobile;
  static const Field<TravelTicketModel, String> _f$contactMobile = Field(
    'contactMobile',
    _$contactMobile,
    key: r'contact_mobile',
    opt: true,
  );
  static SourceType _$sourceType(TravelTicketModel v) => v.sourceType;
  static const Field<TravelTicketModel, SourceType> _f$sourceType = Field(
    'sourceType',
    _$sourceType,
    key: r'source_type',
    opt: true,
    def: SourceType.manual,
  );
  static String? _$rawData(TravelTicketModel v) => v.rawData;
  static const Field<TravelTicketModel, String> _f$rawData = Field(
    'rawData',
    _$rawData,
    key: r'raw_data',
    opt: true,
  );
  static String? _$createdAt(TravelTicketModel v) => v.createdAt;
  static const Field<TravelTicketModel, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
    opt: true,
  );
  static String? _$updatedAt(TravelTicketModel v) => v.updatedAt;
  static const Field<TravelTicketModel, String> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static List<String> _$seatNumbersList(TravelTicketModel v) =>
      v.seatNumbersList;
  static const Field<TravelTicketModel, List<String>> _f$seatNumbersList =
      Field('seatNumbersList', _$seatNumbersList, mode: FieldMode.member);
  static String _$displayName(TravelTicketModel v) => v.displayName;
  static const Field<TravelTicketModel, String> _f$displayName = Field(
    'displayName',
    _$displayName,
    mode: FieldMode.member,
  );
  static String _$displayDate(TravelTicketModel v) => v.displayDate;
  static const Field<TravelTicketModel, String> _f$displayDate = Field(
    'displayDate',
    _$displayDate,
    mode: FieldMode.member,
  );
  static String _$displayTime(TravelTicketModel v) => v.displayTime;
  static const Field<TravelTicketModel, String> _f$displayTime = Field(
    'displayTime',
    _$displayTime,
    mode: FieldMode.member,
  );
  static bool _$isPastTravel(TravelTicketModel v) => v.isPastTravel;
  static const Field<TravelTicketModel, bool> _f$isPastTravel = Field(
    'isPastTravel',
    _$isPastTravel,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<TravelTicketModel> fields = const {
    #ticketType: _f$ticketType,
    #providerName: _f$providerName,
    #id: _f$id,
    #userId: _f$userId,
    #bookingReference: _f$bookingReference,
    #pnrNumber: _f$pnrNumber,
    #tripCode: _f$tripCode,
    #sourceLocation: _f$sourceLocation,
    #destinationLocation: _f$destinationLocation,
    #journeyDate: _f$journeyDate,
    #journeyTime: _f$journeyTime,
    #departureTime: _f$departureTime,
    #arrivalTime: _f$arrivalTime,
    #passengerName: _f$passengerName,
    #passengerAge: _f$passengerAge,
    #passengerGender: _f$passengerGender,
    #seatNumbers: _f$seatNumbers,
    #coachNumber: _f$coachNumber,
    #classOfService: _f$classOfService,
    #bookingDate: _f$bookingDate,
    #amount: _f$amount,
    #currency: _f$currency,
    #status: _f$status,
    #boardingPoint: _f$boardingPoint,
    #pickupLocation: _f$pickupLocation,
    #eventName: _f$eventName,
    #venueName: _f$venueName,
    #contactMobile: _f$contactMobile,
    #sourceType: _f$sourceType,
    #rawData: _f$rawData,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #seatNumbersList: _f$seatNumbersList,
    #displayName: _f$displayName,
    #displayDate: _f$displayDate,
    #displayTime: _f$displayTime,
    #isPastTravel: _f$isPastTravel,
  };

  static TravelTicketModel _instantiate(DecodingData data) {
    return TravelTicketModel(
      ticketType: data.dec(_f$ticketType),
      providerName: data.dec(_f$providerName),
      id: data.dec(_f$id),
      userId: data.dec(_f$userId),
      bookingReference: data.dec(_f$bookingReference),
      pnrNumber: data.dec(_f$pnrNumber),
      tripCode: data.dec(_f$tripCode),
      sourceLocation: data.dec(_f$sourceLocation),
      destinationLocation: data.dec(_f$destinationLocation),
      journeyDate: data.dec(_f$journeyDate),
      journeyTime: data.dec(_f$journeyTime),
      departureTime: data.dec(_f$departureTime),
      arrivalTime: data.dec(_f$arrivalTime),
      passengerName: data.dec(_f$passengerName),
      passengerAge: data.dec(_f$passengerAge),
      passengerGender: data.dec(_f$passengerGender),
      seatNumbers: data.dec(_f$seatNumbers),
      coachNumber: data.dec(_f$coachNumber),
      classOfService: data.dec(_f$classOfService),
      bookingDate: data.dec(_f$bookingDate),
      amount: data.dec(_f$amount),
      currency: data.dec(_f$currency),
      status: data.dec(_f$status),
      boardingPoint: data.dec(_f$boardingPoint),
      pickupLocation: data.dec(_f$pickupLocation),
      eventName: data.dec(_f$eventName),
      venueName: data.dec(_f$venueName),
      contactMobile: data.dec(_f$contactMobile),
      sourceType: data.dec(_f$sourceType),
      rawData: data.dec(_f$rawData),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TravelTicketModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TravelTicketModel>(map);
  }

  static TravelTicketModel fromJson(String json) {
    return ensureInitialized().decodeJson<TravelTicketModel>(json);
  }
}

mixin TravelTicketModelMappable {
  String toJson() {
    return TravelTicketModelMapper.ensureInitialized()
        .encodeJson<TravelTicketModel>(this as TravelTicketModel);
  }

  Map<String, dynamic> toMap() {
    return TravelTicketModelMapper.ensureInitialized()
        .encodeMap<TravelTicketModel>(this as TravelTicketModel);
  }

  TravelTicketModelCopyWith<
    TravelTicketModel,
    TravelTicketModel,
    TravelTicketModel
  >
  get copyWith =>
      _TravelTicketModelCopyWithImpl<TravelTicketModel, TravelTicketModel>(
        this as TravelTicketModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TravelTicketModelMapper.ensureInitialized().stringifyValue(
      this as TravelTicketModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TravelTicketModelMapper.ensureInitialized().equalsValue(
      this as TravelTicketModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TravelTicketModelMapper.ensureInitialized().hashValue(
      this as TravelTicketModel,
    );
  }
}

extension TravelTicketModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TravelTicketModel, $Out> {
  TravelTicketModelCopyWith<$R, TravelTicketModel, $Out>
  get $asTravelTicketModel => $base.as(
    (v, t, t2) => _TravelTicketModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TravelTicketModelCopyWith<
  $R,
  $In extends TravelTicketModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    TicketType? ticketType,
    String? providerName,
    int? id,
    int? userId,
    String? bookingReference,
    String? pnrNumber,
    String? tripCode,
    String? sourceLocation,
    String? destinationLocation,
    String? journeyDate,
    String? journeyTime,
    String? departureTime,
    String? arrivalTime,
    String? passengerName,
    int? passengerAge,
    String? passengerGender,
    String? seatNumbers,
    String? coachNumber,
    String? classOfService,
    String? bookingDate,
    double? amount,
    String? currency,
    TicketStatus? status,
    String? boardingPoint,
    String? pickupLocation,
    String? eventName,
    String? venueName,
    String? contactMobile,
    SourceType? sourceType,
    String? rawData,
    String? createdAt,
    String? updatedAt,
  });
  TravelTicketModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TravelTicketModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TravelTicketModel, $Out>
    implements TravelTicketModelCopyWith<$R, TravelTicketModel, $Out> {
  _TravelTicketModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TravelTicketModel> $mapper =
      TravelTicketModelMapper.ensureInitialized();
  @override
  $R call({
    TicketType? ticketType,
    String? providerName,
    Object? id = $none,
    int? userId,
    Object? bookingReference = $none,
    Object? pnrNumber = $none,
    Object? tripCode = $none,
    Object? sourceLocation = $none,
    Object? destinationLocation = $none,
    Object? journeyDate = $none,
    Object? journeyTime = $none,
    Object? departureTime = $none,
    Object? arrivalTime = $none,
    Object? passengerName = $none,
    Object? passengerAge = $none,
    Object? passengerGender = $none,
    Object? seatNumbers = $none,
    Object? coachNumber = $none,
    Object? classOfService = $none,
    Object? bookingDate = $none,
    Object? amount = $none,
    String? currency,
    TicketStatus? status,
    Object? boardingPoint = $none,
    Object? pickupLocation = $none,
    Object? eventName = $none,
    Object? venueName = $none,
    Object? contactMobile = $none,
    SourceType? sourceType,
    Object? rawData = $none,
    Object? createdAt = $none,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (ticketType != null) #ticketType: ticketType,
      if (providerName != null) #providerName: providerName,
      if (id != $none) #id: id,
      if (userId != null) #userId: userId,
      if (bookingReference != $none) #bookingReference: bookingReference,
      if (pnrNumber != $none) #pnrNumber: pnrNumber,
      if (tripCode != $none) #tripCode: tripCode,
      if (sourceLocation != $none) #sourceLocation: sourceLocation,
      if (destinationLocation != $none)
        #destinationLocation: destinationLocation,
      if (journeyDate != $none) #journeyDate: journeyDate,
      if (journeyTime != $none) #journeyTime: journeyTime,
      if (departureTime != $none) #departureTime: departureTime,
      if (arrivalTime != $none) #arrivalTime: arrivalTime,
      if (passengerName != $none) #passengerName: passengerName,
      if (passengerAge != $none) #passengerAge: passengerAge,
      if (passengerGender != $none) #passengerGender: passengerGender,
      if (seatNumbers != $none) #seatNumbers: seatNumbers,
      if (coachNumber != $none) #coachNumber: coachNumber,
      if (classOfService != $none) #classOfService: classOfService,
      if (bookingDate != $none) #bookingDate: bookingDate,
      if (amount != $none) #amount: amount,
      if (currency != null) #currency: currency,
      if (status != null) #status: status,
      if (boardingPoint != $none) #boardingPoint: boardingPoint,
      if (pickupLocation != $none) #pickupLocation: pickupLocation,
      if (eventName != $none) #eventName: eventName,
      if (venueName != $none) #venueName: venueName,
      if (contactMobile != $none) #contactMobile: contactMobile,
      if (sourceType != null) #sourceType: sourceType,
      if (rawData != $none) #rawData: rawData,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  TravelTicketModel $make(CopyWithData data) => TravelTicketModel(
    ticketType: data.get(#ticketType, or: $value.ticketType),
    providerName: data.get(#providerName, or: $value.providerName),
    id: data.get(#id, or: $value.id),
    userId: data.get(#userId, or: $value.userId),
    bookingReference: data.get(#bookingReference, or: $value.bookingReference),
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
    tripCode: data.get(#tripCode, or: $value.tripCode),
    sourceLocation: data.get(#sourceLocation, or: $value.sourceLocation),
    destinationLocation: data.get(
      #destinationLocation,
      or: $value.destinationLocation,
    ),
    journeyDate: data.get(#journeyDate, or: $value.journeyDate),
    journeyTime: data.get(#journeyTime, or: $value.journeyTime),
    departureTime: data.get(#departureTime, or: $value.departureTime),
    arrivalTime: data.get(#arrivalTime, or: $value.arrivalTime),
    passengerName: data.get(#passengerName, or: $value.passengerName),
    passengerAge: data.get(#passengerAge, or: $value.passengerAge),
    passengerGender: data.get(#passengerGender, or: $value.passengerGender),
    seatNumbers: data.get(#seatNumbers, or: $value.seatNumbers),
    coachNumber: data.get(#coachNumber, or: $value.coachNumber),
    classOfService: data.get(#classOfService, or: $value.classOfService),
    bookingDate: data.get(#bookingDate, or: $value.bookingDate),
    amount: data.get(#amount, or: $value.amount),
    currency: data.get(#currency, or: $value.currency),
    status: data.get(#status, or: $value.status),
    boardingPoint: data.get(#boardingPoint, or: $value.boardingPoint),
    pickupLocation: data.get(#pickupLocation, or: $value.pickupLocation),
    eventName: data.get(#eventName, or: $value.eventName),
    venueName: data.get(#venueName, or: $value.venueName),
    contactMobile: data.get(#contactMobile, or: $value.contactMobile),
    sourceType: data.get(#sourceType, or: $value.sourceType),
    rawData: data.get(#rawData, or: $value.rawData),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  TravelTicketModelCopyWith<$R2, TravelTicketModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TravelTicketModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

