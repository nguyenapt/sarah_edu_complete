# Hướng Dẫn Setup - Sarah Edu Complete

## 1. Cài Đặt Dependencies

Chạy lệnh sau để cài đặt tất cả các packages:

```bash
flutter pub get
```

## 2. Setup Firebase

### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Thêm Android/iOS app vào project

### Bước 2: Cấu hình Android

1. Tải file `google-services.json` từ Firebase Console
2. Đặt file vào `android/app/google-services.json`
3. Cập nhật `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```
4. Cập nhật `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Bước 3: Cấu hình iOS

1. Tải file `GoogleService-Info.plist` từ Firebase Console
2. Đặt file vào `ios/Runner/GoogleService-Info.plist`
3. Mở Xcode và thêm file vào project

### Bước 4: Enable Authentication

Trong Firebase Console:
1. Vào **Authentication** > **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** (cần cấu hình OAuth consent screen)

### Bước 5: Tạo Firestore Database

1. Vào **Firestore Database** > **Create database**
2. Chọn **Start in test mode** (sau đó cập nhật security rules)
3. Chọn location gần nhất

### Bước 6: Cấu hình Security Rules

Copy security rules từ `ARCHITECTURE_DESIGN.md` vào Firestore Rules trong Firebase Console.

## 3. Setup Azure Speech Service (Tùy chọn)

### Bước 1: Tạo Azure Resource

1. Truy cập [Azure Portal](https://portal.azure.com/)
2. Tạo **Speech Services** resource
3. Lấy **Subscription Key** và **Region**

### Bước 2: Cấu hình trong App

Tạo file `lib/core/config/azure_config.dart`:

```dart
class AzureConfig {
  static const String subscriptionKey = 'YOUR_SUBSCRIPTION_KEY';
  static const String region = 'YOUR_REGION'; // e.g., 'eastus'
}
```

**LƯU Ý**: Không commit file này lên Git! Thêm vào `.gitignore` và sử dụng environment variables hoặc secure storage.

## 4. Setup OpenAI API (Tùy chọn)

### Bước 1: Lấy API Key

1. Truy cập [OpenAI Platform](https://platform.openai.com/)
2. Tạo API key mới

### Bước 2: Cấu hình trong App

Tạo file `lib/core/config/openai_config.dart`:

```dart
class OpenAIConfig {
  static const String apiKey = 'YOUR_API_KEY';
  static const String baseUrl = 'https://api.openai.com/v1';
}
```

**LƯU Ý**: Tương tự Azure, không commit API key. Sử dụng Cloud Functions hoặc secure storage.

## 5. Tạo Dữ Liệu Mẫu trong Firestore

### Tạo Levels

```javascript
// Collection: levels
{
  id: "A1",
  name: "Beginner A1",
  description: "Cấp độ cơ bản nhất",
  order: 1,
  totalUnits: 5,
  estimatedHours: 40,
  iconUrl: null
}
```

### Tạo Units

```javascript
// Collection: units
{
  id: "unit_a1_1",
  levelId: "A1",
  title: "Unit 1: Present Simple",
  description: "Học về thì hiện tại đơn",
  order: 1,
  estimatedTime: 60,
  lessons: ["lesson_1", "lesson_2"],
  prerequisites: []
}
```

### Tạo Lessons

```javascript
// Collection: lessons
{
  id: "lesson_1",
  unitId: "unit_a1_1",
  levelId: "A1",
  title: "Present Simple - Affirmative",
  type: "grammar",
  content: {
    theory: {
      title: "Present Simple",
      description: "Thì hiện tại đơn dùng để...",
      examples: [
        {
          sentence: "I go to school every day.",
          explanation: "Tôi đi học mỗi ngày",
          audioUrl: null
        }
      ],
      usage: "Dùng để diễn tả thói quen, sự thật hiển nhiên",
      forms: {
        affirmative: "Subject + Verb(s/es)",
        negative: "Subject + do/does + not + Verb",
        interrogative: "Do/Does + Subject + Verb?"
      }
    },
    exercises: ["exercise_1", "exercise_2"]
  },
  order: 1
}
```

### Tạo Exercises

```javascript
// Collection: exercises
{
  id: "exercise_1",
  lessonId: "lesson_1",
  unitId: "unit_a1_1",
  levelId: "A1",
  type: "single_choice",
  question: "Choose the correct form: I ___ to school every day.",
  content: {
    options: ["go", "goes", "going", "went"],
    correctAnswers: ["go"]
  },
  points: 10,
  timeLimit: 30,
  difficulty: "easy",
  explanation: "Với chủ ngữ 'I', ta dùng 'go' (không thêm 's')"
}
```

## 6. Chạy Ứng Dụng

```bash
flutter run
```

## 7. Cấu Trúc Thư Mục Đã Tạo

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── firebase_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── services/
│       ├── firestore_service.dart
│       └── auth_service.dart
├── models/
│   ├── user_model.dart
│   ├── level_model.dart
│   ├── unit_model.dart
│   ├── lesson_model.dart
│   ├── exercise_model.dart
│   └── progress_model.dart
└── screens/
    └── home/
        └── home_screen.dart
```

## 8. Next Steps

1. **Hoàn thiện Authentication UI**: Tạo màn hình login/register
2. **Implement Navigation**: Sử dụng go_router hoặc Navigator
3. **Tích hợp State Management**: Sử dụng Provider hoặc Riverpod
4. **Tạo Exercise Widgets**: Single choice, multiple choice, fill blank, matching
5. **Implement Progress Tracking**: Lưu và cập nhật tiến độ học tập
6. **Tích hợp AI Services**: OpenAI và Azure Speech
7. **Tạo Weak Points Analysis**: Phân tích điểm yếu từ exercise history

## 9. Troubleshooting

### Lỗi Firebase không kết nối được
- Kiểm tra file `google-services.json` / `GoogleService-Info.plist` đã đặt đúng chưa
- Kiểm tra package name/bundle ID khớp với Firebase project
- Chạy `flutter clean` và `flutter pub get`

### Lỗi Authentication
- Kiểm tra Authentication methods đã enable trong Firebase Console
- Kiểm tra SHA-1 fingerprint cho Android (nếu dùng Google Sign-In)

### Lỗi Firestore permissions
- Kiểm tra Security Rules đã cấu hình đúng chưa
- Kiểm tra user đã đăng nhập chưa

## 10. Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Azure Speech Service](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/)


