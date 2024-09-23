import 'package:flutter/material.dart';
import 'package:teaching_app/core/helper/helper.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/video_main_screen/widgets/decrypt_image_view.dart';
import 'package:teaching_app/services/background_service_controller.dart';

class QuestionWithOption extends StatelessWidget {
  final QuestionBank question;
  final int questionNumber;
  final bool showAnswer;
  const QuestionWithOption(
      {super.key,
      required this.question,
      required this.showAnswer,
      required this.questionNumber});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            optiontile(
              1,
              optionText: question.option1 ?? "",
              isAnswer: question.answer1IsCorrect,
              optionDownloadPath: question.option1DownPath,
            ),
            optiontile(2,
                optionText: question.option2 ?? "",
                isAnswer: question.answer2IsCorrect,
                optionDownloadPath: question.option2DownPath),
          ],
        ),
        if (question.noOfOption > 2)
          Row(
            children: [
              optiontile(3,
                  optionText: question.option3 ?? "",
                  isAnswer: question.answer3IsCorrect,
                  optionDownloadPath: question.option3DownPath),
              if (question.noOfOption > 3)
                optiontile(4,
                    optionText: question.option4 ?? "",
                    isAnswer: question.answer4IsCorrect,
                    optionDownloadPath: question.option4DownPath),
            ],
          ),
        if (showAnswer) ...[
          const SizedBox(
            height: 15,
          ),
          textContainer("Answer : ", text: getCorrectAnswer()),
          const SizedBox(
            height: 15,
          ),
          textContainer("Explanation : ", text: question.explanation ?? ""),
        ]
      ]),
    );
  }

  Widget textContainer(String title, {required String text}) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
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
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget optiontile(int index,
      {required String optionText,
      String? optionDownloadPath,
      required bool isAnswer}) {
    return Flexible(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isAnswer && showAnswer ? Colors.green : Colors.white),
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
                )
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
