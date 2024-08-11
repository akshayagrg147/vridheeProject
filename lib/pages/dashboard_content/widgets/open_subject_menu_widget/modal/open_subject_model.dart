import 'dart:developer';

import 'package:get/get.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/modals/tbl_institute_topic.dart';
import 'package:teaching_app/modals/tbl_institute_topic_data.dart';
import 'package:teaching_app/modals/tbl_intitute_chapter_model.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';

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
  List<int>? completedContentData;
  List<int>? completedQuestionData;

  LocalTopic(
      {required this.topic,
      required this.topicData,
      required this.questionData,
      this.completedContentData,
      this.completedQuestionData});

  Future<void> initiateContentCompleteCount() async {
    final databaseController = Get.find<DatabaseController>();
    if (topic.onlineInstituteTopicId == 1955 ||
        topic.instituteTopicId == 1955) {
      log('message');
    }
    final data = await databaseController.rawQuery(
        "select online_institute_topic_data_id as id from tbl_content_access where institute_topic_id = ${topic.instituteTopicId} and is_question = 0 ");
    final questionData = await databaseController.rawQuery(
        "select online_institute_topic_data_id as id from tbl_content_access where institute_topic_id = ${topic.onlineInstituteTopicId} and is_question = 1 ");
    completedContentData = (data ?? []).map((e) => e['id'] as int).toList();
    completedQuestionData =
        (questionData ?? []).map((e) => e['id'] as int).toList();
  }

  int get mediaCount {
    return topicData
        .where((data) =>
            data.topicDataType == 'HTML5' || data.topicDataType == 'MP4')
        .length;
  }

  int get eMaterialCount {
    return topicData.where((data) => data.topicDataType == "e-Material").length;
  }

  int get mediaCompletedCount {
    final idList = topicData
        .where((element) =>
            element.topicDataType == 'HTML5' || element.topicDataType == 'MP4')
        .map((e) => e.onlineInstituteTopicDataId)
        .toList();
    final count = (completedContentData ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get ematerialCompletedCount {
    final idList = topicData
        .where((element) => element.topicDataType == "e-Material")
        .map((e) => e.onlineInstituteTopicDataId)
        .toList();
    final count = (completedContentData ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get questionCompletedCount {
    final idList = questionData.map((e) => e.onlineLmsQuesBankId).toList();
    final count = (completedQuestionData ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }
}
