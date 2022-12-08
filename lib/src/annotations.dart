class ToString {
  const ToString({
    this.ignorePrivate = false,
    this.sortByName = false,
    this.ignoreNull = false,
    this.extraParams,
  });

  /// If true, ignore private fields
  final bool ignorePrivate;

  /// If true, sort fields by name, otherwise they will be sorted by the
  /// declaration order
  final bool sortByName;

  /// If true, ignore fields that are null
  final bool ignoreNull;

  /// Add extra params to the generated toString function
  ///
  /// @ToString(extraParams: r"{bool print = true}")
  /// class ExtraParams {
  ///   @override
  ///   String toString({bool print = true}) => _$toString(print: print);
  /// }
  final String? extraParams;
}

/// Annotate a field to be ignored from the string
///
/// Example:
/// @toString
/// class Foo {
///   @Ignore
///   final bar = 0;
/// }
class Ignore {
  const Ignore();
}

/// Annotate a field to customize its output in the generated toString
///
/// The output is formatted by the [formatString], when formatting, the
/// $? placeholder will be replaced by the name of the field.
///
/// For example with a class like this,
/// @toString
/// class A {
///   @Format(r"${$?.toStringAsFixed(1)}")
///   final double abc = 1.23;
/// }
///
/// The generated toString will be,
/// String _toString() {
///   return "A {abc: ${abc.toStringAsFixed(1)}}";
/// }
///
/// If you want to set the format string to every single instance of a type, you
/// can do so in build.yaml
class Format {
  const Format(this.formatString);

  final String formatString;
}

const toString = ToString();
const ignore = Ignore();
