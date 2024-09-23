import 'package:teaching_app/modals/tbl_institute_topic.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';

class QuizArgumentModel {
  final String className;
  final String subjectName;
  final String chapterName;
  final List<QuestionBank> questions;
  final InstituteTopic topicData;

  QuizArgumentModel(
      {required this.className,
      required this.subjectName,
      required this.chapterName,
      required this.questions,
      required this.topicData});
}
