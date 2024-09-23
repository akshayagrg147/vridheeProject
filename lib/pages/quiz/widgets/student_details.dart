import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/pages/quiz/models/student_quiz_summary_model.dart';
import 'package:teaching_app/utils/app_colors.dart';

class StudentDetails extends StatelessWidget {
  final StudentExamResult studentResult;
  const StudentDetails({super.key, required this.studentResult});

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
            "Student Details",
            style: GoogleFonts.poppins(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
          ),
         const Spacer(),
          keyValuePair("Name :", studentResult.name),
          SizedBox(
            height: 12,
          ),
          keyValuePair("Email :", studentResult.email),
          SizedBox(
            height: 12,
          ),
          keyValuePair("Contact :", studentResult.mobile),
          SizedBox(
            height: 12,
          ),
          keyValuePair("Roll No :", studentResult.rollNo.toString()),
        ],
      ),
    );
  }

  Widget keyValuePair(String title, String value) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Text(
              title,
              style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            )),
        SizedBox(
          width: 5,
        ),
        Expanded(
            flex: 7,
            child: Text(
              value,
              style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            )),
      ],
    );
  }
}
