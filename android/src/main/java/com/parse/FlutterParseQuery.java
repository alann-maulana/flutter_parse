package com.parse;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterParseQuery {
  private static final String TAG = FlutterParseQuery.class.getSimpleName();
  public static final String QUERY_IN_BACKGROUND = "queryInBackground";

  private final ParseQuery<ParseObject> query;
  private boolean count;

  private FlutterParseQuery(ParseQuery<ParseObject> query, boolean count) {
    this.query = query;
    this.count = count;
  }

  private static FlutterParseQuery createQuery(JSONObject json) {
    String className = json.optString(FlutterParseObject.KEY_CLASS_NAME);
    if (className == null) {
      return null;
    }

    final ParseDecoder decoder = ParseDecoder.get();
    ParseQuery<ParseObject> query = ParseQuery.getQuery(className);

    JSONObject where = json.optJSONObject("where");
    Iterator<String> keys = where.keys();
    while (keys.hasNext()) {
      String key = keys.next();
      Object object = where.opt(key);

      if (object instanceof JSONObject) {
        JSONObject clause = (JSONObject) object;
        String type = clause.optString("__type", null);
        if (type != null) {
          query.whereEqualTo(key, decoder.decode(object));
        } else {
          Iterator<String> keysClause = clause.keys();
          while (keysClause.hasNext()) {
            String keyClause = keysClause.next();
            Object objectClause = clause.opt(keyClause);

            parseQuery(query, key, keyClause, decoder.decode(objectClause));
          }
        }
      } else {
        query.whereEqualTo(key, decoder.decode(object));
      }
    }

    boolean count = json.optInt("count") == 1;

    int limit = json.optInt("limit");
    if (limit != 0) {
      query.setLimit(limit);
    }

    int skip = json.optInt("skip");
    if (skip != 0) {
      query.setSkip(skip);
    }

    String include = json.optString("include");
    if (include.length() > 0) {
      String[] split = include.split(",");
      if (split.length > 0) {
        for (String key : split) {
          query.include(key);
        }
      } else {
        query.include(include);
      }
    }

    String order = json.optString("order");
    if (order.length() > 0) {
      String[] split = order.split(",");
      if (split.length > 0) {
        for (String o : split) {
          boolean desc = o.contains("-");
          String key = o.replace("-", "");
          if (desc) {
            query.addDescendingOrder(key);
          } else {
            query.addAscendingOrder(key);
          }
        }
      } else {
        boolean desc = order.contains("-");
        String key = order.replace("-", "");
        if (desc) {
          query.orderByDescending(key);
        } else {
          query.orderByAscending(key);
        }
      }
    }

    String fields = json.optString("fields");
    if (fields.length() > 0) {
      List<String> list = Arrays.asList(fields.split(","));
      query.selectKeys(list);
    }

    return new FlutterParseQuery(query, count);
  }

  private static void parseQuery(ParseQuery query, String key, String keyClause, Object object) {
    final ParseDecoder decoder = ParseDecoder.get();

    if (keyClause.equals("whereLessThan")) {
      query.whereLessThan(key, object);
    } else if (keyClause.equals("whereNotEqualTo")) {
      query.whereNotEqualTo(key, object);
    } else if (keyClause.equals("whereGreaterThan")) {
      query.whereGreaterThan(key, object);
    } else if (keyClause.equals("whereLessThanOrEqualTo")) {
      query.whereLessThanOrEqualTo(key, object);
    } else if (keyClause.equals("whereGreaterThanOrEqualTo")) {
      query.whereGreaterThanOrEqualTo(key, object);
    } else if (keyClause.equals("whereContainedIn") && object instanceof Collection) {
      query.whereContainedIn(key, (Collection<?>) object);
    } else if (keyClause.equals("whereContainsAll") && object instanceof Collection) {
      //noinspection unchecked
      query.whereContainsAll(key, (Collection<?>) object);
    } else if (keyClause.equals("whereFullText") && object instanceof String) {
      query.whereFullText(key, (String) object);
    } else if (keyClause.equals("whereNotContainedIn") && object instanceof Collection) {
      query.whereNotContainedIn(key, (Collection<?>) object);
    } else if (keyClause.equals("whereMatches") && object instanceof JSONObject) {
      JSONObject param = (JSONObject) object;
      String regex = param.optString("regex");
      String modifiers = param.optString("modifiers");
      if (modifiers.length() != 0) {
        query.whereMatches(key, regex, modifiers);
      } else {
        query.whereMatches(key, regex);
      }
    } else if (keyClause.equals("whereContains") && object instanceof String) {
      query.whereContains(key, (String) object);
    } else if (keyClause.equals("whereStartsWith") && object instanceof String) {
      query.whereStartsWith(key, (String) object);
    } else if (keyClause.equals("whereEndsWith") && object instanceof String) {
      query.whereEndsWith(key, (String) object);
    } else if (keyClause.equals("whereExists")) {
      query.whereExists(key);
    } else if (keyClause.equals("whereDoesNotExist")) {
      query.whereDoesNotExist(key);
    } else if (keyClause.equals("whereDoesNotMatchKeyInQuery") && object instanceof JSONObject) {
      JSONObject param = (JSONObject) object;
      String keyInQuery = param.optString("keyInQuery");
      JSONObject queryNotMatches = param.optJSONObject("query");
      FlutterParseQuery parseQuery = FlutterParseQuery.createQuery(queryNotMatches);
      if (parseQuery != null) {
        //noinspection unchecked
        query.whereDoesNotMatchKeyInQuery(key, keyInQuery, parseQuery.query);
      }
    } else if (keyClause.equals("whereMatchesKeyInQuery") && object instanceof JSONObject) {
      JSONObject param = (JSONObject) object;
      String keyInQuery = param.optString("keyInQuery");
      JSONObject queryMatches = param.optJSONObject("query");
      FlutterParseQuery parseQuery = FlutterParseQuery.createQuery(queryMatches);
      if (parseQuery != null) {
        //noinspection unchecked
        query.whereMatchesKeyInQuery(key, keyInQuery, parseQuery.query);
      }
    } else if (keyClause.equals("whereDoesNotMatchQuery") && object instanceof JSONObject) {
      JSONObject jsonObject = (JSONObject) object;
      FlutterParseQuery parseQuery = FlutterParseQuery.createQuery(jsonObject);
      if (parseQuery != null) {
        //noinspection unchecked
        query.whereDoesNotMatchQuery(key, parseQuery.query);
      }
    } else if (keyClause.equals("whereMatchesQuery") && object instanceof JSONObject) {
      JSONObject jsonObject = (JSONObject) object;
      FlutterParseQuery parseQuery = FlutterParseQuery.createQuery(jsonObject);
      if (parseQuery != null) {
        //noinspection unchecked
        query.whereMatchesQuery(key, parseQuery.query);
      }
    } else if (keyClause.equals("whereNear") && object instanceof JSONObject) {
      ParseGeoPoint point = (ParseGeoPoint) decoder.decode(object);
      query.whereNear(key, point);
    } else if (keyClause.equals("whereWithinRadians") && object instanceof JSONObject) {
      JSONObject jsonObject = (JSONObject) object;
      ParseGeoPoint point = (ParseGeoPoint) decoder.decode(jsonObject.optJSONObject("point"));
      double maxDistance = jsonObject.optDouble("maxDistance");
      query.whereWithinRadians(key, point, maxDistance);
    } else if (keyClause.equals("whereWithinGeoBox") && object instanceof JSONArray) {
      JSONArray array = (JSONArray) object;
      ParseGeoPoint northWest = (ParseGeoPoint) decoder.decode(array.optJSONObject(0));
      ParseGeoPoint southEast = (ParseGeoPoint) decoder.decode(array.optJSONObject(1));
      query.whereWithinGeoBox(key, northWest, southEast);
    } else if (keyClause.equals("whereWithinPolygon") && object instanceof JSONArray) {
      JSONArray array = (JSONArray) object;
      //noinspection unchecked
      List<ParseGeoPoint> points = (List<ParseGeoPoint>) decoder.decode(array);
      query.whereWithinPolygon(key, points);
    } else if (keyClause.equals("wherePolygonContains") && object instanceof JSONObject) {
      JSONObject jsonObject = (JSONObject) object;
      ParseGeoPoint point = (ParseGeoPoint) decoder.decode(jsonObject);
      query.wherePolygonContains(key, point);
    }
  }

  public static void executeAsync(final MethodCall call, final MethodChannel.Result result) {
    JSONObject objectMap = FlutterParseUtils.parsingParams(call.arguments);

    if (objectMap == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parse query", null);
      return;
    }

    final FlutterParseQuery parseQuery = FlutterParseQuery.createQuery(objectMap);
    if (parseQuery == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "no className found", null);
      return;
    }

    if (!parseQuery.count) {
      parseQuery.query.findInBackground(new FindCallback<ParseObject>() {
        @Override
        public void done(List<ParseObject> objects, ParseException e) {
          if (e != null) {
            result.error(String.valueOf(e.getCode()), e.getMessage(), null);
            return;
          }

          JSONArray array = new JSONArray();
          for (ParseObject parseObject : objects) {
            FlutterParseObject object = new FlutterParseObject(parseObject);
            array.put(object.toJsonObject());
          }
          result.success(array.toString());
        }
      });
    } else {
      parseQuery.query.countInBackground(new CountCallback() {
        @Override
        public void done(int count, ParseException e) {
          if (e != null) {
            result.error(String.valueOf(e.getCode()), e.getMessage(), null);
            return;
          }

          result.success(count);
        }
      });
    }
  }
}
