import 'package:dart_mappable/dart_mappable.dart';

part 'ticket_status.mapper.dart';
@MappableEnum()
enum TicketStatus {
  @MappableValue('CONFIRMED')
  confirmed,
  @MappableValue('CANCELLED')
  cancelled,
  @MappableValue('PENDING')
  pending,
  @MappableValue('COMPLETED')
  completed,
}