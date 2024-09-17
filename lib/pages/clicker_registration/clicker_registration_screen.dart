import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/pages/clicker_registration/controller/clicker_registration_controller.dart';
import 'package:teaching_app/pages/clicker_registration/widgets/add_clicker.dart';
import 'package:teaching_app/pages/clicker_registration/widgets/student_card.dart';
import 'package:teaching_app/pages/clicker_registration/widgets/teacher_card.dart';

class ClickerRegistration extends StatefulWidget {

  const ClickerRegistration({super.key});

  @override
  State<ClickerRegistration> createState() => _ClickerRegistrationState();
}

class _ClickerRegistrationState extends State<ClickerRegistration> {
  late ClickerRegistrationController  controller;

  @override
  void initState() {
    controller =   Get.put(ClickerRegistrationController());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
appBar: AppBar(
  title: Obx(
     () {
      return Text("Clicker Registration ${controller.className.value??''}");
    }
  )
  ,
),

      body: GetBuilder<ClickerRegistrationController>(builder: (_){
        if(controller.isLoading.isTrue){
          return const Center(child: CircularProgressIndicator(),);
        }

        return GridView(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8,mainAxisSpacing: 15,crossAxisSpacing: 15),
          padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 20),

        children: [
          TeacherClickerCard(isSelected: controller.isTeacherRegistrationInProcess.value,clickerId: controller.teacherClickerId.value,),
          for(int index=0;index<controller.students.length; index++)
            StudentCard(student: controller.students[index], isSelected:   index == controller.selectedStudentIndex.value , index: index),
          AddClickers()
          ],

        );



      }),


    ));
  }
}
