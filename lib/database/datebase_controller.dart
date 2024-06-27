import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:teaching_app/database/database_helper_dummy.dart';

class DatabaseController extends GetxController {
  Database? database;

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
      if (userTypeNameMap.isNotEmpty) {
        final designation = userTypeNameMap.first['designation_for'];
        if (designation == 'Department') {
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
            if (userName == 'Teacher' || userName == 'Principal') {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getDownloadList() async {
    if (database != null) {
      final List<Map<String, dynamic>> maps = await database!.rawQuery(
          'SELECT html5_download_url as url,online_institute_topic_data_id as filename,file_name_ext as ext FROM tbl_institute_topic_data');
      return maps;
    } else {
      throw Exception("Database is not initialized");
    }
  }
}
