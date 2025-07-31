import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // If user is not authenticated and trying to access protected route
    if (!authService.isLoggedIn && route != '/login') {
      return const RouteSettings(name: '/login');
    }

    // If user is authenticated and trying to access login page
    if (authService.isLoggedIn && route == '/login') {
      return const RouteSettings(name: '/dashboard');
    }

    return null;
  }
}
