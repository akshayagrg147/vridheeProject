import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:teaching_app/database/datebase_controller.dart';

class BackgroundServiceController {
  BackgroundServiceController._privateConstructor();

  static final BackgroundServiceController instance =
  BackgroundServiceController._privateConstructor();

  final Connectivity _connectivity = Connectivity();

  Future<void> performBackgroundTask() async {
    final DatabaseController dbController = Get.put(DatabaseController());
    await dbController.initializeDatabase();
    // Get the download list
    final rows = await dbController.getDownloadList();
    for (var row in rows) {
      final url = row['html5_download_url'];
      final fileName = getFileNameFromUrl(url);
      await downloadFile(url, fileName);
    }
  }

  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  Future<void> downloadFile(String url, String fileName) async {
    final directory = await getExternalStorageDirectory();
    final path = directory?.path;

    if (path != null) {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    }
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
