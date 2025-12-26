# Troubleshooting - Màn Hình Trắng

## Vấn Đề: Màn hình trắng khi khởi động app

### Nguyên nhân có thể:

1. **Firebase chưa được khởi tạo đúng**
2. **File google-services.json thiếu hoặc sai**
3. **Lỗi trong AuthProvider khi load user data**
4. **Exception không được catch**

## Các Bước Kiểm Tra

### 1. Kiểm tra Firebase Setup

```bash
# Kiểm tra file google-services.json
ls android/app/google-services.json

# Nếu không có, tải từ Firebase Console và đặt vào đúng vị trí
```

### 2. Kiểm tra Logs

Chạy app với verbose logging:
```bash
flutter run -v
```

Tìm các lỗi liên quan đến:
- `Firebase.initializeApp`
- `AuthProvider`
- `Firestore`

### 3. Kiểm tra Firebase Console

1. Vào Firebase Console
2. Kiểm tra Authentication đã enable chưa
3. Kiểm tra Firestore Database đã tạo chưa
4. Kiểm tra Security Rules

### 4. Test Firebase Connection

Thêm vào `main.dart` để test:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  runApp(const MyApp());
}
```

## Giải Pháp Đã Áp Dụng

### 1. Thêm Error Handling trong main.dart
- Try-catch cho Firebase initialization
- Debug print để track lỗi

### 2. Cải thiện AuthProvider
- Set initial loading state
- Thêm error handling cho auth state listener
- Handle onError trong stream

### 3. Cải thiện AuthWrapper
- Đơn giản hóa logic loading
- Đảm bảo luôn có UI hiển thị

## Debug Steps

### Bước 1: Kiểm tra Console Logs

Mở terminal và chạy:
```bash
flutter run
```

Xem logs để tìm:
- `Error initializing Firebase`
- `Error in auth state listener`
- `Error loading user data`

### Bước 2: Test Firebase Connection

Tạo file test `test_firebase.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void testFirebase() async {
  try {
    await Firebase.initializeApp();
    print('Firebase initialized');
    
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('levels').limit(1).get();
    print('Firestore connected: ${snapshot.docs.length} documents');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Bước 3: Kiểm tra google-services.json

Đảm bảo file có:
- Đúng package name
- Đúng project_id
- Đúng SHA-1 (cho Google Sign-In)

### Bước 4: Kiểm tra Dependencies

```bash
flutter pub get
flutter clean
flutter pub get
```

## Quick Fix

Nếu vẫn bị màn hình trắng, thử:

1. **Tạm thời bypass AuthWrapper**:

```dart
// Trong main.dart, thay AuthWrapper bằng LoginScreen
home: const LoginScreen(),
```

2. **Kiểm tra có exception không**:

Thêm vào `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
  };
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase Error: $e');
  }
  
  runApp(const MyApp());
}
```

3. **Test với Simple Screen**:

Tạo màn hình test đơn giản:
```dart
class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test')),
      body: Center(child: Text('App is working!')),
    );
  }
}
```

Thay `home: const AuthWrapper()` bằng `home: const TestScreen()` để xem app có chạy không.

## Nếu Vẫn Không Được

1. Kiểm tra Flutter version: `flutter --version`
2. Kiểm tra Firebase packages version trong `pubspec.yaml`
3. Xem full error logs trong terminal
4. Thử chạy trên device khác hoặc emulator

## Liên Hệ

Nếu vẫn gặp vấn đề, cung cấp:
- Full error logs từ terminal
- Flutter version
- Firebase packages versions
- Screenshot của màn hình trắng (nếu có)


