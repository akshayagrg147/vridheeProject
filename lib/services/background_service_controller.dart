import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:teaching_app/core/api_client/api_client.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/database/datebase_controller.dart';

class BackgroundServiceController {
  BackgroundServiceController._privateConstructor();

  static final BackgroundServiceController instance =
      BackgroundServiceController._privateConstructor();

  final Connectivity _connectivity = Connectivity();

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

      await Future.forEach(rows, (row) async {
        final url = row['url'];
        final ext =
            (row['ext'] ?? "").isNotEmpty ? row['ext'] : getFileExtFromUrl(url);
        if (ext == "zip") {
          return;
        }
        final fileName = "${row['filename'] ?? ""}.$ext";
        await downloadFile(url, fileName);
      });

      final questionImagesData =
          await dbController.getDownloadQuestionImageList();

      await Future.forEach(questionImagesData, (element) async {
        final id = element['id'];
        final quesUrl = element['ques_url'];
        if ((quesUrl ?? "").isNotEmpty) {
          final questionFileName = "ques_$id.${getFileExtFromUrl(quesUrl)}";
          await downloadFile(quesUrl, questionFileName);
        }

        final opt1url = element['opt_1_url'];
        if ((opt1url ?? "").isNotEmpty) {
          final optionFileName = "${id}_option_1.${getFileExtFromUrl(opt1url)}";
          await downloadFile(opt1url, optionFileName);
        }

        final opt2url = element['opt_2_url'];
        if ((opt2url ?? "").isNotEmpty) {
          final optionFileName = "${id}_option_2.${getFileExtFromUrl(opt2url)}";
          await downloadFile(opt2url, optionFileName);
        }

        final opt3url = element['opt_3_url'];
        if ((opt3url ?? "").isNotEmpty) {
          final optionFileName = "${id}_option_3.${getFileExtFromUrl(opt3url)}";
          await downloadFile(opt3url, optionFileName);
        }

        final opt4url = element['opt_4_url'];
        if ((opt4url ?? "").isNotEmpty) {
          final optionFileName = "${id}_option_4.${getFileExtFromUrl(opt4url)}";
          await downloadFile(opt4url, optionFileName);
        }
      });
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

  Future<void> downloadFile(String url, String fileName) async {
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

        // await FlutterDownloader.enqueue(
        //   url: url,
        //   savedDir: path,
        //   fileName: fileName,
        //   showNotification: true,
        //   openFileFromNotification: true,
        // );
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future<String> getContentDirectoryPath() async {
    final directory = await getExternalStorageDirectory();

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
}
