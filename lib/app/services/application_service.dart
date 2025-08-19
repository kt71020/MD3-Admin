import 'package:admin/app/models/application/application_model.dart';
import 'package:flutter/foundation.dart';

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
  Future<ApiResult<Map<String, dynamic>>> getApplicationList(
    String channel,
  ) async {
    final authService = AuthService.instance;

    // 檢查是否有有效的認證token
    if (authService.currentToken.isEmpty) {
      return ApiResult.error('請重新登入系統');
    }
    final requestBody = {"channel": channel};
    return await _apiService.post(
      ApiUrls.getApplicationListAPI,
      data: requestBody,
    );
  }

  /// 取得案件歷程紀錄
  Future<ApiResult<Map<String, dynamic>>> getApplicationLogList(
    int id,
    String type,
  ) async {
    final requestBody = {"id": id, "type": type};

    final result = await _apiService.post(
      ApiUrls.applicationLogAPI,
      data: requestBody,
    );

    if (result.isSuccess) {
      return ApiResult.success(result.data);
    } else {
      return ApiResult.error(result.error ?? '取得案件歷程紀錄失敗');
    }
  }

  /// 審核案件：拒絕
  Future<ApiResult<bool>> applicationReject({
    required int applicationId,
    required String reviewNote,
  }) async {
    final authService = AuthService.instance;
    debugPrint('🔄 案件審核人：${authService.currentUserName}');
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
    required Application application,
  }) async {
    final authService = AuthService.instance;

    final result = await _apiService.post(
      ApiUrls.applicationCaseCloseAPI,
      data: {
        "id": application.id,
        "status": application.status,
        "shop_name": application.shopName,
        "request_uid": application.uid,
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

  /// 取得進件資料列表 CSV
  Future<ApiResult<Map<String, dynamic>>> getApplicationCsvList(
    int id,
    String type,
  ) async {
    final requestBody = {"id": id, "type": type};

    final result = await _apiService.post(
      ApiUrls.applicationCsvAPI,
      data: requestBody,
    );

    if (result.isSuccess) {
      return ApiResult.success(result.data);
    } else {
      return ApiResult.error(result.error ?? '取得進件資料列表 CSV 失敗');
    }
  }

  /// 更新進件資料列
  Future<ApiResult<Map<String, dynamic>>> updateApplication(
    int id,
    String shopName,
    String shopTaxId,
    String shopPhone,
    String shopContactName,
    String shopMobile,
    String shopWebsite,
    String shopEmail,
    String shopCity,
    String shopRegion,
    String shopAddress,
    String shopDescription,
    String shopNote,
  ) async {
    final requestBody = {
      "id": id,
      "shop_name": shopName,
      "shop_tax_id": shopTaxId,
      "shop_phone": shopPhone,
      "shop_contact_name": shopContactName,
      "shop_mobile": shopMobile,
      "shop_website": shopWebsite,
      "shop_email": shopEmail,
      "shop_city": shopCity,
      "shop_region": shopRegion,
      "shop_address": shopAddress,
      "shop_description": shopDescription,
      "shop_note": shopNote,
    };

    final result = await _apiService.post(
      ApiUrls.applicationUpdateAPI,
      data: requestBody,
    );
    debugPrint('🔄 Service 更新進件資料列：$result');

    if (result.isSuccess) {
      return ApiResult.success(result.data);
    } else {
      return ApiResult.error(result.error ?? '取得進件資料列表 CSV 失敗');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getApplicationSummary() async {
    final authService = AuthService.instance;

    if (authService.currentToken.isEmpty) {
      return ApiResult.error('請重新登入系統');
    }

    final result = await _apiService.post(
      ApiUrls.applicationSummaryAPI,
      data: {},
    );

    if (result.isSuccess) {
      return ApiResult.success(result.data);
    } else {
      return ApiResult.error(result.error ?? '取得統計資料失敗');
    }
  }
}
