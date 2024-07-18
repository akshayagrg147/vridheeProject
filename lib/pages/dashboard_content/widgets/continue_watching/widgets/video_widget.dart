import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/app_theme.dart';
import 'package:teaching_app/modals/tbl_institute_topic_data.dart';
import 'package:teaching_app/widgets/app_rich_text.dart';

import '../../open_subject_menu_widget/modal/open_subject_model.dart';

class VideoDashboardThumbnailWidget extends StatelessWidget {
  final Map<String, dynamic> video;

  // final Map<int,Map<String, List<LocalChapter>>> chapterData;

  const VideoDashboardThumbnailWidget({super.key, required this.video
      // ,required this.chapterData
      });

  @override
  Widget build(BuildContext context) {
    // print("in thumbnail ${chapterData[34]?["inProgress"]?[0].chapter.chapterName}");
    return SizedBox(
      width: 280, // adjust width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Get.toNamed('/videoScreen', arguments: [true, video]);
              },
              child: Card(
                elevation: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(assetPath(
                          (video['topicData'] as InstituteTopicData?)
                                  ?.fileNameExt ??
                              "")),
                      // Replace with your selected image URL
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white, // White circle background
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow,
                            color: Colors.transparent),
                        // Transparent triangle icon
                        onPressed: () {
                          Get.toNamed('/videoScreen', arguments: [true, video]);
                        },
                        color: Colors.white,
                        iconSize: 50,
                        splashColor: Colors.white.withOpacity(
                            0.5), // Optional: Adds a splash effect on press
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: ThemeColor.white,
              ),
              child: Column(
                children: [
                  RowAppRichText(
                    title: "Class",
                    content: video['class'],
                    titleColor: ThemeColor.black,
                    contentColor: ThemeColor.darkBlue4392,
                  ),
                  RowAppRichText(
                    title: "Subject",
                    content: video['subject'],
                    titleColor: ThemeColor.black,
                    contentColor: ThemeColor.darkBlue4392,
                  ),
                  RowAppRichText(
                    title: "Chapter",
                    content: video['chapter'],
                    titleColor: ThemeColor.black,
                    contentColor: ThemeColor.darkBlue4392,
                  ),
                  RowAppRichText(
                    title: "Topic",
                    content: video['topic'],
                    titleColor: ThemeColor.black,
                    contentColor: ThemeColor.darkBlue4392,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String assetPath(String ext) {
    switch (ext) {
      case "mp4":
        return "assets/icons/video.jpeg";
      case "mp3":
        return "assets/icons/mp3.jpeg";
      default:
        return "assets/icons/other.jpeg";
    }
  }
}
