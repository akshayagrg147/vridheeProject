import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/utils/app_colors.dart';

class GaugePainter extends CustomPainter {
  final double value; // Value to determine the needle's position (0-100 range)

  GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2,
        size.height / 1.2); // Adjusted center for 180-degree arc
    final radius = min(size.width / 2, size.height / 2) -
        20; // Radius for the arc and ticks

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    // Define angles
    double startAngle = pi; // Start at 180 degrees (left)
    double sweepAngle = pi; // Sweep for 180 degrees

    // Green arc (50-100)
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.5, // Starts at 50% of the sweep (90 degrees)
      sweepAngle * 0.5, // Remaining 50% sweep
      false,
      paint,
    );

    // Red arc (0-50)
    paint.color = Colors.red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * 0.5, // First 50% of the sweep (0 to 90 degrees)
      false,
      paint,
    );

    // Draw ticks and labels
    final tickPaint = Paint()
      ..strokeWidth = 3
      ..color = Colors.black;

    final textStyle = TextStyle(color: Colors.black, fontSize: 12);

    for (int i = 0; i <= 10; i++) {
      double tickAngle =
          startAngle + (i * sweepAngle / 10); // Calculate tick angle
      double x1 = center.dx + radius * cos(tickAngle);
      double y1 = center.dy + radius * sin(tickAngle);
      double x2 =
          center.dx + (radius + 15) * cos(tickAngle); // Outward-pointing ticks
      double y2 = center.dy + (radius + 15) * sin(tickAngle);

      // Draw the tick line
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);

      // Draw the labels
      String label = (i * 10).toString(); // Label values (0 to 100)
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      double labelX =
          center.dx + (radius + 30) * cos(tickAngle) - textPainter.width / 2;
      double labelY =
          center.dy + (radius + 30) * sin(tickAngle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // Draw the needle with a wide base and pointed head
    final needlePaint = Paint()..color = Colors.black;
    double needleAngle =
        startAngle + sweepAngle * (value / 100); // Needle based on value
    double needleX = center.dx + (radius - 20) * cos(needleAngle);
    double needleY = center.dy + (radius - 20) * sin(needleAngle);

// Create a wide base for the needle
    double needleBaseWidth = 8; // Width of the needle base
    Path needlePath = Path();
    needlePath.moveTo(center.dx, center.dy); // Needle base start

// Draw the left side of the needle
    needlePath.lineTo(
      center.dx + needleBaseWidth * cos(needleAngle + pi / 2),
      center.dy + needleBaseWidth * sin(needleAngle + pi / 2),
    );

// Draw the tip of the needle
    needlePath.lineTo(needleX, needleY);

// Draw the right side of the needle
    needlePath.lineTo(
      center.dx + needleBaseWidth * cos(needleAngle - pi / 2),
      center.dy + needleBaseWidth * sin(needleAngle - pi / 2),
    );

// Close the needle path to create a filled shape
    needlePath.close();

// Draw the needle
    canvas.drawPath(needlePath, needlePaint);
    // Draw needle center circle
    canvas.drawCircle(center, 10, Paint()..color = Colors.grey);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Redraw when value changes
  }
}

class QaPerformanceGaugeChart extends StatelessWidget {
  final double classScore;
  const QaPerformanceGaugeChart({super.key, required this.classScore});

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
            "Class Q&A Performance",
            style: GoogleFonts.poppins(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: SizedBox(
                width: double.maxFinite,
                child: CustomPaint(
                  painter: GaugePainter(value: classScore),
                )),
          ),
          legend(Colors.red, text: 'Need to explain topic again'),
          legend(Colors.green, text: 'Can move to next topic'),
        ],
      ),
    );
  }

  Widget legend(Color color, {required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
