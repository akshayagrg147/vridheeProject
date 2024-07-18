import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pagination_flutter/pagination.dart';
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
  int currentPage = 0;
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
      currentPage = currentQuesIndex;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _pageController?.jumpToPage(currentQuesIndex);
      });
    } else {
      currentPage = currentQuesIndex != -1 ? currentQuesIndex : 0;
      _pageController = PageController(initialPage: currentPage);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: widget.questionList.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.questionList.length,
                    onPageChanged: (int currentPage) {
                      this.currentPage = currentPage;
                      setState(() {});
                    },
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
                  )),
        Pagination(
          numOfPages:
              widget.questionList.isNotEmpty ? widget.questionList.length : 1,
          selectedPage: widget.questionList.isNotEmpty ? currentPage : 0,
          pagesVisible: widget.questionList.isNotEmpty
              ? widget.questionList.length > 6
                  ? 6
                  : widget.questionList.length
              : 1,
          onPageChanged: (page) {
            _pageController?.jumpToPage(page);
            setState(() {
              currentPage = page;
            });
          },
          spacing: 1,
          nextIcon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
            size: 14,
          ),
          previousIcon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
            size: 14,
          ),
          activeTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          activeBtnStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
            fixedSize: MaterialStateProperty.all(Size(35, 35)),
            maximumSize: MaterialStateProperty.all(Size(35, 35)),
            minimumSize: MaterialStateProperty.all(Size(35, 35)),
          ),
          inactiveBtnStyle: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(38),
            )),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
            fixedSize: MaterialStateProperty.all(Size(35, 35)),
            maximumSize: MaterialStateProperty.all(Size(35, 35)),
            minimumSize: MaterialStateProperty.all(Size(35, 35)),
          ),
          inactiveTextStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
