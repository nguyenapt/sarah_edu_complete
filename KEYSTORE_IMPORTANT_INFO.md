# 🔐 Keystore Information - QUAN TRỌNG

## ⚠️ LƯU Ý BẢO MẬT

File keystore này RẤT QUAN TRỌNG! Nếu mất file này, bạn sẽ KHÔNG THỂ update app lên Google Play Store.

## 📋 Thông tin Keystore

- **File location**: `android/app/release.keystore`
- **Alias**: `release`
- **Store Password**: `sarah_release_2024`
- **Key Password**: `sarah_release_2024`
- **Validity**: 10000 days (~27 years)
- **Algorithm**: RSA 2048-bit

## 🔒 Bảo mật

1. **BACKUP ngay lập tức**:
   - Copy file `android/app/release.keystore` vào ít nhất 2 nơi an toàn (cloud storage, USB, external hard drive)
   - Lưu password vào password manager (LastPass, 1Password, etc.)

2. **KHÔNG commit file keystore lên Git**:
   - File `release.keystore` đã được thêm vào `.gitignore`
   - File `key.properties` có thể commit (nhưng nên cân nhắc)

3. **Thay đổi password** (nếu muốn):
   ```bash
   keytool -storepasswd -keystore app/release.keystore
   keytool -keypasswd -alias release -keystore app/release.keystore
   ```

## 📱 Sử dụng

File `key.properties` đã được cấu hình sẵn. Khi build release:

```bash
flutter build appbundle --release
# hoặc
flutter build apk --release
```

File sẽ được tự động sign với keystore này.

## 🔄 Tạo keystore mới (nếu cần)

Nếu muốn tạo keystore mới với password khác:

```bash
cd android
keytool -genkey -v -keystore app/release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

Sau đó cập nhật `key.properties` với password mới.

## 📝 Thông tin Certificate

Để xem thông tin certificate:

```bash
keytool -list -v -keystore app/release.keystore -alias release
```

---

**NGÀY TẠO**: $(Get-Date -Format "yyyy-MM-dd")
**LƯU Ý**: Giữ thông tin này ở nơi an toàn và KHÔNG chia sẻ với người khác!




