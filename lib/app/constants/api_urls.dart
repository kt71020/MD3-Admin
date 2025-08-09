import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiUrls {
  // 環境配置
  static const _defaultUrls = {
    'production': 'http://192.168.0.80:5120',
    'androidDev': 'http://10.0.2.2:5120',
    'iosDev': 'http://localhost:5120',
    'web': 'http://dev.uirapuka.com:5120',
    'redis': 'https://producer.uirapuka.com',
  };

  /// 取得主要 API 基礎 URL
  static String get baseUrl {
    // 優先使用環境變數
    final envUrl = _getEnvValue('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Web 環境處理
    if (kIsWeb) {
      final proxyUrl = _getEnvValue('PROXY_URL');
      if (proxyUrl.isNotEmpty) {
        debugPrint('🔄 Using proxy: $proxyUrl');
        return proxyUrl;
      }
      debugPrint('🌐 Using direct backend connection');
      return _defaultUrls['web']!;
    }

    // 平台特定 URL
    return _getPlatformUrl();
  }

  /// 取得 Redis URL
  static String get redisUrl =>
      _getEnvValue('REDIS_URL', fallback: _defaultUrls['redis']!);

  /// 取得環境變數值
  static String _getEnvValue(String key, {String fallback = ''}) {
    if (!dotenv.isInitialized) return fallback;
    return dotenv.get(key, fallback: fallback);
  }

  /// 取得平台特定 URL
  static String _getPlatformUrl() {
    if (Platform.isAndroid && !kReleaseMode) {
      return _defaultUrls['androidDev']!;
    }
    if (Platform.isIOS && !kReleaseMode) {
      return _defaultUrls['iosDev']!;
    }
    return _defaultUrls['production']!;
  }

  // === API Endpoints ===

  // User 相關 endpoints
  static String get loginCheckAPI => _userEndpoints['loginCheck']!;
  static String get getEmployeeListAPI => _userEndpoints['employeeList']!;
  static String get addEmployeeAPI => _userEndpoints['addEmployee']!;
  static String get editEmployeeAPI => _userEndpoints['editEmployee']!;

  // Shop 相關 endpoints
  static String get uploadAddShopAPI => _shopEndpoints['uploadAddShop']!;

  // Application 相關 endpoints
  static String get getApplicationListAPI => _applicationEndpoints['getList']!;
  static String get isReviewedAPI => _applicationEndpoints['isReviewed']!;
  static String get updateApplicationAPI => _applicationEndpoints['update']!;
  static String get applicationRejectAPI => _applicationEndpoints['reject']!;
  static String get applicationApproveAPI => _applicationEndpoints['approve']!;
  static String get caseReviewFailedAPI =>
      _applicationEndpoints['caseReviewFailed']!;
  static String get applicationCaseCloseAPI =>
      _applicationEndpoints['caseClose']!;
  static String get applicationLogAPI =>
      _applicationEndpoints['applicationLog']!;
  static String get applicationCsvAPI =>
      _applicationEndpoints['applicationCsv']!;
  static String get applicationUpdateAPI =>
      _applicationEndpoints['applicationUpdate']!;
  // 私有 endpoints 定義
  static const _userEndpoints = {
    'loginCheck': '/api/v2/adm/user/login_check',
    'employeeList': '/api/v2/adm/user/get_employee_list',
    'addEmployee': '/api/v2/adm/user/add_employee',
    'editEmployee': '/api/v2/adm/user/edit_employee',
  };

  static const _shopEndpoints = {'uploadAddShop': '/api/v1/upload/add_shop'};

  static const _applicationEndpoints = {
    'getList': '/api/v2/adm/application/get_list',
    'isReviewed': '/api/v2/adm/application/is_reviewed',
    'update': '/api/v2/adm/application/update',
    'reject': '/api/v2/adm/application/reject',
    'approve': '/api/v2/adm/application/accept',
    'caseReviewFailed': '/api/v2/adm/application/case_review_failed',
    'caseClose': '/api/v2/adm/application/case_close',
    'applicationLog': '/api/v2/adm/application/get_application_log_list',
    'applicationCsv': '/api/v2/adm/application/get_csv_file',
    'applicationUpdate': '/api/v2/adm/application/update_application',
  };

  // === Helper Methods ===

  /// 建構完整 API URL
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  /// 建構完整 Redis URL
  static String buildRedisUrl(String endpoint) => '$redisUrl$endpoint';

  /// 快速取得完整 API URL (向後兼容)
  static String getFullUrl(String endpoint) => buildUrl(endpoint);

  /// 快速取得完整 Redis URL (向後兼容)
  static String getRedisUrl(String endpoint) => buildRedisUrl(endpoint);

  // === 向後兼容 ===
  @Deprecated('Use baseUrl instead')
  static String get apiUrl => baseUrl;
}
