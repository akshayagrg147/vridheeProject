import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/pages/clicker_registration/modal/clicker_model.dart';
import 'package:teaching_app/services/clicker_service.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

class ClickerRegistrationController extends GetxController {
  final DatabaseController myDataController = Get.find();

  final students = RxList<ClickerModel>();
  RxBool isLoading = false.obs;
  RxBool isTeacherRegistrationInProcess = false.obs;
  Rx<String?> teacherClickerId = Rx<String?>(null);
  Rx<String?> className = Rx<String?>(null);
  RxInt selectedStudentIndex = (-1).obs;

  StreamSubscription<ClickerData>? _clickerStream;

  @override
  void onInit() {
    FlutterClickerService.instance.setClickerScanMode(ClickerScanMode.dongle);
    FlutterClickerService.instance.startClickerScanning();
  teacherClickerId.value= SharedPrefHelper().getTeacherClickerId();
        fetchStudents();


    super.onInit();
  }

  @override
  void dispose() {
    FlutterClickerService.instance.stopClickerScanning();
    _clickerStream?.cancel();
    _clickerStream=null;
    super.dispose();
  }

  void onStudentRegisterationCancel(){
    selectedStudentIndex.value=-1;
    _clickerStream?.cancel();
    _clickerStream=null;
    update();
  }

  void onTeacherRegistrationCancel(){
    isTeacherRegistrationInProcess.value=false;
    _clickerStream?.cancel();

    _clickerStream=null;
update();
  }

  void onTeacherRegistration()async{

    final isAvailable = await FlutterClickerService.instance.isClickerScanningAvailable();
    if(isAvailable){
      selectedStudentIndex.value=-1;
      isTeacherRegistrationInProcess.value=true;
      update();
      _clickerStream?.cancel();
      _clickerStream= FlutterClickerService.instance.clickerScanStream.listen((event)async {
        log(event.deviceId);
        log(event.clickerButtonValue.index.toString() +"\t btn value");
        if(event.clickerButtonValue.index==(7)){
         await SharedPrefHelper().setTeacherClickerId(event.deviceId);
         teacherClickerId.value= SharedPrefHelper().getTeacherClickerId();

          onTeacherRegistrationCancel();
          return;
        }
      });
    }

  }

  void onStudentRegistration(ClickerModel data,{required int index})async{

    final isAvailable = await FlutterClickerService.instance.isClickerScanningAvailable();
    log("clicker scanning available :- $isAvailable");
    if(isAvailable){
      isTeacherRegistrationInProcess.value=false;
      selectedStudentIndex.value = index;
      update();
if(_clickerStream!=null){
  _clickerStream?.cancel();
  _clickerStream=null;
}
     _clickerStream= FlutterClickerService.instance.clickerScanStream.listen((event)async {
        log(event.deviceId);
        log(event.clickerButtonValue.index.toString() +"\t btn value");
        if(event.clickerButtonValue.index==(selectedStudentIndex.value%5)){
         await myDataController.setClickerRollNo(data.rollNo, deviceId: event.deviceId);

         students[index]= students[index].copyWith(event.deviceId);
         onStudentRegisterationCancel();
          return;
        }
      });

    }


  }


  void fetchStudents()async{
    try{
      isLoading.value=true;
      update();
    final response = await myDataController.getClickersData();
    students.clear();
    students.addAll(response);
    }catch(e){
  print("error in fetching students :- $e");
    }finally{
isLoading.value=false;
update();

    }
  }

  void generateClickers(int clickersLength) async{
    isLoading.value=true;
    update();
    try{
  await  myDataController.generateClickers(clickersLength);
    fetchStudents();

    }
        catch(e){
          isLoading.value=false;
          update();
      print("error while generating clickers :- $e");
        }

  }

}