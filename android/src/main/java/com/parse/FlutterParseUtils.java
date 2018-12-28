package com.parse;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

class FlutterParseUtils {

  static JSONObject parsingParams(Object arguments) {
    if (arguments instanceof String) {
      try {
        return new JSONObject(arguments.toString());
      } catch (JSONException ignored) {
      }
    } else if (arguments instanceof Map) {
      try {
        return new JSONObject((Map) arguments);
      } catch (NullPointerException ignored) {
      }
    }
    return null;
  }
}
