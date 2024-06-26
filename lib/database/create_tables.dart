class CreateTables {
  // String android_metsdata = ('''CREATE TABLE android_metadata (locale TEXT)''');

  String tbl_assign_subject = ('''
    CREATE TABLE tbl_assign_subject (
      assign_subject_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_assign_subject_id INTEGER,
      parent_institute_id INTEGER NOT NULL,
      institute_id INTEGER,
      institute_subject_id INTEGER,
      user_type_id INTEGER,
      institute_user_id INTEGER,
      institute_course_id INTEGER
    )
  ''');

  String tbl_employee = ('''
    CREATE TABLE tbl_employee (
      institute_user_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_user_id INTEGER,
      parent_institute_id INTEGER,
      institute_id INTEGER,
      user_type_id INTEGER,
      user_name TEXT,
      user_email_id TEXT,
      user_password TEXT,
      user_mobile_no TEXT,
      user_gender TEXT,
      user_status TEXT
    )
  ''');

  String tbl_institute = ('''
    CREATE TABLE tbl_institute (
      institute_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_id INTEGER,
      parent_institute_id INTEGER,
      institute_name TEXT,
      institute_code TEXT,
      institute_address TEXT,
      institute_country TEXT,
      institute_state TEXT,
      district TEXT,
      institute_logo TEXT,
      status TEXT,
      license_start_date TEXT,
      license_end_date TEXT
    )
  ''');

  String tbl_institute_chapter = ('''
    CREATE TABLE tbl_institute_chapter (
      institute_chapter_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_chapter_id INTEGER,
      parent_institute_id INTEGER,
      institute_course_id INTEGER,
      institute_subject_id INTEGER,
      unit_name TEXT,
      chapter_name TEXT,
      chapter_description TEXT,
      priority TEXT,
      status TEXT,
      number_of_periods TEXT
    )
  ''');

  String tbl_institute_course = ('''
    CREATE TABLE tbl_institute_course (
      institute_course_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_course_id INTEGER,
      parent_institute_id INTEGER,
      institute_course_name TEXT,
      priority TEXT,
      course_status TEXT
    )
  ''');

  String tbl_institute_course_breakup = ('''
    CREATE TABLE tbl_institute_course_breakup (
      institute_course_breakup_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_course_breakup_id INTEGER,
      institute_id INTEGER,
      parent_institute_id INTEGER,
      institute_course_id INTEGER,
      institute_course_breakup_name TEXT,
      priority TEXT,
      course_break_status TEXT,
      primary_class_teacher_user_id INTEGER,
      secondary_class_teacher_user_id INTEGER
    )
  ''');

  String tbl_institute_course_breakup_session = ('''
    CREATE TABLE tbl_institute_course_breakup_session (
      institute_session_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_session_id INTEGER,
      parent_institute_id INTEGER,
      session_start_year TEXT,
      session_end_year TEXT,
      session_start_date TEXT,
      session_end_date TEXT,
      is_current_session TEXT
    )
  ''');

  String tbl_institute_course_relation = ('''
    CREATE TABLE tbl_institute_course_relation (
      institute_course_relation_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_course_relation_id INTEGER,
      parent_institute_id INTEGER,
      institute_id INTEGER,
      institute_course_id INTEGER
    )
  ''');

  String tbl_institute_subject = ('''
    CREATE TABLE tbl_institute_subject (
      institute_subject_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_subject_id INTEGER,
      parent_institute_id INTEGER,
      subject_name TEXT,
      subject_credit TEXT,
      subject_description TEXT,
      priority TEXT,
      subject_status TEXT
    )
  ''');

  String tbl_institute_subject_course_rel = ('''
    CREATE TABLE tbl_institute_subject_course_rel (
      institute_subject_course_rel_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_subject_course_rel_id INTEGER,
      parent_institute_id INTEGER,
      institute_subject_id INTEGER,
      institute_course_id INTEGER
    )
  ''');

  String tbl_institute_topic = ('''
    CREATE TABLE tbl_institute_topic (
      institute_topic_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_topic_id INTEGER,
      parent_institute_id INTEGER,
      institute_chapter_id INTEGER,
      institute_course_id INTEGER,
      topic_name TEXT,
      topic_description TEXT,
      priority TEXT,
      status TEXT,
      ext TEXT,
      last_class_topic_id INTEGER
    )
  ''');

  String tbl_institute_topic_data = ('''
    CREATE TABLE tbl_institute_topic_data (
      institute_topic_data_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_topic_data_id INTEGER,
      institute_id INTEGER,
      parent_institute_id INTEGER,
      institute_topic_id INTEGER,
      topic_data_kind TEXT,
      topic_data_type TEXT,
      topic_data_file_code_name TEXT,
      code TEXT,
      file_name_ext TEXT,
      html5_file_name TEXT,
      html5_file_name_app TEXT,
      reference_url TEXT,
      no_of_clicks INTEGER,
      priority TEXT,
      status TEXT,
      display_type TEXT,
      is_default TEXT,
      default_topic_date_id INTEGER,
      entry_by_institute_user_id INTEGER,
      added_type TEXT,
      content_level TEXT,
      content_tag TEXT,
      content_lang TEXT,
      is_verified TEXT,
      verified_by TEXT,
      is_local_content_available INTEGER DEFAULT (0),
      html5_download_url TEXT
    )
  ''');

  String tbl_institute_user_rel = ('''
    CREATE TABLE tbl_institute_user_rel (
      institute_user_rel_id INTEGER PRIMARY KEY NOT NULL UNIQUE,
      online_institute_user_rel_id INTEGER,
      parent_institute_id INTEGER,
      type TEXT,
      institute_id INTEGER,
      state_name TEXT,
      district_name TEXT,
      institute_user_id TEXT
    )
  ''');

  String tbl_la_hw_cn_assessment = ('''
    CREATE TABLE tbl_la_hw_cn_assessment (
      la_hw_cn_assessment_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_la_hw_cn_assessment_id INTEGER,
      parent_institute_id INTEGER,
      institute_id INTEGER,
      type TEXT,
      heading_name TEXT,
      content TEXT,
      file_ext TEXT,
      points TEXT,
      created_by_teacher_user_id INTEGER,
      created_date TEXT,
      submission_date TEXT
    )
  ''');

  String tbl_la_hw_cn_assessment_rel = ('''
    CREATE TABLE tbl_la_hw_cn_assessment_rel (
      la_hw_cn_assessment_rel_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_la_hw_cn_assessment_rel_id INTEGER,
      parent_institute_id INTEGER,
      institute_id INTEGER,
      la_hw_cn_assessment_id INTEGER,
      institute_course_id INTEGER,
      institute_course_breakup_id INTEGER,
      institute_subject_id INTEGER,
      institute_chapter_id INTEGER,
      entry_date TEXT,
      last_update_date TEXT
    )
  ''');

  String tbl_syllabus = ('''
    CREATE TABLE tbl_syllabus (
      syllabus_id INTEGER PRIMARY KEY,
      online_syllabus_id INTEGER,
      institute_course_id INTEGER NOT NULL,
      institute_subject_id INTEGER NOT NULL,
      start_year INTEGER,
      end_year INTEGER,
      exam_name VARCHAR(255),
      start_date DATE,
      end_date DATE,
      chapter_id INTEGER,
      periods INTEGER,
      topic_ids TEXT,
      created_by INTEGER,
      created_date DATETIME,
      updated_date DATETIME
    )
  ''');

  String tbl_user_type = ('''
    CREATE TABLE tbl_user_type (
      user_type_id INTEGER PRIMARY KEY NOT NULL UNIQUE,
      online_user_type_id INTEGER,
      user_type_name TEXT,
      parent_institute_id INTEGER,
      is_teaching TEXT,
      designation_for char (30)
    )
  ''');

//   String tbl_user_type = ('''
//  CREATE table `tbl_user_type` (
// 	`user_type_id` double ,
// 	`user_type_name` varchar (150),
// 	`parent_institute_id` double ,
// 	`is_teaching` char (36),
// 	`rank` double ,
// 	`is_ot_flag` char (9),
// 	`min_ot_timing` double ,
// 	`max_ot_timing` double ,
// 	`designation_for` char (30),
// 	`entry_date` timestamp ,
// 	`last_update_date` timestamp ,
// 	`old_erp_id` double
// );
//   ''');
}
