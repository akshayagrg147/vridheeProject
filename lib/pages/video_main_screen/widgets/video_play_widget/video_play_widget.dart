import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:teaching_app/app_theme.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';
import 'package:teaching_app/services/background_service_controller.dart';
import 'package:video_player_win/video_player_win.dart';
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

  late dynamic controller;
  late YoutubePlayerController _controller;
  Uint8List? docData;
  bool isLoading = false;
  @override
  void initState() {
    if(GetPlatform.isAndroid){
      _controller = YoutubePlayerController();
    }
    loadVideoPlayer();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoPlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic?.code != widget.topic?.code) {
      loadVideoPlayer();
    } else if (oldWidget.topic?.instituteTopicDataId !=
        widget.topic?.instituteTopicDataId) {
      loadVideoPlayer();
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
  }

  void loadVideoPlayer() async {
    setState(() {
      isLoading = true;
    });

    if ((widget.topic?.fileNameExt == 'mp4' ||
            widget.topic?.fileNameExt == 'html5') &&
        widget.topic?.code != null) {
      print("in init : ${widget.topic!.code!}");
      if (widget.topic!.code!.contains("https://www.youtube.com")) {
        if(GetPlatform.isAndroid){
          String id = extractYouTubeVideoId(widget.topic!.code!);
          _controller.loadVideoById(videoId: id);
        }else{
          controller = WinVideoPlayerController.network(widget.topic!.code!,

             )
            ..initialize().then((value) => setState(() {
              controller.play();
            }));
        }
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

          if(GetPlatform.isAndroid){
           controller = VideoPlayerController.file(File(tempPath),
               //TODO :-  check andd option if needed
               videoPlayerOptions: VideoPlayerOptions())
             ..initialize().then((value) => setState(() {
               controller.play();
             }));
         }else{
           controller = WinVideoPlayerController.file(File(tempPath),
               )
             ..initialize().then((value) => setState(() {
               controller.play();
             }));
         }
        }
      } else {
        if(GetPlatform.isAndroid){
          controller = VideoPlayerController.networkUrl(Uri.parse(
              "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"))
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              setState(() {});
            });
        }else{
          controller = WinVideoPlayerController.network( "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
          )
            ..initialize().then((value) => setState(() {
              controller.play();
            }));
        }

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

  //
  @override
  void dispose() {
    print("in dispose 3");
    if ((widget.topic?.topicDataType == 'MP4' ||
            widget.topic?.topicDataType == 'HTML5') &&
        widget.topic?.code != null) {
      if (!widget.topic!.code!.contains("https://www.youtube.com")&&GetPlatform.isAndroid) {
        _controller.close();
        print("in dispose 1");
      }else{
        controller.dispose();
      }
      // _controller.dispose();
      print("in dispose 2");
    }
    BackgroundServiceController.clearTemporaryDirectory();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
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
            widget.topic?.fileNameExt == 'html5') &&
        widget.topic?.code != null) {
      if (widget.topic!.code!.contains("https://www.youtube.com")) {
        contentWidget = Center(
          // Youtube player as widget
          child: GetPlatform.isWindows?WinVideoPlayer(controller): YoutubePlayer(
            controller: _controller, // Controler that we created earlier
            aspectRatio: 16 / 9, // Aspect ratio you want to take in screen
          ),
        );
      } else {
        contentWidget = controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: GetPlatform.isAndroid? VideoPlayer(controller):WinVideoPlayer(controller),
              )
            : const Center(child: CircularProgressIndicator());
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
      contentWidget = controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            )
          : const Center(child: CircularProgressIndicator());
      // contentWidget = const Center(child: Text('Unsupported file type'));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ThemeColor.greyLight,
        ),
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.72,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                contentWidget,
              ],
            ),
          ),
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
