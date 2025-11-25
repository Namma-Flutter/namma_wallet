import 'package:dart_mappable/dart_mappable.dart';

part 'extras_model.mapper.dart';

@MappableClass()
class ExtrasModel with ExtrasModelMappable {
  ExtrasModel({
    required this.value,
    this.child,
    this.title,
  });
  final String? title;
  final String value;
  final List<ExtrasModel>? child;
}
