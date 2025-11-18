// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ticket_type.dart';

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

