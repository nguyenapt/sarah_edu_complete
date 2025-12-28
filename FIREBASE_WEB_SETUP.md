# Hướng Dẫn Lấy Web App Configuration từ Firebase

## Để lấy Web App ID và cấu hình Web:

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project **sarah-learn-english**
3. Vào **Project Settings** (biểu tượng bánh răng)
4. Scroll xuống phần **Your apps**
5. Nếu chưa có Web app, click **Add app** > chọn **Web** (biểu tượng `</>`)
6. Đặt tên app (ví dụ: "Sarah Edu Web")
7. Click **Register app**
8. Copy các thông tin:
   - **apiKey**: Đã có trong google-services.json
   - **appId**: Có dạng `1:595631319099:web:xxxxx`
   - **messagingSenderId**: `595631319099`
   - **projectId**: `sarah-learn-english`
   - **authDomain**: `sarah-learn-english.firebaseapp.com`
   - **storageBucket**: `sarah-learn-english.firebasestorage.app`

9. Cập nhật vào `lib/firebase_options.dart` trong phần `web`

## Web Client ID cho Google Sign-In

Web Client ID đã được cấu hình:
- **Client ID**: `595631319099-bmkhfmrtfsqueanp0ku245iulrjn6v2e.apps.googleusercontent.com`
- Đã được thêm vào:
  - `web/index.html` (meta tag)
  - `lib/core/services/auth_service.dart` (GoogleSignIn clientId)

