import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/pages/clicker_registeration/model/clicker_data.dart';
import 'package:teaching_app/pages/clicker_registeration/model/clicker_model.dart';
import 'package:teaching_app/services/clicker_service.dart';

class ClickerRegistrationController extends GetxController {
  final DatabaseController myDataController = Get.find();
  final _clickerSdk = TaghiveClickerSdk();
  final students = RxList<ClickerModel>();
  RxBool isLoading = false.obs;
  RxBool isTeacherRegistrationInProcess = false.obs;
  Rx<String?> teacherClickerId = Rx<String?>(null);
  Rx<String?> className = Rx<String?>(null);
  RxInt selectedStudentIndex = (-1).obs;

  StreamSubscription<Map<String, dynamic>>? _clickerStream;

  @override
  void onInit() {
    // FlutterClickerService.instance.setClickerScanMode(ClickerScanMode.dongle);
    // FlutterClickerService.instance.startClickerScanning();
    _initializeClickerBle();
    teacherClickerId.value = SharedPrefHelper().getTeacherClickerId();
    fetchStudents();

    super.onInit();
  }

  @override
  void dispose() {
    // FlutterClickerService.instance.stopClickerScanning();
    _clickerSdk.stopBleTask();
    _clickerStream?.cancel();
    _clickerStream = null;
    super.dispose();
  }

  void _initializeClickerBle() async {
    await _clickerSdk.checkPermissions();
  }

  void onStudentRegisterationCancel() {
    selectedStudentIndex.value = -1;
    _clickerStream?.cancel();
    _clickerStream = null;
    update();
  }

  void onTeacherRegistrationCancel() {
    isTeacherRegistrationInProcess.value = false;
    _clickerStream?.cancel();
    _clickerStream = null;
    update();
  }

  void onTeacherRegistration() async {
    selectedStudentIndex.value = -1;
    isTeacherRegistrationInProcess.value = true;
    update();
    _clickerStream?.cancel();
    _clickerStream = _clickerSdk.clickerEvents.listen((event) async {
      final data = ClickerData.fromJson(event);
      log(data.deviceId);
      log(data.btnPressed.toString() + "\t btn value");
      if (data.btnPressed == (7)) {
        await SharedPrefHelper().setTeacherClickerId(data.deviceId);
        teacherClickerId.value = SharedPrefHelper().getTeacherClickerId();

        onTeacherRegistrationCancel();
        return;
      }
    });
  }

  void onStudentRegistration(ClickerModel clickerModel,
      {required int index}) async {
    isTeacherRegistrationInProcess.value = false;
    selectedStudentIndex.value = index;
    update();
    if (_clickerStream != null) {
      _clickerStream?.cancel();
      _clickerStream = null;
    }
    _clickerStream = _clickerSdk.clickerEvents.listen((event) async {
      final data = ClickerData.fromJson(event);
      log(data.deviceId);
      log(data.btnPressed.toString() + "\t btn value");
      if (data.btnPressed == (selectedStudentIndex.value % 5)) {
        await myDataController.setClickerRollNo(clickerModel.rollNo,
            deviceId: data.deviceId);

        students[index] = students[index].copyWith(data.deviceId);
        onStudentRegisterationCancel();
        return;
      }
    });
  }

  void fetchStudents() async {
    try {
      isLoading.value = true;
      update();
      final response = await myDataController.getClickersData();
      students.clear();
      students.addAll(response);
    } catch (e) {
      print("error in fetching students :- $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void generateClickers(int clickersLength) async {
    isLoading.value = true;
    update();
    try {
      await myDataController.generateClickers(clickersLength);
      fetchStudents();
    } catch (e) {
      isLoading.value = false;
      update();
      print("error while generating clickers :- $e");
    }
  }
}
