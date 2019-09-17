part of flutter_parse;

final PointerOrLocalIdEncoder pointerOrLocalIdEncoder =
    PointerOrLocalIdEncoder._internal();

class PointerOrLocalIdEncoder {
  PointerOrLocalIdEncoder._internal();

  Map<String, dynamic> encodeRelatedObject(ParseObject object) {
    Map<String, dynamic> json = Map();

    json.putIfAbsent("__type", () => "Pointer");
    json.putIfAbsent("className", () => object.className);
    if (object.objectId != null) {
      json.putIfAbsent("objectId", () => object.objectId);
    } else {
      String localId = DateTime.now().millisecondsSinceEpoch.toString();
      json.putIfAbsent("objectId", () => localId);
    }

    return json;
  }
}
