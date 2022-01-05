const String keyClassName = 'className';
const String keyObjectId = 'objectId';

abstract class ParseBaseObject {
  dynamic get asMap;

  Uri get path;
}
