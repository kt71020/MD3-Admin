import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiUrls {
  // 根據不同環境返回適合的 API URL
  static String get apiUrl {
    try {
      // 檢查 dotenv 是否已初始化
      if (dotenv.isInitialized) {
        // 從環境變數中獲取
        String configuredUrl = dotenv.get('API_URL', fallback: '');

        if (configuredUrl.isNotEmpty) {
          return configuredUrl;
        }
      }

      // Web 環境的特殊處理 - 測試直接後端 CORS
      if (kIsWeb) {
        // 檢查是否有環境變數指定代理服務器
        if (dotenv.isInitialized) {
          String proxyUrl = dotenv.get('PROXY_URL', fallback: '');
          if (proxyUrl.isNotEmpty) {
            debugPrint('🔄 Using proxy server: $proxyUrl');
            return proxyUrl;
          }
        }

        // 直接連接後端 - CORS 已配置 ✅
        debugPrint('🌐 Web environment - using direct backend connection');
        return 'http://dev.uirapuka.com:5120'; // 直接連接後端
      }

      // 如果環境變數為空或 dotenv 未初始化，則使用預設值
      // 對於 Android 模擬器，使用 10.0.2.2 代替 localhost
      if (Platform.isAndroid && !kReleaseMode) {
        return 'http://10.0.2.2:5120'; // Android 模擬器連接主機的特殊 IP
      }
      // 對於 iOS 模擬器，使用 localhost
      else if (Platform.isIOS && !kReleaseMode) {
        return 'http://localhost:5120';
      }
      // 對於實體裝置或發布版本，使用原來的配置
      else {
        return 'http://192.168.0.80:5120';
      }
    } catch (e) {
      debugPrint('獲取 API URL 時出錯: $e');
      // 如果 dotenv 載入失敗，使用預設值
      return _getDefaultApiUrl();
    }
  }

  static String get redisUrl {
    try {
      // 檢查 dotenv 是否已初始化
      if (dotenv.isInitialized) {
        return dotenv.get(
          'REDIS_URL',
          fallback: 'https://producer.uirapuka.com',
        );
      }

      // 如果 dotenv 未初始化，使用預設值
      return 'https://producer.uirapuka.com';
    } catch (e) {
      // 如果 dotenv 載入失敗，使用預設值
      return 'https://producer.uirapuka.com';
    }
  }

  // 私有方法：獲取預設的 API URL
  static String _getDefaultApiUrl() {
    // 對於 Android 模擬器，使用 10.0.2.2 代替 localhost
    if (Platform.isAndroid && !kReleaseMode) {
      return 'http://10.0.2.2:5120'; // Android 模擬器連接主機的特殊 IP
    }
    // 對於 iOS 模擬器，使用 localhost
    else if (Platform.isIOS && !kReleaseMode) {
      return 'http://localhost:5120';
    }
    // 對於實體裝置或發布版本，使用原來的配置
    else {
      return 'http://192.168.0.80:5120';
    }
  }

  // === 位置：/api/v1/user ===
  static const String loginCheckAPI =
      '/api/v2/adm/user/login_check'; // 檢查帳號是否存在

  // 取得完整 API URL
  static String getFullUrl(String endpoint) {
    return '$apiUrl$endpoint';
  }

  // 取得完整 Radis URL
  static String getRedisUrl(String endpoint) {
    return '$redisUrl$endpoint';
  }
}
