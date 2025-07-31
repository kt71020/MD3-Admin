import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

/// 示例小部件：展示如何在任何地方使用共用的用戶資料
class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authService = AuthService.instance;

      // 如果沒有用戶資料，顯示載入狀態
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
              // 用戶頭像
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        authService.currentUserAvatar.contains('http')
                            ? NetworkImage(authService.currentUserAvatar)
                            : null,
                    child:
                        authService.currentUserAvatar.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                  ),
                  const SizedBox(width: 16),
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
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          authService.currentUserEmail,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 用戶詳細信息
              _buildInfoRow('用戶等級', authService.currentUserLevel),
              _buildInfoRow('用戶 ID', authService.currentUid),
              _buildInfoRow(
                '權限 Token',
                authService.currentToken.isNotEmpty
                    ? '${authService.currentToken.substring(0, 20)}...'
                    : '無',
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '無資料',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
