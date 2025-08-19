import 'package:event_management/services/auth_service.dart';
import 'package:event_management/services/event_service.dart';
import 'package:event_management/services/profile_service.dart';
import 'package:event_management/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthService());
  Get.put(EventService());
  Get.put(ProfileService());
  Get.put(StorageService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Event Management',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF667eea),
      //     brightness: Brightness.dark,
      //   ),
      //   useMaterial3: true,
      // ),
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}
