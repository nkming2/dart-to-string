import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:to_string/src/annotations.dart';

class ToStringGenerator extends GeneratorForAnnotation<ToString> {
  const ToStringGenerator({
    this.configFormatStringNameMapping,
    this.configFormatStringUrlMapping,
    this.configUseEnumName,
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
    // ignore: unnecessary_string_interpolations
    return "${clazz.name} {${_buildbody(keys.map((k) => fields[k]!).toList(), annotation)}}";
  }
}
""";
  }

  String _buildbody(List<_FieldMeta> fields, ConstantReader annotation) {
    final isIgnoreNull = annotation.read("ignoreNull").boolValue;
    if (!isIgnoreNull) {
      return fields
          .map((f) =>
              "${f.name}: ${_applyFormatString(f, isIgnoreNull: isIgnoreNull)}")
          .join(", ");
    } else {
      return fields.map((f) {
        final stringify = _applyFormatString(f, isIgnoreNull: isIgnoreNull);
        if (f.isNullable) {
          return "\${${f.name} == null ? \"\" : \"${f.name}: $stringify, \"}";
        } else {
          return "${f.name}: $stringify, ";
        }
      }).join();
    }
  }

  Map<String, _FieldMeta> _getFields(
      ClassElement clazz, ConstantReader annotation) {
    final data = <String, _FieldMeta>{};
    if (clazz.supertype?.isDartCoreObject == false) {
      final parent = clazz.supertype!.element2;
      data.addAll(_getFields(parent as ClassElement, annotation));
    }
    for (final f
        in clazz.fields.where((f) => _shouldIncludeField(f, annotation))) {
      final meta = _FieldMetaBuilder(
        configFormatStringNameMapping: configFormatStringNameMapping,
        configFormatStringUrlMapping: configFormatStringUrlMapping,
        configUseEnumName: configUseEnumName,
      ).build(f);
      data[f.name] = meta;
    }
    return data;
  }

  bool _shouldIncludeField(FieldElement field, ConstantReader annotation) {
    if (field.isStatic) {
      // ignore static fields
      return false;
    }
    if (TypeChecker.fromRuntime(Ignore).hasAnnotationOf(field)) {
      // ignore fields annotated by [Ignore]
      return false;
    }
    if (annotation.read("ignorePrivate").boolValue && field.isPrivate) {
      // ignore private fields if so configured
      return false;
    }
    if (field.isSynthetic) {
      // skip getters
      return false;
    }
    return true;
  }

  String _applyFormatString(
    _FieldMeta meta, {
    required bool isIgnoreNull,
  }) {
    if (meta.formatString == null) {
      return r"$" + meta.name;
    } else {
      if (meta.isNullable) {
        final formatted = meta.formatString!.replaceAll("\$?", "${meta.name}!");
        if (isIgnoreNull) {
          // if isIgnoreNull == true, the null check is done with the key not
          // only the value
          return formatted;
        } else {
          return "\${${meta.name} == null ? null : \"$formatted\"}";
        }
      } else {
        return meta.formatString!.replaceAll("\$?", meta.name);
      }
    }
  }

  final Map<String, String>? configFormatStringNameMapping;
  final Map<String, String>? configFormatStringUrlMapping;

  /// If true, use the .name property when printing an enum
  final bool? configUseEnumName;
}

class _FieldMeta {
  const _FieldMeta({
    required this.name,
    required this.isNullable,
    this.formatString,
  });

  final String name;
  final bool isNullable;
  final String? formatString;
}

class _FieldMetaBuilder {
  _FieldMetaBuilder({
    this.configFormatStringNameMapping,
    this.configFormatStringUrlMapping,
    this.configUseEnumName,
  });

  _FieldMeta build(FieldElement field) {
    _parseNullable(field);
    _parseFormatString(field);
    return _FieldMeta(
      name: field.name,
      isNullable: _isNullable,
      formatString: _formatString,
    );
  }

  void _parseNullable(FieldElement field) {
    _isNullable = field.type.nullabilitySuffix == NullabilitySuffix.question;
  }

  void _parseFormatString(FieldElement field) {
    if (TypeChecker.fromRuntime(Format).hasAnnotationOf(field)) {
      final annotation =
          TypeChecker.fromRuntime(Format).annotationsOf(field).first;
      final formatString =
          annotation.getField("formatString")!.toStringValue()!;
      _formatString = formatString;
    } else {
      final formatString = _getFieldFormatString(field);
      if (formatString != null) {
        _formatString = formatString;
      }
    }
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

    if (configUseEnumName == true && field.type.element2 is EnumElement) {
      return r"${$?.name}";
    }

    return null;
  }

  final Map<String, String>? configFormatStringNameMapping;
  final Map<String, String>? configFormatStringUrlMapping;
  final bool? configUseEnumName;

  late bool _isNullable;
  String? _formatString;
}
