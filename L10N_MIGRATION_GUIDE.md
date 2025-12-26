# Hướng Dẫn Migration sang Flutter l10n

## ✅ Đã Hoàn Thành

1. ✅ Setup l10n trong `pubspec.yaml` (thêm `flutter_localizations` và `generate: true`)
2. ✅ Tạo `l10n.yaml` config file
3. ✅ Tạo ARB files cho 11 ngôn ngữ trong `lib/l10n/`
4. ✅ Generate l10n code (`flutter gen-l10n`)
5. ✅ Update `main.dart` để dùng generated localizations
6. ✅ Update `language_provider.dart`
7. ✅ Update `main_navigation.dart` và `settings_screen.dart`
8. ✅ Xóa custom delegate files

## ⏳ Cần Update Các Screens Còn Lại

Các screens cần update để dùng l10n:

### 1. Auth Screens
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/register_screen.dart`
- `lib/screens/auth/forgot_password_screen.dart`

### 2. Home & Learning Screens
- `lib/screens/home/home_screen.dart`
- `lib/screens/learning/level_selection_screen.dart`
- `lib/screens/learning/unit_list_screen.dart`
- `lib/screens/learning/lesson_detail_screen.dart`
- `lib/screens/learning/exercise_screen.dart`

### 3. Other Screens
- `lib/screens/practice/practice_screen.dart`
- `lib/screens/progress/progress_screen.dart`

## Cách Update

### Bước 1: Thay Import

**Cũ**:
```dart
import '../../core/localization/app_localizations.dart';
```

**Mới**:
```dart
import '../../l10n/app_localizations.dart';
```

### Bước 2: Thay Cách Sử Dụng

**Cũ**:
```dart
Text(AppLocalizations.of(context)?.welcome ?? 'Welcome')
```

**Mới**:
```dart
Text(AppLocalizations.of(context)!.welcome)
```

**Lưu ý**: Với l10n, `AppLocalizations.of(context)` không bao giờ null nếu đã setup đúng, nên dùng `!` thay vì `?`.

### Bước 3: Các Keys Đã Có Sẵn

Tất cả keys từ custom delegate đã được migrate sang ARB files:
- `appName`, `home`, `practice`, `progress`, `settings`
- `welcome`, `welcomeBack`, `whatToLearnToday`
- `login`, `register`, `email`, `password`, etc.
- `units`, `lessons`, `exercises`, `theory`, `examples`
- `submit`, `correct`, `incorrect`, `explanation`
- Và nhiều keys khác...

## Quick Find & Replace

### Pattern 1: Import
```
Find: import.*core/localization/app_localizations
Replace: import '../../l10n/app_localizations.dart';
```

### Pattern 2: Usage với null check
```
Find: AppLocalizations\.of\(context\)\?\.(\w+)
Replace: AppLocalizations.of(context)!.$1
```

## Files Đã Xóa

- ✅ `lib/core/localization/app_localizations.dart` (custom)
- ✅ `lib/core/localization/app_localizations_delegate.dart` (custom)

## Files Giữ Lại

- ✅ `lib/models/multilanguage_content.dart` - Helper cho Firestore content
- ✅ `lib/core/services/language_service.dart` - Service quản lý language selection
- ✅ `lib/providers/language_provider.dart` - Provider cho language state

## Database Multilanguage

**Lưu ý quan trọng**: Database vẫn cần multilanguage format như đã thiết kế:

```javascript
{
  title: {
    vi: "...",
    en: "...",
    ko: "...",
    // ... tất cả 11 ngôn ngữ
  }
}
```

Sử dụng `MultilanguageContent.getText()` để lấy content theo language hiện tại.

## Test Migration

1. Chạy `flutter pub get`
2. Chạy `flutter gen-l10n` (nếu cần)
3. Chạy app và test đổi language
4. Kiểm tra tất cả screens hiển thị đúng translations

## Troubleshooting

### Lỗi: "AppLocalizations.of(context) returns null"
- Đảm bảo đã thêm `AppLocalizations.localizationsDelegates` trong MaterialApp
- Đảm bảo đã chạy `flutter gen-l10n`

### Lỗi: "Undefined name 'xxx'"
- Kiểm tra ARB file có key đó không
- Chạy `flutter gen-l10n` lại

### Translations không đổi
- Restart app (không chỉ hot reload)
- Kiểm tra LanguageProvider đã update locale chưa

