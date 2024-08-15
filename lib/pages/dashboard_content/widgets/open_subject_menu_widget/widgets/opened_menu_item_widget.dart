import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/app_theme.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/open_subject_menu_widget/modal/open_subject_model.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/open_subject_menu_widget/widgets/opened_menu_item_controller.dart';
import 'package:teaching_app/utils/contants.dart';
import 'package:teaching_app/widgets/filled_arrow_icon_widget.dart';
import 'package:teaching_app/widgets/text_view.dart';

import '../../../../../database/datebase_controller.dart';

class DashboardOpenedSubjectMenuItemWidget extends StatelessWidget {
  final List<LocalChapter> model;
  final bool isToDo;
  final int selectedSubject;
  final String type;
  const DashboardOpenedSubjectMenuItemWidget(
      {super.key,
      required this.selectedSubject,
      required this.model,
      required this.type,
      required this.isToDo});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: DashboardOpenMenuItemController(),
        builder: (_) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 50, bottom: 15, left: 15, right: 15),
            child: ListView.builder(
              itemCount: model.length,
              itemBuilder: (context, index) {
                // print("in hereee ${model.length}");
                final localChapter = model[index];
                final chapter = model[index].chapter;
                final topics = model[index].topics;
                return Obx(() => Card(
                      elevation: 5,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: ThemeColor.greyLight)),
                          child: ExpansionTile(
                            collapsedBackgroundColor: ThemeColor.white,
                            backgroundColor: ThemeColor.lightBlueF5F9,
                            collapsedTextColor: ThemeColor.darkBlue4392,
                            textColor: ThemeColor.darkBlue4392,
                            onExpansionChanged: (isExpanded) {
                              _.isExpanded.value = isExpanded;
                            },
                            trailing: FilledArrowIcon(
                              direction: _.isExpanded.value
                                  ? Direction.up
                                  : Direction.down,
                            ),
                            title: Text(chapter.chapterName ?? ""),
                            children: [
                              Container(
                                color: ThemeColor
                                    .white, // Set background color for content
                                child:
                                    _buildChapterContent(topics, localChapter),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
              },
            ),
          );
        });
  }

  Widget _buildChapterContent(
      List<LocalTopic> localTopic, LocalChapter localChapter) {
    return Column(
      children: [
        Table(
          columnWidths: {
            0: const FlexColumnWidth(9),
            1: const FlexColumnWidth(3.5),
            2: const FlexColumnWidth(3.5),
            3: const FlexColumnWidth(3.5),
            4: const FlexColumnWidth(3.5),
          },
          border: TableBorder.all(color: ThemeColor.greyLight),
          children: [
            TableRow(
              children: [
                TableCell(
                    child: Center(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2.0, right: 2, top: 8, bottom: 8),
                      child: TextView(
                        'Topics',
                        fontsize: 12,
                      )),
                )),
                TableCell(
                    child: Center(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2.0, right: 2, top: 8, bottom: 8),
                      child: TextView(
                        'Media',
                        fontsize: 12,
                      )),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.only(
                      left: 2, right: 2, top: 8, bottom: 8),
                  child: Center(
                    child: TextView(
                      'E-Material',
                      fontsize: 12,
                    ),
                  ),
                )),
                TableCell(
                    child: Center(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2, right: 2, top: 8, bottom: 8),
                      child: TextView(
                        'Questions',
                        fontsize: 12,
                      )),
                )),
                // TableCell(
                //     child: Padding(
                //   padding: const EdgeInsets.only(
                //       left: 2.0, right: 2, top: 8, bottom: 8),
                //   child: Center(
                //     child: TextView(
                //       'Quiz',
                //       fontsize: 12,
                //     ),
                //   ),
                // )),
              ],
            ),
            ...localTopic.map((topic) {
              return TableRow(
                children: [
                  TableCell(
                      child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Row(children: [
                            !isToDo
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 16,
                                  )
                                : const Icon(
                                    Icons.circle,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                            // const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextView(
                                    (topic.topic.topicName ?? ""),
                                    fontsize: 13,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            print("outside");
                                            if (isToDo) {
                                              print("inside");

                                              // final DashboardOpenMenuItemController controller = Get.find();
                                              addToExecution(
                                                courseId: topic
                                                    .topic.instituteCourseId,
                                                subjectId: selectedSubject,
                                                chapterId: topic
                                                    .topic.instituteChapterId,
                                                topicIds: localChapter.topics
                                                    .map((e) => e.topic
                                                        .onlineInstituteTopicId)
                                                    .toList(),
                                              );
                                            }
                                            Get.toNamed("/videoScreen",
                                                arguments: [
                                                  false,
                                                  model,
                                                  topic,
                                                  type
                                                ]);
                                          },
                                          icon: const Icon(
                                            Icons.play_circle_fill_outlined,
                                            color: ThemeColor.green,
                                            size: 20,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            Get.toNamed('/contentPlanning',
                                                arguments: [
                                                  topic,
                                                  localChapter,
                                                  type
                                                ]);
                                          },
                                          icon: Icon(
                                            Icons.queue_play_next_outlined,
                                            color: ThemeColor.green,
                                            size: 20,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]))),
                  TableCell(
                      child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextView(
                            '${topic.mediaSyllabuscount}/${topic.mediaCount}',
                            fontsize: 13)),
                  )),
                  TableCell(
                      child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextView(
                            '${topic.eMaterialSyllabusCount}/${topic.eMaterialCount}',
                            fontsize: 13)),
                  )),
                  TableCell(
                      child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextView(
                            '${topic.questionSyllabusCount}/${topic.questionData.length}',
                            fontsize: 13)),
                  )),
                  // TableCell(
                  //     child: Center(
                  //   child: Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: TextView('2', fontsize: 13)),
                  // )),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  void addToExecution({
    required int courseId,
    required int subjectId,
    required int chapterId,
    required List<int> topicIds,
  }) async {
    try {
      print(
          "in adding : ${courseId} : ${subjectId} : ${chapterId} : ${topicIds}");

      final DatabaseController myDataController =
          Get.find<DatabaseController>();
      Map<String, dynamic> data = {
        "online_la_plan_execution_id": null,
        "parent_institute_id": myDataController.currentuser.parentInstituteId,
        "institute_id": myDataController.currentuser.instituteId,
        "institute_course_id": courseId,
        "institute_course_breakup_id": null,
        "institute_subject_id": subjectId,
        "institute_chapter_id": chapterId,
        "period_num": 1,
        "session": "2024-2025",
        "execution_date": DateTime.now().toIso8601String(),
        "institute_topic_ids": topicIds.join(','),
        "execution_by_teacher_user_id":
            myDataController.currentuser.onlineInstituteUserId,
        "entry_date": DateTime.now().toIso8601String(),
        "last_update_date": DateTime.now().toIso8601String(),
        "update_flag": 0
      };

      int id = await myDataController.insert(
          'tbl_la_plan_execution_2024_2025', data);
    } catch (e) {
      log('message');
    }
  }
}
