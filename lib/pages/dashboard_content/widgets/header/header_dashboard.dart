import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/app_theme.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/modals/tbl_institute_course.dart';
import 'package:teaching_app/modals/tbl_institute_subject.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/header/header_dashboard_controller.dart';
import 'package:teaching_app/services/clicker_service.dart';
import 'package:teaching_app/utils/ext_utils.dart';
import 'package:teaching_app/widgets/app_dropDown.dart';
import 'package:teaching_app/widgets/app_rich_text.dart';
import 'package:teaching_app/widgets/text_view.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';


class DashboardHeaderWidget extends StatelessWidget {
  const DashboardHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: DashboardHeaderController(),
        builder: (_) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      await SharedPrefHelper().setIsLoginSuccessful(false);
                      Get.offAllNamed("/loginPage");
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Logout')
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: () {
                      if(_.selectedClass.value==null){
                        Get.showSnackbar(const GetSnackBar(
                          message: "Please Select a class !!",
                          duration: Duration(
                            seconds: 2

                          ),
                        ));
                        return;
                      }
                      Get.toNamed('/clickerRegistration',arguments: [
                        _.selectedClass.value!.onlineInstituteCourseId,
                        _.selectedClass.value!.instituteCourseName
                      ]);
                    },
                    child: Icon(Icons.ads_click_outlined, color: Colors.green,),


                  )
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Card(
                elevation: 5,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 110,
                      decoration: const BoxDecoration(
                          color: ThemeColor.headerBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Obx(() => ColumnAppRichText(
                                    title: "Class *",
                                    titleWidget: const Row(
                                      children: [
                                        Text("Class"),
                                        Text(
                                          " *",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    child: AppDropDown<InstituteCourse>(
                                        onChange: (p0) async {
                                          _.selectedClass.value = p0;
                                          if (p0 != null) {
                                            await _.fetchSubjectsForClass(p0);
                                          }
                                          _.resetChapters();
                                        },
                                        hintText: "Select class",
                                        value: _.selectedClass.value,
                                        items: _.classList.dropDownItem(
                                            (element) =>
                                                element.instituteCourseName),
                                        height: 40)))),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Obx(() => ColumnAppRichText(
                                    title: "Subject",
                                    titleWidget: const Row(
                                      children: [
                                        Text("Subject"),
                                        Text(
                                          " *",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    child: AppDropDown<InstituteSubject>(
                                        onChange: (p0) {
                                          _.selectedSubject.value = p0;
                                          _.resetChapters();

                                        },
                                        value: _.selectedSubject.value,
                                        items: _.subjectList.dropDownItem(
                                            (element) => element.subjectName!),
                                        height: 40)))),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: ColumnAppRichText(
                                    title: "Language",
                                    titleWidget: const Row(
                                      children: [
                                        Text("Language"),
                                        Text(
                                          " *",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    child: AppDropDown<String>(
                                        onChange: (p0) {
                                          _.selectedLanguage.value = p0!;
                                          _.resetChapters();

                                        },
                                        value: _.selectedLanguage.value,
                                        items: _.languageList
                                            .dropDownItem((element) => element),
                                        height: 40))),
                            const SizedBox(
                              width: 40,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () async {



                                    if (_.selectedClass.value != null &&
                                        _.selectedSubject.value != null) {
                                      _.fetchDataForSelectedSubject();
                                      _.fetchContinueData();
                                    }
                                  },
                                  child: Container(
                                      height: 40,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.blue,
                                      )),
                                ),
                                const SizedBox(
                                  height: 18,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -10,
                      left: 50,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            height: 30,
                            width: 200,
                            child: Center(
                              child: TextView(
                                "Home/Content",
                                textColor: ThemeColor.commonDarkBlueColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
