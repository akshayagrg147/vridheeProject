
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/pages/clicker_registration/controller/clicker_registration_controller.dart';
import 'package:teaching_app/pages/clicker_registration/modal/student_data_model.dart';

class StudentCard extends StatelessWidget {
  final StudentDataModel student;
  final bool isSelected;
  final int index;
  const StudentCard({super.key, required this.student, required this.isSelected, required this. index});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)
          ),
          padding:const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Center(child: Icon(student.gender=="Male"?Icons.person:Icons.person_2,size: 40,color: Colors.grey.shade400,)),
              SizedBox(height: 20,),
              Text(student.name,style: TextStyle(
                color: Colors.black
                    ,
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),),
        

        
              Text("Student Id :- ${student.onlineInstituteUserId}",style: TextStyle(
                  color: Colors.black
                  ,
                  fontSize: 12,
                  fontWeight: FontWeight.w600
              ),)
            ],
          ),
        ),
        
        if(isSelected)
          Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                  shape: BoxShape.circle
                ),
                height: 50,
                  width: 50,
               alignment: Alignment.center,
               child: Text("${index%5+1}",style: TextStyle(
                 fontSize: 30,
                 fontWeight: FontWeight.w500
               ),),
              ),
            ),
          ),

      Positioned(
          top: 0,
          right: 0,
          child:   isSelected?
          IconButton(onPressed: (){
            Get.find<ClickerRegistrationController>().onStudentRegisterationCancel();
          }, icon:const Icon(Icons.close,color: Colors.white,)):
      IconButton(onPressed: (){
        Get.find<ClickerRegistrationController>().onStudentRegistration(student, index: index);
        
      }, icon: Icon(Icons.ads_click_outlined,color: student.clickerDeviceID!=null? Colors.green:Colors.red,))
    )
      ],
    );
  }
}
