import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/modals/tbl_institute_topic.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/clicker_registration/modal/student_data_model.dart';
import 'package:teaching_app/pages/quiz/models/quiz_argument_model.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';
import 'package:teaching_app/services/clicker_service.dart';

class QuizController extends GetxController{
  final DatabaseController myDataController = Get.find();

  RxBool isLoading = false.obs;
  RxString className= "".obs;
  RxString subjectName = "".obs;
  RxString chapterName = "".obs;
  Rx<InstituteTopic?> topic = Rx<InstituteTopic?>(null);
  RxList<QuestionBank> questions = RxList();

  RxList<StudentDataModel> students = RxList();

  String teacherClickerId = "";
  StreamSubscription<ClickerData>? _clickerStream;

  @override
  void onInit() {
    final argument = Get.arguments as QuizArgumentModel;
    className.value = argument.className;
    subjectName.value = argument.subjectName;
    chapterName.value = argument.chapterName;
    topic.value= argument.topicData;
    questions.clear();
    questions.addAll(argument.questions);
    teacherClickerId=SharedPrefHelper().getTeacherClickerId()??"";

    super.onInit();
  }

  _initiateClickerStream(){
    FlutterClickerService.instance.setClickerScanMode(ClickerScanMode.dongle);
    FlutterClickerService.instance.startClickerScanning();
    _clickerStream?.cancel();
    _clickerStream=FlutterClickerService.instance.clickerScanStream.listen((event)async {
      final deviceId = event.deviceId;
      final clickerButtonValueIndex = event.clickerButtonValue.index;
      log(deviceId);
      log(clickerButtonValueIndex.toString() +"\t btn value");
      // if()

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }




}