import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiUrls {
  // 透過 --dart-define 注入的變數（Web/Release 推薦使用）
  static const String _apiUrlDefine = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );
  static const String _proxyUrlDefine = String.fromEnvironment(
    'PROXY_URL',
    defaultValue: '',
  );
  static const String _redisUrlDefine = String.fromEnvironment(
    'REDIS_URL',
    defaultValue: '',
  );

  // 預設 URL（最後保底）
  static const _defaultUrls = {
    // 正式預設網址（避免 Web 未帶參數時意外打到 dev）
    'production': 'https://producer.uirapuka.com',
    // 開發裝置預設
    'androidDev': 'http://10.0.2.2:5120',
    'iosDev': 'http://localhost:5120',
    // Web 未設定時改為走正式，不再預設 dev
    'webDefault': 'https://producer.uirapuka.com',
    'redis': 'https://producer.uirapuka.com',
    'proxy': 'http://dev.uirapuka.com:5120',
  };

  /// 取得主要 API 基礎 URL
  static String get baseUrl {
    // 1) 優先使用 --dart-define（適用 Web 與任意平台 Release）
    if (_apiUrlDefine.isNotEmpty) {
      if (!kReleaseMode) {
        debugPrint('🔄 Using --dart-define API_URL: $_apiUrlDefine');
      }
      return _apiUrlDefine;
    }

    // 2) 其次使用 .env（僅行動/桌面；Web 預設不載入）
    final envUrl = _getEnvValue('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Web 環境處理
    if (kIsWeb) {
      // 3) Web 若有 --dart-define/ENV 的 PROXY_URL 亦可覆蓋
      final proxyFromDefine = _proxyUrlDefine;
      if (proxyFromDefine.isNotEmpty) {
        if (!kReleaseMode) {
          debugPrint('🔄 Using --dart-define PROXY_URL: $proxyFromDefine');
        }
        return proxyFromDefine;
      }
      final proxyFromEnv = _getEnvValue('PROXY_URL');
      if (proxyFromEnv.isNotEmpty) {
        if (!kReleaseMode) {
          debugPrint('🔄 Using PROXY_URL from .env: $proxyFromEnv');
        }
        return proxyFromEnv;
      }
      if (!kReleaseMode) {
        debugPrint('🌐 Using Web default (production) backend connection');
      }
      return _defaultUrls['webDefault']!;
    }

    // 平台特定 URL
    return _getPlatformUrl();
  }

  /// 取得 Redis URL
  static String get redisUrl {
    if (_redisUrlDefine.isNotEmpty) return _redisUrlDefine;
    return _getEnvValue('REDIS_URL', fallback: _defaultUrls['redis']!);
  }

  /// 取得 Proxy URL
  static String get proxyUrl {
    if (_proxyUrlDefine.isNotEmpty) return _proxyUrlDefine;
    return _getEnvValue('PROXY_URL', fallback: _defaultUrls['proxy']!);
  }

  /// 取得環境變數值
  static String _getEnvValue(String key, {String fallback = ''}) {
    if (!dotenv.isInitialized) return fallback;
    final value = dotenv.get(key, fallback: fallback);
    if (!kReleaseMode) {
      debugPrint('🔄 取得環境變數：$key -> ${value.isNotEmpty ? '[set]' : '[empty]'}');
    }
    return value;
  }

  /// 取得平台特定 URL
  static String _getPlatformUrl() {
    // 在 Web 不會走到這裡（上方已經先行判斷 kIsWeb）
    // 避免在 Web 匯入 dart:io，改用 defaultTargetPlatform 判斷
    if (!kReleaseMode) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return _defaultUrls['androidDev']!;
        case TargetPlatform.iOS:
          return _defaultUrls['iosDev']!;
        default:
          // 其他桌面平台開發預設也走本機
          return _defaultUrls['iosDev']!;
      }
    }
    // Release 一律走正式
    return _defaultUrls['production']!;
  }

  // === API Endpoints ===

  // Adms 相關 endpoints
  static String get admsSummaryAPI => _admsEndpoints['admsSummary']!;

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
  static String get applicationSummaryAPI =>
      _applicationEndpoints['applicationSummary']!;
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
    'applicationSummary': '/api/v2/adm/application/fetch_summary',
  };

  // Adms 相關 endpoints
  static const _admsEndpoints = {
    'admsSummary': '/api/v2/adm/adms/fetch_summary',
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
