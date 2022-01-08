import 'package:flutter_parse/flutter_parse.dart';
import 'package:flutter_parse/src/config/global.dart';
import 'package:uuid/uuid.dart';

import 'parse_local_storage.dart';

class ParseInstallation extends ParseObject {
  static const kClassName = '_Installation';
  static const _keyCurrentInstallation = '_currentInstallation';
  bool _isCurrentInstallation = false;

  ParseInstallation({String? objectId, dynamic json})
      : super(className: kClassName, objectId: objectId, json: json);

  factory ParseInstallation.fromJson({required dynamic json}) {
    return ParseInstallation(json: json);
  }

  static Future<LocalStorage?> get _currentInstallationStorage =>
      parseLocalStorage.get(_keyCurrentInstallation);

  static Future<ParseInstallation?> get currentInstallation async {
    final storage = await _currentInstallationStorage;
    if (storage != null && storage.getData().isNotEmpty) {
      return ParseInstallation.fromJson(json: storage.getData())
        .._isCurrentInstallation = true;
    }

    final installation = ParseInstallation();
    final uuid = Uuid();
    if (parse.configuration?.installationId != null) {
      installation.set(
        'installationId',
        uuid.v5(Uuid.NAMESPACE_OID, parse.configuration?.installationId),
      );
    } else {
      installation.set('installationId', uuid.v4());
    }
    installation._updateInstallation();
    final currentStorage = await _currentInstallationStorage;
    if (currentStorage != null) {
      await currentStorage.setData(installation.asMap);
    }

    return installation;
  }

  bool get isCurrentInstallation => _isCurrentInstallation;
  String? get deviceToken => getString('deviceToken');
  set deviceToken(String? value) => set('deviceToken', value);

  String get deviceType => getString('deviceType')!;
  String get installationId => getString('installationId')!;
  String get appName => getString('appName')!;
  String get appVersion => getString('appVersion')!;
  String get appIdentifier => getString('appIdentifier')!;
  String get parseVersion => getString('parseVersion')!;

  _updateInstallation() {
    final config = parse.configuration!;
    set('deviceType', kDeviceType);
    set('localeIdentifier', config.localeIdentifier);
    set('appName', config.appName);
    set('appVersion', config.appVersion);
    set('appIdentifier', config.appIdentifier);
    set('parseVersion', kParseSdkVersion);
  }

  @override
  Future<ParseInstallation> save({bool useMasterKey = false}) async {
    await super.save(useMasterKey: useMasterKey);
    final currentStorage = await _currentInstallationStorage;
    if (currentStorage != null) {
      await currentStorage.setData(asMap);
    }

    return this;
  }
}
