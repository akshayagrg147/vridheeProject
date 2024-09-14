import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/pages/clicker_registration/modal/student_data_model.dart';
import 'package:teaching_app/services/clicker_service.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

class ClickerRegistrationController extends GetxController {
  final DatabaseController myDataController = Get.find();

  final students = RxList<StudentDataModel>();
  RxBool isLoading = false.obs;
  Rx<String?> className = Rx<String?>(null);
  RxInt selectedStudentIndex = (-1).obs;

  StreamSubscription<ClickerData>? _clickerStream;
  @override
  void onInit() {
    final args = Get.arguments;
    if(args!=null&& args is List){
      final instituteCourseId =args.isNotEmpty?args.first:null;
      final classNo = args.length>1?args[1]:null;
      if(classNo!=null){
        className.value= ">> Class $classNo";

      }
      if(instituteCourseId!=null){
        fetchStudents(instituteCourseId);
      }
    }

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
  void onStudentRegistration(StudentDataModel data,{required int index})async{

    FlutterClickerService.instance.setClickerScanMode(ClickerScanMode.dongle);
    final isAvailable = await FlutterClickerService.instance.isClickerScanningAvailable();
    log("clicker scanning available :- $isAvailable");
    if(isAvailable){
      selectedStudentIndex.value = index;
      update();
      FlutterClickerService.instance.startClickerScanning();
if(_clickerStream!=null){
  _clickerStream?.cancel();
  _clickerStream=null;
}
     _clickerStream= FlutterClickerService.instance.clickerScanStream.listen((event)async {
        log(event.deviceId);
        log(event.clickerButtonValue.index.toString() +"\t btn value");
        if(event.clickerButtonValue.index==(selectedStudentIndex.value%5)){
         await myDataController.setStudentClickerID(studentSessionId: data.sessionId, clickerID: event.deviceId);
         students[index]= students[index].copyWith(event.deviceId);
         onStudentRegisterationCancel();
          return;
        }
      });

    }


  }


  void fetchStudents(int instituteCourseId)async{
    try{
      isLoading.value=true;
      update();
    final response = await myDataController.fetchStudentsByClass(instituteCourseId);
    students.clear();
    students.addAll(response);
    }catch(e){
  print("error in fetching students :- $e");
    }finally{
isLoading.value=false;
update();

    }
  }

}