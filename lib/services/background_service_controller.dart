import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:teaching_app/core/api_client/api_client.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/pages/dashboard_content/widgets/download_progress_dialog.dart';

class BackgroundServiceController {
  BackgroundServiceController._privateConstructor();

  static final BackgroundServiceController instance =
      BackgroundServiceController._privateConstructor();

  final Connectivity _connectivity = Connectivity();
  static int totalFilesTOBeDownload = 0;
  static ValueNotifier<int> filesDownloaded = ValueNotifier(0);
  Future<void> performBackgroundTask() async {
    try {
      final DatabaseController dbController = Get.put(DatabaseController());
      await dbController.initializeDatabase();
      // Get the download list
      final response = await dbController.getDownloadList();
      final List<Map<String, dynamic>> rows = [];
      rows.add(
          {"url": "http://dbhjjdbh//", "filename": "filename", "ext": "fg"});
      rows.addAll(response);
      totalFilesTOBeDownload = rows.length;
      if (GetPlatform.isWindows) {
        DownloadProgressDialog.show();
      }
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
      });
      final isInternetAvailable1 = await ApiClient().isInternetAvailable();
      if (!isInternetAvailable) {
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
    }
  }

  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  String getFileExtFromUrl(String url) {
    return url.split('/').last.split(".").last;
  }

  Future<void> downloadFile(String url, String fileName, String ext) async {
    log("Forground Service Download Url :- $url");
    final path = await getContentDirectoryPath();
    if (url.isNotEmpty) {
      try {
        final filePath = "$path/$fileName";
        await ApiClient().download(url, path: filePath,
            onReceiveProgress: (recieved, total) {
          if (recieved == total) {
            FileEncryptor().encryptFile(File(filePath), filePath);
          }
        });
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future<String> getContentDirectoryPath() async {
    final directory = GetPlatform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    return directory!.path;
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

  static Future<void> clearTemporaryDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.listSync().forEach((file) {
          file.deleteSync(recursive: true);
        });
      }
    } catch (e) {
      print("Error clearing temporary directory: $e");
    }
  }
}
