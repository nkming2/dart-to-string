import 'package:code_gen_tester/code_gen_tester.dart';
import 'package:test/test.dart';
import 'package:to_string_builder/src/generator.dart';

void main() {
  final tester = SourceGenTester.fromPath("test/src/to_string.dart");
  final generator = ToStringGenerator();
  Future<void> expectGen(String name, Matcher matcher) async =>
      expectGenerateNamed(await tester, name, generator, matcher);

  group("ToString", () {
    test("empty", () async {
      await expectGen("Empty", completion("""
extension _\$EmptyToString on Empty {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "Empty {}";
  }
}
"""));
    });

    test("signel field", () async {
      await expectGen("SingleField", completion("""
extension _\$SingleFieldToString on SingleField {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "SingleField {abc: \$abc}";
  }
}
"""));
    });

    test("multiple fields", () async {
      await expectGen("MultipleField", completion("""
extension _\$MultipleFieldToString on MultipleField {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "MultipleField {abc: \$abc, def: \$def, geh: \$geh}";
  }
}
"""));
    });

    test("derived class", () async {
      await expectGen("DerivedClass", completion("""
extension _\$DerivedClassToString on DerivedClass {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "DerivedClass {abc: \$abc, def: \$def}";
  }
}
"""));
    });

    test("static field", () async {
      await expectGen("StaticField", completion("""
extension _\$StaticFieldToString on StaticField {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "StaticField {abc: \$abc}";
  }
}
"""));
    });

    test("ignore field", () async {
      await expectGen("IgnoreField", completion("""
extension _\$IgnoreFieldToString on IgnoreField {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "IgnoreField {def: \$def}";
  }
}
"""));
    });

    test("private field", () async {
      await expectGen("PrivateField", completion("""
extension _\$PrivateFieldToString on PrivateField {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "PrivateField {abc: \$abc, _def: \$_def}";
  }
}
"""));
    });

    test("private field (ignorePrivate=true)", () async {
      await expectGen("IgnorePrivateField", completion("""
extension _\$IgnorePrivateFieldToString on IgnorePrivateField {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "IgnorePrivateField {def: \$def}";
  }
}
"""));
    });

    test("sort by name (sortByName=true)", () async {
      await expectGen("SortByName", completion("""
extension _\$SortByNameToString on SortByName {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "SortByName {abc: \$abc, def: \$def}";
  }
}
"""));
    });

    test("sort by declaration (sortByName=false)", () async {
      await expectGen("SortByDeclaration", completion("""
extension _\$SortByDeclarationToString on SortByDeclaration {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "SortByDeclaration {def: \$def, abc: \$abc}";
  }
}
"""));
    });

    test("empty parent non-empty grandparent", () async {
      await expectGen("Grandchild", completion("""
extension _\$GrandchildToString on Grandchild {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "Grandchild {abc: \$abc, def: \$def}";
  }
}
"""));
    });

    test("format string", () async {
      await expectGen("FormatDouble", completion("""
extension _\$FormatDoubleToString on FormatDouble {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatDouble {abc: \${abc.toStringAsFixed(1)}}";
  }
}
"""));
    });

    test("getter", () async {
      await expectGen("Getter", completion("""
extension _\$GetterToString on Getter {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "Getter {abc: \$abc}";
  }
}
"""));
    });

    test("ignore null", () async {
      await expectGen("IgnoreNull", completion("""
extension _\$IgnoreNullToString on IgnoreNull {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "IgnoreNull {abc: \$abc, \${def == null ? "" : "def: \$def"}}";
  }
}
"""));
    });

    test("abstract class", () async {
      await expectGen("AbstractClass", completion("""
extension _\$AbstractClassToString on AbstractClass {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "\${objectRuntimeType(this, "AbstractClass")} {abc: \$abc}";
  }
}
"""));
    });

    test("extra params", () async {
      await expectGen("ExtraParams", completion("""
extension _\$ExtraParamsToString on ExtraParams {
  String _\$toString({bool print = true}) {
    // ignore: unnecessary_string_interpolations
    return "ExtraParams {abc: \${print ? abc : ''}}";
  }
}
"""));
    });

    group("yaml options", () {
      group("name mapping", () {
        test("basic", () async {
          final generator = ToStringGenerator(
            configFormatStringNameMapping: {
              "List": r"${$?.first}",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYaml", completion("""
extension _\$FormatYamlToString on FormatYaml {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYaml {abc: \${abc.first}}";
  }
}
"""));
        });

        test("nullable", () async {
          final generator = ToStringGenerator(
            configFormatStringNameMapping: {
              "List": r"${$?.first}",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlNull", completion("""
extension _\$FormatYamlNullToString on FormatYamlNull {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlNull {abc: \${abc == null ? null : "\${abc!.first}"}}";
  }
}
"""));
        });

        test("unnamed function type", () async {
          final generator = ToStringGenerator(
            configFormatStringNameMapping: {
              "void Function(int)": r"function",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlUnnamedFunction", completion("""
extension _\$FormatYamlUnnamedFunctionToString on FormatYamlUnnamedFunction {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlUnnamedFunction {abc: function}";
  }
}
"""));
        });

        test("function alias", () async {
          final generator = ToStringGenerator(
            configFormatStringNameMapping: {
              "VoidCallback": r"callback",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlFunctionAlias", completion("""
extension _\$FormatYamlFunctionAliasToString on FormatYamlFunctionAlias {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlFunctionAlias {abc: callback}";
  }
}
"""));
        });

        test("alias", () async {
          final generator = ToStringGenerator(
            configFormatStringNameMapping: {
              "MyType": r"mytype",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlAlias", completion("""
extension _\$FormatYamlAliasToString on FormatYamlAlias {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlAlias {abc: mytype}";
  }
}
"""));
        });

        test("alias (original type)", () async {
          final generator = ToStringGenerator(
            configFormatStringNameMapping: {
              "double": r"double",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlAlias", completion("""
extension _\$FormatYamlAliasToString on FormatYamlAlias {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlAlias {abc: double}";
  }
}
"""));
        });
      });

      group("url mapping", () {
        test("basic", () async {
          final generator = ToStringGenerator(
            configFormatStringUrlMapping: {
              "dart:core#List": r"${$?.first}",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYaml", completion("""
extension _\$FormatYamlToString on FormatYaml {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYaml {abc: \${abc.first}}";
  }
}
"""));
        });

        test("nullable", () async {
          final generator = ToStringGenerator(
            configFormatStringUrlMapping: {
              "dart:core#List": r"${$?.first}",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlNull", completion("""
extension _\$FormatYamlNullToString on FormatYamlNull {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlNull {abc: \${abc == null ? null : "\${abc!.first}"}}";
  }
}
"""));
        });

        test("function alias", () async {
          final generator = ToStringGenerator(
            configFormatStringUrlMapping: {
              "dart:html#VoidCallback": r"callback",
            },
          );
          Future<void> expectGen(String name, Matcher matcher) async =>
              expectGenerateNamed(await tester, name, generator, matcher);

          await expectGen("FormatYamlFunctionAlias", completion("""
extension _\$FormatYamlFunctionAliasToString on FormatYamlFunctionAlias {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlFunctionAlias {abc: callback}";
  }
}
"""));
        });
      });

      test("enum name (true)", () async {
        final generator = ToStringGenerator(
          configUseEnumName: true,
        );
        Future<void> expectGen(String name, Matcher matcher) async =>
            expectGenerateNamed(await tester, name, generator, matcher);

        await expectGen("FormatYamlEnumName", completion("""
extension _\$FormatYamlEnumNameToString on FormatYamlEnumName {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlEnumName {abc: \${abc.name}}";
  }
}
"""));
      });

      test("enum name (false)", () async {
        final generator = ToStringGenerator(
          configUseEnumName: false,
        );
        Future<void> expectGen(String name, Matcher matcher) async =>
            expectGenerateNamed(await tester, name, generator, matcher);

        await expectGen("FormatYamlEnumName", completion("""
extension _\$FormatYamlEnumNameToString on FormatYamlEnumName {
  String _\$toString() {
    // ignore: unnecessary_string_interpolations
    return "FormatYamlEnumName {abc: \$abc}";
  }
}
"""));
      });
    });
  });
}
