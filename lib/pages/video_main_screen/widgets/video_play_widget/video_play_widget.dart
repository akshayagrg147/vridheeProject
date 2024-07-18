import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:teaching_app/app_theme.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/pages/video_main_screen/widgets/video_play_widget/custom_video_player.dart';
import 'package:teaching_app/pages/video_main_screen/widgets/web_view/html_viewer.dart';
import 'package:teaching_app/services/background_service_controller.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../modals/tbl_institute_topic_data.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayWidget extends StatefulWidget {
  final InstituteTopicData? topic;

  const VideoPlayWidget({super.key, required this.topic});

  @override
  State<VideoPlayWidget> createState() => _VideoPlayWidgetState();
}

class _VideoPlayWidgetState extends State<VideoPlayWidget> {
  // late VideoPlayerController _videoController;

  // var controller = WebViewController()
  // ..setJavaScriptMode(JavaScriptMode.unrestricted)
  // ..setBackgroundColor(const Color(0x00000000))
  // ..setNavigationDelegate(
  // NavigationDelegate(
  // onProgress: (int progress) {
  // // Update loading bar.
  // },
  // onPageStarted: (String url) {},
  // onPageFinished: (String url) {},
  // onWebResourceError: (WebResourceError error) {},
  // onNavigationRequest: (NavigationRequest request) {
  // if (request.url.startsWith('https://www.youtube.com/')) {
  // return NavigationDecision.prevent;
  // }
  // return NavigationDecision.navigate;
  // },
  // ),
  // )
  // ..loadRequest(Uri.parse('https://www.youtube.com/watch?v=xXyfon-SOR8'));

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.topic?.fileNameExt == 'mp4' && widget.topic?.code != null) {
  //     _videoController = VideoPlayerController.network(widget.topic!.code!)
  //       ..initialize().then((_) {
  //         setState(() {});  // Ensure the first frame is shown
  //       });
  //   }
  // }

  VideoPlayerController? controller;
  final _controller = YoutubePlayerController();
  Uint8List? docData;
  String? html5FilePath;
  bool isLoading = false;
  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoPlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic?.instituteTopicDataId !=
        widget.topic?.instituteTopicDataId) {
      if (controller?.value.isInitialized == true) {
        controller?.pause();
      }

      controller = null;
      docData = null;
      html5FilePath = null;
      loadVideoPlayer();
    }
  }

  showLoader() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void loadVideoPlayer() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showLoader();
    });

    isLoading = true;

    if ((widget.topic?.fileNameExt == 'mp4' ||
            widget.topic?.fileNameExt == 'html5' ||
            widget.topic?.topicDataType == 'HTML5') &&
        widget.topic?.code != null) {
      print("in init : ${widget.topic!.code!}");
      if (widget.topic!.code!.contains("https://www.youtube.com")) {
        String id = extractYouTubeVideoId(widget.topic!.code!);
        _controller.loadVideoById(videoId: id);
      } else if (widget.topic?.topicDataType == 'HTML5') {
        final filename = "${widget.topic?.onlineInstituteTopicDataId}.zip";
        String filePath = await BackgroundServiceController.instance
            .getContentDirectoryPath();
        filePath += "/$filename";
        if (await File(filePath).exists()) {
          initializeZipFile(filePath,
              dirName: "${widget.topic?.onlineInstituteTopicDataId}");
        } else {
          hideLoadingdialog();
        }
        return;
      } else if (widget.topic?.fileNameExt == 'mp4' &&
          widget.topic?.onlineInstituteTopicDataId != null) {
        final filename =
            "${widget.topic?.onlineInstituteTopicDataId}.${widget.topic?.fileNameExt}";
        String filePath = await BackgroundServiceController.instance
            .getContentDirectoryPath();
        filePath += "/$filename";
        if (await File(filePath).exists()) {
          final decryptedBytes =
              await FileEncryptor().decryptFile(File(filePath));
          final tempPath = (await getTemporaryDirectory()).path + "/$filename";
          await File(tempPath).writeAsBytes(decryptedBytes);

          controller = VideoPlayerController.file(File(tempPath),
              //TODO :-  check andd option if needed
              videoPlayerOptions: VideoPlayerOptions())
            ..initialize().then((value) => setState(() {
                  controller?.play();
                }));
        }
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(
            "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
      }
    } else if ((widget.topic?.fileNameExt == 'pdf' ||
            widget.topic?.fileNameExt == 'doc') &&
        (widget.topic?.code ?? "").isEmpty) {
      final filename =
          "${widget.topic?.onlineInstituteTopicDataId}.${widget.topic?.fileNameExt}";
      String filePath =
          await BackgroundServiceController.instance.getContentDirectoryPath();
      filePath += "/$filename";
      final isFileExists = await File(filePath).exists();
      if (isFileExists) {
        docData = await FileEncryptor().decryptFile(File(filePath));
      }
    }
    hideLoadingdialog();
  }

  void hideLoadingdialog() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.pop(context);
    });

    setState(() {
      isLoading = false;
    });
  }

  String extractYouTubeVideoId(String url) {
    final RegExp regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final Match? match = regExp.firstMatch(url);
    return match?.group(7) ?? '';
  }

  initializeZipFile(String filePath, {required String dirName}) async {
    // final zipPath =
    // "/storage/emulated/0/Android/data/com.vridhee.offlinelms/files/477.zip";
    final outputPath = (await getTemporaryDirectory()).path;
    final decryptedBytes = await FileEncryptor().decryptFile(File(filePath));
// Decode the zip from the InputFileStream. The archive will have the contents of the
// zip, without having stored the data in memory.
    final archive = ZipDecoder().decodeBytes(decryptedBytes);

    extractArchiveToDisk(archive, "$outputPath/$dirName").then((value) {
      html5FilePath = "$outputPath/$dirName/story_html5.html";
      hideLoadingdialog();
    });
  }

  @override
  void dispose() {
    print("in dispose 3");
    if ((widget.topic?.topicDataType == 'MP4' ||
            widget.topic?.topicDataType == 'HTML5') &&
        widget.topic?.code != null) {
      if (!widget.topic!.code!.contains("https://www.youtube.com")) {
        controller?.dispose();
        print("in dispose 1");
      }
      // _controller.dispose();
      print("in dispose 2");
    }

    BackgroundServiceController.instance.clearTemporaryDirectory();
    // _controller.dispose();
    super.dispose();
  }

  Widget noFileFound() {
    return const Center(
      child: Text(
        "File Not Found",
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (widget.topic == null) {
      return Center(
        child: Icon(Icons.error_outline),
      );
    }
    print("topic data in : ${widget.topic?.instituteTopicDataId}");
    print(": ${widget.topic?.toJson()}");

    Widget contentWidget;

    // if (widget.topic?.fileNameExt == 'html5' && widget.topic?.code != null) {
    //   contentWidget = WebViewWidget(controller: controller);
    //   //     WebView(
    //   //   initialUrl: widget.topic!.code,
    //   //   javascriptMode: JavascriptMode.unrestricted,
    //   // );
    // } else

    if ((widget.topic?.fileNameExt == 'mp4' ||
            widget.topic?.fileNameExt == 'html5' ||
            widget.topic?.topicDataType == 'HTML5') &&
        widget.topic?.code != null) {
      if (widget.topic!.code!.contains("https://www.youtube.com")) {
        contentWidget = Center(
          // Youtube player as widget
          child: YoutubePlayer(
            controller: _controller, // Controler that we created earlier
            aspectRatio: 16 / 9, // Aspect ratio you want to take in screen
          ),
        );
      } else if (widget.topic?.topicDataType == 'HTML5') {
        if (html5FilePath != null) {
          contentWidget = HtmlViewer(
            htmlFilePath: html5FilePath!,
          );
        } else {
          contentWidget = noFileFound();
        }
      } else {
        contentWidget = controller?.value.isInitialized == true
            ? CustomVideoPlayer(controller: controller!)
            : noFileFound();
      }
    } else if ((widget.topic?.fileNameExt == 'pdf' ||
            widget.topic?.fileNameExt == 'doc') &&
        (widget.topic?.code ?? "").isNotEmpty) {
      contentWidget = SfPdfViewer.network(widget.topic!.code!);
    } else if ((widget.topic?.fileNameExt == 'pdf' ||
            widget.topic?.fileNameExt == 'doc') &&
        docData != null) {
      contentWidget = SfPdfViewer.memory(docData!);
    } else {
      contentWidget = controller?.value.isInitialized == true
          ? CustomVideoPlayer(controller: controller!)
          // AspectRatio(
          //         aspectRatio: controller!.value.aspectRatio,
          //         child: VideoPlayer(controller!),
          //       )
          : noFileFound();
      // contentWidget = const Center(child: Text('Unsupported file type'));
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border.all(
          color: ThemeColor.greyLight,
        ),
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.72,
      child: Stack(
        children: [
          contentWidget,
        ],
      ),
    );
  }
}

// else
//   VlcPlayer(
//     controller: videoPlayerController,
//     aspectRatio: 16 / 9,
//     placeholder:
//         const Center(child: CircularProgressIndicator()),
//   ),

// Positioned.fill(
//   child: Signature(
//     color: Colors.black, // Color of the drawing
//     strokeWidth: 2.0, // Thickness of the drawing lines
//   ),
// ),

// late VlcPlayerController videoPlayerController;
// final pdfController = PdfController(
//   document: PdfDocument.openAsset(
//       'assets/testflutter pub run pdfx:install_web.pdf'),
// );

// File? _pdfFile;
// final String path = "C:\\Users\\Saurabh\\Documents\\11.pdf";

// @override
// void initState() {
//   super.initState();
//   _loadPdfFile();
// }
//
// Future<void> _loadPdfFile() async {
//   final filePath = 'D:\\11.pdf';
//   _pdfFile = File(filePath);
//   setState(() {});
//   print("in hh ${filePath}");
// }

// Future<void> _loadPdfFile() async {
//   final pdfBytes = await readPdfFile();
//   setState(() {
//     _pdfFile = pdfBytes;
//   });
// }

// Future<List<int>> readPdfFile() async {
//   final filePath = 'C:\\Users\\Saurabh\\Documents\\11.pdf';
//   final file = File(filePath);
//   return await file.readAsBytes();
// }
