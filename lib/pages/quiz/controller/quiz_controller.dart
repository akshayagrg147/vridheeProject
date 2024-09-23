import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:teaching_app/core/helper/helper.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/modals/tbl_institute_topic.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/clicker_registeration/model/clicker_data.dart';
import 'package:teaching_app/pages/clicker_registeration/model/student_data_model.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/header/header_dashboard_controller.dart';
import 'package:teaching_app/pages/quiz/models/quiz_argument_model.dart';
import 'package:teaching_app/pages/quiz/models/student_answer_model.dart';
import 'package:teaching_app/pages/quiz/models/student_quiz_summary_model.dart';
import 'package:teaching_app/services/clicker_service.dart';
import 'package:teaching_app/utils/enums.dart';

class QuizController extends GetxController {
  final DatabaseController myDataController = Get.find();
  final DashboardHeaderController headerController = Get.find();
  final _clickerSdk = TaghiveClickerSdk();
  RxBool isLoading = false.obs;
  RxBool isTimerInProgress = false.obs;
  RxBool showQuizSummary = false.obs;
  RxBool showStudentReport = false.obs;
  StudentExamResult? studentResult;
  RxString className = "".obs;
  RxString subjectName = "".obs;
  RxString chapterName = "".obs;
  Rx<InstituteTopic?> topic = Rx<InstituteTopic?>(null);
  RxList<QuestionBank> questions = RxList();
  Timer? questionTimer;
  List<StudentExamResult> studentExamResult = [];
  Rx<int> questionDurationRemaining = 0.obs;

  RxList<StudentDataModel> students = RxList();

  String teacherClickerId = "";
  StreamSubscription<ClickerData>? _clickerStream;
  RxMap<int, List<StudentAnswerModel>> questionStatus =
      RxMap<int, List<StudentAnswerModel>>();
  RxMap<String, StudentAnswerModel> currentQuestionStudentResponse =
      RxMap<String, StudentAnswerModel>();

  final questionDuration = 120;
  final questionMarks = 2;

  late Rx<QuestionBank> currentQuestion;
  Rx<int> currentQuestionIndex = 0.obs;

  late DateTime examStartTime;
  DateTime? examEndTime;
  late num examTotalMarks;
  late num examTotalDuration;

  bool get isCurrentQuestionAnswered =>
      questionStatus.containsKey(currentQuestion.value.onlineLmsQuesBankId);

  double quizScore() {
    final totalScore = questionMarks * questions.length * students.length;
    int totalStudentsScore = 0;
    for (var question in questions) {
      final response = questionStatus[question.onlineLmsQuesBankId];
      if (response != null) {
        totalStudentsScore += response.fold(
            0,
            (previousValue, element) =>
                previousValue +
                (getCorrectAnswerIndex().contains(element.optionSelected)
                    ? questionMarks
                    : 0));
      }
    }
    return (totalStudentsScore / totalScore) * 100;
  }

  setStudentExamResults() {
    List<StudentExamResult> examResult = [];
    for (var element in students) {
      int correctCount = 0;
      int wrongCount = 0;
      int naCount = 0;
      final Map<int, int> studentResponse = {};

      for (var response in questionStatus.entries) {
        final questionResponse = response.value.firstWhereOrNull(
            (answer) => answer.deviceId == element.clickerDeviceID);
        final question = questions.firstWhereOrNull(
            (ques) => ques.onlineLmsQuesBankId == response.key);
        studentResponse[response.key] = questionResponse?.optionSelected ?? -1;
        final correctAnswerIndex = getCorrectAnswerIndex(question: question);
        if (correctAnswerIndex.contains(questionResponse?.optionSelected)) {
          correctCount += 1;
        } else if (questionResponse?.optionSelected == -1) {
          naCount += 1;
        } else {
          wrongCount += 1;
        }
      }
      final studentResult = StudentExamResult(
          rollNo: element.rollNo,
          name: element.name,
          email: element.email,
          mobile: element.mobile,
          studentResponse: studentResponse,
          wrongAnswerCount: wrongCount,
          naAnswerCount: naCount,
          correctAnswerCount: correctCount);

      examResult.add(studentResult);
    }
    studentExamResult.clear();
    studentExamResult.addAll(examResult);
  }

  @override
  void onInit() {
    _initialize();

    super.onInit();
  }

  void showStudentSpecificReport(StudentExamResult studentResult) {
    showStudentReport.value = true;
    showQuizSummary.value = false;
    this.studentResult = studentResult;
    update();
  }

  void showQuizSummaryReport() {
    showStudentReport.value = false;
    showQuizSummary.value = true;
    studentResult = null;
    update();
  }

  _initialize() async {
    final argument = Get.arguments as QuizArgumentModel;
    className.value = argument.className;
    subjectName.value = argument.subjectName;
    chapterName.value = argument.chapterName;
    topic.value = argument.topicData;
    questions.clear();
    questions.addAll(argument.questions);
    await fetchStudents(topic.value!.instituteCourseId);
    currentQuestion = questions[0].obs;
    examStartTime = DateTime.now();
    examTotalMarks = questionMarks * questions.length;
    examTotalDuration = questionDuration * questions.length;
    teacherClickerId = SharedPrefHelper().getTeacherClickerId() ?? "";
    _initiateClickerStream();
    update();
    questionDurationRemaining.value = questionDuration;
    resumeTimer();
  }

  _initiateClickerStream() async {
    await _clickerSdk.checkPermissions();
    _clickerStream?.cancel();
    _clickerSdk.clickerEvents.listen((event) async {
      final data = ClickerData.fromJson(event);
      log(data.deviceId);
      log(data.btnPressed.toString() + "\t btn value");
      if (data.deviceId == teacherClickerId) {
        teacherClickerFunctions(data.btnPressed);
      } else if (isTimerInProgress.value &&
          data.btnPressed < currentQuestion.value.noOfOption) {
        currentQuestionStudentResponse[data.deviceId] = StudentAnswerModel(
            optionSelected: data.btnPressed + 1,
            deviceId: data.deviceId,
            answeredTime: DateTime.now(),
            duration: questionTimer?.tick ?? 0);
      }
    });
  }

  teacherClickerFunctions(int btnIndex) {
    switch (btnIndex) {
      case 0:
        if (isLoading.value || isCurrentQuestionAnswered == false) {
          return;
        }
        moveToNextQuestion();
        break;
      case 1:
        if (isLoading.value || isCurrentQuestionAnswered == true) {
          return;
        }
        showQuestionStats();
        break;
      case 2:
        if (isCurrentQuestionAnswered == false && isLoading.value == false) {
          pauseTimer();
        }
        break;
      case 3:
        if (isCurrentQuestionAnswered == false && isLoading.value == false) {
          resumeTimer();
        }
        break;
    }
  }

  moveToNextQuestion() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 300));
    if (currentQuestionIndex.value == questions.length - 1) {
      questionTimer?.cancel();
      setStudentExamResults();
      showQuizSummary.value = true;
      isLoading.value = false;
      update();
      return;
    }
    currentQuestionIndex.value++;
    currentQuestion = questions[currentQuestionIndex.value].obs;
    questionDurationRemaining.value = questionDuration;
    questionTimer?.cancel();
    currentQuestionStudentResponse.clear();
    resumeTimer();
    isLoading.value = false;
    update();
  }

  showQuestionStats() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 300));
    pauseTimer();
    questionTimer?.cancel();
    isTimerInProgress.value = false;
    questionStatus[currentQuestion.value.onlineLmsQuesBankId] =
        List<StudentAnswerModel>.from(
            currentQuestionStudentResponse.values.map((e) => e));
    await insertStudentMarksData();
    isLoading.value = false;
    update();
    log("message");
  }

  Future<void> insertStudentMarksData() async {
    isLoading.value = true;
    update();
    try {
      final batch = myDataController.database!.batch();
      final examEndTime = DateTime.now();
      for (var element in students) {
        final studentResponse =
            currentQuestionStudentResponse[element.clickerDeviceID];
        element.marksObtained +=
            (getCorrectAnswerIndex().contains(studentResponse?.optionSelected)
                ? questionMarks
                : 0);
        element.totalDuration += studentResponse?.duration ?? 0;
        if (element.resultId == null) {
          final resultQuesId = await myDataController.database!
              .insert('tbl_exam_online_paper_result', {
            "parent_institute_id": topic.value!.parentInstituteId,
            "institute_id": element.instituteId,
            "institute_course_id": topic.value!.instituteCourseId,
            "institute_subject_id": headerController
                .selectedSubject.value!.onlineInstituteSubjectId,
            "institute_topic_ids": topic.value!.onlineInstituteTopicId,
            "paper_type": PaperType.classRoomTest.label,
            "student_institute_user_id": element.onlineInstituteUserId,
            "exam_start_date_time": examStartTime.toIso8601String(),
            "exam_end_date_time": examEndTime.toIso8601String(),
            "exam_total_duration": examTotalDuration,
            "exam_total_question": questions.length,
            "exam_total_marks": examTotalMarks,
            "exam_total_student_marks": element.marksObtained,
            "exam_total_student_duration": element.totalDuration
          });
          students[students.indexWhere((e) =>
                  e.onlineInstituteUserId == element.onlineInstituteUserId)] =
              element = element.copyWithResultId(resultQuesId);
        } else {
          batch.update(
              'tbl_exam_online_paper_result',
              {
                "exam_total_marks": examTotalMarks,
                "exam_end_date_time": examEndTime.toIso8601String(),
                "exam_total_student_marks": element.marksObtained,
                "exam_total_student_duration": element.totalDuration
              },
              where: 'exam_paper_result_id = ?',
              whereArgs: [element.resultId]);
        }

        batch.insert('tbl_exam_online_paper_result_ques', {
          "parent_institute_id": topic.value!.parentInstituteId,
          "institute_id": element.instituteId,
          "institute_course_id": topic.value!.instituteCourseId,
          "institute_subject_id":
              headerController.selectedSubject.value!.onlineInstituteSubjectId,
          "institute_chapter_id": topic.value!.instituteChapterId,
          "institute_topic_id": topic.value!.onlineInstituteTopicId,
          "lms_ques_bank_id": currentQuestion.value.onlineLmsQuesBankId,
          "student_institute_user_id": element.onlineInstituteUserId,
          'exam_online_paper_result_id': element.resultId,
          'question_marks': questionMarks,
          'marks_obtained':
              getCorrectAnswerIndex().contains(studentResponse?.optionSelected)
                  ? questionMarks
                  : 0,
          'option_selected_by_user': studentResponse?.optionSelected.toString(),
          'correct_options': getCorrectAnswerIndex().join(','),
          'answer_status': studentResponse == null
              ? AnswerStatus.notAttempted.label
              : getCorrectAnswerIndex().contains(studentResponse.optionSelected)
                  ? AnswerStatus.correct.label
                  : AnswerStatus.wrong.label,
          'date_time_of_ans': studentResponse?.answeredTime.toIso8601String() ??
              '0000-00-00 00:00:00'
        });
      }
      await batch.commit();
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Map<String, int> getBarChartData() {
    final data = <String, int>{};
    for (int i = 0; i <= (currentQuestion.value.noOfOption ?? 0); i++) {
      if (i == (currentQuestion.value.noOfOption ?? 0)) {
        data['NA'] = 0;
      } else {
        data[Helper.getOptionName(i + 1)] = 0;
      }
    }
    for (var element in students) {
      final response = currentQuestionStudentResponse[element.clickerDeviceID];
      final label = response?.optionSelected == null
          ? "NA"
          : Helper.getOptionName(response!.optionSelected);
      data[label] = (data[label] ?? 0) + 1;
    }
    return data;
  }

  Map<String, int> getPieChartData() {
    final data = <String, int>{"Correct": 0, "Wrong": 0, "NA": 0};

    for (var element in students) {
      final response = currentQuestionStudentResponse[element.clickerDeviceID];
      final label = response?.optionSelected == null
          ? "NA"
          : getCorrectAnswerIndex().contains(response!.optionSelected)
              ? "Correct"
              : "Wrong";
      data[label] = (data[label] ?? 0) + 1;
    }
    final total = data.values.reduce((a, b) => a + b);
    data.forEach((key, value) {
      data[key] = (value / total * 100).round();
    });
    return data;
  }

  List<int> getCorrectAnswerIndex({QuestionBank? question}) {
    final quest = question ?? currentQuestion.value;
    List<int> correctIndex = [];
    if (quest.answer1IsCorrect) {
      correctIndex.add(1);
    }
    if (quest.answer2IsCorrect) {
      correctIndex.add(2);
    }
    if (quest.answer3IsCorrect) {
      correctIndex.add(3);
    }
    if (quest.answer4IsCorrect) {
      correctIndex.add(4);
    }
    return correctIndex;
  }

  pauseTimer() {
    questionTimer?.cancel();
    isTimerInProgress.value = false;
  }

  resumeTimer() {
    questionTimer?.cancel();
    questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      questionDurationRemaining.value--;
      if (questionDurationRemaining.value == 0) {
        timer.cancel();
        showQuestionStats();
      }
    });
    isTimerInProgress.value = true;
  }

  Future<void> fetchStudents(int instituteCourseId) async {
    try {
      isLoading.value = true;
      update();
      final response =
          await myDataController.fetchStudentsByClass(instituteCourseId);
      students.clear();
      students.addAll(response);
    } catch (e) {
      print("error in fetching students :- $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  double getPerformance() {
    final correctCount = studentExamResult.fold(
        0, (value, element) => value + element.correctAnswerCount);
    final wrongCount = studentExamResult.fold(
        0, (value, element) => value + element.wrongAnswerCount);
    final naCount = studentExamResult.fold(
        0, (value, element) => value + element.naAnswerCount);
    final total = correctCount + wrongCount + naCount;
    return (total == 0 ? 0 : (correctCount / total) * 100);
  }

  Map<String, int> getWholeClassSummary() {
    final correctCount = studentExamResult.fold(
        0, (value, element) => value + element.correctAnswerCount);
    final wrongCount = studentExamResult.fold(
        0, (value, element) => value + element.wrongAnswerCount);
    final naCount = studentExamResult.fold(
        0, (value, element) => value + element.naAnswerCount);
    final total = correctCount + wrongCount + naCount;
    final data = <String, int>{
      "Correct": (correctCount / total * 100).round(),
      "Wrong": (wrongCount / total * 100).round(),
      "NA": (naCount / total * 100).round()
    };
    return data;
  }

  @override
  void dispose() {
    _clickerStream?.cancel();
    questionTimer?.cancel();
    super.dispose();
  }
}
