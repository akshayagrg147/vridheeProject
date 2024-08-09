import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/video_main_screen/widgets/decrypt_image_view.dart';
import 'package:teaching_app/services/background_service_controller.dart';

class QuestionView extends StatefulWidget {
  final int questionNo;
  final QuestionBank question;
  const QuestionView(
      {super.key, required this.questionNo, required this.question});

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView>
    with AutomaticKeepAliveClientMixin<QuestionView> {
  late QuestionBank question;
  int selectedOption = -1;
  bool showAnswer = false;

  String getCorrectAnswer() {
    String answer = "";
    if (widget.question.answer1IsCorrect) {
      answer += widget.question.option1 ?? "";
    }
    if (widget.question.answer2IsCorrect) {
      if (answer.isNotEmpty) {
        answer += "\t,\t";
      }
      answer += widget.question.option2 ?? "";
    }
    if (widget.question.answer3IsCorrect) {
      if (answer.isNotEmpty) {
        answer += "\t,\t";
      }
      answer += widget.question.option3 ?? "";
    }
    if (widget.question.answer4IsCorrect) {
      if (answer.isNotEmpty) {
        answer += "\t,\t";
      }
      answer += widget.question.option4 ?? "";
    }
    return answer;
  }

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question.onlineLmsQuesBankId != question.onlineLmsQuesBankId) {
      setState(() {});
    }
  }

  @override
  void initState() {
    question = widget.question;
    super.initState();
  }

  void onOptionTap(int selectedOption) {
    this.selectedOption = selectedOption;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          quesTile(),
          Row(
            children: [
              optiontile(1,
                  optionText: question.option1 ?? "",
                  optionDownloadPath: question.option1DownPath),
              optiontile(2,
                  optionText: question.option2 ?? "",
                  optionDownloadPath: question.option2DownPath),
            ],
          ),
          if (widget.question.noOfOption > 2)
            Row(
              children: [
                optiontile(3,
                    optionText: question.option3 ?? "",
                    optionDownloadPath: question.option3DownPath),
                if (widget.question.noOfOption > 3)
                  optiontile(4,
                      optionText: question.option4 ?? "",
                      optionDownloadPath: question.option4DownPath),
              ],
            ),
          Center(
            child: GestureDetector(
              onTap: () {
                showAnswer = !showAnswer;
                if (showAnswer == true) {
                  final dbController = Get.find<DatabaseController>();
                  dbController.updateContentProgress(
                      widget.question.onlineLmsQuesBankId,
                      instituteTopicId: widget.question.instituteTopicId,
                      isQuestion: true);
                }
                setState(() {});
              },
              child: Text(
                showAnswer ? "Hide Answer" : "Show Answer",
                style: TextStyle(color: Colors.blue, fontSize: 13),
              ),
            ),
          ),
          if (showAnswer)
            Padding(
                padding: const EdgeInsets.all(5.0),
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "Answer :- ${getCorrectAnswer()}",
                    style: TextStyle(color: Colors.green, fontSize: 8),
                  ),
                  TextSpan(text: "\n"),
                  TextSpan(
                    text: "Explanation :- ${widget.question.explanation}",
                    style: TextStyle(color: Colors.green, fontSize: 8),
                  ),
                ])))
        ],
      ),
    );
  }

  Widget quesTile() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(question.questionText),
          if ((question.questionDownPath ?? "").trim().isNotEmpty)
            SizedBox(
              height: 20,
              child: DecryptImageView(
                  path:
                      "ques_${question.onlineLmsQuesBankId}.${BackgroundServiceController.instance.getFileExtFromUrl(question.questionDownPath ?? "")}"),
            )
        ],
      ),
    );
  }

  Widget optiontile(int index,
      {required String optionText, required String? optionDownloadPath}) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          onOptionTap(index);
        },
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color:
                      selectedOption == index ? Colors.green : Colors.black)),
          child: Row(
            children: [
              Text("${getOptionName(index)}) "),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      optionText,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    if ((optionDownloadPath ?? "").trim().isNotEmpty)
                      SizedBox(
                        height: 15,
                        child: DecryptImageView(
                            path:
                                "${question.onlineLmsQuesBankId}_option_$index.${BackgroundServiceController.instance.getFileExtFromUrl(optionDownloadPath ?? "")}"),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getOptionName(int index) {
    switch (index) {
      case 1:
        return "A";
      case 2:
        return "B";
      case 3:
        return "C";
      case 4:
        return "D";
    }
    return "";
  }

  @override
  bool get wantKeepAlive => true;
}
