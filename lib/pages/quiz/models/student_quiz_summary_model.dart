class StudentExamResult {
  final int rollNo;
  final String name;
  final String email;
  final String mobile;
  final Map<int, int> studentResponse;
  final int correctAnswerCount;
  final int wrongAnswerCount;
  final int naAnswerCount;

  StudentExamResult({
    required this.rollNo,
    required this.name,
    required this.email,
    required this.mobile,
    required this.studentResponse,
    required this.wrongAnswerCount,
    required this.naAnswerCount,
    required this.correctAnswerCount,
  });

  Map<String, int> getScoreData() {
    final total = correctAnswerCount + wrongAnswerCount + naAnswerCount;
    return {
      "Correct": (correctAnswerCount / total * 100).round(),
      "Wrong": (wrongAnswerCount / total * 100).round(),
      "NA": (naAnswerCount / total * 100).round()
    };
  }
}
