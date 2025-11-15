// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'source_type.dart';

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

