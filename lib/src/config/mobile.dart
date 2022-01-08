import 'dart:io';

const bool kOverrideUserAgentHeaderRequest = true;

String get kDeviceType {
  if (Platform.isAndroid) {
    return 'android';
  }
  if (Platform.isIOS) {
    return 'ios';
  }
  if (Platform.isMacOS) {
    return 'macos';
  }
  if (Platform.isWindows) {
    return 'windows';
  }
  if (Platform.isLinux) {
    return 'linux';
  }

  return Platform.operatingSystem;
}
