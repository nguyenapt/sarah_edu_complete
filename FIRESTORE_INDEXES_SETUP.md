# Hướng Dẫn Tạo Firestore Indexes

## Vấn Đề

Firestore yêu cầu **composite indexes** cho các queries phức tạp (filter + orderBy). Khi query thiếu index, bạn sẽ thấy lỗi:
```
The query requires an index. You can create it here: [link]
```

## Cách 1: Tạo Index Tự Động (Nhanh Nhất)

### Khi gặp lỗi trong app:
1. **Click vào link** trong error message
2. Firebase Console sẽ mở với form tạo index đã được điền sẵn
3. Click **Create Index**
4. Đợi 1-2 phút để index được build
5. Restart app

## Cách 2: Tạo Index Thủ Công

### Bước 1: Vào Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project **sarah-learn-english**
3. Vào **Firestore Database** > **Indexes** tab
4. Click **Create Index**

### Bước 2: Tạo Indexes Cần Thiết

#### Index 1: Units Collection
**Collection ID**: `units`

**Fields to index**:
1. `levelId` - Ascending
2. `order` - Ascending

**Query scope**: Collection

Click **Create**

#### Index 2: Lessons Collection
**Collection ID**: `lessons`

**Fields to index**:
1. `unitId` - Ascending
2. `order` - Ascending

**Query scope**: Collection

Click **Create**

#### Index 3: Exercises Collection
**Collection ID**: `exercises`

**Fields to index**:
1. `lessonId` - Ascending

**Query scope**: Collection

Click **Create**

#### Index 4: UserProgress Collection (Optional - cho tương lai)
**Collection ID**: `userProgress`

**Fields to index**:
1. `exerciseHistory.completedAt` - Descending

**Query scope**: Collection

Click **Create**

## Indexes Cần Tạo (Tổng Hợp)

### 1. Units Index
```
Collection: units
Fields:
  - levelId (Ascending)
  - order (Ascending)
```

### 2. Lessons Index
```
Collection: lessons
Fields:
  - unitId (Ascending)
  - order (Ascending)
```

### 3. Exercises Index
```
Collection: exercises
Fields:
  - lessonId (Ascending)
```

### 4. UserProgress Index (Optional)
```
Collection: userProgress
Fields:
  - exerciseHistory.completedAt (Descending)
```

## Cách 3: Tạo Index bằng Firebase CLI (Nâng cao)

### Bước 1: Tạo file `firestore.indexes.json`

Tạo file trong thư mục root của project:

```json
{
  "indexes": [
    {
      "collectionGroup": "units",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "levelId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "order",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "unitId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "order",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "exercises",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "lessonId",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

### Bước 2: Deploy indexes

```bash
firebase deploy --only firestore:indexes
```

## Kiểm Tra Index Status

1. Vào **Firestore Database** > **Indexes** tab
2. Xem status của các indexes:
   - **Building** - Đang tạo (đợi vài phút)
   - **Enabled** - Đã sẵn sàng
   - **Error** - Có lỗi (xem logs)

## Lưu Ý Quan Trọng

1. **Thời gian build**: Indexes có thể mất 1-5 phút để build, tùy vào số lượng documents
2. **Chi phí**: Indexes không tốn thêm chi phí, nhưng tốn storage
3. **Tự động tạo**: Firebase sẽ tự động đề xuất index khi query thiếu
4. **Best practice**: Tạo indexes trước khi deploy app

## Troubleshooting

### Index vẫn đang "Building"?
- Đợi thêm vài phút
- Kiểm tra số lượng documents (nhiều documents = lâu hơn)
- Refresh trang Firebase Console

### Vẫn bị lỗi sau khi tạo index?
1. Đảm bảo index status là "Enabled"
2. Restart app hoàn toàn (không chỉ hot reload)
3. Kiểm tra query trong code có đúng không
4. Xem lại error message để biết cần index nào

### Muốn xóa index?
1. Vào **Indexes** tab
2. Click vào index cần xóa
3. Click **Delete**

## Quick Fix cho Lỗi Hiện Tại

**Lỗi**: `Error fetching units: The query requires an index`

**Giải pháp nhanh**:
1. Click vào link trong error message
2. Hoặc vào Firebase Console > Firestore > Indexes
3. Tạo index với:
   - Collection: `units`
   - Fields: `levelId` (Ascending), `order` (Ascending)
4. Đợi index build xong
5. Restart app

## Sau Khi Tạo Index

1. Đợi index status chuyển sang "Enabled"
2. Restart app (không chỉ hot reload)
3. Test lại query
4. Nếu vẫn lỗi, kiểm tra xem có cần index khác không


