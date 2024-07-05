import 'dart:io';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:video_player/video_player.dart';

class VideoPlayController extends GetxController {
  late VlcPlayerController? vlcPlayerController;

  // VlcPlayerController _videoPlayerController;

  @override
  void onInit() {
    super.onInit();
    initializePlayer();
  }

  @override
  void onClose() {
    vlcPlayerController?.dispose();
    super.onClose();
  }

  Future<String> getDecryptedFilePath(String filePath, String fileName) async {
    final decryptedBytes = await FileEncryptor().decryptFile(File(filePath));
    final tempPath = (await getTemporaryDirectory()).path + "/$fileName";
    await File(tempPath).writeAsBytes(decryptedBytes);
    return tempPath;
  }

  void initializePlayer() {
    vlcPlayerController = VlcPlayerController.network(
      'https://www.youtube.com/watch?v=xDxhr-zgAhE',
      // Replace with your video URL
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    )..initialize().then((_) {
        update(); // This calls GetX's update method to refresh the UI
      });
  }
}

// https://www.youtube.com/watch?v=xDxhr-zgAhE
