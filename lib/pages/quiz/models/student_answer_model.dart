class StudentAnswerModel {
  final int optionSelected;
  final DateTime answeredTime;
  final String deviceId;
  final int duration;

  StudentAnswerModel(
      {required this.optionSelected,
      required this.answeredTime,
      required this.deviceId,
      required this.duration});
}
