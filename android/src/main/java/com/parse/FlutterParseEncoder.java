package com.parse;

import org.json.JSONException;
import org.json.JSONObject;

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
        json = object.toRest(this);
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
}