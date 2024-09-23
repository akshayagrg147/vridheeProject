class Helper {
  static bool validateEmailFunction({required String email}) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@(('
            r'\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+'
            r'\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  static String formatMinutesSeconds(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    // Ensure both minutes and seconds are always displayed as two digits
    String formattedMinutes = minutes < 10 ? '0$minutes' : '$minutes';
    String formattedSeconds = seconds < 10 ? '0$seconds' : '$seconds';

    return '$formattedMinutes:$formattedSeconds';
  }

  static String getOptionName(int index) {
    switch (index) {
      case 1:
        return "A";
      case 2:
        return "B";
      case 3:
        return "C";
      case 4:
        return "D";
    }
    return "";
  }
}
