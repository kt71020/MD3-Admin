import 'package:admin/app/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MD3 Admin',
      theme: ThemeData(
        useMaterial3: true, // 啟用 Material 3
        // fontFamily: 'NotoSansTC', // 預設字型
        textTheme: appTextTheme, // 使用自訂的 TextTheme
        colorSchemeSeed: Colors.green, // 可選，提供種子色
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
