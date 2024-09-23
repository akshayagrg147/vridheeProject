enum AnswerStatus {
  correct('Correct'),
  wrong('Wrong'),
  notAttempted('Not Attempted'),
  marksByTeacher('MarksByTeacher');

  final String label;

  const AnswerStatus(this.label);
}

enum PaperType {
  mockTest('Mock Test'),
  instituteTest('Institute Test'),
  classRoomTest('Class Room Test'),
  challenge('Challenge');

  final String label;

  const PaperType(this.label);
}
