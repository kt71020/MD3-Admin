import 'package:get/get.dart';

class DashboardController extends GetxController {
  // 統計數據
  final RxInt totalUsers = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt activeProducts = 0.obs;

  // 加載狀態
  final RxBool isLoading = false.obs;

  // 圖表數據
  final RxList<Map<String, dynamic>> chartData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// 載入儀表板數據
  Future<void> loadDashboardData() async {
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
}
