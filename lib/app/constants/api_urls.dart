import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiUrls {
  // 根據不同環境返回適合的 API URL
  static String get apiUrl {
    try {
      // 從環境變數中獲取
      String configuredUrl = dotenv.get('API_URL', fallback: '');

      if (configuredUrl.isNotEmpty) {
        return configuredUrl;
      }

      // 如果環境變數為空，則使用預設值
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
      return 'http://192.168.0.80:5120';
    }
  }

  static String get redisUrl {
    try {
      return dotenv.get('REDIS_URL', fallback: 'https://producer.uirapuka.com');
    } catch (e) {
      // 如果 dotenv 載入失敗，使用預設值
      return 'https://producer.uirapuka.com';
    }
  }

  // === 位置：/api/v1/user ===
  static const String socialSignAPI = '/api/v1/user/social_signIn'; // 社交帳號登入註冊
  static const String checkTokenAPI = '/api/v1/user/check_token'; // 檢查token是否過期
  static const String firebaseLoginAPI = '/api/v1/user/firebase_signin'; // 登入
  static const String getUserInfoAPI = '/api/v1/user/get_user_info'; // 取得用戶基本資料

  // 取得完整 API URL
  static String getFullUrl(String endpoint) {
    return '$apiUrl$endpoint';
  }

  // 取得完整 Radis URL
  static String getRedisUrl(String endpoint) {
    return '$redisUrl$endpoint';
  }
}
