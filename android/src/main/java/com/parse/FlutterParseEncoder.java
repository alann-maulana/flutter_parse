package com.parse;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

class FlutterParseEncoder extends PointerEncoder {

  private static final FlutterParseEncoder INSTANCE = new FlutterParseEncoder();
  public static FlutterParseEncoder get() {
    return INSTANCE;
  }

  @Override
  public JSONObject encodeRelatedObject(ParseObject object) {
    JSONObject json;
    try {
      if (object.getState().isComplete()) {
        json = new JSONObject(object.toRest(this).toString());
        json.put("__type", "Object");
      } else {
        json = new JSONObject();
        json.put("__type", "Pointer");
        json.put("className", object.getClassName());
        json.put("objectId", object.getObjectId());
      }
    } catch (JSONException e) {
      // This should not happen
      throw new RuntimeException(e);
    }
    return json;
  }

  public JSONObject encodeMap(Map<String, Object> map) {
    JSONObject json = new JSONObject();

    for (Map.Entry<String, Object> entry : map.entrySet()) {
      String key = entry.getKey();
      Object value = entry.getValue();

      try {
        json.put(key, encode(value));
      } catch (JSONException ignored) { }
    }

    return json;
  }
}