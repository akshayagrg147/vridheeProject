// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'background_service_controller.dart';
//
// class BackgroundService {
//   static final BackgroundService instance = BackgroundService._internal();
//
//   factory BackgroundService() => instance;
//
//   BackgroundService._internal();
//
//   final FlutterBackgroundService _service = FlutterBackgroundService();
//
//   Future<void> initializeService() async {
//     await _service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         isForegroundMode: true,
//         // autoStart: true,
//         // foregroundServiceType: ForegroundServiceType.dataSync,
//       ),
//       iosConfiguration: IosConfiguration(
//         onForeground: onStart,
//         onBackground: onIosBackground,
//       ),
//     );
//   }
//
//   static void onStart(ServiceInstance service) async {
//     DartPluginRegistrant.ensureInitialized();
//
//     service.on('downloadFiles').listen((event) async {
//       await BackgroundServiceController.instance.performBackgroundTask();
//     });
//
//     service.on('stopService').listen((event) {
//       service.stopSelf();
//     });
//   }
//
//   static bool onIosBackground(ServiceInstance service) {
//     WidgetsFlutterBinding.ensureInitialized();
//     return true;
//   }
//
//   void startService() {
//     _service.startService();
//   }
//
//   void triggerDownload() {
//     // _service.sendData({'action': 'downloadFiles'});
//     _service.invoke("downloadFiles");
//   }
// }
