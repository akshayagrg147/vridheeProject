import 'package:dio/dio.dart';
import 'package:teaching_app/core/api_client/api_client.dart';
import 'package:teaching_app/core/route/api_route.dart';
import 'package:teaching_app/modals/app_version_response.dart';

class DashboardRepo{
  static final _apiClient = ApiClient();

  static Future<AppVersion> getAppVersion()async{
    FormData? formData = FormData.fromMap({
      "app_for": "Exe",
    });
    final response = await _apiClient.post(
      ApiRoute.getAppVersion,
      body: formData,
    );
      return AppVersionResponse.fromJson(response).data!;
  }
}