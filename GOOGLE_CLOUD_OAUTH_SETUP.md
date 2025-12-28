# Hướng Dẫn Cấu Hình OAuth 2.0 trên Google Cloud Console

## Tổng Quan

Để Google Sign-In hoạt động, bạn cần cấu hình OAuth 2.0 Client IDs trên Google Cloud Console cho:
1. **Android Application** - Thêm SHA-1 fingerprints
2. **Web Application** - Tạo OAuth 2.0 Client ID cho web

## Thông Tin Project

- **Project ID**: `sarah-learn-english`
- **Project Number**: `595631319099`
- **Package Name**: `com.sarah.edu.complete.sarah_edu_complete`

## SHA-1 Fingerprints

### Debug SHA-1:
```
80:D1:04:3E:52:98:52:6C:B2:3D:1E:DB:31:A1:62:7D:83:D8:3B:07
```

### Release SHA-1:
```
60:66:97:B2:92:7B:64:59:DA:E5:03:14:0F:A1:BB:A3:76:6B:08:E2
```

## Bước 1: Truy Cập Google Cloud Console

1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project **sarah-learn-english** (hoặc project ID của bạn)
3. Vào **APIs & Services** > **Credentials**

## Bước 2: Cấu Hình OAuth Consent Screen (Nếu chưa có)

1. Vào **APIs & Services** > **OAuth consent screen**
2. Chọn **External** (hoặc Internal nếu dùng Google Workspace)
3. Điền thông tin:
   - **App name**: Sarah Edu
   - **User support email**: Email của bạn
   - **Developer contact information**: Email của bạn
4. Click **Save and Continue**
5. Ở màn hình **Scopes**, click **Save and Continue** (có thể thêm scopes sau)
6. Ở màn hình **Test users** (nếu External), thêm test users nếu cần
7. Click **Save and Continue** > **Back to Dashboard**

## Bước 3: Cấu Hình Android OAuth Client

1. Vào **APIs & Services** > **Credentials**
2. Tìm OAuth 2.0 Client ID cho Android (có thể đã được tạo tự động bởi Firebase)
   - Tên thường là: `Android client (auto created by Google Service)`
   - Hoặc tìm theo package name: `com.sarah.edu.complete.sarah_edu_complete`
3. Click vào OAuth client để chỉnh sửa
4. Trong phần **SHA-1 certificate fingerprints**, thêm:
   - **Debug SHA-1**: `80:D1:04:3E:52:98:52:6C:B2:3D:1E:DB:31:A1:62:7D:83:D8:3B:07`
   - **Release SHA-1**: `60:66:97:B2:92:7B:64:59:DA:E5:03:14:0F:A1:BB:A3:76:6B:08:E2`
5. Click **Save**

**Lưu ý**: Nếu chưa có OAuth client cho Android, tạo mới:
1. Click **+ CREATE CREDENTIALS** > **OAuth client ID**
2. Chọn **Application type**: **Android**
3. Điền:
   - **Name**: Sarah Edu Android
   - **Package name**: `com.sarah.edu.complete.sarah_edu_complete`
   - **SHA-1 certificate fingerprint**: Thêm cả Debug và Release SHA-1
4. Click **Create**

## Bước 4: Cấu Hình Web OAuth Client

1. Vào **APIs & Services** > **Credentials**
2. Kiểm tra xem đã có OAuth 2.0 Client ID cho Web chưa
   - Tên thường là: `Web client (auto created by Google Service)`
3. Nếu chưa có, tạo mới:
   - Click **+ CREATE CREDENTIALS** > **OAuth client ID**
   - Chọn **Application type**: **Web application**
   - Điền:
     - **Name**: Sarah Edu Web
     - **Authorized JavaScript origins**: 
       - `http://localhost` (cho development)
       - `https://sarah-learn-english.firebaseapp.com` (cho production)
       - `https://YOUR_DOMAIN.com` (nếu có custom domain)
     - **Authorized redirect URIs**:
       - `http://localhost` (cho development)
       - `https://sarah-learn-english.firebaseapp.com/__/auth/handler` (cho Firebase Auth)
       - `https://YOUR_DOMAIN.com/__/auth/handler` (nếu có custom domain)
   - Click **Create**
4. Copy **Client ID** (sẽ có dạng: `xxxxx.apps.googleusercontent.com`)
5. Cập nhật Client ID này vào:
   - `web/index.html` (meta tag `google-signin-client_id`)
   - `lib/core/services/auth_service.dart` (trong `GoogleSignIn` constructor)

## Bước 5: Cập Nhật Code (Nếu cần)

Sau khi tạo Web OAuth Client, cập nhật Client ID mới:

### File: `web/index.html`
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

### File: `lib/core/services/auth_service.dart`
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
);
```

## Bước 6: Kích Hoạt Các API Cần Thiết

### 6.1. Google Sign-In API / Identity Toolkit API

1. Vào **APIs & Services** > **Library**
2. Tìm **Google Sign-In API** hoặc **Identity Toolkit API**
3. Click vào và chọn **Enable** (nếu chưa enable)

### 6.2. Google People API (QUAN TRỌNG - Cần cho Google Sign-In)

1. Vào **APIs & Services** > **Library**
2. Tìm **Google People API**
3. Click vào và chọn **Enable**
4. Hoặc truy cập trực tiếp: [Enable People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=595631319099)
5. Click **Enable** và đợi vài phút để API được kích hoạt

**Lưu ý**: Google People API là bắt buộc để Google Sign-In hoạt động. Nếu không enable, bạn sẽ gặp lỗi:
```
People API has not been used in project 595631319099 before or it is disabled
```

## Bước 7: Kiểm Tra Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project **sarah-learn-english**
3. Vào **Authentication** > **Sign-in method**
4. Kiểm tra **Google** đã được **Enable**
5. Nếu chưa, click **Google** > **Enable** > **Save**

## Xác Minh Cấu Hình

Sau khi hoàn thành các bước trên:

1. **Android**: Google Sign-In sẽ hoạt động với cả Debug và Release builds
2. **Web**: Google Sign-In sẽ hoạt động trên web với Client ID đã cấu hình

## Troubleshooting

### Lỗi: "ClientID not set"
- Kiểm tra `web/index.html` có meta tag `google-signin-client_id` chưa
- Kiểm tra `auth_service.dart` có truyền `clientId` vào `GoogleSignIn` chưa

### Lỗi: "SHA-1 certificate fingerprint not found"
- Đảm bảo đã thêm đúng SHA-1 vào OAuth client trong Google Cloud Console
- Đảm bảo package name khớp với `google-services.json`

### Lỗi: "Redirect URI mismatch"
- Kiểm tra Authorized redirect URIs trong Web OAuth client
- Đảm bảo domain khớp với nơi app được host

## Tài Liệu Tham Khảo

- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android/start)
- [Google Sign-In for Web](https://developers.google.com/identity/sign-in/web)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

