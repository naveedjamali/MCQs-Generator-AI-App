import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';
import 'package:mcqs_generator_ai_app/widgets/homepage.dart';
import 'package:window_manager/window_manager.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows) {
      await windowManager.ensureInitialized();
      WindowManager.instance.setMinimumSize(const Size(1200, 800));
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.put(AppController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MCQs Generator App | Govt. Boys Degree College Nawabshah',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Homepage(),
    );
  }
}
