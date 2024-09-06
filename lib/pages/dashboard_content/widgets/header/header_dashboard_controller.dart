import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:teaching_app/core/remote_config/remote_config_service.dart';
import 'package:teaching_app/modals/tbl_institute_subject.dart';
import 'package:teaching_app/modals/tbl_lms_ques_bank.dart';
import 'package:teaching_app/utils/string_constant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../database/datebase_controller.dart';
import '../../../../modals/tbl_institite_user_content_access_23_24.dart';
import '../../../../modals/tbl_institute_course.dart';
import '../../../../modals/tbl_institute_topic.dart';
import '../../../../modals/tbl_institute_topic_data.dart';
import '../../../../modals/tbl_intitute_chapter_model.dart';
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

  RxList<Map<String, dynamic>> cData = <Map<String, dynamic>>[].obs;
  RxBool isFetchingData = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await myDataController.setUserDetails();
    fetchClassData();
    fetchContinueData();
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

  Future<List<InstituteChapter>> fetchChapters(
      int courseId, int subjectId) async {
    // print("in fetch chapter  maps $courseId  ${subjectId}");
    final List<Map<String, dynamic>> chapterDataMaps =
        await myDataController.rawQuery('''
    select * ,  EXISTS (
        SELECT 1 
        FROM tbl_institute_user_content_access_2024_2025 a 
        WHERE a.institute_chapter_id = c.online_institute_chapter_id AND a.institute_user_id = ${myDataController.currentuser.onlineInstituteUserId}
    ) AS isStarted from tbl_institute_chapter c
    where c.institute_course_id = $courseId and c.institute_subject_id = $subjectId
    ''');

    // print("in fetch chapter  maps${chapterDataMaps.length}");
    final List<InstituteChapter> chapterData =
        chapterDataMaps.map((map) => InstituteChapter.fromMap(map)).toList();
    // print("in fetch chapter 3");
    // print("in fetch chapter data ${chapterData[0].onlineInstituteChapterId} ${chapterData[1].onlineInstituteChapterId} ${chapterData[2].onlineInstituteChapterId} ${chapterData[4].onlineInstituteChapterId} ${chapterData[3].onlineInstituteChapterId} ${chapterData[5].onlineInstituteChapterId} ${chapterData[6].onlineInstituteChapterId} ");

    return chapterData;
  }

  Future<List<InstituteTopic>> fetchTopics(
      int courseId, List<int> chapterId) async {
    // print("in fetch topic 1");
    // print("in fetch topics  maps $courseId  ${chapterId}");
    final ids = chapterId.join(',');

    try {
      final List<Map<String, dynamic>> topicsMaps =
          await myDataController.rawQuery('''
     select t.*,
     EXISTS (
        SELECT 1 
        FROM tbl_institute_user_content_access_2024_2025 a 
        WHERE a.institute_topic_id = t.online_institute_topic_id AND a.institute_user_id = ${myDataController.currentuser.onlineInstituteUserId}
    ) AS isViewed ,
     (SELECT GROUP_CONCAT(Distinct s.institute_topic_data_id) 
     FROM ${StringConstant().tblSyllabusPlanning}  s
     WHERE s.institute_topic_id = t.online_institute_topic_id and s.content_type != "Question"
    ) AS topic_data_syllabus_ids,
     (SELECT GROUP_CONCAT(Distinct sq.institute_topic_data_id) 
     FROM ${StringConstant().tblSyllabusPlanning}  sq
     WHERE sq.institute_topic_id = t.online_institute_topic_id and sq.content_type = "Question"
    ) AS question_syllabus_ids
      from tbl_institute_topic t where t.institute_course_id = $courseId and t.institute_chapter_id in ($ids)
     ''');
      // print("in fetch topics  maps${topicsMaps.length}");
      // print("${topicsMaps}");
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

  Future<List<InstituteTopicData>> fetchTopicData(List<int> topicIds,
      {required String language}) async {
    // print("in fetch topic data 1");
    final ids = topicIds.join(',');
    final List<Map<String, dynamic>> topicsDataMaps =
        await myDataController.rawQuery('''
     select tb.* , tt.topic_name from tbl_institute_topic_data tb
join tbl_institute_topic tt on tb.institute_topic_id = tt.online_institute_topic_id
where tb.institute_topic_id in ($ids) and tb.content_lang = "$language"
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

  Future<List<QuestionBank>> fetchQuestionsData(List<int> topicIds,
      {required String language}) async {
    // print("in fetch topic data 1");
    final ids = topicIds.join(',');

    final List<Map<String, dynamic>> questionDataMap =
        await myDataController.rawQuery('''
      select * from tbl_lms_ques_bank where institute_topic_id in ($ids) and content_lang = "$language"
      ''');

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
    final chapterIds =
        List<int>.from(chaptersData.map((e) => e.onlineInstituteChapterId));
    final List<InstituteTopic> topicsList =
        await fetchTopics(courseId, chapterIds);
    final topicIds =
        List<int>.from(topicsList.map((e) => e.onlineInstituteTopicId));
    final List<InstituteTopicData> topicDataList =
        await fetchTopicData(topicIds, language: selectedLanguage.value ?? "");

    final List<QuestionBank> questionList = await fetchQuestionsData(topicIds,
        language: selectedLanguage.value ?? "");

    List<LocalTopic> localTopicList = [];
    for (var topic in topicsList) {
      final topicData = topicDataList
          .where((element) =>
              element.instituteTopicId == topic.onlineInstituteTopicId)
          .toList();
      final questionData = questionList
          .where((element) =>
              element.instituteTopicId == topic.onlineInstituteTopicId)
          .toList();
      localTopicList.add(LocalTopic(
          topic: topic, topicData: topicData, questionData: questionData));
    }

    for (var chapterMap in chaptersData) {
      final int chapterId = chapterMap.onlineInstituteChapterId;

      final localTopics = localTopicList
          .where((element) => element.topic.instituteChapterId == chapterId)
          .toList();

      chapters.add(LocalChapter(chapter: chapterMap, topics: localTopics));
      // print("fetch all chapter chaptersAdd ${chapters.length}");
    }
    // print("fetch all chapter topicListAdd return ${chapters.length}");
    return chapters;
  }

  Future<void> fetchDataForSelectedSubject() async {
    allChapterList.clear();
    toDo.clear();
    inProgress.clear();
    completed.clear();

    List<LocalChapter> chapters = await fetchAllChapters(
        selectedClass.value?.onlineInstituteCourseId ?? 0,
        selectedSubject.value!.onlineInstituteSubjectId);

    allChapterList.clear();
    allChapterList.assignAll(chapters);

    filterChapters();

    update();
  }

  void filterChapters() {
    List<LocalChapter> chapters = [];
    chapters.addAll(allChapterList);
    inProgress.assignAll(chapters.where((element) =>
        element.chapter.isStarted &&
        element.topics.map((e) => e.topic.isViewed).toList().contains(false) ==
            true));
    completed.assignAll(chapters.where((element) =>
        element.chapter.isStarted &&
        element.topics.map((e) => e.topic.isViewed).toList().contains(false) ==
            false));
    chapters.removeWhere((element) => element.chapter.isStarted);
    toDo.assignAll(chapters);
  }

//  continuing watching
  Future<void> fetchContinueData() async {
    // print("fetch data called");
    final int? classId = selectedClass.value?.onlineInstituteCourseId;
    final int? subjectId = selectedSubject.value?.onlineInstituteSubjectId;
    cData.clear();
    update();
    try {
      // Fetch data from the database, you might need to adjust this according to your database setup.

      isFetchingData.value = true;

      List<InstituteUserContentAccess> data =
          await fetchContentAccessData(classId, subjectId, isLast6: true);

      final topicIds = data.map((e) => e.instituteTopicDataId).toList();
      List<InstituteTopicData> topicDatas =
          topicIds.isEmpty ? [] : await fetchContinueTopicData(topicIds);
      List<Map<String, dynamic>> fetchedVideos = [];
      for (var item in data) {
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
      int? classId, int? subjectId,
      {bool isLast6 = false}) async {
    // Construct the SQL query with optional filters
    String whereClause =
        'where institute_user_id = ${myDataController.currentuser.onlineInstituteUserId}';

    if (classId != null) {
      whereClause += ' AND ta.institute_course_id = $classId';
    }

    if (subjectId != null) {
      whereClause += ' AND ta.institute_subject_id = $subjectId';
    }

    if (isLast6) {
      whereClause += ' ORDER BY institute_user_content_access_id DESC LIMIT 6';
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

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
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

  void addToProgress({
    required int courseId,
    required int chapterId,
    required int topicId,
    required int topicDataId,
  }) async {
    try {
      print("in adding : ${courseId}  : ${chapterId} : ${topicId}");

      final DatabaseController myDataController =
          Get.find<DatabaseController>();

      Map<String, dynamic> data = {
        "online_institute_user_content_access_id": null,
        "parent_institute_id": myDataController.currentuser.parentInstituteId,
        "institute_id": myDataController.currentuser.instituteId,
        "institute_user_id": myDataController.currentuser.onlineInstituteUserId,
        "user_type": "Employee",
        "institute_course_id": courseId,
        "institute_subject_id": selectedSubject.value!.onlineInstituteSubjectId,
        "institute_chapter_id": chapterId,
        "institute_topic_id": topicId,
        "institute_topic_data_id": topicDataId,
        "last_access_start_time": DateTime.now().toIso8601String(),
        "last_access_end_time": DateTime.now().toIso8601String(),
        "total_access_time": 0,
        "no_of_views": DateTime.now().toIso8601String(),
        "entry_date": null,
        "last_update_date": null,
        "update_flag": 0
      };

      int id = await myDataController.insert(
          StringConstant().tblInstituteUserContentAccess, data);
      print("Inserted row id: $id");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }
}
