package com.parse.flutterparse;

import com.parse.FlutterParse;
import com.parse.FlutterParseInstallation;
import com.parse.FlutterParseObject;
import com.parse.FlutterParseQuery;
import com.parse.FlutterParseUser;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FlutterParsePlugin implements MethodCallHandler {
  private final Registrar registrar;

  private FlutterParsePlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_parse");
    channel.setMethodCallHandler(new FlutterParsePlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case FlutterParse.INITIALIZE:
        FlutterParse.initialize(registrar.activeContext().getApplicationContext(), call, result);
        break;
      case FlutterParseInstallation.INSTALLATION:
        FlutterParseInstallation.init(result);
        break;
      case FlutterParseUser.GET_CURRENT_USER:
        FlutterParseUser.getCurrentUser(result);
        break;
      case FlutterParseUser.LOGIN:
        FlutterParseUser.login(call, result);
        break;
      case FlutterParseUser.REGISTER:
        FlutterParseUser.register(call, result);
        break;
      case FlutterParseUser.LOGOUT:
        FlutterParseUser.logout(result);
        break;
      case FlutterParseObject.DELETE_IN_BACKGROUND:
        FlutterParseObject.deleteAsync(call, result, false);
        break;
      case FlutterParseObject.DELETE_EVENTUALLY:
        FlutterParseObject.deleteAsync(call, result, true);
        break;
      case FlutterParseObject.FETCH_IN_BACKGROUND:
        FlutterParseObject.fetchAsync(call, result);
        break;
      case FlutterParseObject.SAVE_IN_BACKGROUND:
        FlutterParseObject.saveAsync(call, result, false);
        break;
      case FlutterParseObject.SAVE_EVENTUALLY:
        FlutterParseObject.saveAsync(call, result, true);
        break;
      case FlutterParseQuery.QUERY_IN_BACKGROUND:
        FlutterParseQuery.executeAsync(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
