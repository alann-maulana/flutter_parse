const String keyClassName = 'className';
const String keyObjectId = 'objectId';

abstract class ParseBaseObject {
  dynamic get asMap;

  String get path;

  Uri get uri;
}
