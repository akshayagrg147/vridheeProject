class ClickerData {
  final String deviceId;
  final int btnPressed;
  final String batterylevel;

  ClickerData(
      {required this.deviceId,
      required this.btnPressed,
      required this.batterylevel});

  factory ClickerData.fromJson(Map<String, dynamic> json) {
    return ClickerData(
      deviceId: json['deviceId'],
      btnPressed: json['buttonPressed'],
      batterylevel: json['batteryLevel'],
    );
  }
}
