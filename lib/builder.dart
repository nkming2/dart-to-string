import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:to_string/src/generator.dart';

Builder toStringBuilder(BuilderOptions options) => SharedPartBuilder([
      ToStringGenerator(
        configFormatStringNameMapping:
            options.config["formatStringNameMapping"]?.cast<String, String>(),
        configFormatStringUrlMapping:
            options.config["formatStringUrlMapping"]?.cast<String, String>(),
      )
    ], "to_string");
