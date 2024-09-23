import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/pages/quiz/controller/quiz_controller.dart';
import 'package:teaching_app/pages/quiz/widgets/qa_score_pie_chart.dart';
import 'package:teaching_app/utils/app_colors.dart';

class QuestionFeedback extends StatelessWidget {
  const QuestionFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();
    final barChartData = controller.getBarChartData();
    final pieChartData = controller.getPieChartData();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.royalBlue),
          child: Text(
            "Question Feedback",
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 300,
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.paleGrey),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x1A000000),
                          // #0000001A in hex (black with 10% opacity)
                          offset: Offset(0, 12),
                          // Horizontal and vertical offset
                          blurRadius: 12, // Blur radius
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(15),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: controller.students.length.toDouble() < 10
                            ? 10
                            : controller.students.length.toDouble(),
                        barGroups: _createBarGroups(data: barChartData),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text("Options"),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  return _bottomTitles(value, meta,
                                      data: barChartData);
                                }),
                          ),
                          leftTitles: AxisTitles(
                            axisNameSize: 20,
                            axisNameWidget: Text("Count"),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  flex: 1,
                  child: QaScorePieChart(
                    data: pieChartData,
                  ))
            ],
          ),
        )
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups({required Map<String, int> data}) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    data.forEach((label, value) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10)),
              color:
                  AppColors.getBarColors[index % AppColors.getBarColors.length],
              width: 20,
            ),
          ],
        ),
      );
      index++;
    });
    return barGroups;
  }

  Widget _bottomTitles(double value, TitleMeta meta,
      {required Map<String, int> data}) {
    final label = data.keys.elementAt(value.toInt());
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(label),
    );
  }
}
