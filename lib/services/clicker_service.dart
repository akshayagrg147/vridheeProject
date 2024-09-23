import 'package:flutter/services.dart';

class TaghiveClickerSdk {
  static const MethodChannel _methodChannel =
      MethodChannel('com.example/clicker');
  static const EventChannel _eventChannel =
      EventChannel('com.example/clickerEvents');

  Future<void> checkPermissions() async {
    return await _methodChannel.invokeMethod('checkPermissions');
  }

  Future<void> startBleTask() async {
    return await _methodChannel.invokeMethod('startBleTask');
  }

  Future<void> stopBleTask() async {
    return await _methodChannel.invokeMethod('stopBleTask');
  }

  Stream<Map<String, dynamic>> get clickerEvents {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event);
    });
  }
}
