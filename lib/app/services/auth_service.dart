import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable user state
  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;

  // Authentication state
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = true.obs;

  // User data from API
  final RxString userEmail = ''.obs;
  final RxString userLevel = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxString uid = ''.obs;
  final RxString token = ''.obs;
  final RxString userName = ''.obs;

  // SharedPreferences keys
  static const String _userDataKey = 'user_data';

  @override
  void onInit() {
    super.onInit();

    // Load saved user data
    _loadUserData();

    // Listen to auth state changes
    _user.bindStream(_auth.authStateChanges());

    // Update authentication status when user changes
    ever(_user, _setInitialScreen);
  }

  // Set initial screen based on auth state
  void _setInitialScreen(User? user) {
    isLoading.value = false;

    if (user == null) {
      isAuthenticated.value = false;
      // If we're not on login page, navigate to login
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } else {
      isAuthenticated.value = true;
      // Don't auto-navigate on login - let LoginController handle it
      // This allows for admin permission checking before navigation
      debugPrint('User authenticated: ${user.email}');
    }
  }

  // Get initial route based on current auth state
  String getInitialRoute() {
    final currentUser = _auth.currentUser;
    return currentUser != null ? '/dashboard' : '/login';
  }

  // Login method - returns ID token on success, null on failure
  Future<String?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get ID token from the authenticated user
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } catch (e) {
      return null;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Clear user data on logout
      await clearUserData();
    } catch (e) {
      Get.snackbar('錯誤', '登出失敗：$e');
    }
  }

  // Check if user is authenticated
  bool get isLoggedIn => _auth.currentUser != null;

  // Save user data to local storage and update observables
  Future<void> setUserData({
    required String email,
    required String level,
    required String avatar,
    required String userId,
    required String authToken,
    required String name,
  }) async {
    // Update observables
    userEmail.value = email;
    userLevel.value = level;
    userAvatar.value = avatar;
    uid.value = userId;
    token.value = authToken;
    userName.value = name;

    // Save to SharedPreferences
    await _saveUserData();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'email': userEmail.value,
        'level': userLevel.value,
        'avatar': userAvatar.value,
        'uid': uid.value,
        'token': token.value,
        'name': userName.value,
      };
      await prefs.setString(_userDataKey, jsonEncode(userData));
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);

      if (userDataJson != null && userDataJson.isNotEmpty) {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;

        userEmail.value = userData['email'] ?? '';
        userLevel.value = userData['level'] ?? '';
        userAvatar.value = userData['avatar'] ?? '';
        uid.value = userData['uid'] ?? '';
        token.value = userData['token'] ?? '';
        userName.value = userData['name'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Clear user data
  Future<void> clearUserData() async {
    try {
      // Clear observables
      userEmail.value = '';
      userLevel.value = '';
      userAvatar.value = '';
      uid.value = '';
      token.value = '';
      userName.value = '';

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  // Helper getters for easy access
  String get currentUserEmail => userEmail.value;
  String get currentUserLevel => userLevel.value;
  String get currentUserAvatar => userAvatar.value;
  String get currentUid => uid.value;
  String get currentToken => token.value;
  String get currentUserName => userName.value;

  // Check if user data is available
  bool get hasUserData => uid.value.isNotEmpty;
}
