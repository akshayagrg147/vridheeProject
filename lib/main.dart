import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:teaching_app/core/remote_config/remote_config_service.dart';
import 'package:teaching_app/core/shared_preferences/shared_preferences.dart';
import 'package:teaching_app/database/datebase_controller.dart';
import 'package:teaching_app/pages/add_content_planning/content_planning_screen.dart';
import 'package:teaching_app/pages/clicker_registration/clicker_registration_screen.dart';
import 'package:teaching_app/pages/dashboard_content/dashboard_screen.dart';
import 'package:teaching_app/pages/login_screen/login_screen.dart';
import 'package:teaching_app/pages/quiz/quiz_screen.dart';
import 'package:teaching_app/pages/resgistration_screen/registration_or_splash_screen.dart';
import 'package:teaching_app/pages/video_main_screen/video_main_screen.dart';
import 'package:teaching_app/services/ForegroundTaskService.dart';
import 'package:teaching_app/services/background_service.dart';

// const platform = MethodChannel('com.example.foreground_service');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(GetPlatform.isAndroid){
    await FlutterDownloader.initialize(
        debug: true, // optional: set false to disable printing logs to console
        ignoreSsl: true);
  }
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAS-9eo7zrU6wByUHyH689k3hM4MPHrvCQ",
        authDomain: "vridhee-lms.firebaseapp.com",
        projectId: "vridhee-lms",
        storageBucket: "vridhee-lms.appspot.com",
        messagingSenderId: "445532701923",
        appId: "1:445532701923:web:38a9e040b7cf2f858071d6",
        measurementId: "G-CLJPMWFCQP"),
  );
  sqfliteFfiInit();
  // Set the database factory
  databaseFactory = databaseFactoryFfi;
  await SharedPrefHelper().initialize();
  await RemoteConfigService.initConfig();
  // FlutterDownloader.registerCallback(downloadCallback);
  await _requestPermissions();
  // await BackgroundService.instance.initializeService();
  final databaseController = Get.put(DatabaseController());
  await databaseController.initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Teaching App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<DatabaseController>(() => DatabaseController());
      }),
      initialRoute: '/registrationPage',
      getPages: [
        GetPage(name: '/', page: () => const DashboardScreen()),
        GetPage(
            name: '/registrationPage', page: () => const RegistrationScreen()),
        GetPage(name: '/loginPage', page: () => const LoginScreen()),
        GetPage(
            name: '/contentPlanning',
            page: () => const ContentPlanningScreen()),
        GetPage(name: "/clickerRegistration", page:()=>const ClickerRegistration()),
        GetPage(name: "/quiz", page:()=>const QuizScreen()),
        GetPage(name: '/videoScreen', page: () => const VideoMainScreen()),
      ],
    );
  }
}

Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.notification,
  ].request();

  statuses.forEach((permission, status) {
    if (status.isDenied) {
      // Get.back();
    }
  });
}

void downloadCallback(String id, int status, int progress) {
  // Handle download progress, completion, etc.
}

// void startForegroundService() async {
//   try {
//     String result = await platform.invokeMethod('startForegroundService');
//     print(result);
//   } on PlatformException catch (e) {
//     print("Error: ${e.message}");
//   }
// }
