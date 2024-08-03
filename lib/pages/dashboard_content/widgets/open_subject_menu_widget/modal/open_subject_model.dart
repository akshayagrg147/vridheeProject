import 'package:get/get.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/modals/tbl_institute_topic.dart';
import 'package:teaching_app/modals/tbl_institute_topic_data.dart';
import 'package:teaching_app/modals/tbl_intitute_chapter_model.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/utils/string_constant.dart';

class LocalChapter {
  final InstituteChapter chapter;
  final List<LocalTopic> topics;

  LocalChapter({
    required this.chapter,
    required this.topics,
  });
}

class LocalTopic {
  final InstituteTopic topic;
  final List<InstituteTopicData> topicData;
  final List<QuestionBank> questionData;
  List<int>? existingContentPlanIds;

  LocalTopic({
    required this.topic,
    required this.topicData,
    required this.questionData,
    this.existingContentPlanIds,
  });

  Future<void> updateExistingContentPlanIds() async {
    final DatabaseController myDataController = Get.find();
    final List<Map<String, dynamic>> existingSyllabusData =
        await myDataController.rawQuery('''
      select institute_topic_data_id from ${StringConstant().tblSyllabusPlanning}
      where institute_topic_id = ${topic.onlineInstituteTopicId}
      
      ''');
    List<int> existingTopicDataIds = [];

    existingSyllabusData.forEach((element) {
      final id = element['institute_topic_data_id'];
      if (id != null) {
        existingTopicDataIds.add(id);
      }
    });

    existingContentPlanIds = existingTopicDataIds;
  }

  int get mediaCount {
    return topicData
        .where((data) =>
            data.topicDataType == 'HTML5' ||
            data.topicDataType == 'MP3' ||
            data.topicDataType == 'MP4')
        .length;
  }

  int get mediaSyllabusCount {
    final idList = topicData
        .where((element) =>
            element.topicDataType == 'HTML5' ||
            element.topicDataType == 'MP3' ||
            element.topicDataType == 'MP4')
        .map((e) => e.instituteTopicDataId)
        .toList();
    final count = (existingContentPlanIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get ematerialSyllabusCount {
    final idList = topicData
        .where((element) => element.topicDataType == 'Embedded')
        .map((e) => e.instituteTopicDataId)
        .toList();
    final count = (existingContentPlanIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get questionSyllabusCount {
    final idList = questionData.map((e) => e.onlineLmsQuesBankId).toList();
    final count = (existingContentPlanIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get eMaterialCount {
    return topicData.where((data) => data.topicDataType == 'Embedded').length;
  }
}
