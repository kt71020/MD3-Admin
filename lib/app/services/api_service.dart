import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_urls.dart';
import 'auth_service.dart';

/// API 服務統一抽象層
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static ApiService get instance => _instance;

  /// 應用狀態常數
  static const int statusRejected = 5;
  static const int statusApproved = 1;
  static const String reviewStatusReject = 'REJECT';
  static const String reviewStatusApprove = 'APPROVE';

  /// 統一的 HTTP 請求方法
  Future<http.Response> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
  }) async {
    final authService = AuthService.instance;

    // 檢查認證
    if (requireAuth && authService.currentToken.isEmpty) {
      throw ApiException('JWT Token 不存在，請重新登入', 401);
    }

    // 建立標準 headers
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (requireAuth) {
      requestHeaders['Authorization'] = 'Bearer ${authService.currentToken}';
    }

    final uri = Uri.parse(ApiUrls.getFullUrl(endpoint));

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(uri, headers: requestHeaders, body: body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: requestHeaders, body: body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders);
          break;
        default:
          throw ApiException('不支援的 HTTP 方法: $method');
      }

      debugPrint(
        'API ${method.toUpperCase()} $endpoint - Status: ${response.statusCode}',
      );
      debugPrint('Response: ${utf8.decode(response.bodyBytes)}');

      return response;
    } catch (e) {
      throw ApiException('網路請求失敗: $e');
    }
  }

  /// GET 請求
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool requireAuth = true,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await _makeRequest(
        method: 'GET',
        endpoint: endpoint,
        headers: headers,
        requireAuth: requireAuth,
      );

      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// POST 請求
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    bool requireAuth = true,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await _makeRequest(
        method: 'POST',
        endpoint: endpoint,
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
        requireAuth: requireAuth,
      );

      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// 處理 API 回應
  ApiResult<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? parser,
  ) {
    final decodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(decodedBody) as Map<String, dynamic>;

        if (parser != null) {
          return ApiResult.success(parser(json));
        } else {
          return ApiResult.success(json as T);
        }
      } catch (e) {
        return ApiResult.error('JSON 解析失敗: $e');
      }
    } else {
      return ApiResult.error(
        'API 請求失敗: HTTP ${response.statusCode} - $decodedBody',
      );
    }
  }
}

/// API 結果封裝
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResult.success(this.data) : isSuccess = true, error = null;
  ApiResult.error(this.error) : isSuccess = false, data = null;
}

/// API 異常類別
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}
