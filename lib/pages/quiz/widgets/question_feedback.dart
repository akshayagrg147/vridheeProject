import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/utils/app_colors.dart';

class QuestionFeedback extends StatelessWidget {
  const QuestionFeedback({super.key});

  @override
  Widget build(BuildContext context) {
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
                  )),
              const SizedBox(
                width: 20,
              ),
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
                  ))
            ],
          ),
        )
      ],
    );
  }
}
