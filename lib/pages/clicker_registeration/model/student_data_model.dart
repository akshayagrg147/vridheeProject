class StudentDataModel {
  final num sessionId;
  final num onlineSessionId;
  final num instituteUserId;
  final num onlineInstituteUserId;
  final num instituteId;
  final num instituteCourseId;
  final String className;
  final String name;
  final String gender;
  final String email;
  final String mobile;
  final String? clickerDeviceID;
  final int rollNo;
  final int? resultId;
  num marksObtained;
  num totalDuration;

  StudentDataModel({
    required this.sessionId,
    required this.onlineSessionId,
    required this.instituteUserId,
    required this.onlineInstituteUserId,
    required this.instituteId,
    required this.instituteCourseId,
    required this.className,
    required this.name,
    required this.gender,
    required this.email,
    required this.mobile,
    required this.clickerDeviceID,
    this.resultId,
    required this.rollNo,
    this.marksObtained = 0,
    this.totalDuration = 0,
  });

  factory StudentDataModel.fromJSon(Map<String, dynamic> json) {
    return StudentDataModel(
        sessionId: json['sessionId'],
        onlineSessionId: json['onlineSessionId'],
        instituteUserId: json['instituteUserId'],
        onlineInstituteUserId: json['onlineInstituteUserId'],
        instituteId: json['instituteId'],
        instituteCourseId: json['instituteCourseId'],
        className: json['className'],
        name: json['name'],
        gender: json['gender'],
        email: json['email'],
        mobile: json['mobile'],
        rollNo: json['rollNo'],
        clickerDeviceID: json['clickerDeviceID']);
  }

  StudentDataModel copyWith(String clickerID) {
    return StudentDataModel(
        sessionId: sessionId,
        onlineSessionId: onlineSessionId,
        instituteUserId: instituteUserId,
        onlineInstituteUserId: onlineInstituteUserId,
        instituteId: instituteId,
        instituteCourseId: instituteCourseId,
        className: className,
        name: name,
        gender: gender,
        email: email,
        mobile: mobile,
        rollNo: rollNo,
        marksObtained: marksObtained,
        totalDuration: totalDuration,
        clickerDeviceID: clickerID);
  }

  StudentDataModel copyWithResultId(int resultId) {
    return StudentDataModel(
        sessionId: sessionId,
        onlineSessionId: onlineSessionId,
        instituteUserId: instituteUserId,
        onlineInstituteUserId: onlineInstituteUserId,
        instituteId: instituteId,
        instituteCourseId: instituteCourseId,
        className: className,
        name: name,
        gender: gender,
        email: email,
        mobile: mobile,
        rollNo: rollNo,
        clickerDeviceID: clickerDeviceID,
        marksObtained: marksObtained,
        totalDuration: totalDuration,
        resultId: resultId);
  }
}
