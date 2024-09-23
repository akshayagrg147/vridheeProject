class CreateTables {
  // String android_metsdata = ('''CREATE TABLE android_metadata (locale TEXT)''');

  String tbl_assign_subject = ('''
   CREATE TABLE IF NOT EXISTS tbl_assign_subject (
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
   CREATE TABLE IF NOT EXISTS tbl_employee (
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
   CREATE TABLE IF NOT EXISTS tbl_institute (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_chapter (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_course (
      institute_course_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_course_id INTEGER,
      parent_institute_id INTEGER,
      institute_course_name TEXT,
      priority TEXT,
      course_status TEXT
    )
  ''');

  String tbl_institute_course_breakup = ('''
   CREATE TABLE IF NOT EXISTS tbl_institute_course_breakup (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_course_breakup_session (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_course_relation (
      institute_course_relation_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_course_relation_id INTEGER,
      parent_institute_id INTEGER,
      institute_id INTEGER,
      institute_course_id INTEGER
    )
  ''');

  String tbl_institute_subject = ('''
   CREATE TABLE IF NOT EXISTS tbl_institute_subject (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_subject_course_rel (
      institute_subject_course_rel_id INTEGER PRIMARY KEY UNIQUE NOT NULL,
      online_institute_subject_course_rel_id INTEGER,
      parent_institute_id INTEGER,
      institute_subject_id INTEGER,
      institute_course_id INTEGER
    )
  ''');

  String tbl_institute_topic = ('''
   CREATE TABLE IF NOT EXISTS tbl_institute_topic (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_topic_data (
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
   CREATE TABLE IF NOT EXISTS tbl_institute_user_rel (
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
   CREATE TABLE IF NOT EXISTS tbl_la_hw_cn_assessment (
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
   CREATE TABLE IF NOT EXISTS tbl_la_hw_cn_assessment_rel (
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
   CREATE TABLE IF NOT EXISTS tbl_syllabus (
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
   CREATE TABLE IF NOT EXISTS tbl_user_type (
      user_type_id INTEGER PRIMARY KEY NOT NULL UNIQUE,
      online_user_type_id INTEGER,
      user_type_name TEXT,
      parent_institute_id INTEGER,
      is_teaching TEXT,
      designation_for char (30)
    )
  ''');

  String tbl_question_bank = '''
 CREATE TABLE IF NOT EXISTS `tbl_lms_ques_bank` (
'online_lms_ques_bank_id' INTEGER NOT NULL, 
`parent_institute_id` INTEGER NOT NULL,
`institute_id` INTEGER NOT NULL,
`institute_course_id` INTEGER NOT NULL,
`institute_subject_id` INTEGER NOT NULL,
`institute_chapter_id` INTEGER NOT NULL,
`institute_topic_id` INTEGER NOT NULL,
`content_lang` TEXT NOT NULL DEFAULT 'English',
`is_parent` TEXT  NOT NULL DEFAULT 'Yes',
`lms_ques_bank_parent_id` double NOT NULL ,
`question_text` text NOT NULL,
`question_ext` TEXT DEFAULT NULL,
`lms_ques_bank_type_name` TEXT  NOT NULL,
`question_category` TEXT  DEFAULT 'Not Applicable',
`difficulty_level` TEXT  NOT NULL,
`no_of_option` INTEGER DEFAULT 0,
`option_1` text DEFAULT NULL,
`option_2` text DEFAULT NULL,
`option_3` text DEFAULT NULL,
`option_4` text DEFAULT NULL,
`option_1_img_ext` TEXT DEFAULT NULL,
`option_2_img_ext` TEXT DEFAULT NULL,
`option_3_img_ext` TEXT DEFAULT NULL,
`option_4_img_ext` TEXT DEFAULT NULL,
`explanation` text DEFAULT NULL,
`explanation_ext` TEXT DEFAULT NULL,
`explanation_youtube_url` TEXT DEFAULT NULL,
`answer_1_is_correct` TEXT  DEFAULT 'NA',
`answer_2_is_correct` TEXT  DEFAULT 'NA',
`answer_3_is_correct` TEXT  DEFAULT 'NA',
`answer_4_is_correct` TEXT  DEFAULT 'NA',
`option_matching_p` text DEFAULT NULL,
`option_matching_q` text DEFAULT NULL,
`option_matching_r` text DEFAULT NULL,
`option_matching_s` text DEFAULT NULL,
`option_matching_t` text DEFAULT NULL,
`option_matching_p_img_ext` TEXT DEFAULT NULL,
`option_matching_q_img_ext` TEXT DEFAULT NULL,
`option_matching_r_img_ext` TEXT DEFAULT NULL,
`option_matching_s_img_ext` TEXT DEFAULT NULL,
`option_matching_t_img_ext` TEXT DEFAULT NULL,
`answer_option_1_matrix_matching` TEXT DEFAULT NULL,
`answer_option_2_matrix_matching` TEXT DEFAULT NULL,
`answer_option_3_matrix_matching` TEXT DEFAULT NULL,
`answer_option_4_matrix_matching` TEXT DEFAULT NULL,
`answer_int_alpha_fill` TEXT DEFAULT NULL,
`question_for` TEXT  NOT NULL DEFAULT 'Practice Test',
`display_type` TEXT  NOT NULL DEFAULT 'Private',
`added_type` TEXT  DEFAULT 'Manual',
`created_by_user_id` double DEFAULT NULL,
`question_down_path` TEXT DEFAULT NULL,
`option_1_down_path` TEXT DEFAULT NULL,
`option_2_down_path` TEXT DEFAULT NULL,
`option_3_down_path` TEXT DEFAULT NULL,
`option_4_down_path` TEXT DEFAULT NULL,
`is_local_available` INTEGER DEFAULT 0

)''';

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

  String tbl_content_access = '''
CREATE TABLE IF NOT EXISTS `tbl_content_access` (
 `online_institute_topic_data_id` INTEGER NOT NULL,
 `user_id` INTEGER NOT NULL,
 `institute_topic_id` INTEGER NOT NULL,
 `created_date` DATETIME,
      `updated_date` DATETIME,
      'is_question' INTEGER DEFAULT 0 ,
      UNIQUE(`online_institute_topic_data_id`, `user_id`, `is_question`) )
''';

  String tbl_student = '''
  CREATE TABLE IF NOT EXISTS tbl_student (
  institute_user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  online_institute_user_id INTEGER,
  parent_institute_id REAL NOT NULL,
  institute_id REAL DEFAULT NULL,
  user_name TEXT NOT NULL,
  user_email_id TEXT NOT NULL,
  user_mobile_no TEXT DEFAULT NULL,
  dob DATE DEFAULT '0000-00-00',
  user_gender TEXT DEFAULT NULL CHECK(user_gender IN ('Male', 'Female', 'Other')),
  registration_no TEXT DEFAULT NULL,
  admission_no TEXT DEFAULT NULL,
  father_name TEXT DEFAULT NULL,
  father_email_id TEXT DEFAULT NULL,
  father_mobile_no TEXT DEFAULT NULL,
  mother_name TEXT DEFAULT NULL,
  mother_email_id TEXT DEFAULT NULL,
  mother_mobile_no TEXT DEFAULT NULL,
  user_status TEXT DEFAULT 'Active' CHECK(user_status IN ('Active', 'In-Active')),
  student_status TEXT DEFAULT 'Confirm' CHECK(student_status IN ('Confirm', 'Dropout', 'Passout')),
  last_update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  entry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
  ''';

  String tbl_student_session = '''
  CREATE TABLE IF NOT EXISTS tbl_student_session (
  student_session_id INTEGER PRIMARY KEY AUTOINCREMENT,
  online_student_session_id INTEGER,
  parent_institute_id REAL NOT NULL,
  institute_id REAL NOT NULL,
  institute_user_id REAL NOT NULL,
  institute_course_id REAL NOT NULL,
  institute_course_breakup_id REAL DEFAULT NULL,
  roll_no INTEGER DEFAULT NULL,
  move_flag REAL NOT NULL DEFAULT 0,
  session_start_year REAL NOT NULL,
  session_end_year REAL NOT NULL,
  entry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
  ''';

  String tbl_clicker = '''
  CREATE TABLE IF NOT EXISTS tbl_clicker (
  roll_no INTEGER PRIMARY KEY AUTOINCREMENT,
  clicker_id TEXT DEFAULT NULL
)
  ''';

  String tbl_exam_online_paper_result = '''
  CREATE TABLE IF NOT EXISTS tbl_exam_online_paper_result (
  exam_paper_result_id INTEGER PRIMARY KEY AUTOINCREMENT,	
  exam_online_paper_result_id double NULL,
  parent_institute_id double NOT NULL,
  institute_id double NOT NULL,
  institute_course_id double NOT NULL,
  institute_course_breakup_id double DEFAULT NULL,
  institute_subject_id double NOT NULL,
  institute_topic_ids varchar(100) NOT NULL,
  paper_type text DEFAULT NULL,
  student_institute_user_id double NOT NULL,
  exam_start_date_time timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  exam_end_date_time timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  exam_total_duration double NOT NULL DEFAULT 0,
  exam_total_question double NOT NULL DEFAULT 0,
  exam_total_marks double DEFAULT 0,
  exam_total_student_duration double DEFAULT 0,
  exam_total_student_marks double DEFAULT 0
  )
  ''';

  String tbl_exam_online_paper_result_ques = '''
  CREATE TABLE IF NOT EXISTS tbl_exam_online_paper_result_ques (
  exam_paper_result_ques_id INTEGER PRIMARY KEY AUTOINCREMENT,	
  exam_online_paper_result_ques_id double DEFAULT NULL,
  parent_institute_id double NOT NULL,
  institute_id double NOT NULL,
  institute_course_id double NOT NULL,
  institute_course_breakup_id double DEFAULT NULL,
  institute_subject_id double NOT NULL,
  institute_chapter_id double NOT NULL,
  institute_topic_id double NOT NULL,
  exam_online_paper_result_id double NOT NULL,
  lms_ques_bank_id double NOT NULL,
  student_institute_user_id double NOT NULL,
  question_marks double NOT NULL,
  marks_obtained double NOT NULL DEFAULT 0,
  option_selected_by_user text DEFAULT NULL,
  correct_options varchar(100) NOT NULL,
  answer_status text DEFAULT 'Not Attempted',
  date_time_of_ans timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'
  )
  ''';
}
