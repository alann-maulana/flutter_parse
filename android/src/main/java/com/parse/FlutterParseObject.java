package com.parse;

import android.util.Log;

import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterParseObject {
  private static final String TAG = FlutterParseObject.class.getSimpleName();
  public static final String FETCH_IN_BACKGROUND = "fetchInBackground";
  public static final String DELETE_IN_BACKGROUND = "deleteInBackground";
  public static final String DELETE_EVENTUALLY = "deleteEventually";
  public static final String SAVE_IN_BACKGROUND = "saveInBackground";
  public static final String SAVE_EVENTUALLY = "saveEventually";
  static final String KEY_OBJECT_ID = "objectId";
  static final String KEY_CLASS_NAME = "className";

  private final ParseObject parseObject;

  FlutterParseObject(ParseObject parseObject) {
    this.parseObject = parseObject;
  }

  private static FlutterParseObject createObject(String className, JSONObject map) {
    ParseObject parseObject = null;
    if (className.equals("_User")) {
      String objectId = map.optString(KEY_OBJECT_ID);
      if (objectId != null && ParseUser.getCurrentUser() != null) {
        if (objectId.equals(ParseUser.getCurrentUser().getObjectId())) {
          parseObject = ParseUser.getCurrentUser();
        }
      }
    } else {
      parseObject = new ParseObject(className);
    }

    if (map != null && parseObject != null) {
        parseObject.mergeREST(parseObject.getState(), map, ParseDecoder.get());
    }
    return new FlutterParseObject(parseObject);
  }

  private static FlutterParseObject createObject(JSONObject map) {
    String className = map.optString(KEY_CLASS_NAME);
    if (className == null) {
      return null;
    }

    map.remove(KEY_CLASS_NAME);
    return createObject(className, map);
  }

  private static FlutterParseObject createWithoutData(JSONObject map) {
    String className = map.optString(KEY_CLASS_NAME);
    if (className == null) {
      return null;
    }

    String objectId = map.optString(KEY_OBJECT_ID);
    if (objectId == null) {
      return null;
    }

    return new FlutterParseObject(ParseObject.createWithoutData(className, objectId));
  }

  public static void saveAsync(MethodCall call, final MethodChannel.Result result, boolean isEventually) {
    JSONObject objectMap = FlutterParseUtils.parsingParams(call.arguments);

    if (objectMap == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse object", null);
      return;
    }

    final FlutterParseObject object = FlutterParseObject.createObject(objectMap);
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
    JSONObject map = FlutterParseUtils.parsingParams(call.arguments);
    if (map == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse object", null);
      return;
    }

    final FlutterParseObject object = FlutterParseObject.createWithoutData(map);
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
    JSONObject map = FlutterParseUtils.parsingParams(call.arguments);
    if (map == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse object", null);
      return;
    }

    final FlutterParseObject object = FlutterParseObject.createWithoutData(map);
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

        result.success(new FlutterParseObject(parseObject).toJsonObject().toString());
      }
    };
    object.getParseObject().fetchInBackground(callback);
  }

  private ParseObject getParseObject() {
    return parseObject;
  }

  JSONObject toJsonObject() {
    return parseObject.toRest(FlutterParseEncoder.get());
  }
}
