package com.parse;

import io.flutter.plugin.common.MethodChannel;

public class FlutterParseInstallation {
  public static final String INSTALLATION = "installation";

  public static void init(final MethodChannel.Result result) {
    final ParseInstallation installation = ParseInstallation.getCurrentInstallation();

    if (installation != null) {
      installation.saveEventually(new SaveCallback() {
        @Override
        public void done(ParseException e) {
          if (e != null) {
            result.error(String.valueOf(e.getCode()), e.getMessage(), e);
          } else {
            result.success(true);
          }
        }
      });
    }
  }
}
