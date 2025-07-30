import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboard;

  static final routes = [
    // 儀表板路由 - 設為預設首頁
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // 原始 Home 路由保留
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // 其他模組路由可以在此添加
    // GetPage(
    //   name: _Paths.users,
    //   page: () => const UsersView(),
    //   binding: UsersBinding(),
    // ),
  ];
}
