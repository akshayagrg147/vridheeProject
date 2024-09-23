import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/core/helper/helper.dart';
import 'package:teaching_app/pages/quiz/controller/quiz_controller.dart';
import 'package:teaching_app/pages/quiz/widgets/question_feedback.dart';
import 'package:teaching_app/pages/quiz/widgets/question_with_option.dart';
import 'package:teaching_app/pages/quiz/widgets/quiz_summary.dart';
import 'package:teaching_app/pages/quiz/widgets/student_question_wise_report.dart';
import 'package:teaching_app/utils/app_colors.dart';
import 'package:teaching_app/widgets/address_header.dart';
import 'package:teaching_app/widgets/elevated_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizController _controller;

  @override
  void initState() {
    _controller = Get.put(QuizController());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder<QuizController>(builder: (_) {
        if (_.isLoading.isTrue) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            children: [
              ElevatedCard(
                  elevation: 4,
                  child: AddressHeader(
                    address:
                        "${_controller.className} / ${_controller.subjectName} / ${_controller.chapterName} / ${_controller.topic.value?.topicName ?? ''}",
                  )),
              SizedBox(
                height: 10,
              ),
              if (_.showQuizSummary.isTrue)
                const QuizSummary()
              else if (_.showStudentReport.isTrue)
                StudentQuestionWiseReport(
                  examResult: _.studentResult!,
                )
              else
                Expanded(
                    child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                            0x29000000), // #00000029 in hex (translucent black)
                        offset: Offset(0, 3), // Horizontal and vertical offsets
                        blurRadius: 6, // Blur radius
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Obx(() {
                          if (_.isCurrentQuestionAnswered == true) {
                            return QuestionFeedback();
                          }
                          return buildTimer(
                              _controller.questionDurationRemaining.value);
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        Obx(() {
                          return QuestionWithOption(
                            question: _.currentQuestion.value,
                            showAnswer: _.isCurrentQuestionAnswered,
                            questionNumber: _.currentQuestionIndex.value + 1,
                          );
                        })
                      ],
                    ),
                  ),
                )),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildTimer(int timeRemaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer, color: Colors.black),
        SizedBox(width: 5),
        Text(
          Helper.formatMinutesSeconds(timeRemaining),
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
