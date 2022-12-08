import 'package:source_gen/source_gen.dart';

extension ConstantReaderExtension on ConstantReader {
  String? get stringValueOrNull => isNull ? null : stringValue;
}
