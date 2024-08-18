import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teaching_app/core/api_client/api_client.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/download_progress_dialog.dart';
 bool _isSyncingInProgress = false;



class BackgroundServiceController {
  BackgroundServiceController._privateConstructor();

  static final BackgroundServiceController instance =
      BackgroundServiceController._privateConstructor();

  final Connectivity _connectivity = Connectivity();
  static int totalFilesTOBeDownload = 0;
  static ValueNotifier<int> filesDownloaded = ValueNotifier(0);
  Future<void> performBackgroundTask() async {
    try {
      if (_isSyncingInProgress) {
        return;
      }
      _isSyncingInProgress = true;
      filesDownloaded.value=0;
      await SharedPrefHelper().initialize();
      final DatabaseController dbController = Platform.isAndroid? Get.put(DatabaseController()):Get.find<DatabaseController>();
      if(Platform.isAndroid){
        await dbController.initializeDatabase();

      }

      // Get the download list
      final response = await dbController.getDownloadList();
      final List<Map<String, dynamic>> rows = [];
      rows.add(
          {"url": "http://dbhjjdbh//", "filename": -1, "ext": "fg"});
      rows.addAll(response);
      rows.removeWhere((item)=> (item['url']??"").trim().isEmpty);
      totalFilesTOBeDownload = rows.length;
      if (GetPlatform.isWindows) {
        DownloadProgressDialog.show();
      }
      await Future.forEach(rows, (row) async {
        final url = row['url'];
        final ext =
            (row['ext'] ?? "").isNotEmpty ? row['ext'] : getFileExtFromUrl(url);
final id = row['filename'];
        final fileName = "${row['filename'] ?? ""}.$ext";
        final isInternetAvailable = await ApiClient().isInternetAvailable();
        if (!isInternetAvailable) {
          throw ApiClient().noInternet;
        }
        await downloadFile(url, fileName, ext,onlineTopicDataId: id);
        filesDownloaded.value += 1;
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
          totalFilesTOBeDownload += 1;
          await downloadFile(quesUrl, questionFileName, ext);
          filesDownloaded.value += 1;
        }

        final opt1url = element['opt_1_url'];
        if ((opt1url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt1url);
          final optionFileName = "${id}_option_1.${ext}";
          totalFilesTOBeDownload += 1;
          await downloadFile(opt1url, optionFileName, ext);
          filesDownloaded.value += 1;
        }

        final opt2url = element['opt_2_url'];
        if ((opt2url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt2url);
          final optionFileName = "${id}_option_2.${ext}";
          totalFilesTOBeDownload += 1;
          await downloadFile(opt2url, optionFileName, ext);
          filesDownloaded.value += 1;
        }

        final opt3url = element['opt_3_url'];
        if ((opt3url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt3url);
          final optionFileName = "${id}_option_3.${ext}";
          totalFilesTOBeDownload += 1;
          await downloadFile(opt3url, optionFileName, ext);
          filesDownloaded.value += 1;
        }

        final opt4url = element['opt_4_url'];
        if ((opt4url ?? "").isNotEmpty) {
          final ext = getFileExtFromUrl(opt4url);
          final optionFileName = "${id}_option_4.${ext}";
          totalFilesTOBeDownload += 1;
          await downloadFile(opt4url, optionFileName, ext);
          filesDownloaded.value += 1;
        }

     await   dbController.database?.execute('''UPDATE tbl_lms_ques_bank
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
      if (GetPlatform.isWindows) {
        Get.back();
      } else {
        FlutterForegroundTask.stopService();
      }
      _isSyncingInProgress = false;
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
           await _databaseController.database
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
      final directory = GetPlatform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
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
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      print("Error clearing temporary directory: $e");
    }
  }
}
