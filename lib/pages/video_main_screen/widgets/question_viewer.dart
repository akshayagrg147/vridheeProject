import 'package:flutter/material.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/pages/video_main_screen/widgets/question_view.dart';
import 'package:teaching_app/widgets/flag_container.dart';

class QuestionViewer extends StatefulWidget {
  final List<QuestionBank> questionList;
  final QuestionBank currentQuestion;
  const QuestionViewer(
      {super.key, required this.questionList, required this.currentQuestion});

  @override
  State<QuestionViewer> createState() => _QuestionViewerState();
}

class _QuestionViewerState extends State<QuestionViewer> {
  PageController? _pageController;
  late QuestionBank currentQuestion;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant QuestionViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentQuestion.onlineLmsQuesBankId !=
        currentQuestion.onlineLmsQuesBankId) {
      initialize();
    }
  }

  initialize() {
    currentQuestion = widget.currentQuestion;
    final currentQuesIndex = widget.questionList.indexWhere((element) =>
        element.onlineLmsQuesBankId ==
        widget.currentQuestion.onlineLmsQuesBankId);
    if (_pageController != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _pageController?.jumpToPage(currentQuesIndex);
      });
    } else {
      _pageController = PageController(
          initialPage: currentQuesIndex != -1 ? currentQuesIndex : 0);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: widget.questionList.isNotEmpty
            ? PageView.builder(
                controller: _pageController,
                itemCount: widget.questionList.length,

                // physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return QuestionView(
                    questionNo: index + 1,
                    question: widget.questionList[index],
                  );
                })
            : QuestionView(
                questionNo: 1,
                question: widget.currentQuestion,
              ));
  }
}
