import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_universal/webview_universal.dart';
// import 'package:win32/win32.dart';
// import 'package:ffi/ffi.dart';
// import 'dart:ffi';


class HtmlViewer extends StatefulWidget {
  final String htmlFilePath;

  const HtmlViewer({super.key, required this.htmlFilePath});

  @override
  State<HtmlViewer> createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  WebViewController webViewController = WebViewController();
String? htmlFilePath;
  @override
  void initState() {
    super.initState();
    htmlFilePath=widget.htmlFilePath;
    loadWebView();
  }

  @override
  void dispose(){
    webViewController.webview_desktop_controller.close();
    super.dispose();
  }




    Future<void> loadWebView() async {
    await webViewController.init(context: context, setState: setState, uri: Uri.file(widget.htmlFilePath,windows: true));

  }
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Html5 Data is playing",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 16),));



  }
}



// class HtmlViewer extends StatelessWidget {
//   final String htmlFilePath;
//   const HtmlViewer({super.key, required this.htmlFilePath});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = WebViewController();
//     controller.loadFile(htmlFilePath);
//
//     return WebViewWidget(controller: controller);
//
//
//   }
// }