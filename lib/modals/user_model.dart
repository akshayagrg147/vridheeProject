class UserDataModel {
  final int instituteUserId;
  final int onlineInstituteUserId;
  final int parentInstituteId;
  final int instituteId;
  final int userTypeId;
  final String userName;
  final String userEmailId;

  UserDataModel({
    required this.instituteUserId,
    required this.onlineInstituteUserId,
    required this.parentInstituteId,
    required this.instituteId,
    required this.userTypeId,
    required this.userName,
    required this.userEmailId,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      instituteUserId: json['institute_user_id'],
      onlineInstituteUserId: json['online_institute_user_id'],
      parentInstituteId: json['parent_institute_id'],
      instituteId: json['institute_id'],
      userTypeId: json['user_type_id'],
      userName: json['user_name'],
      userEmailId: json['user_email_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institute_user_id': instituteUserId,
      'online_institute_user_id': onlineInstituteUserId,
      'parent_institute_id': parentInstituteId,
      'institute_id': instituteId,
      'user_type_id': userTypeId,
      'user_name': userName,
      'user_email_id': userEmailId,
    };
  }
}
