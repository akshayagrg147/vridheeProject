import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/pages/quiz/controller/quiz_controller.dart';
import 'package:teaching_app/pages/quiz/models/student_quiz_summary_model.dart';
import 'package:teaching_app/pages/quiz/widgets/qa_performance_gauge_chart.dart';
import 'package:teaching_app/pages/quiz/widgets/qa_score_pie_chart.dart';
import 'package:teaching_app/utils/app_colors.dart';

class QuizSummary extends StatelessWidget {
  const QuizSummary({super.key});

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
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.royalBlue),
              child: Text(
                "Feedback",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
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
                      child: QaScorePieChart(
                        data: controller.getWholeClassSummary(),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: QaPerformanceGaugeChart(
                        classScore: controller.getPerformance(),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0), // background: #F0F0F0
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x29000000), // #00000029 (16% opacity)
                      offset: Offset(0, 3), // Similar to 0px 3px in CSS
                      blurRadius: 6, // Similar to 6px blur
                    ),
                  ],
                  borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Expanded(
                      flex: 48,
                      child: Center(
                          child: Text(
                        "#",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                  const CustomVerticalDivider(),
                  Expanded(
                      flex: 473,
                      child: Center(
                          child: Text(
                        "Student Name",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                  const CustomVerticalDivider(),
                  Expanded(
                      flex: 115,
                      child: Center(
                          child: Text(
                        "Score",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                  const CustomVerticalDivider(),
                  Expanded(
                      flex: 85,
                      child: Center(
                          child: Text(
                        "Correct",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                  const CustomVerticalDivider(),
                  Expanded(
                      flex: 70,
                      child: Center(
                          child: Text(
                        "Wrong",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                  const CustomVerticalDivider(),
                  Expanded(
                      flex: 125,
                      child: Center(
                          child: Text(
                        "Not Attempted",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                  const CustomVerticalDivider(),
                  Expanded(
                      flex: 80,
                      child: Center(
                          child: Text(
                        "Details",
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))),
                ],
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            for (var studentExamResult in controller.studentExamResult)
              StudenQuizResponseRow(
                result: studentExamResult,
                onTap: () {
                  controller.showStudentSpecificReport(studentExamResult);
                },
              ),
          ],
        ),
      ),
    ));
  }
}

class StudenQuizResponseRow extends StatelessWidget {
  final StudentExamResult result;
  final VoidCallback onTap;
  const StudenQuizResponseRow(
      {super.key, required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 62,
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // background: #FFFFFF
        border: Border.all(
          color: Color(0x1F000000), // border color: #0000001F (12% opacity)
          width: 1, // 1px solid border
        ),
        borderRadius: BorderRadius.circular(4), // border-radius: 4px
      ),
      child: Row(
        children: [
          Expanded(
              flex: 8,
              child: Container(
                color: AppColors.royalBlue,
              )),
          Expanded(
              flex: 48,
              child: Center(
                  child: Text(
                "${result.rollNo}",
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ))),
          const CustomVerticalDivider(),
          Expanded(
              flex: 473,
              child: Center(
                  child: Text(
                result.name,
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ))),
          const CustomVerticalDivider(),
          Expanded(
              flex: 115,
              child: Center(
                  child: Text(
                "Score",
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ))),
          const CustomVerticalDivider(),
          Expanded(
              flex: 85,
              child: Center(
                  child: Text(
                result.correctAnswerCount.toString(),
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ))),
          const CustomVerticalDivider(),
          Expanded(
              flex: 70,
              child: Center(
                  child: Text(
                result.wrongAnswerCount.toString(),
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ))),
          const CustomVerticalDivider(),
          Expanded(
              flex: 125,
              child: Center(
                  child: Text(
                result.naAnswerCount.toString(),
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ))),
          const CustomVerticalDivider(),
          Expanded(
              flex: 80,
              child: Center(
                  child: GestureDetector(
                onTap: onTap,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.visibility_outlined,
                      color: AppColors.royalBlue,
                    )),
              ))),
        ],
      ),
    );
  }
}

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(
      color: Color(0xFF004392),
      thickness: 1,
    );
  }
}
