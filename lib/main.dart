import 'dart:async';
import 'package:admin/app/theme/app_text_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';

void main() async {
  // 確保在同一個 zone 中完成所有初始化
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize environment variables
      try {
        await dotenv.load(fileName: ".env");
        debugPrint('Environment variables loaded successfully');
      } catch (e) {
        debugPrint('Warning: Could not load .env file: $e');
        debugPrint('Using default configuration values');
      }

      // Initialize Firebase with platform-specific options
      if (kIsWeb) {
        // Web 配置 - 使用 index.html 中定義的配置
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDGECPQu5Z4xudlX7Gg1HNvobA3Xs0BXc8",
            authDomain: "must-dine-3.firebaseapp.com",
            projectId: "must-dine-3",
            storageBucket: "must-dine-3.firebasestorage.app",
            messagingSenderId: "55834580879",
            appId: "1:55834580879:web:ae05b720b04993b4681dfa",
            measurementId: "G-BF76WDFZZD",
          ),
        );
      } else {
        // 移動端 (Android/iOS) - 使用配置文件
        await Firebase.initializeApp();
      }

      // Initialize Auth Service 並等待初始化完成
      Get.put(AuthService());

      // 小延遲確保 AuthService 完全初始化
      await Future.delayed(const Duration(milliseconds: 100));

      runApp(const MyApp());
    },
    (error, stack) {
      debugPrint('Zone error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 ScreenUtilInit 進行響應式初始化
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // 設計稿尺寸（桌面版）
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MD3 Admin - 響應式管理系統',
          theme: ThemeData(
            useMaterial3: true, // 啟用 Material 3
            // fontFamily: 'NotoSansTC', // 預設字型
            textTheme: appTextTheme, // 使用自訂的 TextTheme
            // 全域背景：將整體背景、Scaffold 與 surface 統一為 grey 50
            scaffoldBackgroundColor: Colors.grey, // 先填入基色避免空值
            canvasColor: Colors.grey, // 先填入基色避免空值
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 10, 14, 84),
              brightness: Brightness.light,
            ).copyWith(
              surface: Colors.grey.shade50,
              background: Colors.grey.shade50,
            ),
          ).copyWith(
            // 明確指定實際色階（避免上一段臨時值造成誤會）
            scaffoldBackgroundColor: Colors.grey.shade50,
            canvasColor: Colors.grey.shade50,
          ),
          // 使用 ResponsiveFramework 包裝應用
          builder:
              (context, child) => ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                    start: 1921,
                    end: double.infinity,
                    name: '4K',
                  ),
                ],
              ),
          initialRoute: '/login', // 使用安全的默認路由，避免 zone 問題
          getPages: AppPages.routes,
        );
      },
    );
  }
}
