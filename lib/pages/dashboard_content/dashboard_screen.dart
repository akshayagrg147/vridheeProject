import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/app_theme.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/continue_watching/dashboard_continue_watching.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/header/header_dashboard.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/header/header_dashboard_controller.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/open_subject_menu_widget/open_subject_menu_screen.dart';
import 'package:teaching_app/widgets/address_header.dart';
import 'package:teaching_app/widgets/app_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardHeaderController());
    return GetBuilder<DashboardHeaderController>(builder: (_) {
      return AppScaffold(
        showTopRadius: false,
        showAppbar: false,
        bgColor: ThemeColor.scaffoldBgColor,
        showLeading: false,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const DashboardHeaderWidget(),
                const SizedBox(
                  height: 20,
                ),
                Obx(() => _.isFetchingData.value
                    ? const CircularProgressIndicator()
                    : _.cData.isNotEmpty? Card(
                        elevation: 5,
                        child: DashboardContinueWatchingWidget(
                          cData: _.cData,
                          // chapterData: _.allSubjectsData,
                        ),
                      ):const SizedBox.shrink()),
                const SizedBox(
                  height: 20,
                ),
                Obx(() {
                  if (_.selectedSubject.value != null&&_.allChapterList.isNotEmpty) {
                    // print("in index error: ${_.allSubjectsData.length}");
                    return Column(
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 10,
                          child: AddressHeader(
                            topicNumber:
                                _.selectedClass.value!.instituteCourseName ??
                                    "",
                            topicTitle: _.selectedSubject.value!.subjectName,
                            isMenuHeader: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_.allChapterList.isNotEmpty)
                          DashboardOpenedSubjectMenuScreen(
                              selectedSubject: _.selectedSubject.value!
                                  .onlineInstituteSubjectId,
                              inProgress: _.inProgress,
                              completed: _.completed,
                              toDo: _.toDo),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
