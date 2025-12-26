# Firestore Security Rules - Sarah Edu Complete

## Vấn Đề Hiện Tại

App đang gặp lỗi `permission-denied` khi load levels vì Security Rules chưa cho phép đọc dữ liệu công khai.

## Giải Pháp

Cập nhật Firestore Security Rules để:
1. **Cho phép đọc công khai** các collections: levels, units, lessons, exercises (không cần login)
2. **Yêu cầu authentication** cho user data: users, userProgress

## Security Rules Cần Copy vào Firebase Console

### Bước 1: Vào Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Firestore Database** > **Rules** tab

### Bước 2: Copy và Paste Rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // ============================================
    // PUBLIC COLLECTIONS (Readable by everyone)
    // ============================================
    
    // Levels - Public read, no write
    match /levels/{levelId} {
      allow read: if true; // Anyone can read
      allow write: if false; // Only admin (via Cloud Functions)
    }
    
    // Units - Public read, no write
    match /units/{unitId} {
      allow read: if true; // Anyone can read
      allow write: if false; // Only admin
    }
    
    // Lessons - Public read, no write
    match /lessons/{lessonId} {
      allow read: if true; // Anyone can read
      allow write: if false; // Only admin
    }
    
    // Exercises - Public read, no write
    match /exercises/{exerciseId} {
      allow read: if true; // Anyone can read
      allow write: if false; // Only admin
    }
    
    // ============================================
    // USER-SPECIFIC COLLECTIONS (Require auth)
    // ============================================
    
    // Users - Read own data, write own data
    match /users/{userId} {
      allow read: if isAuthenticated(); // Any authenticated user can read
      allow create: if isOwner(userId); // Can only create own document
      allow update: if isOwner(userId); // Can only update own document
      allow delete: if false; // No one can delete
    }
    
    // User Progress - Only owner can read/write
    match /userProgress/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }
    
    // AI Practice Sessions - Only owner can read/write
    match /aiPractice/{sessionId} {
      allow read: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && 
        request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Bước 3: Publish Rules
1. Click **Publish** để lưu rules
2. Đợi vài giây để rules được apply

## Giải Thích Rules

### Public Collections (levels, units, lessons, exercises)
- `allow read: if true` - Bất kỳ ai cũng có thể đọc (kể cả chưa đăng nhập)
- `allow write: if false` - Không ai có thể ghi (chỉ admin qua Cloud Functions)

### User Collections (users, userProgress)
- `allow read: if isOwner(userId)` - Chỉ user đó mới đọc được
- `allow write: if isOwner(userId)` - Chỉ user đó mới ghi được

### AI Practice
- Chỉ user tạo session mới có thể đọc/ghi session đó

## Test Rules

Sau khi publish rules, test bằng cách:

1. **Test Public Read** (không cần login):
   - Mở app
   - Vào Home screen
   - Levels sẽ load được

2. **Test User Write** (cần login):
   - Đăng nhập
   - Làm bài tập
   - Progress sẽ được lưu

## Lưu Ý Quan Trọng

1. **Security**: Rules này cho phép đọc công khai levels/units/lessons/exercises. Nếu bạn muốn bảo vệ nội dung, có thể thay đổi thành:
   ```javascript
   allow read: if isAuthenticated();
   ```

2. **Admin Access**: Để admin có thể ghi data, bạn cần:
   - Tạo Cloud Functions với admin SDK
   - Hoặc thêm custom claim cho admin users

3. **Testing**: Luôn test rules trong Firebase Console > Rules > Rules Playground

## Troubleshooting

### Vẫn bị permission-denied?
1. Kiểm tra đã publish rules chưa
2. Đợi 1-2 phút để rules propagate
3. Restart app
4. Kiểm tra lại rules trong Console

### Muốn bảo vệ nội dung hơn?
Thay đổi public collections thành:
```javascript
allow read: if isAuthenticated();
```
Nhưng điều này sẽ yêu cầu user phải đăng nhập để xem levels.


