abstract class ApiRoute {
  //PROD URL = 'https://mafatlaleducation.com'
  //DEV URL = 'https://mafatlaleducation.com'
  static const baseURL = 'https://lms.vridhee.com';
  static const mainURL = '$baseURL/WebServicesNative/public/api';
  static const getDeviceDetail = '$mainURL/GetDeviceDetails';
  static const getSyncData = '$mainURL/GetLMSCompleteData';
  static const getAppVersion = '$mainURL/GetLMSAppVersion';
  static const updateSyncData = '$mainURL/UpdateSyncData';
  static const loginUser = '$mainURL/loginUser';
}