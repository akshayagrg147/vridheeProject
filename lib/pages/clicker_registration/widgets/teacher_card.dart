
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/pages/clicker_registration/controller/clicker_registration_controller.dart';

class TeacherClickerCard extends StatelessWidget {
  final String? clickerId;
  final bool isSelected;
  const TeacherClickerCard({super.key, this.clickerId, required this.isSelected});

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
              Center(child: Icon(Icons.person_4,size: 40,color: Colors.grey.shade400,)),
              SizedBox(height: 20,),


              Center(
                child: Text("Teacher",style: TextStyle(
                    color: Colors.black
                    ,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                ),),
              )
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
                child: Text("8",style: TextStyle(
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
              Get.find<ClickerRegistrationController>().onTeacherRegistrationCancel();
            }, icon:const Icon(Icons.close,color: Colors.white,)):
            IconButton(onPressed: (){
              Get.find<ClickerRegistrationController>().onTeacherRegistration();

            }, icon: Icon(Icons.ads_click_outlined,color: clickerId!=null? Colors.green:Colors.red,))
        )
      ],
    );
  }
}
