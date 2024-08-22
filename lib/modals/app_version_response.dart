class AppVersionResponse {
final bool success;
final String message;
final AppVersion? data;

AppVersionResponse({
  required this.success,
  required this.message,
   this.data,
});

factory AppVersionResponse.fromJson(Map<String, dynamic> json) => AppVersionResponse(
success: json["success"],
message: json["message"],
data:  (json["data"] as List?)?.isNotEmpty==true ? AppVersion.fromJson(json["data"].first):null
);


}

class AppVersion {
final String appVersion;
final String filepath;
final DateTime updatedDate;

AppVersion({
required this.appVersion,
required this.filepath,
required this.updatedDate,
});

factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
appVersion: json["APP_VERSION"],
filepath: json["FILEPATH"],
updatedDate: DateTime.parse(json["UPDATED_DATE"]),
);

}
