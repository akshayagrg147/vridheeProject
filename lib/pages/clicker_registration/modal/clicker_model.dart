class ClickerModel{
  final int rollNo;
  final String? deviceId;

  ClickerModel({required this.rollNo, required this.deviceId});

  factory ClickerModel.fromJson(Map<String,dynamic> json){
    return ClickerModel(rollNo: json['roll_no'], deviceId: json['clicker_id']);
  }

  ClickerModel copyWith(String clickerId){
    return ClickerModel(rollNo: rollNo, deviceId: clickerId);
  }

}