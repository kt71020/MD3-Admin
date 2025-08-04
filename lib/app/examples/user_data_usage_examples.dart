import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

/// 這個文件展示了如何在應用程式的各個部分使用共用的用戶資料
/// 您可以參考這些範例來在您的實際程式碼中實作

class UserDataUsageExamples {
  /// 範例 1: 在 AppBar 中顯示用戶資訊
  static PreferredSizeWidget buildAppBarWithUserInfo(BuildContext context) {
    return AppBar(
      title: const Text('管理後台'),
      actions: [
        Obx(() {
          final authService = AuthService.instance;
          return PopupMenuButton<String>(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        authService.currentUserAvatar.isNotEmpty
                            ? NetworkImage(authService.currentUserAvatar)
                            : null,
                    child:
                        authService.currentUserAvatar.isEmpty
                            ? const Icon(Icons.person, size: 16)
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authService.currentUserName.isNotEmpty
                        ? authService.currentUserName
                        : authService.currentUserEmail,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                AuthService.instance.logout();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text('個人資料 (${authService.currentUserLevel})'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('登出'),
                      ],
                    ),
                  ),
                ],
          );
        }),
      ],
    );
  }

  /// 範例 2: 在 Drawer 中顯示用戶資訊
  static Widget buildDrawerWithUserInfo() {
    return Drawer(
      child: Column(
        children: [
          Obx(() {
            final authService = AuthService.instance;
            return UserAccountsDrawerHeader(
              accountName: Text(
                authService.currentUserName.isNotEmpty
                    ? authService.currentUserName
                    : '用戶',
              ),
              accountEmail: Text(authService.currentUserEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    authService.currentUserAvatar.isNotEmpty
                        ? NetworkImage(authService.currentUserAvatar)
                        : null,
                child:
                    authService.currentUserAvatar.isEmpty
                        ? const Icon(Icons.person)
                        : null,
              ),
              decoration: const BoxDecoration(color: Colors.blue),
            );
          }),
          // 其他選單項目...
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('儀表板'),
            onTap: () => Get.toNamed('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('登出'),
            onTap: () => AuthService.instance.logout(),
          ),
        ],
      ),
    );
  }

  /// 範例 3: 權限檢查小部件
  static Widget buildPermissionWidget({
    required String requiredLevel,
    required Widget child,
    Widget? fallback,
  }) {
    return Obx(() {
      final authService = AuthService.instance;

      // 簡單的權限檢查邏輯（您可以根據需要調整）
      final hasPermission = _checkPermission(
        authService.currentUserLevel,
        requiredLevel,
      );

      if (hasPermission) {
        return child;
      } else {
        return fallback ??
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('您沒有權限查看此內容'),
              ),
            );
      }
    });
  }

  /// 範例 4: API 請求時自動加入 Token
  static Map<String, String> getAuthHeaders() {
    final authService = AuthService.instance;
    return {
      'Content-Type': 'application/json',
      if (authService.currentToken.isNotEmpty)
        'Authorization': 'Bearer ${authService.currentToken}',
    };
  }

  /// 範例 5: 用戶資訊卡片
  static Widget buildUserInfoCard() {
    return Obx(() {
      final authService = AuthService.instance;

      if (!authService.hasUserData) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('載入用戶資料中...'),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        authService.currentUserAvatar.isNotEmpty
                            ? NetworkImage(authService.currentUserAvatar)
                            : null,
                    child:
                        authService.currentUserAvatar.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authService.currentUserName.isNotEmpty
                              ? authService.currentUserName
                              : '未知用戶',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          authService.currentUserEmail,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authService.currentUserLevel,
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 範例 6: 在任何控制器中使用用戶資料
  static void showUserDataInController() {
    // 在任何控制器中，您可以這樣獲取用戶資料：
    final authService = AuthService.instance;

    print('當前用戶郵箱: ${authService.currentUserEmail}');
    print('用戶等級: ${authService.currentUserLevel}');
    print('用戶頭像: ${authService.currentUserAvatar}');
    print('用戶 UID: ${authService.currentUid}');
    print('授權 Token: ${authService.currentToken}');

    // 監聽用戶資料變化
    ever(authService.userEmail, (email) {
      print('用戶郵箱已更新: $email');
    });

    ever(authService.userLevel, (level) {
      print('用戶等級已更新: $level');
    });
  }

  /// 簡單的權限檢查邏輯
  static bool _checkPermission(String userLevel, String requiredLevel) {
    // 定義權限等級（您可以根據實際需求調整）
    final levels = {'user': 1, 'moderator': 2, 'admin': 3, 'super_admin': 4};

    final userLevelValue = levels[userLevel.toLowerCase()] ?? 0;
    final requiredLevelValue = levels[requiredLevel.toLowerCase()] ?? 999;

    return userLevelValue >= requiredLevelValue;
  }
}

/// 範例頁面：展示如何在完整頁面中使用用戶資料
class UserDataExamplePage extends StatelessWidget {
  const UserDataExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserDataUsageExamples.buildAppBarWithUserInfo(context),
      drawer: UserDataUsageExamples.buildDrawerWithUserInfo(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 用戶資訊卡片
            UserDataUsageExamples.buildUserInfoCard(),

            const SizedBox(height: 16),

            // 權限控制的內容
            UserDataUsageExamples.buildPermissionWidget(
              requiredLevel: 'admin',
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('這是只有管理員能看到的內容'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 顯示當前用戶資料的按鈕
            ElevatedButton(
              onPressed: () {
                UserDataUsageExamples.showUserDataInController();
              },
              child: const Text('在控制台打印用戶資料'),
            ),
          ],
        ),
      ),
    );
  }
}
