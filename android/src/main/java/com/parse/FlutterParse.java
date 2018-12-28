package com.parse;

import android.content.Context;
import android.util.Log;

import com.moczul.ok2curl.CurlInterceptor;
import com.moczul.ok2curl.logger.Loggable;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import okhttp3.OkHttpClient;

public class FlutterParse {
  public static final String INITIALIZE = "initialize";
  private static final String SERVER = "server";
  private static final String APPLICATION_ID = "applicationId";
  private static final String CLIENT_KEY = "clientKey";

  public static void initialize(Context context, MethodCall call, MethodChannel.Result result) {
    String server = call.argument(SERVER);
    String applicationId = call.argument(APPLICATION_ID);
    String clientKey = call.argument(CLIENT_KEY);

    Parse.Configuration config = new Parse.Configuration.Builder(context)
        .server(server)
        .applicationId(applicationId)
        .clientKey(clientKey)
        .clientBuilder(new OkHttpClient.Builder()
            .addInterceptor(new CurlInterceptor(new Loggable() {
              @Override
              public void log(String message) {
                Log.v("CURL", message);
              }
            })))
        .enableLocalDataStore()
        .build();

    Parse.initialize(config);
    result.success(true);
  }
}
