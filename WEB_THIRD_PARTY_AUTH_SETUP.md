# Web 第三方登入設定指南 🌐

## ✅ 已完成的項目

- [x] 新增 Google Sign-In 和 Apple Sign-In 依賴套件
- [x] 更新 AuthService 支援第三方登入
- [x] 更新 LoginController 處理第三方登入邏輯
- [x] 更新 LoginView UI 顯示第三方登入按鈕

## 🌐 Web 專用配置 (必須完成才能正常運作)

### 1. Firebase Console 基本設定

1. 前往 [Firebase Console](https://console.firebase.google.com)
2. 選擇你的專案
3. 前往 **Authentication** > **Sign-in method**
4. 啟用 **Google** 登入提供方
5. ⚠️ **Apple Sign-In 在 Web 上支援有限，建議先專注於 Google**

### 2. Firebase Web 應用程式設定

#### 步驟 1: 確認 Web 應用程式存在

1. **Firebase Console**：
   - 前往 Project Settings > General
   - 在 "Your apps" 區域，確保有 Web 應用程式
   - 如果沒有，點擊 "Add app" > Web icon
   - 輸入應用程式名稱並註冊

#### 步驟 2: 設定授權域名

1. **Firebase Console**：

   - 前往 Authentication > Settings > Authorized domains
   - 新增以下域名：
     - `localhost` (本地開發必須)
     - 你的正式域名 (例如：`your-domain.com`)

   **重要**: 不要包含 `http://` 或 `https://`，只輸入域名！

### 3. Google Cloud Console OAuth 設定 ⭐ (關鍵步驟)

#### 步驟 1: 前往 Google Cloud Console

1. 前往 [Google Cloud Console](https://console.cloud.google.com)
2. 選擇與 Firebase 相同的專案
3. 前往 **APIs & Services** > **Credentials**

#### 步驟 2: 配置 OAuth 2.0 客戶端

1. 找到 "OAuth 2.0 Client IDs" 區域
2. 點擊你的 Web 客戶端 (通常名稱包含 firebase)
3. 在 **Authorized JavaScript origins** 新增：

   ```
   http://localhost:3000
   http://localhost:8080
   https://your-domain.com
   ```

4. 在 **Authorized redirect URIs** 新增：
   ```
   http://localhost:3000/__/auth/handler
   http://localhost:8080/__/auth/handler
   https://your-domain.com/__/auth/handler
   ```

**注意**: `3000` 和 `8080` 是常見的 Flutter Web 開發端口

#### 步驟 3: 啟用 People API (必須！)

⚠️ **重要**: Google Sign-In 需要 People API 來獲取用戶資料

1. 在 Google Cloud Console 中，前往 **APIs & Services** > **Library**
2. 搜尋 "People API"
3. 點擊 "Google People API"
4. 點擊 **"Enable"** 按鈕
5. 等待 1-2 分鐘讓服務生效

**或者直接點擊連結**：
[啟用 People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=55834580879)

55834580879-0qlsfm8fql5tr9irl5gae8fdqvf654je.apps.googleusercontent.com

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

### 4. Flutter Web 檢查

#### 步驟 1: 設定 Google Sign-In Client ID (必須)

在 `web/index.html` 的 `<head>` 區域加入：

```html
<!-- Google Sign-In Client ID for Web -->
<meta name="google-signin-client_id" content="你的CLIENT_ID" />
```

**範例**：

```html
<meta
  name="google-signin-client_id"
  content="55834580879-0qlsfm8fql5tr9irl5gae8fdqvf654je.apps.googleusercontent.com"
/>
```

#### 步驟 2: 檢查 Firebase 配置

確保你的 `web/index.html` 在 `<body>` 標籤前包含：

```html
<!-- Firebase Configuration -->
<script type="module">
  import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.23.0/firebase-app.js';
  import { getAuth } from 'https://www.gstatic.com/firebasejs/9.23.0/firebase-auth.js';

  // Your web app's Firebase configuration
  const firebaseConfig = {
    // 從 Firebase Console 複製配置
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
</script>
```

**或者** 使用 Firebase SDK Bundle (推薦)：

```html
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
```

### 5. 測試步驟

#### 本地測試

1. 在終端機執行：

   ```bash
   flutter run -d chrome --web-port=3000
   ```

2. 開啟瀏覽器開發者工具 (F12)
3. 確保沒有 CORS 錯誤
4. 嘗試 Google 登入

#### 檢查清單

- [ ] Firebase Console 啟用 Google 登入
- [ ] Firebase 授權域名包含 `localhost`
- [ ] Google Cloud Console OAuth 設定正確
- [ ] 瀏覽器允許彈出視窗
- [ ] 沒有 Console 錯誤

### 6. Apple Sign-In (Web) - 可選

⚠️ **警告**: Apple Sign-In 在 Web 上較複雜，建議先完成 Google Sign-In

如果要支援：

1. 前往 [Apple Developer Console](https://developer.apple.com)
2. 建立 Services ID
3. 設定 Return URLs: `https://your-domain.com/__/auth/handler`
4. 在 Firebase Console 配置 Apple 提供方

## ⚠️ Web 特定注意事項

1. **CORS 政策**: 最常見的問題！確保域名正確設定
2. **彈出視窗**: 瀏覽器可能阻擋登入彈出視窗
3. **HTTPS**: 正式環境必須使用 HTTPS
4. **localhost**: 本地開發使用 `localhost`，不要用 `127.0.0.1`
5. **端口號**: 確保 OAuth 設定包含你使用的端口

## 🐛 Web 常見問題解決

### 1. CORS 錯誤

```
Access to XMLHttpRequest has been blocked by CORS policy
```

**解決方案**:

- 檢查 Firebase 授權域名設定
- 確認 Google Cloud Console OAuth origins 設定

### 2. 彈出視窗被阻擋

```
Popup blocked or closed by user
```

**解決方案**:

- 在瀏覽器允許彈出視窗
- 檢查瀏覽器設定

### 3. Firebase 初始化錯誤

```
Firebase app not initialized
```

**解決方案**:

- 檢查 `web/index.html` 的 Firebase SDK
- 確認 Firebase 配置正確

### 4. Google Sign-In 失敗

```
Invalid origin or redirect_uri
```

**解決方案**:

- 檢查 Google Cloud Console 的 OAuth 設定
- 確認域名格式正確 (不包含協議)

## 🚀 快速啟動檢查清單

1. ✅ Firebase Console > Authentication > Google 啟用
2. ✅ Firebase Console > Settings > 授權域名新增 `localhost`
3. ✅ Google Cloud Console > OAuth 設定 JavaScript origins
4. ✅ Google Cloud Console > OAuth 設定 redirect URIs
5. ✅ `flutter run -d chrome --web-port=3000`
6. ✅ 測試 Google 登入

---

**完成這些 Web 專用設定後，你的第三方登入就能正常運作了！** 🎉

**記住：Web 和行動裝置的配置完全不同，不要搞混了！**
