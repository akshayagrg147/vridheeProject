import 'package:teaching_app/core/helper/helper.dart';

class QuestionBank {
  final int onlineLmsQuesBankId;
  final int parentInstituteId;
  final int instituteId;
  final int instituteCourseId;
  final int instituteSubjectId;
  final int instituteChapterId;
  final int instituteTopicId;
  final String contentLang;
  final String isParent;
  final double lmsQuesBankParentId;
  final String questionText;
  final String? questionExt;
  final String lmsQuesBankTypeName;
  final String questionCategory;
  final String difficultyLevel;
  final int noOfOption;
  final String? option1;
  final String? option2;
  final String? option3;
  final String? option4;
  final String? option1ImgExt;
  final String? option2ImgExt;
  final String? option3ImgExt;
  final String? option4ImgExt;
  final String? explanation;
  final String? explanationExt;
  final String? explanationYoutubeUrl;
  final bool answer1IsCorrect;
  final bool answer2IsCorrect;
  final bool answer3IsCorrect;
  final bool answer4IsCorrect;
  final String? optionMatchingP;
  final String? optionMatchingQ;
  final String? optionMatchingR;
  final String? optionMatchingS;
  final String? optionMatchingT;
  final String? optionMatchingPImgExt;
  final String? optionMatchingQImgExt;
  final String? optionMatchingRImgExt;
  final String? optionMatchingSImgExt;
  final String? optionMatchingTImgExt;
  final String? answerOption1MatrixMatching;
  final String? answerOption2MatrixMatching;
  final String? answerOption3MatrixMatching;
  final String? answerOption4MatrixMatching;
  final String? answerIntAlphaFill;
  final String questionFor;
  final String displayType;
  final String? addedType;
  final double? createdByUserId;
  final String? questionDownPath;
  final String? option1DownPath;
  final String? option2DownPath;
  final String? option3DownPath;
  final String? option4DownPath;

  QuestionBank({
    required this.onlineLmsQuesBankId,
    required this.parentInstituteId,
    required this.instituteId,
    required this.instituteCourseId,
    required this.instituteSubjectId,
    required this.instituteChapterId,
    required this.instituteTopicId,
    required this.contentLang,
    required this.isParent,
    required this.lmsQuesBankParentId,
    required this.questionText,
    this.questionExt,
    required this.lmsQuesBankTypeName,
    required this.questionCategory,
    required this.difficultyLevel,
    required this.noOfOption,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.option1ImgExt,
    this.option2ImgExt,
    this.option3ImgExt,
    this.option4ImgExt,
    this.explanation,
    this.explanationExt,
    this.explanationYoutubeUrl,
    required this.answer1IsCorrect,
    required this.answer2IsCorrect,
    required this.answer3IsCorrect,
    required this.answer4IsCorrect,
    this.optionMatchingP,
    this.optionMatchingQ,
    this.optionMatchingR,
    this.optionMatchingS,
    this.optionMatchingT,
    this.optionMatchingPImgExt,
    this.optionMatchingQImgExt,
    this.optionMatchingRImgExt,
    this.optionMatchingSImgExt,
    this.optionMatchingTImgExt,
    this.answerOption1MatrixMatching,
    this.answerOption2MatrixMatching,
    this.answerOption3MatrixMatching,
    this.answerOption4MatrixMatching,
    this.answerIntAlphaFill,
    required this.questionFor,
    required this.displayType,
    this.addedType,
    this.createdByUserId,
    this.questionDownPath,
    this.option1DownPath,
    this.option2DownPath,
    this.option3DownPath,
    this.option4DownPath,
  });

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
      onlineLmsQuesBankId: json['online_lms_ques_bank_id'],
      parentInstituteId: json['parent_institute_id'],
      instituteId: json['institute_id'],
      instituteCourseId: json['institute_course_id'],
      instituteSubjectId: json['institute_subject_id'],
      instituteChapterId: json['institute_chapter_id'],
      instituteTopicId: json['institute_topic_id'],
      contentLang: json['content_lang'] ?? 'English',
      isParent: json['is_parent'] ?? 'Yes',
      lmsQuesBankParentId: json['lms_ques_bank_parent_id'],
      questionText: json['question_text'],
      questionExt: json['question_ext'],
      lmsQuesBankTypeName: json['lms_ques_bank_type_name'],
      questionCategory: json['question_category'] ?? 'Not Applicable',
      difficultyLevel: json['difficulty_level'],
      noOfOption: json['no_of_option'] ?? 0,
      option1: json['option_1'],
      option2: json['option_2'],
      option3: json['option_3'],
      option4: json['option_4'],
      option1ImgExt: json['option_1_img_ext'],
      option2ImgExt: json['option_2_img_ext'],
      option3ImgExt: json['option_3_img_ext'],
      option4ImgExt: json['option_4_img_ext'],
      explanation: json['explanation'],
      explanationExt: json['explanation_ext'],
      explanationYoutubeUrl: json['explanation_youtube_url'],
      answer1IsCorrect: json['answer_1_is_correct'] == 'Yes',
      answer2IsCorrect: json['answer_2_is_correct'] == 'Yes',
      answer3IsCorrect: json['answer_3_is_correct'] == 'Yes',
      answer4IsCorrect: json['answer_4_is_correct'] == 'Yes',
      optionMatchingP: json['option_matching_p'],
      optionMatchingQ: json['option_matching_q'],
      optionMatchingR: json['option_matching_r'],
      optionMatchingS: json['option_matching_s'],
      optionMatchingT: json['option_matching_t'],
      optionMatchingPImgExt: json['option_matching_p_img_ext'],
      optionMatchingQImgExt: json['option_matching_q_img_ext'],
      optionMatchingRImgExt: json['option_matching_r_img_ext'],
      optionMatchingSImgExt: json['option_matching_s_img_ext'],
      optionMatchingTImgExt: json['option_matching_t_img_ext'],
      answerOption1MatrixMatching: json['answer_option_1_matrix_matching'],
      answerOption2MatrixMatching: json['answer_option_2_matrix_matching'],
      answerOption3MatrixMatching: json['answer_option_3_matrix_matching'],
      answerOption4MatrixMatching: json['answer_option_4_matrix_matching'],
      answerIntAlphaFill: json['answer_int_alpha_fill'],
      questionFor: json['question_for'] ?? 'Practice Test',
      displayType: json['display_type'] ?? 'Private',
      addedType: json['added_type'] ?? 'Manual',
      createdByUserId: json['created_by_user_id'],
      questionDownPath: json['question_down_path'],
      option1DownPath: json['option_1_down_path'],
      option2DownPath: json['option_2_down_path'],
      option3DownPath: json['option_3_down_path'],
      option4DownPath: json['option_4_down_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'online_lms_ques_bank_id': onlineLmsQuesBankId,
      'parent_institute_id': parentInstituteId,
      'institute_id': instituteId,
      'institute_course_id': instituteCourseId,
      'institute_subject_id': instituteSubjectId,
      'institute_chapter_id': instituteChapterId,
      'institute_topic_id': instituteTopicId,
      'content_lang': contentLang,
      'is_parent': isParent,
      'lms_ques_bank_parent_id': lmsQuesBankParentId,
      'question_text': questionText,
      'question_ext': questionExt,
      'lms_ques_bank_type_name': lmsQuesBankTypeName,
      'question_category': questionCategory,
      'difficulty_level': difficultyLevel,
      'no_of_option': noOfOption,
      'option_1': option1,
      'option_2': option2,
      'option_3': option3,
      'option_4': option4,
      'option_1_img_ext': option1ImgExt,
      'option_2_img_ext': option2ImgExt,
      'option_3_img_ext': option3ImgExt,
      'option_4_img_ext': option4ImgExt,
      'explanation': explanation,
      'explanation_ext': explanationExt,
      'explanation_youtube_url': explanationYoutubeUrl,
      'answer_1_is_correct': answer1IsCorrect,
      'answer_2_is_correct': answer2IsCorrect,
      'answer_3_is_correct': answer3IsCorrect,
      'answer_4_is_correct': answer4IsCorrect,
      'option_matching_p': optionMatchingP,
      'option_matching_q': optionMatchingQ,
      'option_matching_r': optionMatchingR,
      'option_matching_s': optionMatchingS,
      'option_matching_t': optionMatchingT,
      'option_matching_p_img_ext': optionMatchingPImgExt,
      'option_matching_q_img_ext': optionMatchingQImgExt,
      'option_matching_r_img_ext': optionMatchingRImgExt,
      'option_matching_s_img_ext': optionMatchingSImgExt,
      'option_matching_t_img_ext': optionMatchingTImgExt,
      'answer_option_1_matrix_matching': answerOption1MatrixMatching,
      'answer_option_2_matrix_matching': answerOption2MatrixMatching,
      'answer_option_3_matrix_matching': answerOption3MatrixMatching,
      'answer_option_4_matrix_matching': answerOption4MatrixMatching,
      'answer_int_alpha_fill': answerIntAlphaFill,
      'question_for': questionFor,
      'display_type': displayType,
      'added_type': addedType,
      'created_by_user_id': createdByUserId,
      'question_down_path': questionDownPath,
      'option_1_down_path': option1DownPath,
      'option_2_down_path': option2DownPath,
      'option_3_down_path': option3DownPath,
      'option_4_down_path': option4DownPath,
    };
  }

  String getCorrectOptions() {
    List<String> correctIndex = [];
    if (answer1IsCorrect) {
      correctIndex.add(Helper.getOptionName(1));
    }
    if (answer2IsCorrect) {
      correctIndex.add(Helper.getOptionName(2));
    }
    if (answer3IsCorrect) {
      correctIndex.add(Helper.getOptionName(3));
    }
    if (answer4IsCorrect) {
      correctIndex.add(Helper.getOptionName(4));
    }
    return correctIndex.join(",\t");
  }

  List<int> getCorrectOptionIndices() {
    List<int> correctIndex = [];
    if (answer1IsCorrect) {
      correctIndex.add(1);
    }
    if (answer2IsCorrect) {
      correctIndex.add(2);
    }
    if (answer3IsCorrect) {
      correctIndex.add(3);
    }
    if (answer4IsCorrect) {
      correctIndex.add(4);
    }
    return correctIndex;
  }
}
