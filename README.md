# to-string
Generate toString() for classes

## Usage

```dart
@toString
class MyClass {
  @override
  String toString() => _$toString();

  final a = 0;
  final b = 0;
}
// MyClass {a: 0, b:0}
```

Ignoring a field:
```dart
@toString
class MyClass {
  @override
  String toString() => _$toString();

  final a = 0;
  @ignore
  final b = 0;
}
// MyClass {a: 0}
```

Formatting a field:
```dart
@toString
class MyClass {
  @override
  String toString() => _$toString();

  final a = 0;
  @Format(r"${$?.toStringAsFixed(1)}")
  final double b = 1.234;
}
// MyClass {a: 0, b:1.2}
```

For more details, checkout the example dir.
