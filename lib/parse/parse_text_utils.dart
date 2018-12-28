part of flutter_parse;

class ParseTextUtils {
  /// Returns a string containing the tokens joined by delimiters.
  static String join(String delimiter, List<dynamic> tokens) {
    String builder = "";
    bool firstTime = true;

    tokens.forEach((item) {
      if (firstTime) {
        firstTime = false;
      } else {
        builder = "$builder,";
      }
      builder = "$builder$item";
    });

    return builder;
  }
}
