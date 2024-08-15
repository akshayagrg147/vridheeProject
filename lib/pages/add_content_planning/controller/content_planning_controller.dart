import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/header/header_dashboard_controller.dart';
import 'package:teaching_app/services/background_service_controller.dart';
import 'package:teaching_app/utils/string_constant.dart';

import '../../../database/datebase_controller.dart';
import '../../../modals/tbl_institute_topic_data.dart';
import '../../dashboard_content/widgets/open_subject_menu_widget/modal/open_subject_model.dart';

class ContentPlanningController extends GetxController {
  final DatabaseController myDataController = Get.find();

  var selectedTopic = Rxn<LocalTopic>();
  var selectedChapter = Rxn<LocalChapter>();
  var className = RxnString();

  // var subjectName = RxnString();
  var chapterName = RxnString();
  var topicName = RxnString();
  var subjectName = RxnString();
  var topics = RxList<InstituteTopicData>().obs;

  var allVideoList = RxList<InstituteTopicData>().obs;
  var allEMaterialList = RxList<InstituteTopicData>().obs;
  var allQuestionList = RxList<QuestionBank>().obs;

  var selectedVideoList = RxList<InstituteTopicData>().obs;
  var selectedEMaterialList = RxList<InstituteTopicData>().obs;
  var selectedQuestionList = RxList<QuestionBank>().obs;

  var initiallySelectedVideoList = <InstituteTopicData>[];
  var initiallySelectedEMaterialList = <InstituteTopicData>[];
  var initiallySelectedQuestionList = <QuestionBank>[];

  var videoSelected = false.obs;
  var eMaterialSelected = false.obs;
  var questionSelected = false.obs;

  var englishSelected = false.obs;
  var hindiSelected = false.obs;
  var odiaSelected = false.obs;
  String? type;
  @override
  void onInit() async {
    super.onInit();

    List<dynamic> args = Get.arguments;

    // print("in else");
    selectedTopic.value = args[0];
    selectedChapter.value = args[1];
    type = args[2] ?? "";
    className.value =
        await fetchClassName(selectedTopic.value!.topic.instituteCourseId);
    // int subjectId = -1;
    // String chapter = '';
    // (chapter, subjectId) =
    //     await fetchChapterName(selectedTopic.value!.topic.instituteChapterId);
    chapterName.value = selectedChapter.value?.chapter.chapterName;
    subjectName.value = await fetchSubjectName(
        selectedChapter.value!.chapter.instituteSubjectId);

    topicName.value = selectedTopic.value!.topic.topicName;
    topics.value.assignAll(selectedTopic.value!.topicData);
    filterTopicData();
    allQuestionList.value.assignAll(selectedTopic.value!.questionData);
    fetchExistingSelections();
    // currentTopicData.value = topics.value[1];
    // Now you can use the chapterData as needed
  }

  @override
  void onClose() {
    Get.find<DashboardHeaderController>().fetchDataForSelectedSubject();
    Get.find<DashboardHeaderController>().fetchContinueData();

    super.dispose();
  }
  // void submitPlan(){
  //
  // }

  void toggleSelection(InstituteTopicData data, bool isSelected, bool isVideo,
      bool isEMaterial, bool isQuestion) {
    if (isVideo) {
      isSelected
          ? selectedVideoList.value.add(data)
          : selectedVideoList.value.remove(data);
    } else if (isEMaterial) {
      isSelected
          ? selectedEMaterialList.value.add(data)
          : selectedEMaterialList.value.remove(data);
    }
  }

  void toggleQuestionSelection(
    QuestionBank data,
    bool isSelected,
  ) {
    isSelected
        ? selectedQuestionList.value.add(data)
        : selectedQuestionList.value.remove(data);
  }

  bool isQuestionSelected(
    QuestionBank data,
  ) {
    return selectedQuestionList.value.contains(data);
  }

  bool isSelected(InstituteTopicData data, bool isVideo, bool isEMaterial,
      bool isQuestion) {
    if (isVideo) {
      return selectedVideoList.value.contains(data);
    } else if (isEMaterial) {
      return selectedEMaterialList.value.contains(data);
    } else if (isQuestion) {
      return selectedQuestionList.value.contains(data);
    }
    return false;
  }

  Future<void> fetchExistingSelections() async {
    // print(selectedTopic.value!.topic.instituteTopicId.toDouble());

    try {
      final List<Map<String, dynamic>> existingSyllabusData =
          await myDataController.query(
        StringConstant().tblSyllabusPlanning,
        where: 'institute_topic_id = ?',
        whereArgs: [selectedTopic.value!.topic.onlineInstituteTopicId],
      );

      List<int> existingTopicDataIds = [];

      existingSyllabusData.forEach((element) {
        final id = element['institute_topic_data_id'];
        if (id != null) {
          existingTopicDataIds.add(id);
        }
      });

      print(existingTopicDataIds);

      //for video data
      for (var videoData in allVideoList.value) {
        if (existingTopicDataIds.contains(videoData.instituteTopicDataId)) {
          selectedVideoList.value.add(videoData);
          initiallySelectedVideoList.add(videoData);
        }
      }

      // for e-material data
      for (var eMaterialData in allEMaterialList.value) {
        if (existingTopicDataIds.contains(eMaterialData.instituteTopicDataId)) {
          selectedEMaterialList.value.add(eMaterialData);
          initiallySelectedEMaterialList.add(eMaterialData);
        }
      }

      // for questions data
      for (var quesData in allQuestionList.value) {
        if (existingTopicDataIds.contains(quesData.onlineLmsQuesBankId)) {
          selectedQuestionList.value.add(quesData);
          initiallySelectedQuestionList.add(quesData);
        }
      }
    } catch (e) {
      print('Error fetching existing selections: $e');
    }

    if (initiallySelectedQuestionList.isNotEmpty) {
      questionSelected.value = true;
    }
    if (initiallySelectedEMaterialList.isNotEmpty) {
      eMaterialSelected.value = true;
    }
    if (initiallySelectedVideoList.isNotEmpty) {
      videoSelected.value = true;
    }

    if (!(questionSelected.value ||
        eMaterialSelected.value ||
        videoSelected.value)) {
      videoSelected.value = true;
    }
  }

  void filterTopicData() {
    var videoData = topics.value
        .where((topic) =>
            topic.topicDataType == "HTML5" || topic.topicDataType == "MP4")
        .toList();
    // print("filter video dxata :${videoData.length} : ${videoData[videoData.length -1].instituteTopicId}");
    var eMaterialData = topics.value
        .where((topic) => topic.topicDataType == "e-Material")
        .toList();
    // var aiContentData = topics.value.where((topic) => topic.topicDataType == "e-Content (AI)").toList();
    allVideoList.value.clear();
    allEMaterialList.value.clear();
    allVideoList.value.assignAll(videoData);
    allVideoList.refresh();

    allEMaterialList.value.assignAll(eMaterialData);
    allEMaterialList.refresh();
  }

  Future<String> fetchClassName(int courseId) async {
    try {
      final List<Map<String, dynamic>> classDataMaps =
          await myDataController.query(
        'tbl_institute_course',
        where: 'online_institute_course_id = ?',
        whereArgs: [courseId],
      );

      if (classDataMaps.isNotEmpty) {
        final String className =
            classDataMaps.first['institute_course_name'] as String;
        return className;
      } else {
        return ''; // Handle the case where no class name is found
      }
    } catch (e) {
      print('Error fetching class name: $e');
      return ''; // Handle error case
    }
  }

  Future<String> fetchSubjectName(int instituteSubjectId) async {
    try {
      final List<Map<String, dynamic>> subjectDataMaps =
          await myDataController.query(
        'tbl_institute_subject',
        where: 'online_institute_subject_id = ?',
        whereArgs: [instituteSubjectId],
      );

      if (subjectDataMaps.isNotEmpty) {
        final String subjectName =
            subjectDataMaps.first['subject_name'] as String;
        return subjectName;
      } else {
        return ''; // Handle the case where no class name is found
      }
    } catch (e) {
      print('Error fetching class name: $e');
      return ''; // Handle error case
    }
  }

  Future<(String, int)> fetchChapterName(int chapterId) async {
    try {
      final List<Map<String, dynamic>> chapterDataMaps =
          await myDataController.query(
        'tbl_institute_chapter',
        where: 'online_institute_chapter_id = ?',
        // Assuming online_institute_chapter_id is the primary key
        whereArgs: [chapterId],
      );

      if (chapterDataMaps.isNotEmpty) {
        final String chapterName =
            chapterDataMaps.first['chapter_name'] as String;
        final int subjectId =
            chapterDataMaps.first['institute_subject_id'] as int;
        return (chapterName, subjectId);
      } else {
        return ('', -1); // Handle the case where no chapter name is found
      }
    } catch (e) {
      print('Error fetching chapter name: $e');
      return ('', -1); // Handle error case
    }
  }

  // {
  // syllabus_planning_id: 102.0,
  // online_syllabus_planning_id: null,
  // institute_id: 20.0,
  // institute_course_id: 12.0,
  // institute_course_breakup_id: 5702.0,
  // institute_subject_id: 131.0,
  // institute_chapter_id: 537.0,
  // institute_topic_id: 1955.0,
  // institute_topic_data_id: null,
  // question_bank_id: 25955.0,
  // content_type: Question,
  // start_year: 2024.0,
  // end_year: 2025.0,
  // created_date: 2024-05-09 19:35:46,
  // updated_date: 2024-05-09 19:35:46}
  void reset() {
    selectedVideoList.value.clear();
    selectedEMaterialList.value.clear();
    selectedQuestionList.value.clear();
  }

  void submitPlan() async {
    try {
      for (var videoData in selectedVideoList.value) {
        final isInserted = initiallySelectedVideoList.contains(videoData);

        if (!isInserted) {
          Map<String, dynamic> data = {
            'online_syllabus_planning_id': null,
            'institute_id': videoData.instituteId,
            'institute_course_id': selectedTopic.value!.topic.instituteCourseId,
            'institute_course_breakup_id': null,
            'institute_subject_id': null,
            'institute_chapter_id':
                selectedTopic.value!.topic.instituteChapterId,
            'institute_topic_id': videoData.instituteTopicId,
            'institute_topic_data_id': videoData.instituteTopicDataId,
            'question_bank_id': null,
            'content_type': videoData.topicDataType,
            'start_year': 2024,
            'end_year': 2025,
            'created_date': DateTime.now().toIso8601String(),
            'updated_date': DateTime.now().toIso8601String(),
            'plan_priority': null
          };

          int id = await myDataController.insert(
              StringConstant().tblSyllabusPlanning, data);
          print(
              "Plan inserted row id: $id : ${videoData.instituteTopicId} :${videoData.instituteTopicDataId} ");
        }
      }
      for (var eMaterialData in selectedEMaterialList.value) {
        final isInserted =
            initiallySelectedEMaterialList.contains(eMaterialData);
        if (!isInserted) {
          Map<String, dynamic> data = {
            'online_syllabus_planning_id': null,
            'institute_id': eMaterialData.instituteId,
            'institute_course_id': selectedTopic.value!.topic.instituteCourseId,
            'institute_course_breakup_id': null,
            'institute_subject_id': null,
            'institute_chapter_id':
                selectedTopic.value!.topic.instituteChapterId,
            'institute_topic_id': eMaterialData.instituteTopicId,
            'institute_topic_data_id': eMaterialData.instituteTopicDataId,
            'question_bank_id': null,
            'content_type': eMaterialData.topicDataType,
            'start_year': 2024,
            'end_year': 2025,
            'created_date': DateTime.now().toIso8601String(),
            'updated_date': DateTime.now().toIso8601String(),
            'plan_priority': null
          };

          int id = await myDataController.insert(
              StringConstant().tblSyllabusPlanning, data);
          print(
              "Plan inserted row id: $id : ${eMaterialData.instituteTopicId} :${eMaterialData.instituteTopicDataId} ");
        }
      }
      for (var quesData in selectedQuestionList.value) {
        final isInserted = initiallySelectedQuestionList.contains(quesData);

        if (!isInserted) {
          Map<String, dynamic> data = {
            'online_syllabus_planning_id': null,
            'institute_id': quesData.instituteId,
            'institute_course_id': selectedTopic.value!.topic.instituteCourseId,
            'institute_course_breakup_id': null,
            'institute_subject_id': null,
            'institute_chapter_id':
                selectedTopic.value!.topic.instituteChapterId,
            'institute_topic_id': quesData.instituteTopicId,
            'institute_topic_data_id': quesData.onlineLmsQuesBankId,
            'question_bank_id': null,
            'content_type': "Question",
            'start_year': 2024,
            'end_year': 2025,
            'created_date': DateTime.now().toIso8601String(),
            'updated_date': DateTime.now().toIso8601String(),
            'plan_priority': null
          };

          int id = await myDataController.insert(
              StringConstant().tblSyllabusPlanning, data);
          print(
              "Plan inserted row id: $id : ${quesData.instituteTopicId} :${quesData.onlineLmsQuesBankId} ");
        }
      }
      for (var videoData in initiallySelectedVideoList) {
        if (!selectedVideoList.value.contains(videoData)) {
          await myDataController.delete(
            StringConstant().tblSyllabusPlanning,
            where: 'institute_topic_data_id = ?',
            whereArgs: [videoData.instituteTopicDataId],
          );
          print(
              "Plan deleted: ${videoData.instituteTopicId} :${videoData.instituteTopicDataId}");
        }
      }

      for (var eMaterialData in initiallySelectedEMaterialList) {
        if (!selectedEMaterialList.value.contains(eMaterialData)) {
          await myDataController.delete(
            StringConstant().tblSyllabusPlanning,
            where: 'institute_topic_data_id = ?',
            whereArgs: [eMaterialData.instituteTopicDataId],
          );
          print(
              "Plan deleted: ${eMaterialData.instituteTopicId} :${eMaterialData.instituteTopicDataId}");
        }
      }
      for (var quesData in initiallySelectedQuestionList) {
        if (!selectedQuestionList.value.contains(quesData)) {
          await myDataController.delete(
            StringConstant().tblSyllabusPlanning,
            where: 'institute_topic_data_id = ?',
            whereArgs: [quesData.onlineLmsQuesBankId],
          );
          print(
              "Plan deleted: ${quesData.instituteTopicId} :${quesData.onlineLmsQuesBankId}");
        }
      }
    } catch (e) {
      print("Error inserting plan data: $e");
    }
  }

  void addContent() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result?.xFiles.isNotEmpty == true) {
        final file = result!.xFiles.first;
        Get.dialog(
            Center(
              child: CircularProgressIndicator(),
            ),
            barrierDismissible: false);
        final data = await file.readAsBytes();
        String outputDirPath = await BackgroundServiceController.instance
            .getContentDirectoryPath();
        final dt = DateTime.now();
        final onlineId = dt.millisecondsSinceEpoch;
        final ext = file.path.split('.').last;
        final outputFilePath = "$outputDirPath/$onlineId.$ext";
        final employeedataList = await myDataController.query('tbl_employee',
            where: 'user_email_id = ?',
            whereArgs: [SharedPrefHelper().getLoginUserMail()]);
        final employeedata = employeedataList.first;

        InstituteTopicData topicData = InstituteTopicData(
            instituteTopicDataId: null,
            onlineInstituteTopicDataId: onlineId,
            instituteId: employeedata['institute_id'],
            parentInstituteId: employeedata['parent_institute_id'],
            instituteTopicId: selectedTopic.value!.topic.onlineInstituteTopicId,
            topicDataKind: "",
            topicDataType: getTopicDataType(ext),
            topicDataFileCodeName: file.path.split('/').last.split('.').first,
            code: '',
            fileNameExt: ext,
            html5FileName: '',
            referenceUrl: '',
            noOfClicks: 0,
            displayType: 'Public',
            entryByInstituteUserId:
                employeedata['online_institute_user_id'].toString(),
            addedType: 'Manual',
            contentLevel: 'Basic',
            topicName: topicName.value,
            contentTag: '',
            contentLang: 'English',
            isVerified: 'Yes',
            isLocalContentAvailable: 1,
            html5DownloadUrl: '');
        await FileEncryptor().encryptFile(File(file.path), outputFilePath);
        final id = await myDataController.insert(
            'tbl_institute_topic_data', topicData.toJson());
        topicData.instituteTopicDataId = id;
        topics.value.add(topicData);
        filterTopicData();
        Get.back();
        Get.showSnackbar(const GetSnackBar(
          message: "File added successfully!",
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      Get.back();
      Get.showSnackbar(const GetSnackBar(
        message: "Something went wrong",
        duration: const Duration(seconds: 2),
      ));
    }
  }

  String getTopicDataType(String ext) {
    final vidExt = ['mp4', 'mkv'];
    final docExt = ['pdf', 'xlxs', 'doc', 'text'];
    if (vidExt.contains(ext)) {
      return 'MP4';
    } else if (docExt.contains(ext)) {
      return 'e-Material';
    }
    return ext.toUpperCase();
  }
}
