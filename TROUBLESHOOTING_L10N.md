# Troubleshooting l10n Issues

## Vấn Đề: "Cannot find file app_localizations.dart"

### Giải Pháp 1: Restart IDE
1. Đóng IDE hoàn toàn
2. Mở lại IDE
3. IDE sẽ tự động detect generated files

### Giải Pháp 2: Invalidate Caches (VS Code / Android Studio)
**VS Code:**
- `Ctrl+Shift+P` → "Dart: Restart Analysis Server"

**Android Studio:**
- File → Invalidate Caches / Restart

### Giải Pháp 3: Manual Regenerate
```bash
flutter clean
flutter pub get
flutter gen-l10n
```

### Giải Pháp 4: Kiểm Tra l10n.yaml
Đảm bảo `l10n.yaml` có:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### Giải Pháp 5: Kiểm Tra pubspec.yaml
Đảm bảo có:
```yaml
flutter:
  generate: true
```

### Giải Pháp 6: Kiểm Tra File Tồn Tại
File phải ở: `lib/l10n/app_localizations.dart`

Nếu không có, chạy:
```bash
flutter gen-l10n
```

### Giải Pháp 7: Rebuild Project
```bash
flutter clean
flutter pub get
flutter gen-l10n
# Sau đó restart IDE
```

## Lưu Ý

- Generated files nằm trong `lib/l10n/` (không phải `.dart_tool`)
- Không commit generated files vào git (thêm vào `.gitignore`)
- Mỗi khi thay đổi ARB files, cần chạy `flutter gen-l10n`


