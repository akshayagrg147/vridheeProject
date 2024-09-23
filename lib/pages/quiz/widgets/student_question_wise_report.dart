import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/pages/quiz/controller/quiz_controller.dart';
import 'package:teaching_app/pages/quiz/models/student_quiz_summary_model.dart';
import 'package:teaching_app/pages/quiz/widgets/qa_score_pie_chart.dart';
import 'package:teaching_app/pages/quiz/widgets/question_review.dart';
import 'package:teaching_app/pages/quiz/widgets/student_details.dart';
import 'package:teaching_app/utils/app_colors.dart';

class StudentQuestionWiseReport extends StatelessWidget {
  final StudentExamResult examResult;

  const StudentQuestionWiseReport({super.key, required this.examResult});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000), // Hex code for #00000029
            offset: Offset(0, 3), // Equivalent of 0px 3px
            blurRadius: 6, // Equivalent of 6px blur
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.royalBlue),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    controller.showQuizSummaryReport();
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Question List",
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: 300,
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: StudentDetails(
                      studentResult: examResult,
                    )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    flex: 1,
                    child: QaScorePieChart(
                      data: examResult.getScoreData(),
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ...List.generate(
            controller.questions.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: QuestionReview(
                  question: controller.questions[index],
                  questionNumber: index + 1,
                  answerSelected: examResult.studentResponse[
                          controller.questions[index].onlineLmsQuesBankId] ??
                      -1),
            ),
          )
        ]),
      ),
    ));
  }
}
