import 'dart:math';

import 'package:admin/app/constants/api_urls.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/auth_service.dart';

class LoginController extends GetxController {
  // Form controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Form key for validation - create unique key for each instance
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;

  // Password visibility
  final isPasswordHidden = true.obs;

  // Remember email
  final rememberEmail = true.obs;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SharedPreferences key
  static const String _emailKey = 'saved_email';

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Load saved email if available
    _loadSavedEmail();

    // Don't auto-navigate - let AuthService handle all navigation
    // LoginController only handles form interactions
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Check authentication state (for information only, no navigation)
  void checkAuthState() {
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint('User already logged in: ${user.email}');
      // Let AuthService handle navigation - don't navigate here
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Toggle remember email
  void toggleRememberEmail() {
    rememberEmail.value = !rememberEmail.value;
  }

  // Load saved email from SharedPreferences
  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_emailKey);
      if (savedEmail != null && savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
      }
    } catch (e) {
      debugPrint('Error loading saved email: $e');
    }
  }

  // Save email to SharedPreferences
  Future<void> _saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
    } catch (e) {
      debugPrint('Error saving email: $e');
    }
  }

  // Remove saved email from SharedPreferences
  Future<void> _removeSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
    } catch (e) {
      debugPrint('Error removing saved email: $e');
    }
  }

  // Login function
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final idToken = await AuthService.instance.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (idToken != null) {
        // TODO:
        // 檢查在 Admin_users 中是否存在此帳號
        // 如果存在，則跳轉到 dashboard
        // 如果不存在，則跳轉到 login 頁面
        // 如果存在，則跳轉到 dashboard
        // Check if user is admin
        bool isAdminUser = await checkAdminUser(
          emailController.text.trim(),
          idToken,
        );

        if (isAdminUser) {
          // Handle remember email functionality
          if (rememberEmail.value) {
            await _saveEmail(emailController.text.trim());
          } else {
            await _removeSavedEmail();
          }

          Get.snackbar(
            '登入成功',
            '歡迎回來！',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Navigate to dashboard after successful admin login
          Get.offAllNamed(Routes.dashboard);
        } else {
          // User is not an admin, sign them out and show error
          await AuthService.instance.logout();
          Get.snackbar(
            '登入錯誤',
            '此帳號沒有權限登入系統',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // 跳轉到 login 頁面
        Get.offNamed(Routes.login);
        Get.snackbar(
          '登入失敗',
          '請檢查您的電子郵件和密碼',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '登入失敗';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = '找不到此電子郵件對應的帐號';
          break;
        case 'wrong-password':
          errorMessage = '密碼錯誤';
          break;
        case 'invalid-email':
          errorMessage = '電子郵件格式不正確';
          break;
        case 'user-disabled':
          errorMessage = '此帳號已被停用';
          break;
        case 'too-many-requests':
          errorMessage = '嘗試次數過多，請稍後再試';
          break;
        default:
          errorMessage = '登入失敗：${e.message}';
      }

      Get.snackbar(
        '錯誤',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      // 跳轉到 login 頁面
      Get.offNamed(Routes.login);
      Get.snackbar(
        '錯誤',
        '發生未知錯誤：$e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子郵件';
    }
    if (!GetUtils.isEmail(value)) {
      return '請輸入有效的電子郵件格式';
    }
    return null;
  }

  // Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    if (value.length < 6) {
      return '密碼至少需要6個字符';
    }
    return null;
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final idToken = await AuthService.instance.signInWithGoogle();

      if (idToken != null) {
        // Check if user is admin using Firebase user email
        final firebaseUser = _auth.currentUser;
        if (firebaseUser?.email != null) {
          bool isAdminUser = await checkAdminUser(
            firebaseUser!.email!,
            idToken,
          );

          if (isAdminUser) {
            Get.snackbar(
              '登入成功',
              '歡迎使用 Google 帳號登入！',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            // Navigate to dashboard after successful admin login
            Get.offAllNamed(Routes.dashboard);
          } else {
            // User is not an admin, sign them out and show error
            await AuthService.instance.logout();
            Get.snackbar(
              '權限不足',
              '此帳號沒有管理員權限',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        Get.snackbar(
          '登入失敗',
          'Google 登入已取消或失敗',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '錯誤',
        'Google 登入發生錯誤：$e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apple Sign In
  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;

      final idToken = await AuthService.instance.signInWithApple();

      if (idToken != null) {
        // Check if user is admin using Firebase user email
        final firebaseUser = _auth.currentUser;
        if (firebaseUser?.email != null) {
          bool isAdminUser = await checkAdminUser(
            firebaseUser!.email!,
            idToken,
          );

          if (isAdminUser) {
            Get.snackbar(
              '登入成功',
              '歡迎使用 Apple ID 登入！',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            // Navigate to dashboard after successful admin login
            Get.offAllNamed(Routes.dashboard);
          } else {
            // User is not an admin, sign them out and show error
            await AuthService.instance.logout();
            Get.snackbar(
              '登入錯誤',
              '此帳號沒有權限登入系統',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        Get.snackbar(
          '登入失敗',
          'Apple ID 登入已取消或失敗',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '錯誤',
        'Apple ID 登入發生錯誤：$e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkAdminUser(String email, String idToken) async {
    // 檢查 id_token 是否為空
    if (idToken.isEmpty) {
      debugPrint('ERROR: ID token is null or empty!');
      return false;
    }

    final headers = {'Content-Type': 'application/json'};
    final body = {"email": email, "id_token": idToken};
    final response = await http.post(
      Uri.parse(ApiUrls.getFullUrl(ApiUrls.loginCheckAPI)),
      headers: headers,
      body: jsonEncode(body),
    );

    final decodedBody = utf8.decode(response.bodyBytes);
    debugPrint(
      '響應內容: ${decodedBody.substring(0, min(100, decodedBody.length))}...',
    );
    if (response.statusCode == 200) {
      String token = response.headers['authorization'] ?? '';
      final jsonResponse = jsonDecode(decodedBody);
      final uid = jsonResponse['uid'] ?? '';
      final userEmail = jsonResponse['email'] ?? '';
      final userName = jsonResponse['name'] ?? '';
      final userLevel = jsonResponse['level'] ?? '';
      final userAvatar = jsonResponse['photo_url'] ?? '';

      // Save user data to AuthService for global access
      await AuthService.instance.setUserData(
        email: userEmail,
        level: userLevel,
        avatar: userAvatar,
        userId: uid,
        authToken: token,
        name: userName,
      );

      return true;
    } else {
      debugPrint('❌ API Error - Status: ${response.statusCode}');

      // 嘗試解析錯誤信息
      try {
        final errorResponse = jsonDecode(decodedBody);
        debugPrint('Error details: $errorResponse');

        if (errorResponse is Map) {
          final message =
              errorResponse['message'] ??
              errorResponse['error'] ??
              'Unknown error';
          debugPrint('Error message: $message');
        }
      } catch (e) {
        debugPrint('Could not parse error response as JSON: $e');
      }

      return false;
    }
  }
}
