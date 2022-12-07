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
    final toString = ToString(
      ignorePrivate: annotation.read("ignorePrivate").boolValue,
      sortByName: annotation.read("sortByName").boolValue,
      ignoreNull: annotation.read("ignoreNull").boolValue,
    );
    final clazz = element;
    final fields = _getFields(clazz, toString);
    final keys = fields.keys.toList();
    if (toString.sortByName) {
      keys.sort();
    }
    return """
extension _\$${clazz.name}ToString on ${clazz.name} {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "${_buildIdentifier(clazz)} {${_buildbody(keys.map((k) => fields[k]!).toList(), toString)}}";
  }
}
""";
  }

  String _buildIdentifier(ClassElement clazz) {
    if (clazz.isAbstract) {
      return "\${objectRuntimeType(this, \"${clazz.name}\")}";
    } else {
      return clazz.name;
    }
  }

  String _buildbody(List<_FieldMeta> fields, ToString toString) {
    if (!toString.ignoreNull) {
      return fields
          .map((f) => "${f.name}: ${_applyFormatString(
                f,
                isIgnoreNull: toString.ignoreNull,
              )}")
          .join(", ");
    } else {
      return fields.map((f) {
        final stringify = _applyFormatString(
          f,
          isIgnoreNull: toString.ignoreNull,
        );
        if (f.isNullable) {
          return "\${${f.name} == null ? \"\" : \"${f.name}: $stringify, \"}";
        } else {
          return "${f.name}: $stringify, ";
        }
      }).join();
    }
  }

  Map<String, _FieldMeta> _getFields(ClassElement clazz, ToString toString) {
    final data = <String, _FieldMeta>{};
    if (clazz.supertype?.isDartCoreObject == false) {
      final parent = clazz.supertype!.element2;
      data.addAll(_getFields(parent as ClassElement, toString));
    }
    for (final f
        in clazz.fields.where((f) => _shouldIncludeField(f, toString))) {
      final meta = _FieldMetaBuilder(
        configFormatStringNameMapping: configFormatStringNameMapping,
        configFormatStringUrlMapping: configFormatStringUrlMapping,
        configUseEnumName: configUseEnumName,
      ).build(f);
      data[f.name] = meta;
    }
    return data;
  }

  bool _shouldIncludeField(FieldElement field, ToString toString) {
    if (field.isStatic) {
      // ignore static fields
      return false;
    }
    final ignore = _getIgnoreAnnotation(field);
    if (ignore != null) {
      // ignore fields annotated by [Ignore]
      return false;
    }
    if (toString.ignorePrivate && field.isPrivate) {
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

  /// Map a type by name to a format string. Since the types are mapped by name,
  /// this may confuse the generator if you have multiple classes having the
  /// same name. In that case you can use formatStringUrlMapping instead
  final Map<String, String>? configFormatStringNameMapping;

  /// Map a type by name to a format string. The types are mapped by their
  /// library url (e.g, dart:collection#HashMap)
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
    final format = _getFormatAnnotation(field);
    if (format != null) {
      // [Format] annotation takes priority over everything else
      _formatString = format.formatString;
    } else {
      final formatString = _getFieldFormatString(field);
      if (formatString != null) {
        _formatString = formatString;
      }
    }
  }

  String? _getFieldFormatString(FieldElement field) {
    var formatString =
        configFormatStringUrlMapping?.entries.firstWhereOrNull((e) {
      if (field.type.alias != null) {
        if (TypeChecker.fromUrl(e.key).isExactly(field.type.alias!.element)) {
          return true;
        }
      }
      if (field.type.element2 != null) {
        if (TypeChecker.fromUrl(e.key).isExactlyType(field.type)) {
          return true;
        }
      }
      return false;
    })?.value;
    if (formatString != null) {
      return formatString;
    }

    formatString =
        configFormatStringNameMapping?.entries.firstWhereOrNull((e) {
      if (field.type.alias != null) {
        if (field.type.alias!.element.name == e.key) {
          return true;
        }
      }
      if (field.type.element2 != null) {
        if (field.type.element2!.name == e.key) {
          return true;
        }
      } else {
        // unnamed function types will have .element as null
        if (field.type.toString() == e.key) {
          return true;
        }
      }
      return false;
    })?.value;
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

Ignore? _getIgnoreAnnotation(FieldElement field) {
  if (TypeChecker.fromRuntime(Ignore).hasAnnotationOf(field)) {
    return const Ignore();
  } else {
    return null;
  }
}

Format? _getFormatAnnotation(FieldElement field) {
  if (TypeChecker.fromRuntime(Format).hasAnnotationOf(field)) {
    final annotation =
        TypeChecker.fromRuntime(Format).annotationsOf(field).first;
    final formatString = annotation.getField("formatString")!.toStringValue()!;
    return Format(formatString);
  } else {
    return null;
  }
}
