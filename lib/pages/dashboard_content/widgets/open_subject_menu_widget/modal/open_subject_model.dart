import 'package:get/get.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:teaching_app/database/database_helper_dummy.dart';
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
  List<int>? existingQuestionPlanIds;

  LocalTopic({
    required this.topic,
    required this.topicData,
    required this.questionData,
    this.existingContentPlanIds,
    this.existingQuestionPlanIds
  });

  Future<void> updateExistingContentPlanIds() async {
    final Database? myDataController =await DatabaseHelper().database ;
    if(myDataController==null){
      existingContentPlanIds=[];
      return ;
    }
    final List<Map<String, dynamic>> existingSyllabusData =
        await myDataController.rawQuery('''
      select Distinct(institute_topic_data_id) from ${StringConstant().tblSyllabusPlanning}
      where institute_topic_id = ${topic.instituteTopicId} and content_type != "question"
      
      ''');
    List<int> existingTopicDataIds = [];

    for (var element in existingSyllabusData) {
      final id = element['institute_topic_data_id'];
      if (id != null) {
        existingTopicDataIds.add(id);
      }
    }

    final List<Map<String, dynamic>> existingQuestionSyllabusData =
    await myDataController.rawQuery('''
      select Distinct(institute_topic_data_id) from ${StringConstant().tblSyllabusPlanning}
      where institute_topic_id = ${topic.instituteTopicId} and content_type == "question"
      
      ''');
    List<int> existingQuestionDataIds = [];

    for (var element in existingQuestionSyllabusData) {
      final id = element['institute_topic_data_id'];
      if (id != null) {
        existingQuestionDataIds.add(id);
      }
    }

    existingContentPlanIds = existingTopicDataIds;
    existingQuestionPlanIds=existingQuestionDataIds;
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
        .where((element) => element.topicDataType == 'Embedded'||element.topicDataType == "e-Material")
        .map((e) => e.instituteTopicDataId)
        .toList();
    final count = (existingContentPlanIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get questionSyllabusCount {
    final idList = questionData.map((e) => e.onlineLmsQuesBankId).toList();
    final count = (existingQuestionPlanIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get eMaterialCount {
    return topicData.where((data) => data.topicDataType == 'Embedded').length;
  }
}
