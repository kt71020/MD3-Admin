import '../constants/api_urls.dart';
import '../services/auth_service.dart';
import 'api_service.dart';

/// 應用案件服務
class AdmsService {
  static final AdmsService _instance = AdmsService._internal();
  factory AdmsService() => _instance;
  AdmsService._internal();

  static AdmsService get instance => _instance;

  final _apiService = ApiService.instance;

  /// 取得進件資料列表
  Future<ApiResult<Map<String, dynamic>>> getAdmsSummary() async {
    final authService = AuthService.instance;

    // 檢查是否有有效的認證token
    if (authService.currentToken.isEmpty) {
      return ApiResult.error('請重新登入系統');
    }
    // final requestBody = {};
    return await _apiService.post(ApiUrls.admsSummaryAPI);
  }
}
