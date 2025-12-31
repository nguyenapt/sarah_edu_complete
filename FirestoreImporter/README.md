# Firestore Data Importer

Ứng dụng Windows Forms .NET để import dữ liệu (Units, Lessons, Exercises) lên Firestore.

## Yêu cầu

- .NET 9.0 hoặc cao hơn
- Firebase Project với Firestore đã được kích hoạt
- Firebase Service Account Credentials (file JSON)

## Cài đặt

1. Clone hoặc tải project về
2. Mở terminal trong thư mục `FirestoreImporter/FirestoreImporter`
3. Restore packages:
   ```bash
   dotnet restore
   ```
4. Build project:
   ```bash
   dotnet build
   ```
5. Chạy ứng dụng:
   ```bash
   dotnet run
   ```

## Cách sử dụng

### 1. Lấy Firebase Credentials

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key**
5. Lưu file JSON về máy (đây là credentials file)

### 2. Chuẩn bị dữ liệu JSON

File JSON cần có cấu trúc như sau:

```json
{
  "levels": {
    "A1": {
      "name": "Beginner A1",
      "description": "Cấp độ cơ bản",
      "order": 1,
      "totalUnits": 5,
      "estimatedHours": 40
    }
  },
  "units": {
    "unit_a1_1": {
      "levelId": "A1",
      "title": {
        "en": "Unit 1: Present Simple",
        "vi": "Unit 1: Thì hiện tại đơn"
      },
      "description": {
        "en": "Learn about present simple",
        "vi": "Học về thì hiện tại đơn"
      },
      "order": 1,
      "estimatedTime": 60,
      "lessons": ["lesson_a1_1_1", "lesson_a1_1_2"],
      "prerequisites": []
    }
  },
  "lessons": {
    "lesson_a1_1_1": {
      "unitId": "unit_a1_1",
      "levelId": "A1",
      "title": {
        "en": "Present Simple - Affirmative",
        "vi": "Thì hiện tại đơn - Khẳng định"
      },
      "type": "grammar",
      "order": 1,
      "content": {
        "theory": {
          "title": {
            "en": "Present Simple"
          },
          "description": {
            "en": "Description here"
          },
          "examples": [
            {
              "sentence": "I go to school every day.",
              "explanation": {
                "en": "I go to school every day",
                "vi": "Tôi đi học mỗi ngày"
              }
            }
          ]
        },
        "exercises": ["exercise_a1_1_1_1"]
      }
    }
  },
  "exercises": {
    "exercise_a1_1_1_1": {
      "lessonId": "lesson_a1_1_1",
      "unitId": "unit_a1_1",
      "levelId": "A1",
      "type": "single_choice",
      "question": "Choose the correct form: I ___ to school every day.",
      "points": 10,
      "timeLimit": 30,
      "difficulty": "easy",
      "explanation": "Với chủ ngữ 'I', ta dùng 'go'",
      "content": {
        "options": ["go", "goes", "going", "went"],
        "correctAnswers": ["go"]
      }
    }
  }
}
```

Bạn có thể sử dụng file `firestore_sample_data.json` trong thư mục gốc của project làm mẫu.

### 3. Sử dụng ứng dụng

1. **Nhập Project ID**: Nhập Firebase Project ID của bạn
2. **Chọn Credentials File**: Click nút "..." để chọn file credentials JSON
3. **Test Connection**: Click "Test Connection" để kiểm tra kết nối
4. **Chọn JSON File**: Click nút "..." để chọn file dữ liệu JSON
5. **Chọn loại dữ liệu**: Tick vào các checkbox để chọn loại dữ liệu muốn import (Levels, Units, Lessons, Exercises)
6. **Start Import**: Click "Start Import" để bắt đầu import
7. **Xem log**: Theo dõi quá trình import trong khung log bên phải

## Cấu trúc Project

```
FirestoreImporter/
├── FirestoreImporter/
│   ├── Models/
│   │   ├── UnitModel.cs
│   │   ├── LessonModel.cs
│   │   ├── ExerciseModel.cs
│   │   └── ImportData.cs
│   ├── Services/
│   │   ├── FirestoreService.cs
│   │   └── JsonParser.cs
│   ├── Form1.cs
│   ├── Form1.Designer.cs
│   └── Program.cs
└── README.md
```

## Lưu ý

- Đảm bảo Firestore đã được kích hoạt trong Firebase Console
- File credentials phải có quyền truy cập Firestore
- Dữ liệu sẽ được ghi đè nếu document ID đã tồn tại
- Import sẽ mất thời gian tùy thuộc vào số lượng dữ liệu

## Troubleshooting

### Lỗi "Firestore chưa được khởi tạo"
- Đảm bảo đã nhập Project ID và test connection trước khi import

### Lỗi "Permission denied"
- Kiểm tra file credentials có đúng không
- Đảm bảo Service Account có quyền Firestore Admin

### Lỗi "Invalid JSON"
- Kiểm tra cấu trúc JSON file có đúng format không
- Sử dụng JSON validator để kiểm tra

## License

MIT


