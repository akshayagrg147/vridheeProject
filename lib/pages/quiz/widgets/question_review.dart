import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teaching_app/core/helper/helper.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/video_main_screen/widgets/decrypt_image_view.dart';
import 'package:teaching_app/services/background_service_controller.dart';
import 'package:teaching_app/utils/app_colors.dart';

class QuestionReview extends StatelessWidget {
  final QuestionBank question;
  final int questionNumber;
  final int answerSelected;
  const QuestionReview(
      {super.key,
      required this.question,
      required this.questionNumber,
      required this.answerSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000), // Corresponding color to #00000029
            offset: Offset(0, 3), // X and Y offset (0px 3px)
            blurRadius: 12, // Blur radius (12px)
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Qs.($questionNumber) ",
                  style: const TextStyle(color: Colors.black),
                ),
                Expanded(child: Text(question.questionText)),
              ],
            ),
            if ((question.questionDownPath ?? "").trim().isNotEmpty)
              SizedBox(
                height: 20,
                child: DecryptImageView(
                    path:
                        "ques_${question.onlineLmsQuesBankId}.${BackgroundServiceController.instance.getFileExtFromUrl(question.questionDownPath ?? "")}"),
              )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            optiontile(1,
                optionText: question.option1 ?? "",
                isSelected: answerSelected == 1,
                optionDownloadPath: question.option1DownPath),
            optiontile(2,
                optionText: question.option2 ?? "",
                isSelected: answerSelected == 2,
                optionDownloadPath: question.option2DownPath),
          ],
        ),
        if (question.noOfOption > 2)
          Row(
            children: [
              optiontile(3,
                  optionText: question.option3 ?? "",
                  isSelected: answerSelected == 3,
                  optionDownloadPath: question.option3DownPath),
              if (question.noOfOption > 3)
                optiontile(4,
                    optionText: question.option4 ?? "",
                    isSelected: answerSelected == 4,
                    optionDownloadPath: question.option4DownPath),
            ],
          ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getTile(
                title: "Correct Answer",
                text: question.getCorrectOptions(),
                color: AppColors.royalBlue),
            getTile(
                title: "Given Answer",
                text: answerSelected == -1
                    ? "NA"
                    : question
                            .getCorrectOptionIndices()
                            .contains(answerSelected)
                        ? "Correct"
                        : "Wrong",
                color: answerSelected == -1
                    ? AppColors.kYellow
                    : question
                            .getCorrectOptionIndices()
                            .contains(answerSelected)
                        ? Colors.green
                        : Colors.red),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        ExplanationAndHintWidget(
            explanation: question.explanation ?? '', hint: '')
      ]),
    );
  }

  Widget getTile({
    required String title,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        "$title : $text",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget optiontile(int index,
      {required String optionText,
      String? optionDownloadPath,
      required bool isSelected}) {
    return Flexible(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${Helper.getOptionName(index)}) "),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    optionText,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.check,
                      color: AppColors.royalBlue,
                    ),
                  ),
              ],
            ),
            if ((optionDownloadPath ?? "").trim().isNotEmpty)
              SizedBox(
                height: 20,
                child: DecryptImageView(
                    path:
                        "${question.onlineLmsQuesBankId}_option_$index.${BackgroundServiceController.instance.getFileExtFromUrl(optionDownloadPath ?? "")}"),
              )
          ],
        ),
      ),
    );
  }

  String getCorrectAnswer() {
    String answer = "";
    if (question.answer1IsCorrect) {
      answer += question.option1 ?? "";
    }
    if (question.answer2IsCorrect) {
      if (answer.isNotEmpty) {
        answer += "\t,\t";
      }
      answer += question.option2 ?? "";
    }
    if (question.answer3IsCorrect) {
      if (answer.isNotEmpty) {
        answer += "\t,\t";
      }
      answer += question.option3 ?? "";
    }
    if (question.answer4IsCorrect) {
      if (answer.isNotEmpty) {
        answer += "\t,\t";
      }
      answer += question.option4 ?? "";
    }
    return answer;
  }
}

class ExplanationAndHintWidget extends StatefulWidget {
  final String explanation;
  final String hint;
  const ExplanationAndHintWidget(
      {super.key, required this.explanation, required this.hint});

  @override
  State<ExplanationAndHintWidget> createState() =>
      _ExplanationAndHintWidgetState();
}

class _ExplanationAndHintWidgetState extends State<ExplanationAndHintWidget> {
  bool _isExpandedd = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpandedd = !_isExpandedd;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Explanation & Hint",
                    style: GoogleFonts.poppins(
                        color: AppColors.royalBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.arrow_drop_down,
                    color: AppColors.royalBlue, size: 30),
              ],
            ),
          ),
          if (_isExpandedd) ...[
            const SizedBox(
              height: 10,
            ),
            Text.rich(TextSpan(
                text: "Explanation : ",
                style: GoogleFonts.roboto(
                  color: AppColors.royalBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: widget.explanation,
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ])),
            const SizedBox(
              height: 10,
            ),
            Text.rich(TextSpan(
                text: "Hint : ",
                style: GoogleFonts.roboto(
                  color: AppColors.royalBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: widget.hint,
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ])),
          ]
        ],
      ),
    );
  }
}
