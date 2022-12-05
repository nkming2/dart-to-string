import 'package:code_gen_tester/code_gen_tester.dart';
import 'package:test/test.dart';
import 'package:to_string/src/generator.dart';

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
    return "Empty {}";
  }
}
"""));
    });

    test("signel field", () async {
      await expectGen("SingleField", completion("""
extension _\$SingleFieldToString on SingleField {
  String _\$toString() {
    return "SingleField {abc: \$abc}";
  }
}
"""));
    });

    test("multiple fields", () async {
      await expectGen("MultipleField", completion("""
extension _\$MultipleFieldToString on MultipleField {
  String _\$toString() {
    return "MultipleField {abc: \$abc, def: \$def, geh: \$geh}";
  }
}
"""));
    });

    test("derived class", () async {
      await expectGen("DerivedClass", completion("""
extension _\$DerivedClassToString on DerivedClass {
  String _\$toString() {
    return "DerivedClass {abc: \$abc, def: \$def}";
  }
}
"""));
    });

    test("static field", () async {
      await expectGen("StaticField", completion("""
extension _\$StaticFieldToString on StaticField {
  String _\$toString() {
    return "StaticField {abc: \$abc}";
  }
}
"""));
    });

    test("ignore field", () async {
      await expectGen("IgnoreField", completion("""
extension _\$IgnoreFieldToString on IgnoreField {
  String _\$toString() {
    return "IgnoreField {def: \$def}";
  }
}
"""));
    });

    test("private field", () async {
      await expectGen("PrivateField", completion("""
extension _\$PrivateFieldToString on PrivateField {
  String _\$toString() {
    return "PrivateField {abc: \$abc, _def: \$_def}";
  }
}
"""));
    });

    test("private field (ignorePrivate=true)", () async {
      await expectGen("IgnorePrivateField", completion("""
extension _\$IgnorePrivateFieldToString on IgnorePrivateField {
  String _\$toString() {
    return "IgnorePrivateField {def: \$def}";
  }
}
"""));
    });

    test("sort by name (sortByName=true)", () async {
      await expectGen("SortByName", completion("""
extension _\$SortByNameToString on SortByName {
  String _\$toString() {
    return "SortByName {abc: \$abc, def: \$def}";
  }
}
"""));
    });

    test("sort by declaration (sortByName=false)", () async {
      await expectGen("SortByDeclaration", completion("""
extension _\$SortByDeclarationToString on SortByDeclaration {
  String _\$toString() {
    return "SortByDeclaration {def: \$def, abc: \$abc}";
  }
}
"""));
    });

    test("empty parent non-empty grandparent", () async {
      await expectGen("Grandchild", completion("""
extension _\$GrandchildToString on Grandchild {
  String _\$toString() {
    return "Grandchild {abc: \$abc, def: \$def}";
  }
}
"""));
    });

    test("format string", () async {
      await expectGen("FormatDouble", completion("""
extension _\$FormatDoubleToString on FormatDouble {
  String _\$toString() {
    return "FormatDouble {abc: \${abc.toStringAsFixed(1)}}";
  }
}
"""));
    });

    test("getter", () async {
      await expectGen("Getter", completion("""
extension _\$GetterToString on Getter {
  String _\$toString() {
    return "Getter {abc: \$abc}";
  }
}
"""));
    });

    test("ignore null", () async {
      await expectGen("IgnoreNull", completion("""
extension _\$IgnoreNullToString on IgnoreNull {
  String _\$toString() {
    return "IgnoreNull {abc: \$abc, \${def == null ? "" : "def: \$def, "}}";
  }
}
"""));
    });

    group("yaml options", () {
      test("name mapping", () async {
        final generator = ToStringGenerator(
          configFormatStringNameMapping: {
            "List": r"${$?.first}",
          },
        );
        Future<void> expectGen(String name, Matcher matcher) async =>
            expectGenerateNamed(await tester, name, generator, matcher);

        await expectGen("FormatYamlName", completion("""
extension _\$FormatYamlNameToString on FormatYamlName {
  String _\$toString() {
    return "FormatYamlName {abc: \${abc.first}}";
  }
}
"""));
      });

      test("url mapping", () async {
        final generator = ToStringGenerator(
          configFormatStringUrlMapping: {
            "dart:core#List": r"${$?.first}",
          },
        );
        Future<void> expectGen(String name, Matcher matcher) async =>
            expectGenerateNamed(await tester, name, generator, matcher);

        await expectGen("FormatYamlUrl", completion("""
extension _\$FormatYamlUrlToString on FormatYamlUrl {
  String _\$toString() {
    return "FormatYamlUrl {abc: \${abc.first}}";
  }
}
"""));
      });

      test("name mapping (nullable)", () async {
        final generator = ToStringGenerator(
          configFormatStringNameMapping: {
            "List": r"${$?.first}",
          },
        );
        Future<void> expectGen(String name, Matcher matcher) async =>
            expectGenerateNamed(await tester, name, generator, matcher);

        await expectGen("FormatYamlNameNull", completion("""
extension _\$FormatYamlNameNullToString on FormatYamlNameNull {
  String _\$toString() {
    return "FormatYamlNameNull {abc: \${abc == null ? null : "\${abc!.first}"}}";
  }
}
"""));
      });

      test("url mapping (nullable)", () async {
        final generator = ToStringGenerator(
          configFormatStringUrlMapping: {
            "dart:core#List": r"${$?.first}",
          },
        );
        Future<void> expectGen(String name, Matcher matcher) async =>
            expectGenerateNamed(await tester, name, generator, matcher);

        await expectGen("FormatYamlUrlNull", completion("""
extension _\$FormatYamlUrlNullToString on FormatYamlUrlNull {
  String _\$toString() {
    return "FormatYamlUrlNull {abc: \${abc == null ? null : "\${abc!.first}"}}";
  }
}
"""));
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
    return "FormatYamlEnumName {abc: \$abc}";
  }
}
"""));
      });
    });
  });
}
