import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or Title
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '管理員登入',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '請輸入您的帳號和密碼',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                      decoration: InputDecoration(
                        labelText: '電子郵件',
                        hintText: '請輸入您的電子郵件',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        validator: controller.validatePassword,
                        decoration: InputDecoration(
                          labelText: '密碼',
                          hintText: '請輸入您的密碼',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Remember Email Checkbox
                    Obx(
                      () => InkWell(
                        onTap: controller.toggleRememberEmail,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: controller.rememberEmail.value,
                                onChanged:
                                    (value) => controller.toggleRememberEmail(),
                                activeColor: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '記住帳號',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child:
                            controller.isLoading.value
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  '登入',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider with "OR" text
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[400])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '或',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Sign In Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.signInWithGoogle,
                          icon: const Icon(
                            Icons
                                .g_mobiledata, // Temporary icon, ideally use Google's actual icon
                            color: Colors.red,
                            size: 24,
                          ),
                          label: const Text(
                            '使用 Google 帳號登入',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Apple Sign In Button (show on Web, iOS and macOS)
                    if (Theme.of(context).platform == TargetPlatform.iOS ||
                        Theme.of(context).platform == TargetPlatform.macOS ||
                        kIsWeb)
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.signInWithApple,
                            icon: const Icon(
                              Icons.apple,
                              color: Colors.black,
                              size: 24,
                            ),
                            label: const Text(
                              '使用 Apple ID 登入',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (Theme.of(context).platform == TargetPlatform.iOS ||
                        Theme.of(context).platform == TargetPlatform.macOS ||
                        kIsWeb)
                      const SizedBox(height: 16),

                    // Additional links or info
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        Get.snackbar(
                          '提示',
                          '忘記密碼功能尚未實現',
                          snackPosition: SnackPosition.TOP,
                        );
                      },
                      child: const Text(
                        '忘記密碼？',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
