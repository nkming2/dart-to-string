// ignore_for_file: unused_field

import 'package:to_string/to_string.dart';

@toString
class Empty {}

@toString
class SingleField {
  final abc = 1;
}

@toString
class MultipleField {
  final abc = 1;
  final def = 1;
  final geh = 1;
}

class BaseClass {
  final abc = 1;
}

@toString
class DerivedClass extends BaseClass {
  final def = 1;
}

@toString
class StaticField {
  final abc = 1;
  static final def = 1;
}

@toString
class IgnoreField {
  @ignore
  final abc = 1;
  final def = 1;
}

@toString
class PrivateField {
  final abc = 1;
  final _def = 1;
}

@ToString(ignorePrivate: true)
class IgnorePrivateField {
  final _abc = 1;
  final def = 1;
}

@ToString(sortByName: true)
class SortByName {
  final def = 1;
  final abc = 1;
}

@ToString(sortByName: false)
class SortByDeclaration {
  final def = 1;
  final abc = 1;
}

class Grandparent {
  final abc = 1;
}

class EmptyParent extends Grandparent {}

@toString
class Grandchild extends EmptyParent {
  final def = 1;
}

@toString
class FormatDouble {
  @Format(r"${$?.toStringAsFixed(1)}")
  final double abc = 1.23456789;
}

@toString
class Getter {
  final abc = 1;
  int get def => 1;
}

@ToString(ignoreNull: true)
class IgnoreNull {
  final abc = 1;
  final int? def = null;
}

@toString
class FormatYamlName {
  final abc = <int>[];
}

@toString
class FormatYamlUrl {
  final abc = <int>[];
}

@toString
class FormatYamlNameNull {
  final List<int>? abc = null;
}

@toString
class FormatYamlUrlNull {
  final List<int>? abc = null;
}
