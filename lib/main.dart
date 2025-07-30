import 'package:admin/app/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(const MyApp());
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
            colorSchemeSeed: Colors.green, // 可選，提供種子色
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
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
