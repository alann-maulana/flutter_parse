package com.parse;

import io.flutter.plugin.common.MethodChannel;

public class FlutterParseConfig {
  private static final String TAG = FlutterParseObject.class.getSimpleName();
  public static final String GET_CURRENT = "configGetCurrent";
  public static final String FETCH_IN_BACKGROUND = "configFetchInBackground";

  public static void getCurrent(final MethodChannel.Result result) {
    ParseConfig config = ParseConfig.getCurrentConfig();
    if (config != null) {
      FlutterParseEncoder encoder = FlutterParseEncoder.get();
      result.success(encoder.encodeMap(config.getParams()).toString());
      return;
    }

    result.success(null);
  }

  public static void fetchInBackground(final MethodChannel.Result result) {
    ParseConfig.getInBackground(new ConfigCallback() {
      @Override
      public void done(ParseConfig config, ParseException e) {
        if (e != null) {
          result.error(String.valueOf(e.getCode()), e.getMessage(), null);
          return;
        }

        FlutterParseEncoder encoder = FlutterParseEncoder.get();
        result.success(encoder.encodeMap(config.getParams()).toString());
      }
    });
  }
}
