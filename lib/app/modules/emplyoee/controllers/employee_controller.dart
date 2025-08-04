import 'dart:convert';

import 'package:admin/app/constants/api_urls.dart';
import 'package:admin/app/models/emplyoee/emplyoee_model.dart';
import 'package:admin/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmployeeController extends GetxController {
  final count = 0.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final RxInt page = 1.obs; // 改成從1開始
  final RxInt limit = 10.obs; // 增加每頁顯示數量
  final RxInt totalEmployees = 0.obs; // 總員工數
  final RxInt totalPages = 0.obs; // 總頁數
  RxList<EmployeeList> employeeList = <EmployeeList>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchEmployeeList(page.value, limit.value);
  }

  Future<bool> fetchEmployeeList(int page, int limit) async {
    debugPrint('取得員工列表');
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final authService = AuthService.instance;

      // 檢查 JWT token 是否存在
      if (authService.currentToken.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'JWT Token 不存在，請重新登入';
        isLoading.value = false;
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.currentToken}',
      };
      final body = {
        "uid": authService.currentUid,
        "page": page - 1, // 後端可能從0開始計算頁面
        "limit": limit,
      };
      final response = await http.post(
        Uri.parse(ApiUrls.getFullUrl(ApiUrls.getEmployeeListAPI)),
        headers: headers,
        body: jsonEncode(body),
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      // debugPrint('API Response: $decodedBody');

      if (response.statusCode == 200) {
        EmplyoeeModel emplyoeeData = emplyoeeModelFromJson(decodedBody);
        employeeList.value = emplyoeeData.employeeList;
        totalEmployees.value = emplyoeeData.employeeCount;
        // 計算總頁數
        final totalCount = emplyoeeData.employeeCount;
        final pageSize = 10; // 暫時用固定值
        totalPages.value =
            totalCount > 0 ? ((totalCount - 1) ~/ pageSize) + 1 : 1;
        debugPrint(
          '員工人數: ${emplyoeeData.employeeCount}, 總頁數: ${totalPages.value}',
        );
        isLoading.value = false;
        return true;
      } else {
        hasError.value = true;
        errorMessage.value = '載入員工資料失敗：HTTP ${response.statusCode}';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = '載入員工資料時發生錯誤：$e';
      isLoading.value = false;
      debugPrint('Error fetching employee list: $e');
      return false;
    }
  }

  // === 新增員工 ===
  Future<bool> addEmployee(
    String name,
    String email,
    String level,
    bool status,
    String employeeId,
  ) async {
    final authService = AuthService.instance;
    debugPrint('addEmployee: $name, $email, $level, $status, $employeeId');
    try {
      // 檢查 JWT token 是否存在
      if (authService.currentToken.isEmpty) {
        Get.snackbar(
          '錯誤',
          'JWT Token 不存在，請重新登入',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.currentToken}',
      };
      final body = {
        "uid": authService.currentUid,
        "name": name,
        "email": email,
        "level": level,
        "status": status,
        "employee_id": employeeId,
      };
      final response = await http.post(
        Uri.parse(ApiUrls.getFullUrl(ApiUrls.addEmployeeAPI)),
        headers: headers,
        body: jsonEncode(body),
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      debugPrint('API Response: $decodedBody');

      if (response.statusCode == 200) {
        String message = '新增員工成功';
        Get.snackbar(
          '成功',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        String message = '新增員工失敗';
        Get.snackbar(
          '失敗',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = '載入員工資料時發生錯誤：$e';
      debugPrint('Error fetching employee list: $e');
      return false;
    }
  }

  // === 編輯員工 ===
  Future<bool> editEmployee(
    String name,
    String email,
    String level,
    bool status,
    String employeeId,
  ) async {
    final authService = AuthService.instance;
    debugPrint('editEmployee: $name, $email, $level, $status, $employeeId');
    try {
      // 檢查 JWT token 是否存在
      if (authService.currentToken.isEmpty) {
        Get.snackbar(
          '錯誤',
          'JWT Token 不存在，請重新登入',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.currentToken}',
      };
      final body = {
        "uid": authService.currentUid,
        "name": name,
        "email": email,
        "level": level,
        "status": status,
        "employee_id": employeeId,
      };
      final response = await http.post(
        Uri.parse(ApiUrls.getFullUrl(ApiUrls.editEmployeeAPI)),
        headers: headers,
        body: jsonEncode(body),
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      debugPrint('API Response: $decodedBody');

      if (response.statusCode == 200) {
        String message = '編輯員工成功';
        Get.snackbar(
          '成功',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        String message = '編輯員工失敗';
        Get.snackbar(
          '失敗',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = '編輯員工資料時發生錯誤：$e';
      debugPrint('Error fetching employee list: $e');
      return false;
    }
  }

  // === 分頁導航方法 ===

  /// 上一頁
  void previousPage() {
    if (page.value > 1) {
      page.value--;
      fetchEmployeeList(page.value, limit.value);
    }
  }

  /// 下一頁
  void nextPage() {
    if (page.value < totalPages.value) {
      page.value++;
      fetchEmployeeList(page.value, limit.value);
    }
  }

  /// 跳到指定頁面
  void goToPage(int targetPage) {
    if (targetPage >= 1 &&
        targetPage <= totalPages.value &&
        targetPage != page.value) {
      page.value = targetPage;
      fetchEmployeeList(page.value, limit.value);
    }
  }

  /// 檢查是否有上一頁
  bool get hasPreviousPage => page.value > 1;

  /// 檢查是否有下一頁
  bool get hasNextPage => page.value < totalPages.value;

  /// 獲取分頁顯示範圍
  List<int> getPaginationRange() {
    if (totalPages.value <= 7) {
      return List.generate(totalPages.value, (index) => index + 1);
    }

    if (page.value <= 4) {
      return [1, 2, 3, 4, 5, -1, totalPages.value]; // -1 表示省略號
    }

    if (page.value >= totalPages.value - 3) {
      return [
        1,
        -1,
        totalPages.value - 4,
        totalPages.value - 3,
        totalPages.value - 2,
        totalPages.value - 1,
        totalPages.value,
      ];
    }

    return [
      1,
      -1,
      page.value - 1,
      page.value,
      page.value + 1,
      -1,
      totalPages.value,
    ];
  }
}
