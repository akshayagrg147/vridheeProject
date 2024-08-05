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

  LocalTopic(
      {required this.topic,
      required this.topicData,
      required this.questionData});

  int get mediaCount {
    return topicData
        .where((data) =>
            data.topicDataType == 'HTML5' || data.topicDataType == 'MP4')
        .length;
  }

  int get eMaterialCount {
    return topicData.where((data) => data.topicDataType == "e-Material").length;
  }
}
