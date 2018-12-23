package com.parse;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class IParseObject {
  private static final String TAG = IParseObject.class.getSimpleName();
  public static final String FETCH_IN_BACKGROUND = "fetchInBackground";
  public static final String DELETE_IN_BACKGROUND = "deleteInBackground";
  public static final String DELETE_EVENTUALLY = "deleteEventually";
  public static final String SAVE_IN_BACKGROUND = "saveInBackground";
  public static final String SAVE_EVENTUALLY = "saveEventually";
  private static final String KEY_OBJECT_ID = "objectId";
  private static final String KEY_CLASS_NAME = "className";

  private final ParseObject parseObject;

  IParseObject(ParseObject parseObject) {
    this.parseObject = parseObject;
  }

  private static IParseObject createObject(String className, JSONObject map) {
    ParseObject parseObject = new ParseObject(className);
    if (map != null) {
      parseObject.mergeREST(parseObject.getState(), map, ParseDecoder.get());
    }
    return new IParseObject(parseObject);
  }

  private static IParseObject createObject(JSONObject map) {
    String className = map.optString(KEY_CLASS_NAME);
    if (className == null) {
      return null;
    }

    map.remove(KEY_CLASS_NAME);
    return createObject(className, map);
  }

  private static IParseObject createWithoutData(JSONObject map) {
    String className = map.optString(KEY_CLASS_NAME);
    if (className == null) {
      return null;
    }

    String objectId = map.optString(KEY_OBJECT_ID);
    if (objectId == null) {
      return null;
    }

    return new IParseObject(ParseObject.createWithoutData(className, objectId));
  }

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

  public static void saveAsync(MethodCall call, final MethodChannel.Result result, boolean isEventually) {
    JSONObject objectMap = parsingParams(call.arguments);

    if (objectMap == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse object", null);
      return;
    }

    final IParseObject object = IParseObject.createObject(objectMap);
    if (object == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "no className found", null);
      return;
    }

    final SaveCallback callback = new SaveCallback() {
      @Override
      public void done(ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        result.success(object.toJsonObject().toString());
      }
    };

    if (isEventually) {
      object.getParseObject().saveEventually(callback);
    } else {
      object.getParseObject().saveInBackground(callback);
    }
  }

  public static void deleteAsync(MethodCall call, final MethodChannel.Result result, boolean isEventually) {
    JSONObject map = parsingParams(call.arguments);
    if (map == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse object", null);
      return;
    }

    final IParseObject object = IParseObject.createWithoutData(map);
    if (object == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "no className or objectId found", null);
      return;
    }

    final DeleteCallback callback = new DeleteCallback() {
      @Override
      public void done(ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        result.success(null);
      }
    };

    if (isEventually) {
      object.getParseObject().deleteEventually(callback);
    } else {
      object.getParseObject().deleteInBackground(callback);
    }
  }

  public static void fetchAsync(MethodCall call, final MethodChannel.Result result) {
    JSONObject map = parsingParams(call.arguments);
    if (map == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse object", null);
      return;
    }

    final IParseObject object = IParseObject.createWithoutData(map);
    if (object == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "no className or objectId found", null);
      return;
    }

    final GetCallback<ParseObject> callback = new GetCallback<ParseObject>() {
      @Override
      public void done(ParseObject parseObject, ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        result.success(new IParseObject(parseObject).toJsonObject().toString());
      }
    };
    object.getParseObject().fetchInBackground(callback);
  }

  private ParseObject getParseObject() {
    return parseObject;
  }

  JSONObject toJsonObject() {
    return parseObject.toRest(PointerEncoder.get());
  }
}
