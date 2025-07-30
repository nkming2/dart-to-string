import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:to_string_build/src/generator.dart';

void main() async {
  await _resolveCompilationUnit("test/src/to_string.dart");
  tearDown(() {
    // Increment this after each test so the next test has it's own package
    _pkgCacheCount++;
  });

  group("ToString", () {
    test("empty", () async {
      final src = _genSrc(r"""
@toString
class Empty {}
""");
      final expected = _genExpected(r"""
extension _$EmptyToString on Empty {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "Empty {}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("signel field", () async {
      final src = _genSrc(r"""
@toString
class SingleField {
  final abc = 1;
}
""");
      final expected = _genExpected(r"""
extension _$SingleFieldToString on SingleField {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "SingleField {abc: $abc}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("multiple fields", () async {
      final src = _genSrc(r"""
@toString
class MultipleField {
  final abc = 1;
  final def = 1;
  final geh = 1;
}
""");
      final expected = _genExpected(r"""
extension _$MultipleFieldToString on MultipleField {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "MultipleField {abc: $abc, def: $def, geh: $geh}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("derived class", () async {
      final src = _genSrc(r"""
class BaseClass {
  final abc = 1;
}

@toString
class DerivedClass extends BaseClass {
  final def = 1;
}
""");
      final expected = _genExpected(r"""
extension _$DerivedClassToString on DerivedClass {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "DerivedClass {abc: $abc, def: $def}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("static field", () async {
      final src = _genSrc(r"""
@toString
class StaticField {
  final abc = 1;
  static final def = 1;
}
""");
      final expected = _genExpected(r"""
extension _$StaticFieldToString on StaticField {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "StaticField {abc: $abc}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("ignore field", () async {
      final src = _genSrc(r"""
@toString
class IgnoreField {
  @ignore
  final abc = 1;
  final def = 1;
}
""");
      final expected = _genExpected(r"""
extension _$IgnoreFieldToString on IgnoreField {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "IgnoreField {def: $def}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("private field", () async {
      final src = _genSrc(r"""
@toString
class PrivateField {
  final abc = 1;
  final _def = 1;
}
""");
      final expected = _genExpected(r"""
extension _$PrivateFieldToString on PrivateField {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "PrivateField {abc: $abc, _def: $_def}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("private field (ignorePrivate=true)", () async {
      final src = _genSrc(r"""
@ToString(ignorePrivate: true)
class IgnorePrivateField {
  final _abc = 1;
  final def = 1;
}
""");
      final expected = _genExpected(r"""
extension _$IgnorePrivateFieldToString on IgnorePrivateField {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "IgnorePrivateField {def: $def}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("sort by name (sortByName=true)", () async {
      final src = _genSrc(r"""
@ToString(sortByName: true)
class SortByName {
  final def = 1;
  final abc = 1;
}
""");
      final expected = _genExpected(r"""
extension _$SortByNameToString on SortByName {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "SortByName {abc: $abc, def: $def}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("sort by declaration (sortByName=false)", () async {
      final src = _genSrc(r"""
@ToString(sortByName: false)
class SortByDeclaration {
  final def = 1;
  final abc = 1;
}
""");
      final expected = _genExpected(r"""
extension _$SortByDeclarationToString on SortByDeclaration {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "SortByDeclaration {def: $def, abc: $abc}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("empty parent non-empty grandparent", () async {
      final src = _genSrc(r"""
class Grandparent {
  final abc = 1;
}

class EmptyParent extends Grandparent {}

@toString
class Grandchild extends EmptyParent {
  final def = 1;
}
""");
      final expected = _genExpected(r"""
extension _$GrandchildToString on Grandchild {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "Grandchild {abc: $abc, def: $def}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("format string", () async {
      final src = _genSrc(r"""
@toString
class FormatDouble {
  @Format(r"${$?.toStringAsFixed(1)}")
  final double abc = 1.23456789;
}
""");
      final expected = _genExpected(r"""
extension _$FormatDoubleToString on FormatDouble {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatDouble {abc: ${abc.toStringAsFixed(1)}}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("getter", () async {
      final src = _genSrc(r"""
@toString
class Getter {
  final abc = 1;
  int get def => 1;
}
""");
      final expected = _genExpected(r"""
extension _$GetterToString on Getter {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "Getter {abc: $abc}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("ignore null", () async {
      final src = _genSrc(r"""
@ToString(ignoreNull: true)
class IgnoreNull {
  final abc = 1;
  final int? def = null;
}
""");
      final expected = _genExpected(r"""
extension _$IgnoreNullToString on IgnoreNull {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "IgnoreNull {abc: $abc, ${def == null ? "" : "def: $def"}}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("abstract class", () async {
      final src = _genSrc(r"""
@toString
abstract class AbstractClass {
  final abc = 1;
}
""");
      final expected = _genExpected(r"""
extension _$AbstractClassToString on AbstractClass {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "${objectRuntimeType(this, "AbstractClass")} {abc: $abc}";
  }
}
""");
      return _buildTest(src, expected);
    });

    test("extra params", () async {
      final src = _genSrc(r"""
@ToString(extraParams: r"{bool print = true}")
class ExtraParams {
  @Format(r"${print ? abc : ''}")
  final abc = 1;
}
""");
      final expected = _genExpected(r"""
extension _$ExtraParamsToString on ExtraParams {
  String _$toString({bool print = true}) {
    // ignore: unnecessary_string_interpolations
    return "ExtraParams {abc: ${print ? abc : ''}}";
  }
}
""");
      return _buildTest(src, expected);
    });

    group("yaml options", () {
      group("name mapping", () {
        test("basic", () async {
          final src = _genSrc(r"""
@toString
class FormatYaml {
  final abc = <int>[];
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlToString on FormatYaml {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYaml {abc: ${abc.first}}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringNameMapping: {"List": r"${$?.first}"},
          );
        });

        test("nullable", () async {
          final src = _genSrc(r"""
@toString
class FormatYamlNull {
  final List<int>? abc = null;
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlNullToString on FormatYamlNull {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlNull {abc: ${abc == null ? null : "${abc!.first}"}}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringNameMapping: {"List": r"${$?.first}"},
          );
        });

        test("unnamed function type", () async {
          final src = _genSrc(r"""
@toString
class FormatYamlUnnamedFunction {
  void Function(int abc) abc = (_) {};
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlUnnamedFunctionToString on FormatYamlUnnamedFunction {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlUnnamedFunction {abc: function}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringNameMapping: {"void Function(int)": r"function"},
          );
        });

        test("function alias", () async {
          final src = _genSrc(
            r"""
@toString
class FormatYamlFunctionAlias {
  VoidCallback abc = () {};
}
""",
            extraImports: ["dart:ui"],
          );
          final expected = _genExpected(r"""
extension _$FormatYamlFunctionAliasToString on FormatYamlFunctionAlias {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlFunctionAlias {abc: callback}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringNameMapping: {"VoidCallback": r"callback"},
          );
        });

        test("alias", () async {
          final src = _genSrc(r"""
typedef MyType = double;
@toString
class FormatYamlAlias {
  MyType abc = 1;
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlAliasToString on FormatYamlAlias {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlAlias {abc: mytype}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringNameMapping: {"MyType": r"mytype"},
          );
        });

        test("alias (original type)", () async {
          final src = _genSrc(r"""
typedef MyType = double;
@toString
class FormatYamlAlias {
  MyType abc = 1;
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlAliasToString on FormatYamlAlias {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlAlias {abc: double}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringNameMapping: {"double": r"double"},
          );
        });
      });

      group("url mapping", () {
        test("basic", () async {
          final src = _genSrc(r"""
@toString
class FormatYaml {
  final abc = <int>[];
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlToString on FormatYaml {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYaml {abc: ${abc.first}}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringUrlMapping: {"dart:core#List": r"${$?.first}"},
          );
        });

        test("nullable", () async {
          final src = _genSrc(r"""
@toString
class FormatYamlNull {
  final List<int>? abc = null;
}
""");
          final expected = _genExpected(r"""
extension _$FormatYamlNullToString on FormatYamlNull {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlNull {abc: ${abc == null ? null : "${abc!.first}"}}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringUrlMapping: {"dart:core#List": r"${$?.first}"},
          );
        });

        test("function alias", () async {
          final src = _genSrc(
            r"""
@toString
class FormatYamlFunctionAlias {
  VoidCallback abc = () {};
}
""",
            extraImports: ["dart:ui"],
          );
          final expected = _genExpected(r"""
extension _$FormatYamlFunctionAliasToString on FormatYamlFunctionAlias {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlFunctionAlias {abc: callback}";
  }
}
""");
          return _buildTest(
            src,
            expected,
            configFormatStringUrlMapping: {"dart:ui#VoidCallback": r"callback"},
          );
        });
      });

      test("enum name (true)", () async {
        final src = _genSrc(r"""
enum MyEnum { abc, def }
@toString
class FormatYamlEnumName {
  final abc = MyEnum.abc;
}
""");
        final expected = _genExpected(r"""
extension _$FormatYamlEnumNameToString on FormatYamlEnumName {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlEnumName {abc: ${abc.name}}";
  }
}
""");
        return _buildTest(src, expected, configUseEnumName: true);
      });

      test("enum name (false)", () async {
        final src = _genSrc(r"""
enum MyEnum { abc, def }
@toString
class FormatYamlEnumName {
  final abc = MyEnum.abc;
}
""");
        final expected = _genExpected(r"""
extension _$FormatYamlEnumNameToString on FormatYamlEnumName {
  String _$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlEnumName {abc: $abc}";
  }
}
""");
        return _buildTest(src, expected, configUseEnumName: false);
      });
    });
  });
}

String _genSrc(String src, {List<String> extraImports = const []}) {
  return """
import 'package:to_string/to_string.dart';
${extraImports.map((e) => "import '$e';").join("\n")}
part 'test.g.dart';
$src
""";
}

String _genExpected(String src) {
  return """// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// ToStringGenerator
// **************************************************************************

$src""";
}

Future _buildTest(
  String src,
  String expected, {
  Map<String, String>? configFormatStringNameMapping,
  Map<String, String>? configFormatStringUrlMapping,
  bool? configUseEnumName,
}) {
  return testBuilder(
    PartBuilder([
      ToStringGenerator(
        configFormatStringNameMapping: configFormatStringNameMapping,
        configFormatStringUrlMapping: configFormatStringUrlMapping,
        configUseEnumName: configUseEnumName,
      ),
    ], ".g.dart"),
    {"$_pkgName|lib/test.dart": src},
    generateFor: {'$_pkgName|lib/test.dart'},
    outputs: {"$_pkgName|lib/test.g.dart": decodedMatches(expected)},
  );
}

// Taken from source_gen_test, unclear why this is needed...
Future<void> _resolveCompilationUnit(String filePath) async {
  final assetId = AssetId.parse('a|lib/${p.basename(filePath)}');
  final files =
      Directory(p.dirname(filePath)).listSync().whereType<File>().toList();

  final fileMap = Map<String, String>.fromEntries(
    files.map(
      (f) => MapEntry('a|lib/${p.basename(f.path)}', f.readAsStringSync()),
    ),
  );

  await resolveSources(fileMap, (item) async {
    return await item.libraryFor(assetId);
  }, resolverFor: 'a|lib/${p.basename(filePath)}');
}

String get _pkgName => 'pkg$_pkgCacheCount';
int _pkgCacheCount = 1;
