# 🔥 Firebase 設置指南

## 📋 目錄

1. [建立 Firebase 專案](#建立-firebase-專案)
2. [Android 配置](#android-配置)
3. [iOS 配置](#ios-配置)
4. [Web 配置](#web-配置)
5. [啟用 Authentication](#啟用-authentication)
6. [測試設置](#測試設置)

## 🚀 建立 Firebase 專案

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「建立專案」
3. 輸入專案名稱（例如：`MD3-Admin`）
4. 選擇是否啟用 Google Analytics（建議啟用）
5. 完成專案建立

## 📱 Android 配置

### 步驟 1：新增 Android 應用程式

1. 在 Firebase Console 中，點擊「新增應用程式」圖示，選擇 Android
2. 輸入 Android 套件名稱：`com.uirapuka.md3admin.md3_web_admin`
   - 💡 這個套件名稱可以在 `android/app/build.gradle.kts` 中找到
3. 輸入應用程式名稱（可選）：`MD3 Admin`
4. 點擊「註冊應用程式」

### 步驟 2：下載配置檔案

1. 下載 `google-services.json` 文件
2. 將文件放置在以下位置：
   ```
   MD3-Admin/
   ├── android/
   │   └── app/
   │       └── google-services.json  ← 這裡
   ```

### 步驟 3：新增 Firebase SDK（已完成）

- ✅ 已在 `pubspec.yaml` 中添加相關依賴
- ✅ 已在 `main.dart` 中初始化 Firebase

## 🍎 iOS 配置

### 步驟 1：新增 iOS 應用程式

1. 在 Firebase Console 中，點擊「新增應用程式」圖示，選擇 iOS
2. 輸入 iOS Bundle ID：`com.uirapuka.md3admin.md3WebAdmin`
   - 💡 這個 Bundle ID 可以在 `ios/Runner/Info.plist` 中找到
3. 輸入應用程式名稱（可選）：`MD3 Admin`
4. 點擊「註冊應用程式」

### 步驟 2：下載配置檔案

1. 下載 `GoogleService-Info.plist` 文件
2. 將文件放置在以下位置：
   ```
   MD3-Admin/
   ├── ios/
   │   └── Runner/
   │       └── GoogleService-Info.plist  ← 這裡
   ```

### 步驟 3：在 Xcode 中添加文件

1. 打開 Xcode 專案：`open ios/Runner.xcworkspace`
2. 右鍵點擊 `Runner` 資料夾
3. 選擇「Add Files to "Runner"」
4. 選擇 `GoogleService-Info.plist` 文件
5. 確保勾選「Copy items if needed」
6. 點擊「Add」

## 🌐 Web 配置

### 步驟 1：新增 Web 應用程式

1. 在 Firebase Console 中，點擊「新增應用程式」圖示，選擇 Web
2. 輸入應用程式名稱：`MD3 Admin Web`
3. **勾選**「同時為此應用程式設定 Firebase Hosting」（如果您想使用 Firebase Hosting）
4. 點擊「註冊應用程式」

### 步驟 2：複製配置

1. Firebase 會顯示類似以下的配置：

   ```javascript
   const firebaseConfig = {
     apiKey: 'AIzaSyExample...',
     authDomain: 'your-project.firebaseapp.com',
     projectId: 'your-project',
     storageBucket: 'your-project.appspot.com',
     messagingSenderId: '123456789',
     appId: '1:123456789:web:abc123def456',
   };
   ```

2. 將此配置複製並替換 `web/index.html` 中的配置：

   ```html
   <!-- 找到這個部分並替換 -->
   <script>
     const firebaseConfig = {
       // 將您的配置貼在這裡
     };

     firebase.initializeApp(firebaseConfig);
   </script>
   ```

## 🔐 啟用 Authentication

1. 在 Firebase Console 中，前往「Authentication」
2. 點擊「開始使用」
3. 選擇「Sign-in method」分頁
4. 點擊「電子郵件/密碼」
5. 啟用「電子郵件/密碼」
6. 點擊「儲存」

### 建立測試用戶

1. 前往「Users」分頁
2. 點擊「新增使用者」
3. 輸入電子郵件和密碼
4. 點擊「新增使用者」

## 🧪 測試設置

### 準備測試

1. 確保所有配置文件都在正確位置
2. 重新安裝依賴：
   ```bash
   flutter clean
   flutter pub get
   ```

### 運行測試

```bash
# Web 測試
flutter run -d chrome

# Android 測試（需要模擬器或實機）
flutter run -d android

# iOS 測試（需要模擬器或實機，僅 macOS）
flutter run -d ios
```

### 驗證功能

1. 啟動應用程式應該顯示登入頁面
2. 使用您建立的測試帳號登入
3. 登入成功後應該跳轉到 dashboard
4. 檢查 Firebase Console 的 Authentication > Users，應該看到登入記錄

## 🚨 常見問題

### Android 問題

- 如果出現「google-services.json not found」錯誤，檢查文件路徑
- 確保套件名稱與 `android/app/build.gradle.kts` 中的一致

### iOS 問題

- 如果出現配置錯誤，確保 `GoogleService-Info.plist` 已正確添加到 Xcode 專案
- 檢查 Bundle ID 是否正確

### Web 問題

- 如果登入失敗，檢查瀏覽器控制台是否有 Firebase 相關錯誤
- 確保 `web/index.html` 中的配置正確
- 檢查 Firebase Console 中是否已啟用 Web 平台

## ✅ 檢查清單

- [ ] Firebase 專案已建立
- [ ] `google-services.json` 已放置在 `android/app/` 目錄
- [ ] `GoogleService-Info.plist` 已放置在 `ios/Runner/` 目錄並添加到 Xcode
- [ ] `web/index.html` 已更新 Firebase 配置
- [ ] Firebase Authentication 已啟用電子郵件/密碼登入
- [ ] 已建立測試用戶帳號
- [ ] 應用程式可以成功登入和登出

完成這些步驟後，您的 Flutter 應用程式就可以使用 Firebase Authentication 了！
