import 'dart:convert';

import 'package:admin/app/constants/api_urls.dart';
import 'package:admin/app/models/emplyoee/emplyoee_model.dart';
import 'package:admin/app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmployeeController extends GetxController {
  final count = 0.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  RxList<EmployeeList> employeeList = <EmployeeList>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchEmployeeList();
  }

  Future<bool> fetchEmployeeList() async {
    debugPrint('取得員工列表');
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final authService = AuthService.instance;
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': authService.currentToken,
      };
      final body = {"uid": authService.currentUid};
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
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': authService.currentToken,
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
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': authService.currentToken,
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
}
