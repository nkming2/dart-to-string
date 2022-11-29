import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:to_string/src/annotations.dart';

class ToStringGenerator extends GeneratorForAnnotation<ToString> {
  ToStringGenerator({
    this.configFormatStringNameMapping,
    this.configFormatStringUrlMapping,
  });

  @override
  dynamic generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      print("Not a class");
      return null;
    }
    final clazz = element;
    final fields = _getFields(clazz, annotation);
    final keys = fields.keys.toList();
    if (annotation.read("sortByName").boolValue) {
      keys.sort();
    }
    return """
extension _\$${clazz.name}ToString on ${clazz.name} {
  String _\$toString() {
    return "${clazz.name} {${keys.map((k) => "$k: ${fields[k]}").join(", ")}}";
  }
}
""";
  }

  Map<String, String> _getFields(
      ClassElement clazz, ConstantReader annotation) {
    final data = <String, String>{};
    if (clazz.supertype?.isDartCoreObject == false) {
      final parent = clazz.supertype!.element2;
      data.addAll(_getFields(parent as ClassElement, annotation));
    }
    for (final f in clazz.fields.where((f) =>
        !f.isStatic &&
        !TypeChecker.fromRuntime(Ignore).hasAnnotationOf(f) &&
        (!annotation.read("ignorePrivate").boolValue || !f.isPrivate))) {
      final String value;
      if (TypeChecker.fromRuntime(Format).hasAnnotationOf(f)) {
        final annotation =
            TypeChecker.fromRuntime(Format).annotationsOf(f).first;
        final formatString =
            annotation.getField("formatString")!.toStringValue()!;
        value = _applyFormatString(formatString, f);
      } else {
        final formatString = _getFieldFormatString(f);
        if (formatString != null) {
          value = _applyFormatString(formatString, f);
        } else {
          // ignore: prefer_interpolation_to_compose_strings
          value = r"$" + f.name;
        }
      }
      data[f.name] = value;
    }
    return data;
  }

  String? _getFieldFormatString(FieldElement field) {
    var formatString = configFormatStringUrlMapping?.entries
        .firstWhereOrNull(
            (e) => TypeChecker.fromUrl(e.key).isExactlyType(field.type))
        ?.value;
    if (formatString != null) {
      return formatString;
    }

    formatString = configFormatStringNameMapping?.entries
        .firstWhereOrNull((e) => field.type.element2!.name == e.key)
        ?.value;
    if (formatString != null) {
      return formatString;
    }

    return null;
  }

  String _applyFormatString(String format, FieldElement field) {
    return format.replaceAll("\$?", field.name);
  }

  final Map<String, String>? configFormatStringNameMapping;
  final Map<String, String>? configFormatStringUrlMapping;
}
