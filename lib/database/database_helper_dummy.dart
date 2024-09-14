import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:teaching_app/database/create_tables.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbpath = await getDatabasesPath();
    databaseFactory = databaseFactoryFfi;

    String path = join(dbpath, 'my_database.db');
    final db = await databaseFactory.openDatabase(
      path,
    );
    await _onCreate(db, 1);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(CreateTables().tbl_assign_subject);
    await db.execute(CreateTables().tbl_employee);
    await db.execute(CreateTables().tbl_institute);
    await db.execute(CreateTables().tbl_institute_chapter);
    await db.execute(CreateTables().tbl_institute_course);
    await db.execute(CreateTables().tbl_institute_course_breakup);
    await db.execute(CreateTables().tbl_institute_course_breakup_session);
    await db.execute(CreateTables().tbl_institute_course_relation);
    await db.execute(CreateTables().tbl_institute_subject);
    await db.execute(CreateTables().tbl_institute_subject_course_rel);
    await db.execute(CreateTables().tbl_institute_topic);
    await db.execute(CreateTables().tbl_institute_user_rel);
    await db.execute(CreateTables().tbl_institute_topic_data);
    await db.execute(CreateTables().tbl_la_hw_cn_assessment);
    await db.execute(CreateTables().tbl_la_hw_cn_assessment_rel);
    await db.execute(CreateTables().tbl_syllabus);
    await db.execute(CreateTables().tbl_user_type);
    await db.execute(CreateTables().tbl_question_bank);
    await db.execute(CreateTables().tbl_content_access);
    await db.execute(CreateTables().tbl_student);
    await db.execute(CreateTables().tbl_student_session);
  }

  Future<void> initializeDatabase() async {
    await database;
  }

  Future<void> createDatabaseIfNotExists() async {
    Database db = await database;
  }
}
