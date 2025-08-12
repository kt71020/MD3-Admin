import 'package:admin/app/models/adms/adms_summary_model.dart';
import 'package:admin/app/services/adms_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class DashboardController extends GetxController {
  // 服務實例
  final _admsService = AdmsService.instance;
  // 統計數據
  final RxInt totalUsers = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt activeProducts = 0.obs;

  /// 統計數據
  final Rx<AdmsSummaryModel> admsSummary =
      AdmsSummaryModel(groupCount: 0, userCount: 0, shopCount: 0).obs;

  // 加載狀態
  final RxBool isLoading = false.obs;

  // 圖表數據
  final RxList<Map<String, dynamic>> chartData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// ==========================================
  /// 取得統計資料
  /// ==========================================
  Future<void> getAdmsSummary() async {
    final result = await _admsService.getAdmsSummary();
    if (result.isSuccess) {
      admsSummary.value = AdmsSummaryModel.fromJson(result.data!);
      debugPrint('admsSummary: ${admsSummary.value.toJson()}');
    } else {
      Get.snackbar('錯誤', '載入數據失敗: ${result.error}');
    }
  }

  /// 載入儀表板數據
  Future<void> loadDashboardData() async {
    await getAdmsSummary();
    try {
      isLoading.value = true;

      // 模擬 API 調用
      await Future.delayed(const Duration(seconds: 2));

      // 更新統計數據
      totalUsers.value = 1234;
      totalOrders.value = 567;
      totalRevenue.value = 89012.34;
      activeProducts.value = 89;

      // 更新圖表數據
      chartData.value = [
        {'month': '一月', 'value': 1200},
        {'month': '二月', 'value': 1800},
        {'month': '三月', 'value': 1500},
        {'month': '四月', 'value': 2200},
        {'month': '五月', 'value': 1900},
        {'month': '六月', 'value': 2500},
      ];
    } catch (e) {
      Get.snackbar('錯誤', '載入數據失敗: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新數據
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// 登出功能
  Future<void> logout() async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      Get.snackbar('錯誤', '登出失敗: $e');
    }
  }
}
