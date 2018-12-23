package com.parse.flutterparse;

import com.parse.IParse;
import com.parse.IParseInstallation;
import com.parse.IParseObject;
import com.parse.IParseUser;

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
      case IParse.INITIALIZE:
        IParse.initialize(registrar.activeContext().getApplicationContext(), call, result);
        break;
      case IParseInstallation.INSTALLATION:
        IParseInstallation.init(result);
        break;
      case IParseUser.GET_CURRENT_USER:
        IParseUser.getCurrentUser(result);
        break;
      case IParseUser.LOGIN:
        IParseUser.login(call, result);
        break;
      case IParseUser.REGISTER:
        IParseUser.register(call, result);
        break;
      case IParseUser.LOGOUT:
        IParseUser.logout(result);
        break;
      case IParseObject.DELETE_IN_BACKGROUND:
        IParseObject.deleteAsync(call, result, false);
        break;
      case IParseObject.DELETE_EVENTUALLY:
        IParseObject.deleteAsync(call, result, true);
        break;
      case IParseObject.FETCH_IN_BACKGROUND:
        IParseObject.fetchAsync(call, result);
        break;
      case IParseObject.SAVE_IN_BACKGROUND:
        IParseObject.saveAsync(call, result, false);
        break;
      case IParseObject.SAVE_EVENTUALLY:
        IParseObject.saveAsync(call, result, true);
        break;
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
