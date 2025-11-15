// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ticket_status.dart';

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

