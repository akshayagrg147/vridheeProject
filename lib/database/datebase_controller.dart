import 'dart:convert';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/database_helper_dummy.dart';
import 'package:teaching_app/modals/user_model.dart';
import 'package:teaching_app/pages/clicker_registration/modal/clicker_model.dart';
import 'package:teaching_app/pages/clicker_registration/modal/student_data_model.dart';

class DatabaseController extends GetxController {
  Database? database;
  static int loginUserId = -1;
  late UserDataModel currentuser;
  Future<void> setUserDetails() async {
    final employeedataList = await query('tbl_employee',
        where: 'user_email_id = ?',
        whereArgs: [SharedPrefHelper().getLoginUserMail()]);
    final employeedata = employeedataList.first;
    jsonEncode(employeedata);
    currentuser = UserDataModel.fromJson(employeedata);
    loginUserId = employeedata['online_institute_user_id'];
  }

  Future<void> initializeDatabase() async {
    if (database == null) {
      await DatabaseHelper().initializeDatabase();
      database = await DatabaseHelper().database;
    }
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where,
      List<Object?>? whereArgs,
      int? limit,
      String? orderBy}) async {
    if (database != null) {
      return await database!.query(table,
          where: where, whereArgs: whereArgs, limit: limit, orderBy: orderBy);
    } else {
      throw Exception("Database is not initialized");
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (database != null) {
      return await database!.insert(table, data);
    } else {
      throw Exception("Database is not initialized");
    }
  }

  Future<int> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    if (database != null) {
      return await database!.delete(table, where: where, whereArgs: whereArgs);
    } else {
      throw Exception("Database is not initialized");
    }
  }

  Future<void> performTransaction({required String query}) async {
    if (database != null) {
      await database!.transaction((txn) async {
        await txn.execute(query);
      });
      print("Perform Transaction Successfully");
    } else {
      throw Exception("Database is not initialized");
    }
  }

  Future<bool> getLogin({
    required String user,
    required String password,
    required String role,
  }) async {
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        'SELECT user_type_id FROM tbl_employee WHERE user_email_id = ? AND user_password = ?',
        [user, password]);
    print("LoginQuery :- $maps");
    if (maps.isNotEmpty) {
      // now check for department
      final userTypeId = maps.first['user_type_id'];
      final List<
          Map<String,
              dynamic>> userTypeNameMap = await database!.rawQuery(
          'SELECT designation_for FROM tbl_user_type WHERE online_user_type_id = ? ',
          [userTypeId]);
      final designation = userTypeNameMap.first['designation_for'];
      if (userTypeNameMap.isNotEmpty) {
        if (designation == role) {
          return true;
        } else if (designation == 'Institute') {
          //check for teacher or principal
          final List<
              Map<String,
                  dynamic>> userNameMap = await database!.rawQuery(
              'SELECT user_type_name FROM tbl_user_type WHERE online_user_type_id = ? ',
              [userTypeId]);
          if (userNameMap.isNotEmpty) {
            final userName = userNameMap.first['user_type_name'];
            if (userName == role) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> rawQuery(String query) async {
    if (database != null) {
      final List<Map<String, dynamic>> maps = await database!.rawQuery(query);
      return maps;
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDownloadList() async {
    if (database != null) {
      final List<Map<String, dynamic>> maps = await database!.rawQuery(
          'SELECT html5_download_url as url,online_institute_topic_data_id as filename,file_name_ext as ext FROM tbl_institute_topic_data where is_local_content_available = 0');
      return maps;
    } else {
      throw Exception("Database is not initialized");
    }
  }

  Future<List<Map<String, dynamic>>> getDownloadQuestionImageList() async {
    if (database != null) {
      final List<Map<String, dynamic>> maps = await database!.rawQuery(
          '''SELECT online_lms_ques_bank_id as id, question_down_path as ques_url, option_1_down_path as opt_1_url, option_2_down_path as opt_2_url, option_3_down_path as opt_4_url,option_4_down_path as opt_4_url FROM tbl_lms_ques_bank where is_local_available = 0 AND (
          TRIM(question_down_path) <> '' OR
      TRIM(option_1_down_path) <> '' OR
      TRIM(option_2_down_path) <> '' OR
      TRIM(option_3_down_path) <> '' OR
      TRIM(option_4_down_path) <> ''
    )''');
      return maps;
    } else {
      throw Exception("Database is not initialized");
    }
  }

  Future<void> updateContentProgress(int topicDataId,
      {required int instituteTopicId, bool isQuestion = false}) async {
    if (database != null && loginUserId != -1) {
      await database!.insert('tbl_content_access', {
        'online_institute_topic_data_id': topicDataId,
        'user_id': loginUserId,
        'institute_topic_id': instituteTopicId,
        'is_question': isQuestion ? 1 : 0,
        'created_date': DateTime.now().toIso8601String(),
        'updated_date': DateTime.now().toIso8601String()
      });
    }
  }

  Future<List<StudentDataModel>> fetchStudentsByClass(int instituteCourseId)async{
    if (database != null && loginUserId != -1) {
      final instituteId = currentuser.instituteId;
      final response = await database!.rawQuery('''
      SELECT 
	ss.student_session_id as sessionId,
	ss.online_student_session_id as onlineSessionId,
    s.institute_user_id AS instituteUserId,
    s.online_institute_user_id as onlineInstituteUserId,
    ss.institute_id as instituteId,
    s.user_name AS name,
    s.user_email_id AS email,
    s.user_gender AS gender,
    s.user_mobile_no AS mobile,
    c.online_institute_course_id As instituteCourseId,
    c.institute_course_name As className,
    ss.clickerId As clickerDeviceID
FROM 
    tbl_student s
JOIN 
    tbl_student_session ss ON s.online_institute_user_id = ss.institute_user_id
JOIN 
    tbl_institute_course c ON ss.institute_course_id = c.online_institute_course_id AND ss.parent_institute_id = c.parent_institute_id
WHERE 
    ss.institute_course_id = $instituteCourseId
    AND ss.institute_id = $instituteId
Group By s.online_institute_user_id    
   
      ''');
     return  List<StudentDataModel>.from(response.map((e) => StudentDataModel.fromJSon(e)));
    }

    return List<StudentDataModel>.empty();
  }

  Future<List<ClickerModel>> getClickersData()async{
    if(database != null && loginUserId != -1){
     final response =  await database?.query('tbl_clicker');
     return List<ClickerModel>.from(response!.map((e) => ClickerModel.fromJson(e)));
    }
    return List<ClickerModel>.empty();
  }

  Future<void> setClickerRollNo(int rollNo,{required String deviceId})async{
    if(database != null && loginUserId != -1){
      await database!.update("tbl_clicker", {
        'clicker_id':deviceId
      },
          where: "roll_no = ?",
          whereArgs: [rollNo]
      );
    }
  }


  Future<void> generateClickers(int length)async{
    if(database != null && loginUserId != -1) {
      final batch = database!.batch();
      for (int i = 0; i < length; i++) {
        batch.insert('tbl_clicker', {'clicker_id': null});
      }
      await batch.commit();
    }
  }

  Future<void> setStudentClickerID({required num studentSessionId, required String clickerID})async{
    if(database != null && loginUserId != -1){
      await database!.update("tbl_student_session", {
'clickerId':clickerID
      },
      where: "student_session_id = ?",
        whereArgs: [studentSessionId]
      );
    }
  }
}
