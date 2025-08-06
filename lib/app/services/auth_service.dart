import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  // Navigation state to prevent duplicate navigation
  bool _isNavigating = false;

  // Set initial screen based on auth state
  void _setInitialScreen(User? user) {
    isLoading.value = false;

    // Prevent duplicate navigation calls
    if (_isNavigating) {
      debugPrint('Navigation already in progress, skipping...');
      return;
    }

    if (user == null) {
      isAuthenticated.value = false;
      // Check if GetX navigation is ready before navigating
      final currentRoute = Get.currentRoute;
      debugPrint('Current route: $currentRoute, target: /login');

      if (currentRoute != '/login') {
        _isNavigating = true;
        // Use post frame callback to ensure navigation is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context != null && Get.currentRoute != '/login') {
            debugPrint('Navigating to /login');
            Get.offAllNamed('/login')?.then((_) {
                  _isNavigating = false;
                }) ??
                (_isNavigating = false);
          } else {
            _isNavigating = false;
          }
        });
      }
    } else {
      isAuthenticated.value = true;
      // Only navigate to dashboard if user has admin data stored
      // This prevents automatic navigation for non-admin users
      if (hasUserData) {
        final currentRoute = Get.currentRoute;
        debugPrint('Current route: $currentRoute, target: /dashboard');

        if (currentRoute != '/dashboard') {
          _isNavigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context != null && Get.currentRoute != '/dashboard') {
              debugPrint('Navigating to /dashboard');
              Get.offAllNamed('/dashboard')?.then((_) {
                    _isNavigating = false;
                  }) ??
                  (_isNavigating = false);
            } else {
              _isNavigating = false;
            }
          });
        }
      } else {
        // User is authenticated but has no admin data - stay on current page
        debugPrint('User authenticated but no admin data found: ${user.email}');
      }
    }
  }

  // Get initial route based on current auth state and admin permissions
  String getInitialRoute() {
    final currentUser = _auth.currentUser;
    // Only go to dashboard if user is authenticated AND has admin data
    return (currentUser != null && hasUserData) ? '/dashboard' : '/login';
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

  // Google Sign In - returns ID token on success, null on failure
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);

      // Get ID token from the authenticated user
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  // Apple Sign In - returns ID token on success, null on failure
  Future<String?> signInWithApple() async {
    try {
      // Generate a random nonce
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Sign in the user with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Get ID token from the authenticated user
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } catch (e) {
      debugPrint('Apple Sign In Error: $e');
      return null;
    }
  }

  // Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  // Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
