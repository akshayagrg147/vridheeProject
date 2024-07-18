import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:teaching_app/core/remote_config/remote_config_service.dart';
import 'package:teaching_app/modals/tbl_institute_subject.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import '../../../../database/datebase_controller.dart';
import '../../../../modals/tbl_institite_user_content_access_23_24.dart';
import '../../../../modals/tbl_institute_course.dart';
import '../../../../modals/tbl_institute_topic.dart';
import '../../../../modals/tbl_institute_topic_data.dart';
import '../../../../modals/tbl_intitute_chapter_model.dart';
import '../../../../modals/tbl_la_plan_execution_2023_2024.dart';
import 'package:url_launcher/url_launcher.dart';
import '../open_subject_menu_widget/modal/open_subject_model.dart';

class DashboardHeaderController extends GetxController {
  final DatabaseController myDataController = Get.find();

  // RxList<String> classList = ['8th Class', '9th Class','10th Class'].obs;

  RxList<InstituteSubject> subjectList = <InstituteSubject>[].obs;
  var selectedSubject = Rxn<InstituteSubject>();

  RxList<String> languageList = ['English', 'Hindi', 'Sanskrit'].obs;
  var selectedLanguage = RxnString("English");

  RxList<InstituteCourse> classList = <InstituteCourse>[].obs;
  var selectedClass = Rxn<InstituteCourse>();

  RxList<LocalChapter> allChapterList = <LocalChapter>[].obs;
  RxList<LocalChapter> inProgress = <LocalChapter>[].obs;
  RxList<LocalChapter> toDo = <LocalChapter>[].obs;
  RxList<LocalChapter> completed = <LocalChapter>[].obs;

  var allSubjectsData = <int, Map<String, List<LocalChapter>>>{}.obs;

  RxList<Map<String, dynamic>> cData = <Map<String, dynamic>>[].obs;
  RxBool isFetchingData = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClassData();
    fetchContinueData(null, null);
    fetchLanguageData();
    _checkForUpdate();
  }

  Future<void> fetchClassData() async {
    try {
      final List<Map<String, dynamic>> classDataMaps =
          await myDataController.query('tbl_institute_course');
      final List<InstituteCourse> classData =
          classDataMaps.map((map) => InstituteCourse.fromMap(map)).toList();
      classList.assignAll(classData);
    } catch (e) {
      // print('Error fetching data from database: $e');
    }
  }

  Future<void> fetchLanguageData() async {
    try {
      final List<Map<String, dynamic>> languageDataMaps =
          await myDataController.rawQuery('''SELECT DISTINCT content_lang
          FROM tbl_institute_topic_data

          UNION

          SELECT DISTINCT content_lang
          FROM tbl_lms_ques_bank''');
      languageList.value =
          languageDataMaps.map((e) => e['content_lang'].toString()).toList();
      selectedLanguage.value = languageList.first;
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> fetchSubjectsForClass(InstituteCourse selClass) async {
    // print("fetching subject");
    try {
      final int courseId = selClass.onlineInstituteCourseId;
      // final int courseId1 = 4;
      // print("fetching 1");
      // Fetch subject_ids for the selected course_id
      final List<Map<String, dynamic>> subjectRelData =
          await myDataController.query(
        'tbl_institute_subject_course_rel',
        where: 'institute_course_id = ?',
        whereArgs: [courseId],
      );
      // print("fetching 2");
      // Extract subject IDs
      final List<int> subjectIds = subjectRelData
          .map((data) => data['institute_subject_id'] as int)
          .toList();
      // print("fetching 3 ${subjectIds}");
      // print(subjectIds);
      if (subjectIds.isNotEmpty) {
        // Fetch subjects for the selected subject_ids
        // final List<Map<String, dynamic>> subjectDataMaps = await myDataController.query(
        //   'tbl_institute_subject',
        //   where: 'institute_subject_id IN (${subjectIds.join(",")})',
        // );
        final List<Map<String, dynamic>> subjectDataMaps =
            await myDataController.query(
          'tbl_institute_subject',
          where: 'online_institute_subject_id IN (${subjectIds.join(",")})',
          // where: 'institute_subject_id = ?',
          // whereArgs: [courseId1],
        );
        // print("fetching 4 length ${subjectDataMaps.length}  ${subjectDataMaps[0]["institute_subject_id"]}");
        // print(subjectDataMaps);
        final List<InstituteSubject> subjectData = subjectDataMaps
            .map((map) => InstituteSubject.fromMap(map))
            .toList();
        selectedSubject.value = null;
        subjectList.assignAll(subjectData);
        // print(subjectList);
      } else {
        subjectList.clear();
        selectedSubject.value = null;
      }
    } catch (e) {
      // print('Error fetching subjects from database: $e');
    }
  }

  // Future<void> fetchData(int subjectId) async {
  //   print(" in fetchingin data ${subjectId}");
  //   allChapterList.clear();
  //   toDo.clear();
  //   inProgress.clear();
  //   completed.clear();
  //
  //   try {
  //     List<LocalChapter> chapters = await fetchAllChapters(selectedClass.value?.instituteCourseId ?? 0, subjectId);
  //     // print("1 chpaters lenght: ${chapters}");
  //     allChapterList.assignAll(chapters);
  //     // print("2 allchpaterslist lenght: ${allChapterList.value}");
  //
  //     // print("object ff ${allChapterList}");
  //     await filterChaptersByExecution();
  //     await filterChaptersBySyllabusPlanning();
  //   } catch (e) {
  //     // print('Error fetching data: $e');
  //   }
  // }

  Future<List<InstituteChapter>> fetchChapters(
      int courseId, int subjectId) async {
    // print("in fetch chapter  maps $courseId  ${subjectId}");
    final List<Map<String, dynamic>> chapterDataMaps =
        await myDataController.query(
      'tbl_institute_chapter',
      where: 'institute_course_id = ? AND institute_subject_id = ?',
      whereArgs: [courseId, subjectId],
    );
    // print("in fetch chapter  maps${chapterDataMaps.length}");
    final List<InstituteChapter> chapterData =
        chapterDataMaps.map((map) => InstituteChapter.fromMap(map)).toList();
    // print("in fetch chapter 3");
    // print("in fetch chapter data ${chapterData[0].onlineInstituteChapterId} ${chapterData[1].onlineInstituteChapterId} ${chapterData[2].onlineInstituteChapterId} ${chapterData[4].onlineInstituteChapterId} ${chapterData[3].onlineInstituteChapterId} ${chapterData[5].onlineInstituteChapterId} ${chapterData[6].onlineInstituteChapterId} ");

    return chapterData;
  }

  Future<List<InstituteTopic>> fetchTopics(int courseId, int chapterId) async {
    // print("in fetch topic 1");
    // print("in fetch topics  maps $courseId  ${chapterId}");
    final List<Map<String, dynamic>> topicsMaps = await myDataController.query(
      'tbl_institute_topic',
      where: 'institute_course_id = ? AND institute_chapter_id = ?',
      whereArgs: [courseId, chapterId],
    );
    // print("in fetch topics  maps${topicsMaps.length}");
    // print("${topicsMaps}");

    try {
      final List<InstituteTopic> topic = topicsMaps.map((map) {
        // print("Mapping topic data: $map");
        return InstituteTopic.fromMap(map);
      }).toList();

      // print("in fetch topics list length: ${topic.length}");
      return topic;
    } catch (e) {
      // print("Error during mapping: $e");
      return [];
    }
    // final List<InstituteTopic> topic = topicsMaps.map((map) => InstituteTopic.fromMap(map)).toList();
    // print("here here");
    // print("in fetch topics  list${topic.length}");
    // return topic;
  }

  Future<List<InstituteTopicData>> fetchTopicData(int topicId,
      {required String language}) async {
    // print("in fetch topic data 1");

    final List<Map<String, dynamic>> topicsDataMaps =
        await myDataController.rawQuery('''
     select * , tt.topic_name from tbl_institute_topic_data as tb
join tbl_institute_topic tt on tt.online_institute_topic_id=tb.institute_topic_id
where tb.institute_topic_id = $topicId and tb.content_lang = "$language"
      ''');
    //     await myDataController.query(
    //   'tbl_institute_topic_data',
    //   where: 'institute_topic_id = ? and content_lang = ? ',
    //   whereArgs: [topicId, language],
    // );
    // print("in fetch topic data  2");
    final List<InstituteTopicData> topicData =
        topicsDataMaps.map((map) => InstituteTopicData.fromJson(map)).toList();
    // print("in fetch topic data  3 ${topicData.length}");
    return topicData;
  }

  Future<List<QuestionBank>> fetchQuestionsData(int topicId,
      {required String language}) async {
    // print("in fetch topic data 1");

    final List<Map<String, dynamic>> questionDataMap =
        await myDataController.query(
      'tbl_lms_ques_bank',
      where: 'institute_topic_id = ? and content_lang = ? ',
      whereArgs: [topicId, language],
    );
    // print("in fetch topic data  2");
    final List<QuestionBank> questionData =
        questionDataMap.map((map) => QuestionBank.fromJson(map)).toList();
    // print("in fetch topic data  3 ${topicData.length}");
    return questionData;
  }

  Future<List<LocalChapter>> fetchAllChapters(
      int courseId, int subjectId) async {
    final List<InstituteChapter> chaptersData =
        await fetchChapters(courseId, subjectId);

    // print("fetch al lchapter chaptersData length ${chaptersData.length}");

    List<LocalChapter> chapters = [];

    for (var chapterMap in chaptersData) {
      final int chapterId = chapterMap.onlineInstituteChapterId;
      // print("fetch all chhapter chatperId: $chapterId");
      final List<InstituteTopic> topicsList =
          await fetchTopics(courseId, chapterId);
      // print("fetch all chapter topics List length ${topicsList.length}");

      List<LocalTopic> topicList = [];

      for (var topicMap in topicsList) {
        final int topicId = topicMap.onlineInstituteTopicId;
        // print("fetch all chapter topicListAdd id ${topicId}");
        final List<InstituteTopicData> topicDataList = await fetchTopicData(
            topicId,
            language: selectedLanguage.value ?? "");
        final List<QuestionBank> questionList = await fetchQuestionsData(
            topicId,
            language: selectedLanguage.value ?? "");
        topicList.add(LocalTopic(
            topic: topicMap,
            topicData: topicDataList,
            questionData: questionList));
        // print("topic list added for ${topicId} ${topicList.length} and ${topicDataList.length}");
        // // print("in chapter ff");
      }
      chapters.add(LocalChapter(chapter: chapterMap, topics: topicList));
      // print("fetch all chapter chaptersAdd ${chapters.length}");
    }
    // print("fetch all chapter topicListAdd return ${chapters.length}");
    return chapters;
  }

  Future<void> filterChaptersByExecution() async {
    // print("in fetch execution 1");

    final List<Map<String, dynamic>> executionDataMaps =
        await myDataController.query(
      'tbl_la_plan_execution_2024_2025',
    );
    // print("in fetch execution 2");

    final List<LaPlanExecution> executionData = executionDataMaps.map((map) {
      // print("Mapping la plan: $map");
      return LaPlanExecution.fromMap(map);
    }).toList();
    toDo.clear();
    // print("in fetch topics list length: ${executionData.length} : ${executionData[0]}");
    // final List<LaPlanExecution> executionData = executionDataMaps.map((map) => LaPlanExecution.fromMap(map)).toList();
    // print("in fetch execution 3");

    // Filter chapters from allChapterList that match executionData
    for (var execution in executionData) {
      List<LocalChapter> filteredChapters = allChapterList
          .where((chapter) =>
              chapter.chapter.onlineInstituteChapterId ==
                  execution.instituteChapterId &&
              chapter.chapter.instituteSubjectId ==
                  execution.instituteSubjectId)
          .toList();
      print("filteredChapters list" + filteredChapters.toString());
      // print("in dfd ${chapter.chapter.instituteChapterId}");
      // print("aa : ${execution.instituteSubjectId} : ${execution.instituteChapterId}");
      // print("in execution aa");
      if (filteredChapters.isNotEmpty) {
        // print(" in here aa :${filteredChapters.length}");
        // inProgress.addAll(filteredChapters);
        toDo.addAll(filteredChapters);
        // print(" in here if ${inProgress.length}");
        // print(" in here if 2 ${inProgress[0].chapter.onlineInstituteChapterId}");
        allChapterList
            .removeWhere((chapter) => filteredChapters.contains(chapter));
      }
    }
  }

  Future<void> filterChapterByUserAccess() async {
    // print("in fetch execution 1");

    final List<Map<String, dynamic>> executionDataMaps =
        await myDataController.query(
      'tbl_institute_user_content_access_2024_2025',
    );
    // print("in fetch execution 2");

    try {
      final List<InstituteUserContentAccess> executionData =
          executionDataMaps.map((map) {
        print("Mapping topic data: $map");
        return InstituteUserContentAccess.fromMap(map);
      }).toList();

      inProgress.clear();
      // print("in fetch topics list length: ${executionData.length}");

      // final List<LaPlanExecution> executionData = executionDataMaps.map((map) => LaPlanExecution.fromMap(map)).toList();
      // print("in fetch execution 3");

      // Filter chapters from allChapterList that match executionData
      for (var execution in executionData) {
        List<LocalChapter> filteredChapters = allChapterList
            .where((chapter) =>
                chapter.chapter.onlineInstituteChapterId ==
                    execution.instituteChapterId &&
                chapter.chapter.instituteSubjectId ==
                    execution.instituteSubjectId)
            .toList();

        // List<LocalChapter> filteredChapters = allChapterList.where((chapter) {
        //   // Print details of each chapter being processed
        //   print("Checking chapter with onlineInstituteChapterId: ${chapter.chapter.onlineInstituteChapterId} == ${execution.instituteChapterId} and instituteSubjectId: ${chapter.chapter.instituteSubjectId} == ${execution.instituteSubjectId}");
        //
        //   bool isMatchingChapter = chapter.chapter.onlineInstituteChapterId == execution.instituteChapterId &&
        //       chapter.chapter.instituteSubjectId == execution.instituteSubjectId;
        //
        //   // Print if the chapter matches the criteria
        //   if (isMatchingChapter) {
        //     print("Chapter matches criteria");
        //   } else {
        //     print("Chapter does not match criteria");
        //   }
        //
        //   return isMatchingChapter;
        // }).toList();

        // print("in dfd ${filteredChapters.length}");
        // print(execution.instituteSubjectId);
        // print("in execution aa");
        if (filteredChapters.isNotEmpty) {
          // print(" in here aa");
          inProgress.addAll(filteredChapters);
          // print(" in here if ${inProgress.length}");
          // print(" in here if 2 ${inProgress[0].chapter.onlineInstituteChapterId}");
          allChapterList
              .removeWhere((chapter) => filteredChapters.contains(chapter));
        }
      }
    } catch (e) {
      print("Error during mapping user acess: $e");
    }
  }

  // Future<void> filterChaptersBySyllabusPlanning() async {
  //   // print("in fetch syllabus 1");
  //
  //   final List<Map<String, dynamic>> syllabusDataMaps = await myDataController.query(
  //     'tbl_syllabus_planning_2024_2025',
  //   );
  //   // print("in fetch syllabus 2");
  //
  //   final List<SyllabusPlanning> syllabusData = syllabusDataMaps.map((map) => SyllabusPlanning.fromMap(map)).toList();
  //   // print("in syllabus 2 ${syllabusData.length}");
  //   // Filter chapters from allChapterList that match syllabusData
  //   for (var syllabus in syllabusData) {
  //     List<LocalChapter> filteredChapters = allChapterList.where((chapter) =>
  //     chapter.chapter.onlineInstituteChapterId == 536 &&
  //         131.0 == syllabus.instituteSubjectId
  //     ).toList();
  //
  //     if (filteredChapters.isNotEmpty) {
  //       toDdo.assignAll(filteredChapters);
  //       allChapterList.removeWhere((chapter) => filteredChapters.contains(chapter));
  //       update();
  //     }
  //   }
  //
  //   // Remaining chapters in allChapterList will be considered as completed
  //   completed.assignAll(allChapterList);
  // }
  void updateAddedContent(
      {required InstituteTopicData data,
      required String progressType,
      required int onlineInstituteSubjectId,
      required int onlineInstituteChapterId,
      required int onlineInstituteTopicId}) {
    try {
      final chapter = allSubjectsData[onlineInstituteSubjectId]![progressType]
          ?.firstWhereOrNull((element) =>
              element.chapter.onlineInstituteChapterId ==
              onlineInstituteChapterId);
      final topic = chapter!.topics.firstWhereOrNull((element) =>
          element.topic.onlineInstituteTopicId == onlineInstituteTopicId);
      topic?.topicData.add(data);
    } catch (e) {
      print("Error Updating added content :- $e");
    }
  }

  Future<void> fetchDataForAllSubjects() async {
    var tempData = <int, Map<String, List<LocalChapter>>>{};
    for (var subject in subjectList) {
      var inProgress = <LocalChapter>[];
      var toDo = <LocalChapter>[];
      var completed = <LocalChapter>[];

      allChapterList.clear();
      toDo.clear();
      inProgress.clear();
      completed.clear();

      List<LocalChapter> chapters = await fetchAllChapters(
          selectedClass.value?.onlineInstituteCourseId ?? 0,
          subject.onlineInstituteSubjectId);
      allChapterList.clear();
      allChapterList.assignAll(chapters);
      // print("chapter list for : ${subject.onlineInstituteSubjectId} : ${allChapterList.length}");
      await filterChapterByUserAccess();
      await filterChaptersByExecution();
      // await filterChaptersBySyllabusPlanning();
      // print("in all A : ${allChapterList.length} : ${subject.onlineInstituteSubjectId}");

      inProgress.addAll(this.inProgress);

      toDo.addAll(this.toDo);
      completed.addAll(this.completed);

      // print("in all ${inProgress.length} ${subject.onlineInstituteSubjectId}");
      tempData[subject.onlineInstituteSubjectId] = {
        "inProgress": List<LocalChapter>.from(inProgress),
        "toDo": List<LocalChapter>.from(toDo),
        "completed": List<LocalChapter>.from(allChapterList),
        // "inProgress": allChapterList,
        // "completed": allChapterList,
      };
      // print("in all C : ${subject.onlineInstituteSubjectId} : ${tempData[subject.onlineInstituteSubjectId]}");
    }
    allSubjectsData.assignAll(tempData);
    update();
    // print("in all B : ${allChapterList.length} : ${allSubjectsData.length} : ${allSubjectsData[131]}");
  }

//  continuing watching
  Future<void> fetchContinueData(int? classId, int? subjectId) async {
    // print("fetch data called");
    cData.clear();
    // print("c data length${cData.length}");
    update();
    try {
      // Fetch data from the database, you might need to adjust this according to your database setup.
      // For demonstration purposes, we'll use a dummy function `fetchContentAccessData` to simulate data fetching.

      isFetchingData.value = true;

      List<InstituteUserContentAccess> data =
          await fetchContentAccessData(classId, subjectId);
      // print("in data length: ${data.length}");
      // Transform data to the required format
      final topicIds = data.map((e) => e.instituteTopicDataId).toList();
      List<InstituteTopicData> topicDatas =
          topicIds.isEmpty ? [] : await fetchContinueTopicData(topicIds);
      List<Map<String, dynamic>> fetchedVideos = [];
      for (var item in data) {
        // print("In loop");
        // String className = await fetchClassName(item.instituteCourseId);
        // String subjectName = await fetchSubjectName(item.instituteSubjectId);
        // String chapterName = await fetchChapterName(item.instituteChapterId);
        // String topicName = await fetchTopicName(item.instituteTopicId);

        fetchedVideos.add({
          'class': item.className,
          'subject': item.subjectName,
          'subjectId': item.instituteSubjectId,
          'chapterId': item.instituteChapterId,
          'courseId': item.instituteCourseId,
          'topicId': item.instituteTopicId,
          'topicDataId': item.instituteTopicDataId,
          'chapter': item.chapterName,
          'topic': item.topicName,
          'topicData': topicDatas.firstWhereOrNull((element) =>
              element.onlineInstituteTopicDataId == item.instituteTopicDataId),
        });
      }
      cData.clear();

      cData.assignAll(fetchedVideos);
      // print("in continue ${cData.value.length}");
      update();
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
    } finally {
      isFetchingData.value = false;
    }
  }

  Future<List<InstituteUserContentAccess>> fetchContentAccessData(
      int? classId, int? subjectId) async {
    // Construct the SQL query with optional filters
    String whereClause = '';

    if (classId != null) {
      whereClause += 'where ta.institute_course_id = $classId';
    }

    if (subjectId != null) {
      if (whereClause.isNotEmpty)
        whereClause += ' AND ';
      else
        whereClause += ' where ';
      whereClause += 'ta.institute_subject_id = $subjectId';
    }

    final List<Map<String, dynamic>> dataMaps =
        await myDataController.rawQuery('''
    select * , tc.institute_course_name as className ,
     ts.subject_name as subjectName ,
     tch.chapter_name as chapterName, tt.topic_name as TopicName
     from tbl_institute_user_content_access_2024_2025 ta
    left join tbl_institute_course tc on ta.institute_course_id = tc.online_institute_course_id
    left join tbl_institute_subject ts on ta.institute_subject_id = ts.online_institute_subject_id
    left join tbl_institute_chapter tch on ta.institute_chapter_id = tch.online_institute_chapter_id
    left join tbl_institute_topic tt on ta.institute_topic_id = tt.online_institute_topic_id
    $whereClause
    ''');

    // final List<Map<String, dynamic>> dataMaps = await myDataController.

    // final List<Map<String, dynamic>> dataMaps = await myDataController.query(
    //   'tbl_institute_user_content_access_2024_2025',
    //   where: whereClause.isEmpty ? null : whereClause,
    //   whereArgs: whereArgs.isEmpty ? null : whereArgs,
    //   // orderBy: 'institute_user_content_access_id  DESC',
    // );
    // print(dataMaps);
    print("FetchDataContent :- $dataMaps");
    // print("in continue data ${dataMaps.length}");
    final List<InstituteUserContentAccess> data =
        dataMaps.map((map) => InstituteUserContentAccess.fromMap(map)).toList();
    // print("in continue data2 ${data.length}");
    update();
    return data;
  }

  Future<List<InstituteTopicData>> fetchContinueTopicData(
      List<int> topicIds) async {
    try {
      String subQuery = '';
      if (topicIds.isNotEmpty) {
        final ids = topicIds.join(',');
        subQuery = "where online_institute_topic_data_id in ($ids)";
      }
      final List<Map<String, dynamic>> topicDataMaps = await myDataController
          .rawQuery('select * from tbl_institute_topic_data $subQuery');

      print('success fetching topic data: $topicDataMaps');

      final List<InstituteTopicData> topicData =
          topicDataMaps.map((map) => InstituteTopicData.fromJson(map)).toList();

      return topicData;
    } catch (e) {
      print('Error fetching topic data');
      // print('Error fetching topic data: $e');
      return []; // Handle error case
    }
  }

  Future<String> fetchClassName(int courseId) async {
    try {
      final List<Map<String, dynamic>> classDataMaps =
          await myDataController.query(
        'tbl_institute_course',
        where: 'online_institute_course_id = ?',
        whereArgs: [courseId],
      );

      if (classDataMaps.isNotEmpty) {
        final String className =
            classDataMaps.first['institute_course_name'] as String;
        return className;
      } else {
        return ''; // Handle the case where no class name is found
      }
    } catch (e) {
      print('Error fetching class name: $e');
      return ''; // Handle error case
    }
  }

  Future<String> fetchSubjectName(int subjectId) async {
    try {
      final List<Map<String, dynamic>> subjectDataMaps =
          await myDataController.query(
        'tbl_institute_subject',
        where: 'online_institute_subject_id = ?',
        whereArgs: [subjectId],
      );

      if (subjectDataMaps.isNotEmpty) {
        final String subjectName =
            subjectDataMaps.first['subject_name'] as String;
        return subjectName;
      } else {
        return ''; // Handle the case where no subject name is found
      }
    } catch (e) {
      print('Error fetching subject name: $e');
      return ''; // Handle error case
    }
  }

  Future<String> fetchChapterName(int chapterId) async {
    try {
      final List<Map<String, dynamic>> chapterDataMaps =
          await myDataController.query(
        'tbl_institute_chapter',
        where: 'online_institute_chapter_id = ?',
        // Assuming online_institute_chapter_id is the primary key
        whereArgs: [chapterId],
      );

      if (chapterDataMaps.isNotEmpty) {
        final String chapterName =
            chapterDataMaps.first['chapter_name'] as String;
        return chapterName;
      } else {
        return ''; // Handle the case where no chapter name is found
      }
    } catch (e) {
      print('Error fetching chapter name: $e');
      return ''; // Handle error case
    }
  }

  Future<String> fetchTopicName(int topicId) async {
    try {
      final List<Map<String, dynamic>> topicDataMaps =
          await myDataController.query(
        'tbl_institute_topic',
        where: 'online_institute_topic_id = ?',
        // Assuming online_institute_topic_id is the primary key
        whereArgs: [topicId],
      );

      if (topicDataMaps.isNotEmpty) {
        final String topicName = topicDataMaps.first['topic_name'] as String;
        return topicName;
      } else {
        return ''; // Handle the case where no topic name is found
      }
    } catch (e) {
      print('Error fetching topic name: $e');
      return ''; // Handle error case
    }
  }

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }

  Future<void> _checkForUpdate() async {
    if (!(await isInternetAvailable())) {
      return;
    }
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    final String remoteVersion = RemoteConfigService.getAppVersion;
    print("RemoteConfigVersionCurrent : $remoteVersion");
    if (currentVersion.trim().isNotEmpty &&
        remoteVersion.trim().isNotEmpty &&
        _isUpdateRequired(currentVersion, remoteVersion)) {
      print("RemoteConfigVersion : true");
      _showUpdateDialog();
    }
  }

  bool _isUpdateRequired(String currentVersion, String remoteVersion) {
    final currentVersionParts = currentVersion.split('.');
    final remoteVersionParts = remoteVersion.split('.');

    for (int i = 0; i < remoteVersionParts.length; i++) {
      final currentPart = int.parse(currentVersionParts[i]);
      final remotePart = int.parse(remoteVersionParts[i]);

      if (remotePart > currentPart) {
        return true;
      } else if (remotePart < currentPart) {
        return false;
      }
    }

    return false;
  }

  void _showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
            'A new version of the app is available. Please update to continue.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              _launchURL();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _launchURL() async {
    const url =
        'https://track.vridhee.com/Installer/VridheeEDU/VridheeLMSOffline.apk';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
