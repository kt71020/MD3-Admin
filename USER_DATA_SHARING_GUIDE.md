# 用戶資料全域共享解決方案

本文檔說明如何讓 Web APP 的所有程式都能存取共用的用戶資料（userEmail, userLevel, userAvatar, uid, token）。

## 解決方案概述

我們採用 **GetX Service + SharedPreferences** 的組合方案，提供以下特性：

✅ **全域存取**：任何地方都能存取用戶資料  
✅ **響應式更新**：資料變化時 UI 自動更新  
✅ **持久化儲存**：應用重啟後資料仍然存在  
✅ **自動清理**：登出時自動清除所有資料

## 架構說明

### 1. AuthService 擴展

`lib/app/services/auth_service.dart` 已被擴展為包含用戶資料：

```dart
// 響應式用戶資料
final RxString userEmail = ''.obs;
final RxString userLevel = ''.obs;
final RxString userAvatar = ''.obs;
final RxString uid = ''.obs;
final RxString token = ''.obs;
final RxString userName = ''.obs;

// 便捷的存取方法
String get currentUserEmail => userEmail.value;
String get currentUserLevel => userLevel.value;
// ... 其他 getter
```

### 2. 自動資料儲存

登入成功後，用戶資料會自動儲存到 AuthService：

```dart
// 在 login_controller.dart 中
await AuthService.instance.setUserData(
  email: userEmail,
  level: userLevel,
  avatar: userAvatar,
  userId: uid,
  authToken: token,
  name: userName,
);
```

### 3. 持久化儲存

資料會自動儲存到 SharedPreferences，應用重啟後會自動載入。

## 使用方法

### 基本用法

在任何地方存取用戶資料：

```dart
// 獲取 AuthService 實例
final authService = AuthService.instance;

// 直接存取資料
String email = authService.currentUserEmail;
String level = authService.currentUserLevel;
String avatar = authService.currentUserAvatar;
String userId = authService.currentUid;
String token = authService.currentToken;
String name = authService.currentUserName;

// 檢查是否有用戶資料
bool hasData = authService.hasUserData;
```

### 在 Widget 中響應式使用

使用 `Obx` 包裝，當用戶資料變化時 UI 會自動更新：

```dart
Obx(() {
  final authService = AuthService.instance;
  return Text('歡迎, ${authService.currentUserName}!');
})
```

### 在控制器中監聽變化

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    // 監聽用戶郵箱變化
    ever(AuthService.instance.userEmail, (email) {
      print('用戶郵箱已更新: $email');
    });
  }
}
```

## 實際應用範例

### 1. 在 AppBar 顯示用戶資訊

```dart
AppBar(
  title: const Text('管理後台'),
  actions: [
    Obx(() {
      final authService = AuthService.instance;
      return Row(
        children: [
          CircleAvatar(
            backgroundImage: authService.currentUserAvatar.isNotEmpty
                ? NetworkImage(authService.currentUserAvatar)
                : null,
          ),
          Text(authService.currentUserName),
        ],
      );
    }),
  ],
)
```

### 2. API 請求自動加入 Token

```dart
Map<String, String> getAuthHeaders() {
  final authService = AuthService.instance;
  return {
    'Content-Type': 'application/json',
    if (authService.currentToken.isNotEmpty)
      'Authorization': authService.currentToken,
  };
}

// 使用範例
final response = await http.get(
  Uri.parse('your-api-url'),
  headers: getAuthHeaders(),
);
```

### 3. 權限控制

```dart
Widget buildAdminOnlyContent() {
  return Obx(() {
    final authService = AuthService.instance;

    if (authService.currentUserLevel == 'admin') {
      return const Text('管理員專用內容');
    } else {
      return const Text('權限不足');
    }
  });
}
```

### 4. 用戶資訊卡片

```dart
Widget buildUserCard() {
  return Obx(() {
    final authService = AuthService.instance;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: authService.currentUserAvatar.isNotEmpty
              ? NetworkImage(authService.currentUserAvatar)
              : null,
        ),
        title: Text(authService.currentUserName),
        subtitle: Text(authService.currentUserEmail),
        trailing: Chip(
          label: Text(authService.currentUserLevel),
        ),
      ),
    );
  });
}
```

## 進階功能

### 1. 資料驗證

```dart
// 檢查用戶是否有特定權限
bool hasAdminPermission() {
  final level = AuthService.instance.currentUserLevel;
  return level == 'admin' || level == 'super_admin';
}
```

### 2. 條件渲染

```dart
Widget buildConditionalContent() {
  return Obx(() {
    final authService = AuthService.instance;

    if (!authService.hasUserData) {
      return const CircularProgressIndicator();
    }

    switch (authService.currentUserLevel) {
      case 'admin':
        return const AdminDashboard();
      case 'user':
        return const UserDashboard();
      default:
        return const AccessDeniedView();
    }
  });
}
```

### 3. 自動登出處理

AuthService 已經在登出時自動清理用戶資料：

```dart
// 登出時會自動執行
await AuthService.instance.logout(); // 自動清除所有用戶資料
```

## 檔案說明

- `lib/app/services/auth_service.dart` - 核心服務，管理用戶資料
- `lib/app/widgets/user_info_widget.dart` - 用戶資訊顯示小部件
- `lib/app/examples/user_data_usage_examples.dart` - 完整使用範例
- `lib/app/modules/login/controllers/login_controller.dart` - 已更新以儲存用戶資料

## 最佳實踐

1. **總是使用 Obx** 包裝需要響應用戶資料變化的 Widget
2. **檢查資料存在性** 使用 `hasUserData` 確保資料已載入
3. **安全性考慮** 不要在前端儲存敏感資料，Token 應定期更新
4. **錯誤處理** 處理網路錯誤和資料載入失敗的情況

## 故障排除

### 問題：資料沒有更新

**解決**：確保使用 `Obx()` 包裝 Widget，並存取 `.value` 屬性

### 問題：應用重啟後資料丟失

**解決**：檢查 SharedPreferences 權限，確保 `setUserData()` 被正確調用

### 問題：Token 過期

**解決**：實作 Token 自動刷新機制，或在 API 回應 401 時自動登出

這個解決方案提供了完整的用戶資料共享機制，讓您的整個應用程式都能輕鬆存取和使用用戶資料。
