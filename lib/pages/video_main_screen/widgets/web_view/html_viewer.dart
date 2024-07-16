import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HtmlViewer extends StatelessWidget {
  final String htmlFilePath;
  const HtmlViewer({super.key, required this.htmlFilePath});

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.file(htmlFilePath, windows: false)),
    );
  }
}
