// ignore_for_file: unused_field

import 'dart:collection';

import 'package:to_string/to_string.dart';

part 'to_string.g.dart';

@toString
class BasicUsage {
  @override
  String toString() => _$toString();

  final abc = 1;
  final def = 1;
  final geh = 1;
}

@toString
class IgnoreField {
  @override
  String toString() => _$toString();

  @ignore
  final abc = 1;
  final def = 2;
}

@ToString(ignorePrivate: true)
class IgnorePrivateField {
  @override
  String toString() => _$toString();

  final _abc = 1;
  final def = 2;
}

@ToString(sortByName: true)
class SortByName {
  @override
  String toString() => _$toString();

  final def = 1;
  final abc = 1;
}

@toString
class FormatYaml {
  @override
  String toString() => _$toString();

  final double abc = 1.234;
  final def = <int>[];
  final ghi = HashMap<String, int>();
  final jkl = MyEnum.abc;
}

enum MyEnum { abc, def }
