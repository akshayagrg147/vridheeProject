import 'package:flutter/material.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
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
  @override
  void initState() {
    final currentQuesIndex = widget.questionList.indexWhere((element) =>
        element.onlineLmsQuesBankId ==
        widget.currentQuestion.onlineLmsQuesBankId);
    _pageController = PageController(
        initialPage: currentQuesIndex != -1 ? currentQuesIndex : 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView.builder(
            controller: _pageController,
            itemCount: widget.questionList.length,
            itemBuilder: (context, index) {
              return questionViewWidget();
            }));
  }

  Widget questionViewWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContinueWatchingTag(title: "Question", flagTitleColor: Colors.green),
        ],
      ),
    );
  }
}
