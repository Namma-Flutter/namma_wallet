// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ocr_block.dart';

class OCRBlockMapper extends ClassMapperBase<OCRBlock> {
  OCRBlockMapper._();

  static OCRBlockMapper? _instance;
  static OCRBlockMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OCRBlockMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OCRBlock';

  static String _$text(OCRBlock v) => v.text;
  static const Field<OCRBlock, String> _f$text = Field('text', _$text);
  static Rect _$boundingBox(OCRBlock v) => v.boundingBox;
  static const Field<OCRBlock, Rect> _f$boundingBox = Field(
    'boundingBox',
    _$boundingBox,
  );
  static int _$page(OCRBlock v) => v.page;
  static const Field<OCRBlock, int> _f$page = Field('page', _$page);
  static double? _$confidence(OCRBlock v) => v.confidence;
  static const Field<OCRBlock, double> _f$confidence = Field(
    'confidence',
    _$confidence,
    opt: true,
  );

  @override
  final MappableFields<OCRBlock> fields = const {
    #text: _f$text,
    #boundingBox: _f$boundingBox,
    #page: _f$page,
    #confidence: _f$confidence,
  };

  static OCRBlock _instantiate(DecodingData data) {
    return OCRBlock(
      text: data.dec(_f$text),
      boundingBox: data.dec(_f$boundingBox),
      page: data.dec(_f$page),
      confidence: data.dec(_f$confidence),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OCRBlock fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OCRBlock>(map);
  }

  static OCRBlock fromJson(String json) {
    return ensureInitialized().decodeJson<OCRBlock>(json);
  }
}

mixin OCRBlockMappable {
  String toJson() {
    return OCRBlockMapper.ensureInitialized().encodeJson<OCRBlock>(
      this as OCRBlock,
    );
  }

  Map<String, dynamic> toMap() {
    return OCRBlockMapper.ensureInitialized().encodeMap<OCRBlock>(
      this as OCRBlock,
    );
  }

  OCRBlockCopyWith<OCRBlock, OCRBlock, OCRBlock> get copyWith =>
      _OCRBlockCopyWithImpl<OCRBlock, OCRBlock>(
        this as OCRBlock,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OCRBlockMapper.ensureInitialized().stringifyValue(this as OCRBlock);
  }

  @override
  bool operator ==(Object other) {
    return OCRBlockMapper.ensureInitialized().equalsValue(
      this as OCRBlock,
      other,
    );
  }

  @override
  int get hashCode {
    return OCRBlockMapper.ensureInitialized().hashValue(this as OCRBlock);
  }
}

extension OCRBlockValueCopy<$R, $Out> on ObjectCopyWith<$R, OCRBlock, $Out> {
  OCRBlockCopyWith<$R, OCRBlock, $Out> get $asOCRBlock =>
      $base.as((v, t, t2) => _OCRBlockCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OCRBlockCopyWith<$R, $In extends OCRBlock, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? text, Rect? boundingBox, int? page, double? confidence});
  OCRBlockCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OCRBlockCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OCRBlock, $Out>
    implements OCRBlockCopyWith<$R, OCRBlock, $Out> {
  _OCRBlockCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OCRBlock> $mapper =
      OCRBlockMapper.ensureInitialized();
  @override
  $R call({
    String? text,
    Rect? boundingBox,
    int? page,
    Object? confidence = $none,
  }) => $apply(
    FieldCopyWithData({
      if (text != null) #text: text,
      if (boundingBox != null) #boundingBox: boundingBox,
      if (page != null) #page: page,
      if (confidence != $none) #confidence: confidence,
    }),
  );
  @override
  OCRBlock $make(CopyWithData data) => OCRBlock(
    text: data.get(#text, or: $value.text),
    boundingBox: data.get(#boundingBox, or: $value.boundingBox),
    page: data.get(#page, or: $value.page),
    confidence: data.get(#confidence, or: $value.confidence),
  );

  @override
  OCRBlockCopyWith<$R2, OCRBlock, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OCRBlockCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

