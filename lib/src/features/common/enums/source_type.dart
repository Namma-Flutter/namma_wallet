import 'package:dart_mappable/dart_mappable.dart';

part 'source_type.mapper.dart';

@MappableEnum()
enum SourceType {
  @MappableValue('SMS')
  sms,
  @MappableValue('PDF')
  pdf,
  @MappableValue('MANUAL')
  manual,
  @MappableValue('CLIPBOARD')
  clipboard,
  @MappableValue('QR')
  qr,
  @MappableValue('SCANNER')
  scanner,
}
