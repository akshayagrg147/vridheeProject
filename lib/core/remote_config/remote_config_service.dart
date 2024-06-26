import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:teaching_app/core/remote_config/remote_config_strings.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static late FirebaseRemoteConfig _remoteConfig;

// do not get the instance before initConfig is finished.
  static FirebaseRemoteConfig get remoteConfigInstance => _remoteConfig;

  static final RemoteConfigService _instance = RemoteConfigService._();

  factory RemoteConfigService() {
    return _instance;
  }

  static Future initConfig() async {
    try {
      var initTime = DateTime.now();
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        // cache refresh time
        fetchTimeout: const Duration(seconds: 2),
        // a fetch will wait up to 10 seconds before timing out
        minimumFetchInterval: const Duration(seconds: 10),
      ));
      await _remoteConfig.fetchAndActivate();
      log(
        'time taken to initialize remote config : ${DateTime.now().difference(initTime).inMilliseconds} ',
      );
    } catch (e) {}
  }

  static String get getAppVersion {
    return _getStringValueForRemoteKey(RemoteConfigStrings.versionNumber);
  }

  // --------------- * - * -------------- //

  static String _getStringValueForRemoteKey(String key) {
    var response = _remoteConfig.getString(key);
    print("RemoteConfigVersion : $response");
    if (response.isEmpty) {
      return "";
    }
    return response;
  }

  static bool _getBoolValueForRemoteKey(String key) {
    var response = _remoteConfig.getBool(key);
    return response;
  }

  static int _getIntValueForRemoteKey(String key) {
    var response = _remoteConfig.getInt(key);
    return response;
  }
}
