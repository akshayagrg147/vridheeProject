import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teaching_app/services/background_service_controller.dart';

class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({super.key});
static void show(){
  Get.dialog(
      const DownloadProgressDialog(),
      barrierDismissible: false,

    );
}
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: AlertDialog(
        title: Text("Please Wait Resource Downloading is in Progress",),
        content: ValueListenableBuilder<int>(
          valueListenable: BackgroundServiceController.filesDownloaded,
          builder: (context,value,_) {
            if(value == BackgroundServiceController.totalFilesTOBeDownload){
              Future.delayed(const Duration(seconds: 1),(){
                Navigator.pop(context);
              });
            }
            return Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: value/BackgroundServiceController.totalFilesTOBeDownload,
                    minHeight: 20,
                    backgroundColor: Colors.grey,
                  
                    semanticsLabel: "Resource Downloaded",
                    semanticsValue: "${value} / ${BackgroundServiceController.totalFilesTOBeDownload}",
                  ),
                ),
                SizedBox(width: 10,),
                Text("${value} / ${BackgroundServiceController.totalFilesTOBeDownload}",style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600
                ),)
              ],
            );
          }
        ),
      ),
    );
  }
}
