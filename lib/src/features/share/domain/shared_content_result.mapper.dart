// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'shared_content_result.dart';

class SharedContentResultMapper extends ClassMapperBase<SharedContentResult> {
  SharedContentResultMapper._();

  static SharedContentResultMapper? _instance;
  static SharedContentResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SharedContentResultMapper._());
      TicketCreatedResultMapper.ensureInitialized();
      TicketUpdatedResultMapper.ensureInitialized();
      ProcessingErrorResultMapper.ensureInitialized();
      TicketNotFoundResultMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SharedContentResult';

  @override
  final MappableFields<SharedContentResult> fields = const {};

  static SharedContentResult _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('SharedContentResult');
  }

  @override
  final Function instantiate = _instantiate;

  static SharedContentResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SharedContentResult>(map);
  }

  static SharedContentResult fromJson(String json) {
    return ensureInitialized().decodeJson<SharedContentResult>(json);
  }
}

mixin SharedContentResultMappable {
  String toJson();
  Map<String, dynamic> toMap();
  SharedContentResultCopyWith<
    SharedContentResult,
    SharedContentResult,
    SharedContentResult
  >
  get copyWith;
}

abstract class SharedContentResultCopyWith<
  $R,
  $In extends SharedContentResult,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  SharedContentResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class TicketCreatedResultMapper extends ClassMapperBase<TicketCreatedResult> {
  TicketCreatedResultMapper._();

  static TicketCreatedResultMapper? _instance;
  static TicketCreatedResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketCreatedResultMapper._());
      SharedContentResultMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TicketCreatedResult';

  static String _$pnrNumber(TicketCreatedResult v) => v.pnrNumber;
  static const Field<TicketCreatedResult, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
  );
  static String _$from(TicketCreatedResult v) => v.from;
  static const Field<TicketCreatedResult, String> _f$from = Field(
    'from',
    _$from,
  );
  static String _$to(TicketCreatedResult v) => v.to;
  static const Field<TicketCreatedResult, String> _f$to = Field('to', _$to);
  static String _$fare(TicketCreatedResult v) => v.fare;
  static const Field<TicketCreatedResult, String> _f$fare = Field(
    'fare',
    _$fare,
  );
  static String _$date(TicketCreatedResult v) => v.date;
  static const Field<TicketCreatedResult, String> _f$date = Field(
    'date',
    _$date,
  );

  @override
  final MappableFields<TicketCreatedResult> fields = const {
    #pnrNumber: _f$pnrNumber,
    #from: _f$from,
    #to: _f$to,
    #fare: _f$fare,
    #date: _f$date,
  };

  static TicketCreatedResult _instantiate(DecodingData data) {
    return TicketCreatedResult(
      pnrNumber: data.dec(_f$pnrNumber),
      from: data.dec(_f$from),
      to: data.dec(_f$to),
      fare: data.dec(_f$fare),
      date: data.dec(_f$date),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TicketCreatedResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TicketCreatedResult>(map);
  }

  static TicketCreatedResult fromJson(String json) {
    return ensureInitialized().decodeJson<TicketCreatedResult>(json);
  }
}

mixin TicketCreatedResultMappable {
  String toJson() {
    return TicketCreatedResultMapper.ensureInitialized()
        .encodeJson<TicketCreatedResult>(this as TicketCreatedResult);
  }

  Map<String, dynamic> toMap() {
    return TicketCreatedResultMapper.ensureInitialized()
        .encodeMap<TicketCreatedResult>(this as TicketCreatedResult);
  }

  TicketCreatedResultCopyWith<
    TicketCreatedResult,
    TicketCreatedResult,
    TicketCreatedResult
  >
  get copyWith =>
      _TicketCreatedResultCopyWithImpl<
        TicketCreatedResult,
        TicketCreatedResult
      >(this as TicketCreatedResult, $identity, $identity);
  @override
  String toString() {
    return TicketCreatedResultMapper.ensureInitialized().stringifyValue(
      this as TicketCreatedResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return TicketCreatedResultMapper.ensureInitialized().equalsValue(
      this as TicketCreatedResult,
      other,
    );
  }

  @override
  int get hashCode {
    return TicketCreatedResultMapper.ensureInitialized().hashValue(
      this as TicketCreatedResult,
    );
  }
}

extension TicketCreatedResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TicketCreatedResult, $Out> {
  TicketCreatedResultCopyWith<$R, TicketCreatedResult, $Out>
  get $asTicketCreatedResult => $base.as(
    (v, t, t2) => _TicketCreatedResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TicketCreatedResultCopyWith<
  $R,
  $In extends TicketCreatedResult,
  $Out
>
    implements SharedContentResultCopyWith<$R, $In, $Out> {
  @override
  $R call({
    String? pnrNumber,
    String? from,
    String? to,
    String? fare,
    String? date,
  });
  TicketCreatedResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TicketCreatedResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TicketCreatedResult, $Out>
    implements TicketCreatedResultCopyWith<$R, TicketCreatedResult, $Out> {
  _TicketCreatedResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TicketCreatedResult> $mapper =
      TicketCreatedResultMapper.ensureInitialized();
  @override
  $R call({
    String? pnrNumber,
    String? from,
    String? to,
    String? fare,
    String? date,
  }) => $apply(
    FieldCopyWithData({
      if (pnrNumber != null) #pnrNumber: pnrNumber,
      if (from != null) #from: from,
      if (to != null) #to: to,
      if (fare != null) #fare: fare,
      if (date != null) #date: date,
    }),
  );
  @override
  TicketCreatedResult $make(CopyWithData data) => TicketCreatedResult(
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
    from: data.get(#from, or: $value.from),
    to: data.get(#to, or: $value.to),
    fare: data.get(#fare, or: $value.fare),
    date: data.get(#date, or: $value.date),
  );

  @override
  TicketCreatedResultCopyWith<$R2, TicketCreatedResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TicketCreatedResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TicketUpdatedResultMapper extends ClassMapperBase<TicketUpdatedResult> {
  TicketUpdatedResultMapper._();

  static TicketUpdatedResultMapper? _instance;
  static TicketUpdatedResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketUpdatedResultMapper._());
      SharedContentResultMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TicketUpdatedResult';

  static String _$pnrNumber(TicketUpdatedResult v) => v.pnrNumber;
  static const Field<TicketUpdatedResult, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
  );
  static String _$updateType(TicketUpdatedResult v) => v.updateType;
  static const Field<TicketUpdatedResult, String> _f$updateType = Field(
    'updateType',
    _$updateType,
  );

  @override
  final MappableFields<TicketUpdatedResult> fields = const {
    #pnrNumber: _f$pnrNumber,
    #updateType: _f$updateType,
  };

  static TicketUpdatedResult _instantiate(DecodingData data) {
    return TicketUpdatedResult(
      pnrNumber: data.dec(_f$pnrNumber),
      updateType: data.dec(_f$updateType),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TicketUpdatedResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TicketUpdatedResult>(map);
  }

  static TicketUpdatedResult fromJson(String json) {
    return ensureInitialized().decodeJson<TicketUpdatedResult>(json);
  }
}

mixin TicketUpdatedResultMappable {
  String toJson() {
    return TicketUpdatedResultMapper.ensureInitialized()
        .encodeJson<TicketUpdatedResult>(this as TicketUpdatedResult);
  }

  Map<String, dynamic> toMap() {
    return TicketUpdatedResultMapper.ensureInitialized()
        .encodeMap<TicketUpdatedResult>(this as TicketUpdatedResult);
  }

  TicketUpdatedResultCopyWith<
    TicketUpdatedResult,
    TicketUpdatedResult,
    TicketUpdatedResult
  >
  get copyWith =>
      _TicketUpdatedResultCopyWithImpl<
        TicketUpdatedResult,
        TicketUpdatedResult
      >(this as TicketUpdatedResult, $identity, $identity);
  @override
  String toString() {
    return TicketUpdatedResultMapper.ensureInitialized().stringifyValue(
      this as TicketUpdatedResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return TicketUpdatedResultMapper.ensureInitialized().equalsValue(
      this as TicketUpdatedResult,
      other,
    );
  }

  @override
  int get hashCode {
    return TicketUpdatedResultMapper.ensureInitialized().hashValue(
      this as TicketUpdatedResult,
    );
  }
}

extension TicketUpdatedResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TicketUpdatedResult, $Out> {
  TicketUpdatedResultCopyWith<$R, TicketUpdatedResult, $Out>
  get $asTicketUpdatedResult => $base.as(
    (v, t, t2) => _TicketUpdatedResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TicketUpdatedResultCopyWith<
  $R,
  $In extends TicketUpdatedResult,
  $Out
>
    implements SharedContentResultCopyWith<$R, $In, $Out> {
  @override
  $R call({String? pnrNumber, String? updateType});
  TicketUpdatedResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TicketUpdatedResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TicketUpdatedResult, $Out>
    implements TicketUpdatedResultCopyWith<$R, TicketUpdatedResult, $Out> {
  _TicketUpdatedResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TicketUpdatedResult> $mapper =
      TicketUpdatedResultMapper.ensureInitialized();
  @override
  $R call({String? pnrNumber, String? updateType}) => $apply(
    FieldCopyWithData({
      if (pnrNumber != null) #pnrNumber: pnrNumber,
      if (updateType != null) #updateType: updateType,
    }),
  );
  @override
  TicketUpdatedResult $make(CopyWithData data) => TicketUpdatedResult(
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
    updateType: data.get(#updateType, or: $value.updateType),
  );

  @override
  TicketUpdatedResultCopyWith<$R2, TicketUpdatedResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TicketUpdatedResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ProcessingErrorResultMapper
    extends ClassMapperBase<ProcessingErrorResult> {
  ProcessingErrorResultMapper._();

  static ProcessingErrorResultMapper? _instance;
  static ProcessingErrorResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProcessingErrorResultMapper._());
      SharedContentResultMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProcessingErrorResult';

  static String _$message(ProcessingErrorResult v) => v.message;
  static const Field<ProcessingErrorResult, String> _f$message = Field(
    'message',
    _$message,
  );
  static String _$error(ProcessingErrorResult v) => v.error;
  static const Field<ProcessingErrorResult, String> _f$error = Field(
    'error',
    _$error,
  );

  @override
  final MappableFields<ProcessingErrorResult> fields = const {
    #message: _f$message,
    #error: _f$error,
  };

  static ProcessingErrorResult _instantiate(DecodingData data) {
    return ProcessingErrorResult(
      message: data.dec(_f$message),
      error: data.dec(_f$error),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProcessingErrorResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProcessingErrorResult>(map);
  }

  static ProcessingErrorResult fromJson(String json) {
    return ensureInitialized().decodeJson<ProcessingErrorResult>(json);
  }
}

mixin ProcessingErrorResultMappable {
  String toJson() {
    return ProcessingErrorResultMapper.ensureInitialized()
        .encodeJson<ProcessingErrorResult>(this as ProcessingErrorResult);
  }

  Map<String, dynamic> toMap() {
    return ProcessingErrorResultMapper.ensureInitialized()
        .encodeMap<ProcessingErrorResult>(this as ProcessingErrorResult);
  }

  ProcessingErrorResultCopyWith<
    ProcessingErrorResult,
    ProcessingErrorResult,
    ProcessingErrorResult
  >
  get copyWith =>
      _ProcessingErrorResultCopyWithImpl<
        ProcessingErrorResult,
        ProcessingErrorResult
      >(this as ProcessingErrorResult, $identity, $identity);
  @override
  String toString() {
    return ProcessingErrorResultMapper.ensureInitialized().stringifyValue(
      this as ProcessingErrorResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProcessingErrorResultMapper.ensureInitialized().equalsValue(
      this as ProcessingErrorResult,
      other,
    );
  }

  @override
  int get hashCode {
    return ProcessingErrorResultMapper.ensureInitialized().hashValue(
      this as ProcessingErrorResult,
    );
  }
}

extension ProcessingErrorResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProcessingErrorResult, $Out> {
  ProcessingErrorResultCopyWith<$R, ProcessingErrorResult, $Out>
  get $asProcessingErrorResult => $base.as(
    (v, t, t2) => _ProcessingErrorResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ProcessingErrorResultCopyWith<
  $R,
  $In extends ProcessingErrorResult,
  $Out
>
    implements SharedContentResultCopyWith<$R, $In, $Out> {
  @override
  $R call({String? message, String? error});
  ProcessingErrorResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProcessingErrorResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProcessingErrorResult, $Out>
    implements ProcessingErrorResultCopyWith<$R, ProcessingErrorResult, $Out> {
  _ProcessingErrorResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProcessingErrorResult> $mapper =
      ProcessingErrorResultMapper.ensureInitialized();
  @override
  $R call({String? message, String? error}) => $apply(
    FieldCopyWithData({
      if (message != null) #message: message,
      if (error != null) #error: error,
    }),
  );
  @override
  ProcessingErrorResult $make(CopyWithData data) => ProcessingErrorResult(
    message: data.get(#message, or: $value.message),
    error: data.get(#error, or: $value.error),
  );

  @override
  ProcessingErrorResultCopyWith<$R2, ProcessingErrorResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProcessingErrorResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TicketNotFoundResultMapper extends ClassMapperBase<TicketNotFoundResult> {
  TicketNotFoundResultMapper._();

  static TicketNotFoundResultMapper? _instance;
  static TicketNotFoundResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TicketNotFoundResultMapper._());
      SharedContentResultMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TicketNotFoundResult';

  static String _$pnrNumber(TicketNotFoundResult v) => v.pnrNumber;
  static const Field<TicketNotFoundResult, String> _f$pnrNumber = Field(
    'pnrNumber',
    _$pnrNumber,
  );

  @override
  final MappableFields<TicketNotFoundResult> fields = const {
    #pnrNumber: _f$pnrNumber,
  };

  static TicketNotFoundResult _instantiate(DecodingData data) {
    return TicketNotFoundResult(pnrNumber: data.dec(_f$pnrNumber));
  }

  @override
  final Function instantiate = _instantiate;

  static TicketNotFoundResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TicketNotFoundResult>(map);
  }

  static TicketNotFoundResult fromJson(String json) {
    return ensureInitialized().decodeJson<TicketNotFoundResult>(json);
  }
}

mixin TicketNotFoundResultMappable {
  String toJson() {
    return TicketNotFoundResultMapper.ensureInitialized()
        .encodeJson<TicketNotFoundResult>(this as TicketNotFoundResult);
  }

  Map<String, dynamic> toMap() {
    return TicketNotFoundResultMapper.ensureInitialized()
        .encodeMap<TicketNotFoundResult>(this as TicketNotFoundResult);
  }

  TicketNotFoundResultCopyWith<
    TicketNotFoundResult,
    TicketNotFoundResult,
    TicketNotFoundResult
  >
  get copyWith =>
      _TicketNotFoundResultCopyWithImpl<
        TicketNotFoundResult,
        TicketNotFoundResult
      >(this as TicketNotFoundResult, $identity, $identity);
  @override
  String toString() {
    return TicketNotFoundResultMapper.ensureInitialized().stringifyValue(
      this as TicketNotFoundResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return TicketNotFoundResultMapper.ensureInitialized().equalsValue(
      this as TicketNotFoundResult,
      other,
    );
  }

  @override
  int get hashCode {
    return TicketNotFoundResultMapper.ensureInitialized().hashValue(
      this as TicketNotFoundResult,
    );
  }
}

extension TicketNotFoundResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TicketNotFoundResult, $Out> {
  TicketNotFoundResultCopyWith<$R, TicketNotFoundResult, $Out>
  get $asTicketNotFoundResult => $base.as(
    (v, t, t2) => _TicketNotFoundResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TicketNotFoundResultCopyWith<
  $R,
  $In extends TicketNotFoundResult,
  $Out
>
    implements SharedContentResultCopyWith<$R, $In, $Out> {
  @override
  $R call({String? pnrNumber});
  TicketNotFoundResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TicketNotFoundResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TicketNotFoundResult, $Out>
    implements TicketNotFoundResultCopyWith<$R, TicketNotFoundResult, $Out> {
  _TicketNotFoundResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TicketNotFoundResult> $mapper =
      TicketNotFoundResultMapper.ensureInitialized();
  @override
  $R call({String? pnrNumber}) =>
      $apply(FieldCopyWithData({if (pnrNumber != null) #pnrNumber: pnrNumber}));
  @override
  TicketNotFoundResult $make(CopyWithData data) => TicketNotFoundResult(
    pnrNumber: data.get(#pnrNumber, or: $value.pnrNumber),
  );

  @override
  TicketNotFoundResultCopyWith<$R2, TicketNotFoundResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TicketNotFoundResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

