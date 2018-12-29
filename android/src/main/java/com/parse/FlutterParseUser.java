package com.parse;

import android.util.Log;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterParseUser {
  private static final String TAG = FlutterParseObject.class.getSimpleName();
  public static final String GET_CURRENT_USER = "getCurrentUser";
  public static final String LOGIN = "login";
  public static final String LOGOUT = "logout";
  public static final String REGISTER = "register";

  public static void getCurrentUser(final MethodChannel.Result result) {
    ParseUser user = ParseUser.getCurrentUser();
    if (user == null) {
      result.success(null);
      return;
    }

    FlutterParseObject object = new FlutterParseObject(user);
    result.success(object.toJsonObject().toString());
  }

  public static void login(MethodCall call, final MethodChannel.Result result) {
    JSONObject json = FlutterParseUtils.parsingParams(call.arguments);
    if (json == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parameters", null);
      return;
    }

    String username = json.optString("username");

    if (username == null) {
      result.error(String.valueOf(ParseException.USERNAME_MISSING), "missing username", null);
      return;
    }

    String password = json.optString("password");
    if (password == null) {
      result.error(String.valueOf(ParseException.PASSWORD_MISSING), "missing password", null);
      return;
    }

    ParseUser.logInInBackground(username, password, new LogInCallback() {
      @Override
      public void done(ParseUser user, ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        FlutterParseObject object = new FlutterParseObject(user);
        result.success(object.toJsonObject().toString());
      }
    });
  }

  public static void register(MethodCall call, final MethodChannel.Result result) {
    JSONObject json = FlutterParseUtils.parsingParams(call.arguments);
    if (json == null) {
      result.error(String.valueOf(ParseException.INVALID_JSON), "invalid parameters", null);
      return;
    }

    String username = json.optString("username");

    if (username == null) {
      result.error(String.valueOf(ParseException.USERNAME_MISSING), "missing username", null);
      return;
    }

    String password = json.optString("password");
    if (password == null) {
      result.error(String.valueOf(ParseException.PASSWORD_MISSING), "missing password", null);
      return;
    }

    final ParseUser user = new ParseUser();
    user.setUsername(username);
    user.setPassword(password);

    String email = json.optString("email");
    if (email != null && email.length() != 0) {
      user.setEmail(email);
    }

    Iterator<String> keys = json.keys();
    while (keys.hasNext()) {
      String key = keys.next();
      if (!key.equals("username") && !key.equals("password") && !key.equals("email")) {
        user.put(key, json.opt(key));
      }
    }

    user.signUpInBackground(new SignUpCallback() {
      @Override
      public void done(ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        FlutterParseObject object = new FlutterParseObject(user);
        result.success(object.toJsonObject().toString());
      }
    });
  }

  public static void logout(final MethodChannel.Result result) {
    ParseUser.logOutInBackground(new LogOutCallback() {
      @Override
      public void done(ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        result.success(null);
      }
    });
  }
}
