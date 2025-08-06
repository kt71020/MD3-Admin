import '../constants/api_urls.dart';
import '../services/auth_service.dart';
import 'api_service.dart';

/// 應用案件服務
class ApplicationService {
  static final ApplicationService _instance = ApplicationService._internal();
  factory ApplicationService() => _instance;
  ApplicationService._internal();

  static ApplicationService get instance => _instance;

  final _apiService = ApiService.instance;

  /// 取得進件資料列表
  Future<ApiResult<Map<String, dynamic>>> getApplicationList() async {
    final authService = AuthService.instance;

    // 檢查是否有有效的認證token
    if (authService.currentToken.isEmpty) {
      return ApiResult.error('請重新登入系統');
    }

    return await _apiService.post(ApiUrls.getApplicationListAPI);
  }

  /// 審核案件：拒絕
  Future<ApiResult<bool>> applicationReject({
    required int applicationId,
    required String reviewNote,
  }) async {
    final authService = AuthService.instance;

    final requestBody = {
      "id": applicationId,
      "review_by": authService.currentUid,
      "review_by_name": authService.currentUserName,
      "status": ApiService.statusRejected,
      "review_status": ApiService.reviewStatusReject,
      "review_note": reviewNote,
    };

    final result = await _apiService.post(
      ApiUrls.applicationRejectAPI,
      data: requestBody,
    );

    if (result.isSuccess) {
      return ApiResult.success(true);
    } else {
      return ApiResult.error(result.error ?? '拒絕案件失敗');
    }
  }

  /// 審核案件：通過
  Future<ApiResult<bool>> applicationApprove({
    required int applicationId,
    required String reviewNote,
  }) async {
    final authService = AuthService.instance;

    final requestBody = {
      "id": applicationId,
      "review_by": authService.currentUid,
      "review_by_name": authService.currentUserName,
      "status": '2',
      "review_status": ApiService.reviewStatusApprove,
      "review_note": reviewNote,
    };

    final result = await _apiService.post(
      ApiUrls.applicationApproveAPI,
      data: requestBody,
    );

    if (result.isSuccess) {
      return ApiResult.success(true);
    } else {
      return ApiResult.error(result.error ?? '批准案件失敗');
    }
  }

  /// 檢查案件是否已審核
  Future<ApiResult<bool>> isApplicationReviewed(int applicationId) async {
    final result = await _apiService.post(
      ApiUrls.isReviewedAPI,
      data: {"id": applicationId},
    );

    if (result.isSuccess && result.data is Map<String, dynamic>) {
      final data = result.data as Map<String, dynamic>;
      final isReviewed = data['is_reviewed'] ?? false;
      return ApiResult.success(isReviewed);
    } else {
      return ApiResult.error(result.error ?? '檢查審核狀態失敗');
    }
  }

  /// 案件審核結果：拒絕
  Future<ApiResult<bool>> caseReviewFailed({
    required int applicationId,
    required String reviewNote,
  }) async {
    final result = await _apiService.post(
      ApiUrls.caseReviewFailedAPI,
      data: {"id": applicationId, "review_note": reviewNote},
    );

    if (result.isSuccess && result.data is Map<String, dynamic>) {
      final data = result.data as Map<String, dynamic>;
      final isReviewed = data['is_reviewed'] ?? false;
      return ApiResult.success(isReviewed);
    } else {
      return ApiResult.error(result.error ?? '檢查審核狀態失敗');
    }
  }

  /// 案件審核結果：結案
  Future<ApiResult<bool>> applicationCaseClose({
    required int applicationId,
  }) async {
    final authService = AuthService.instance;

    final result = await _apiService.post(
      ApiUrls.applicationCaseCloseAPI,
      data: {
        "id": applicationId,
        "close_by": authService.currentUid,
        "close_by_name": authService.currentUserName,
      },
    );

    if (result.isSuccess && result.data is Map<String, dynamic>) {
      final data = result.data as Map<String, dynamic>;
      final isReviewed = data['is_reviewed'] ?? false;
      return ApiResult.success(isReviewed);
    } else {
      return ApiResult.error(result.error ?? '檢查審核狀態失敗');
    }
  }
}
