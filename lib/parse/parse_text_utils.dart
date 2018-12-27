part of flutter_parse;

class ParseTextUtils {
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
