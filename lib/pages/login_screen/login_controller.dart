import 'dart:developer';
// import 'dart:html';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:teaching_app/core/api_client/api_client.dart';
import 'package:teaching_app/core/api_client/api_exception.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/modals/sync_data/sync_data_response.dart';
import 'package:teaching_app/pages/login_screen/login_repository.dart';
import 'package:teaching_app/services/background_service.dart';
import '../../modals/register_device/register_device_response.dart';
import '../../services/ForegroundTaskService.dart';
import '../../services/background_service_controller.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  RxBool obscureText = true.obs;
  RxString selectedRole = RxString('Teacher');
  Rx<RegisterDeviceResponse> registerDeviceResponse =
      RegisterDeviceResponse().obs;
  Rx<SyncDataResponse> syncDataResponse = SyncDataResponse().obs;
  RxBool isLoading = false.obs;
  final DatabaseController myDataController = Get.find();
  RxBool isSyncDataLoading = false.obs;
  final isLoginSuccessful = SharedPrefHelper().getIsLoginSuccessful();
  RxString deviceIds = ''.obs;

  LoginController() {
    try {
      syncData();
      //
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  void startForegroundService() async {
    print("startForegroundService called");
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }
    FlutterForegroundTask.startService(
      callback: startCallback,
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
    ).then((value) {
      if (value) {
        print("Foreground service started successfully");
      } else {
        print("Failed to start foreground service");
      }
    }).catchError((error) {
      print("Error starting foreground service: $error");
    });
  }

  void callback3() {
    print("startCallback called");
  }

  // @pragma('vm:entry-point')
  // void startCallback() {
  //   print("startCallback called");
  //
  //   // BackgroundServiceController.instance.performBackgroundTask();
  // }

  void togglePasswordVisibility() {
    obscureText.toggle();
  }

  void checkLoginCredentials() {
    if (idController.text == 'akhileshredomud@gmail.com' &&
        passwordController.text == '1234') {
      print('Login successful');
    } else {
      print('Invalid credentials or captcha');
    }
  }

  Future<void> syncData() async {
    try {
      isSyncDataLoading.value = true;

      final response = await LoginRepository.getDeviceInfo(
          deviceId: SharedPrefHelper().getDeviceId());
      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        print("RegisterDevice :- $response");
        syncDataResponse.value = response;
        await executeAndNotify(syncDataResponse.value.data ?? []);
      } else {
        print("SyncDataError: ${response?.msg}");
      }

      print("SyncData :- $response");
    } catch (e) {
      print("SyncDataError :- $e");
      // Get.snackbar("SyncDataError", "$e");
    } finally {
      isSyncDataLoading.value = false;
    }

    final isLoginSuccessful = SharedPrefHelper().getIsLoginSuccessful();
    if (isLoginSuccessful) {
      return Get.offAllNamed("/");
    }
  }

  Future<void> executeAndNotify(List<Datum> items) async {
    String temp = '';
    for (var item in items) {
      try {
        await myDataController.performTransaction(
            query: item.queryStatement ?? '');
        temp = '$temp${item.offlineDeviceSyncRelId ?? ''},';
      } catch (e) {
        print('Error executing query: $e');
      }
    }
    final isSynced = SharedPrefHelper().getIsSynced();
    if (isSynced == false) {
      if (GetPlatform.isAndroid) {
        ForegroundTaskService.init();
        startForegroundService();
      } else if (GetPlatform.isWindows) {
        BackgroundServiceController.instance.performBackgroundTask();
      }
    }
    if (temp.trim().isNotEmpty) {
      await notifyBackend(temp.substring(0, temp.length - 1));
    } else {
      print('UpdateResponseError => Invalid db query');
    }
  }

  Future<void> notifyBackend(String queryId) async {
    try {
      final response = await LoginRepository.updateSyncData(syncId: queryId);
      print('UpdateResponse: $response');
      if (response == null || response.success == false) {
        Get.snackbar("UpdateResponseError", "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("UpdateResponseError", '$e');
      print('UpdateResponseError: $e');
    }
  }

  void login() async {
    isLoading.value = true;
    try {
      final response = await myDataController.getLogin(
        user: idController.text,
        password: passwordController.text,
        role: selectedRole.value,
      );
      if (response == true) {
        print("LoginDevice :- $response");
        await SharedPrefHelper().setIsLoginSuccessful(true);

        await SharedPrefHelper().setLoginUserMail(idController.text);
        Get.offAllNamed("/");
      } else {
        Get.snackbar("LoginDeviceError", "User Id or Password is Wrong");
      }
    } catch (e) {
      print("LoginDeviceError :- $e");
      Get.snackbar("LoginDeviceError", "$e");
    } finally {
      isLoading.value = false;
    }
  }
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'eventCount: $_eventCount',
    );

    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}
