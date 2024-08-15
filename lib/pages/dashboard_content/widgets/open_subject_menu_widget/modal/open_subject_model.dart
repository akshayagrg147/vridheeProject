import 'dart:developer';

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

  LocalTopic({
    required this.topic,
    required this.topicData,
    required this.questionData,
  });

  int get mediaCount {
    return topicData
        .where((data) =>
            data.topicDataType == 'HTML5' || data.topicDataType == 'MP4')
        .length;
  }

  int get eMaterialCount {
    return topicData.where((data) => data.topicDataType == "e-Material").length;
  }

  int get mediaSyllabuscount {
    final idList = topicData
        .where((element) =>
            element.topicDataType == 'HTML5' || element.topicDataType == 'MP4')
        .map((e) => e.instituteTopicDataId)
        .toList();
    final count = (topic.syllabusTopicDataIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get eMaterialSyllabusCount {
    final idList = topicData
        .where((element) => element.topicDataType == "e-Material")
        .map((e) => e.instituteTopicDataId)
        .toList();
    final count = (topic.syllabusTopicDataIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }

  int get questionSyllabusCount {
    if (topic.instituteTopicId == 110) {
      log('message');
    }
    final idList = questionData.map((e) => e.onlineLmsQuesBankId).toList();
    final count = (topic.syllabusQuestionIds ?? [])
        .where((instituteTopicDataId) => idList.contains(instituteTopicDataId))
        .length;
    return count;
  }
}
