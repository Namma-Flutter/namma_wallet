import 'package:dart_mappable/dart_mappable.dart';

part 'ticket_type.mapper.dart';

@MappableEnum()
enum TicketType {
  @MappableValue('BUS')
  bus,
  @MappableValue('TRAIN')
  train,
  @MappableValue('EVENT')
  event,
  @MappableValue('FLIGHT')
  flight,
  @MappableValue('METRO')
  metro,
}
