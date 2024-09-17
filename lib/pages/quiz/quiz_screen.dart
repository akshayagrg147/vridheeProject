import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/pages/quiz/controller/quiz_controller.dart';
import 'package:teaching_app/pages/quiz/widgets/question_feedback.dart';
import 'package:teaching_app/utils/app_colors.dart';
import 'package:teaching_app/widgets/address_header.dart';
import 'package:teaching_app/widgets/elevated_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  late QuizController _controller;

  @override
  void initState() {
    _controller=Get.put(QuizController());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
child: Column(
  children: [
    ElevatedCard(
      elevation: 4,
        child: AddressHeader(
          address:
          "X / Math/ Subject / chapterName / topicName",
        )),
    SizedBox(height: 10,),

    Expanded(child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),  // #00000029 in hex (translucent black)
            offset: Offset(0, 3),      // Horizontal and vertical offsets
            blurRadius: 6,             // Blur radius
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          QuestionFeedback()


        ],
      ),
    )),

    SizedBox(height: 10,),

  ],
),
      ),
    );
  }
}
