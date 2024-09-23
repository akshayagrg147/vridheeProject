import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/utils/app_colors.dart';

class QaScorePieChart extends StatelessWidget {
  final Map<String, int> data;

  const QaScorePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paleGrey),
        boxShadow: [
          const BoxShadow(
            color: Color(0x1A000000),

            offset: Offset(0, 12),

            blurRadius: 12, // Blur radius
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Class Q&A Score",
            style: GoogleFonts.poppins(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildLegend(data: data),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: _createPieSections(data: data),
                      sectionsSpace: 0, // Space between slices
                      centerSpaceRadius:
                          30, // Center hole radius (can be removed)
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events on the chart
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(
      {required Map<String, int> data}) {
    List<PieChartSectionData> sections = [];
    int index = 0;

    data.forEach((label, value) {
      sections.add(
        PieChartSectionData(
          color: AppColors.getPieColors[index % AppColors.getPieColors.length],
          value: value.toDouble(),
          title: '${value.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return sections;
  }

  Widget _buildLegend({required Map<String, int> data}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.keys.map((key) {
        int index = data.keys.toList().indexOf(key);
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors
                    .getPieColors[index % AppColors.getPieColors.length],
              ),
            ),
            SizedBox(width: 8),
            Text(
              key,
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }).toList(),
    );
  }
}
