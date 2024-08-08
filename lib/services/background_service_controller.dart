import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teaching_app/core/api_client/api_client.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';

class BackgroundServiceController {
  BackgroundServiceController._privateConstructor();

  static final BackgroundServiceController instance =
      BackgroundServiceController._privateConstructor();

  final Connectivity _connectivity = Connectivity();

  Future<void> performBackgroundTask() async {
    try {
      await SharedPrefHelper().initialize();
      final DatabaseController dbController = Get.put(DatabaseController());
      await dbController.initializeDatabase();
      // Get the download list
      final response = await dbController.getDownloadList();
      final List<Map<String, dynamic>> rows = [];
      rows.add(
          {"url": "http://dbhjjdbh//", "filename": "filename", "ext": "fg"});
      rows.addAll(response);

      await Future.forEach(rows, (row) async {
        final url = row['url'];
        final ext =
            (row['ext'] ?? "").isNotEmpty ? row['ext'] : getFileExtFromUrl(url);

        final fileName = "${row['filename'] ?? ""}.$ext";
        final isInternetAvailable = await ApiClient().isInternetAvailable();
        if (!isInternetAvailable) {
          throw ApiClient().noInternet;
        }

        await downloadFile(url, fileName, ext);
      });
      final isInternetAvailable = await ApiClient().isInternetAvailable();
      if (!isInternetAvailable) {
        throw ApiClient().noInternet;
      }
      final questionImagesData =
          await dbController.getDownloadQuestionImageList();

      await Future.forEach(questionImagesData, (element) async {
        final id = element['id'];
        final quesUrl = element['ques_url'];
        final isInternetAvailable = await ApiClient().isInternetAvailable();
        if (!isInternetAvailable) {
          throw ApiClient().noInternet;
        }
        if ((quesUrl ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(quesUrl);
          final questionFileName = "ques_$id.${ext}";
          await downloadFile(quesUrl, questionFileName, ext);
        }

        final opt1url = element['opt_1_url'];
        if ((opt1url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt1url);
          final optionFileName = "${id}_option_1.${ext}";
          await downloadFile(opt1url, optionFileName, ext);
        }

        final opt2url = element['opt_2_url'];
        if ((opt2url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt2url);
          final optionFileName = "${id}_option_2.${ext}";
          await downloadFile(opt2url, optionFileName, ext);
        }

        final opt3url = element['opt_3_url'];
        if ((opt3url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt3url);
          final optionFileName = "${id}_option_3.${ext}";
          await downloadFile(opt3url, optionFileName, ext);
        }

        final opt4url = element['opt_4_url'];
        if ((opt4url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt4url);
          final optionFileName = "${id}_option_4.${ext}";
          await downloadFile(opt4url, optionFileName, ext);
        }

        dbController.database?.execute('''UPDATE tbl_lms_ques_bank
SET is_local_available = 1
WHERE online_lms_ques_bank_id = $id''');
      });
      final isInternetAvailable2 = await ApiClient().isInternetAvailable();
      if (!isInternetAvailable2) {
        throw ApiClient().noInternet;
      }
      await SharedPrefHelper().setIsSynced(true);
    } catch (e) {
      print("$e");
    } finally {
      FlutterForegroundTask.stopService();
    }
  }

  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  String getFileExtFromUrl(String url) {
    return url.split('/').last.split(".").last;
  }

  Future<void> downloadFile(String url, String fileName, String ext,
      {int? onlineTopicDataId}) async {
    try {
      log("Forground Service Download Url :- $url");
      final path = await getContentDirectoryPath();
      if (url.isNotEmpty) {
        final filePath = "$path/$fileName";
        final isFileAlreadyExists = await File(filePath).exists();
        if (isFileAlreadyExists) {
          if (onlineTopicDataId != null) {
            final DatabaseController _databaseController =
                Get.find<DatabaseController>();
            _databaseController.database
                ?.execute('''UPDATE tbl_institute_topic_data
SET is_local_content_available = 1
WHERE online_institute_topic_data_id = $onlineTopicDataId''');
          }
          return;
        }
        await ApiClient().download(url, path: filePath,
            onReceiveProgress: (recieved, total) async {
          if (recieved == total) {
            await FileEncryptor().encryptFile(File(filePath), filePath);
            if (onlineTopicDataId != null) {
              final DatabaseController _databaseController =
                  Get.find<DatabaseController>();
              _databaseController.database
                  ?.execute('''UPDATE tbl_institute_topic_data
SET is_local_content_available = 1
WHERE online_institute_topic_data_id = $onlineTopicDataId''');
            }
          }
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> getContentDirectoryPath() async {
    String choosenLocationPath = SharedPrefHelper().getDownLoadFolderLocation();
    if (choosenLocationPath.isEmpty) {
      final directory = await getExternalStorageDirectory();
      choosenLocationPath = directory!.path;
    }

    return choosenLocationPath;
  }

  Future<void> checkPermissions() async {
    if (await Permission.storage.request().isGranted &&
        (await Permission.manageExternalStorage.request().isGranted ||
            await Permission.accessMediaLocation.request().isGranted)) {
      // Permission is granted, proceed with the background task
      await performBackgroundTask();
    } else {
      // Handle the case where permission is not granted
      bool isOpened = await openAppSettings();
      if (!isOpened) {
        // Inform the user about the importance of granting permissions
        // Use a method to show a dialog or a snackbar
        Get.snackbar("Grant Permission", "Allow permission to download file");
      }
    }
  }

  Future<void> clearTemporaryDirectory() async {
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }
}
