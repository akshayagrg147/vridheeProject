import 'dart:io';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/pages/resgistration_screen/registration_repository.dart';

import '../../modals/register_device/register_device_response.dart';

class RegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController trackingIdController = TextEditingController();
  final TextEditingController serialNoController = TextEditingController();
  Rx<RegisterDeviceResponse> registerDeviceResponse =
      RegisterDeviceResponse().obs;
  RxBool isLoading = false.obs;
  Rxn<String> downloadFolderLocation = Rxn<String>(null);
  void registerDevice() async {
    //Initial loading start
    if (downloadFolderLocation.value == null) {
      Get.showSnackbar(const GetSnackBar(
        message: "Please select a folder for downloading data",
        duration: Duration(seconds: 2),
      ));
      return;
    }

    isLoading.value = true;
    try {
      final response = await RegistrationRepository.registerDevice(
        trackingId: trackingIdController.text,
        /* 'OCA-Dem-Pan--47820'*/
        serialNumber: serialNoController.text,
        /*'478268375682424'*/
        projectId: '16',
      );
      if (response != null && response.success == true) {
        print("RegisterDevice :- $response");
        registerDeviceResponse.value = response;
        //Now sync the data
        if (response.data != null && response.data! > 0) {
          //Save Data in shared Preference and marked as registered
          await SharedPrefHelper()
              .setDownLoadFolderLocation(downloadFolderLocation.value!);
          await SharedPrefHelper().setDeviceId(response.data.toString());
          await SharedPrefHelper().setIsRegistrationCompleted(true);
          Get.offAllNamed("/loginPage");
        } else {
          Get.snackbar("RegisterDeviceError", "Device ID is zero");
        }
      } else {
        Get.snackbar(
            "RegisterDeviceError", " Device registration ${response?.msg}");
      }
      print("RegisterDevice :- $response");
    } catch (e) {
      print("RegisterDeviceError :- $e");
      Get.snackbar("RegisterDeviceError", "$e");
    } finally {
      //Stop the loading or loader
      isLoading.value = false;
    }
  }

  void chooseDownloadFolderLocation() async {
    try {
      final isStoragePermissionGranted = await requestStoragePermission();
      // if (isStoragePermissionGranted == false) {
      //   openAppSettings();
      //   return;
      // }
      final isManageStoragePermissionGranted =
          await requestManageStoragepermission();
      if (!isManageStoragePermissionGranted) {
        return;
      }
      final path = await chooseFolder();
      if (path == null) {
        return;
      }
      downloadFolderLocation.value = path;
    } catch (e) {}
  }

  Future<String?> chooseFolder() async {
    Directory? directory = Directory(FolderPicker.rootPath);

    Directory? newDirectory = await FolderPicker.pick(
        allowFolderCreation: true,
        context: Get.context!,
        rootDirectory: directory,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));

    print(newDirectory?.path ?? "--no file Chosen");
    return newDirectory?.path;
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  static Future<bool> requestManageStoragepermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isRestricted || status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }
}
