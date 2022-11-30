import 'package:code_gen_tester/code_gen_tester.dart';
import 'package:test/test.dart';
import 'package:to_string/to_string.dart';

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
  });
}
