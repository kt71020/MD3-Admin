import 'package:admin/app/modules/emplyoee/bindings/employee_binding.dart';
import 'package:admin/app/modules/emplyoee/views/employee_view.dart';
import 'package:admin/app/modules/emplyoee/views/employee_edit.dart';
import 'package:get/get.dart';

import '../middlewares/auth_middleware.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    // 儀表板路由 - 需要認證
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // 原始 Home 路由保留 - 需要認證
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // 其他模組路由可以在此添加
    // GetPage(
    //   name: _Paths.users,
    //   page: () => const UsersView(),
    //   binding: UsersBinding(),
    // ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.emplyoee,
      page: () => const EmployeeView(),
      binding: EmployeeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.emplyoeeEdit,
      page: () => const EmployeeEditView(),
      binding: EmployeeBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
