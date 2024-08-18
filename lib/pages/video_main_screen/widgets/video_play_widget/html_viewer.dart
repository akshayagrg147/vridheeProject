import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class HtmlViewer extends StatelessWidget {
  final String htmlFilePath;
  const HtmlViewer({super.key, required this.htmlFilePath});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();
    controller.loadFile(htmlFilePath);

    return WebViewWidget(controller: controller);


  }
}