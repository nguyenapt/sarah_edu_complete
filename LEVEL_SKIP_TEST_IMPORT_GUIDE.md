# Hướng Dẫn Import Level Skip Test Questions lên Firestore

## Vấn đề
Bạn đã tạo các file JSON (`level_skip_test_A2.json`, `level_skip_test_B1.json`, etc.) nhưng chưa import lên Firestore collection `levelSkipTests`.

## Cách Import: Manual (Khuyến nghị cho lần đầu)

### Bước 1: Vào Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Firestore Database**

### Bước 2: Tạo Collection `levelSkipTests`
1. Click **Start collection**
2. Collection ID: `levelSkipTests`
3. Click **Next**

### Bước 3: Import từng Question

Mỗi question trong file JSON sẽ là một **document** riêng trong collection.

#### Ví dụ: Import question đầu tiên từ `level_skip_test_A2.json`

**Document ID**: `lst_a2_001` (lấy từ key trong JSON)

**Fields** (copy từ object trong JSON):
- `category` (string): `grammar`
- `level` (string): `A2`
- `type` (string): `single_choice`
- `question` (map):
  - `en` (string): `Choose the correct form: I ___ to London last year.`
  - `vi` (string): `Chọn dạng đúng: Tôi ___ đến London năm ngoái.`
- `options` (array): `["go", "goes", "went", "going"]`
- `correctAnswers` (array): `["went"]`
- `explanation` (map):
  - `en` (string): `Use past tense 'went' for actions in the past.`
  - `vi` (string): `Dùng quá khứ 'went' cho hành động trong quá khứ.`
- `points` (number): `5`
- `difficulty` (string): `easy`

**Cách thêm Map (question, explanation)**:
1. Click **Add field**
2. Field name: `question`
3. Type: chọn **map**
4. Click vào map để mở rộng
5. Thêm field `en` (string) và `vi` (string) bên trong map

**Cách thêm Array (options, correctAnswers)**:
1. Click **Add field**
2. Field name: `options`
3. Type: chọn **array**
4. Click vào array để mở
5. Click **Add item** và nhập từng giá trị: `go`, `goes`, `went`, `going`

### Bước 4: Lặp lại cho tất cả questions

Lặp lại Bước 3 cho tất cả questions trong file:
- `level_skip_test_A2.json` → 15 questions (lst_a2_001 đến lst_a2_015)
- `level_skip_test_B1.json` → 15 questions (lst_b1_001 đến lst_b1_015)
- `level_skip_test_B2.json` → 15 questions (lst_b2_001 đến lst_b2_015)
- `level_skip_test_C1.json` → 15 questions (lst_c1_001 đến lst_c1_015)
- `level_skip_test_C2.json` → 15 questions (lst_c2_001 đến lst_c2_015)

**Tổng cộng: 75 questions**

## Cách Import: Script (Nhanh hơn)

Nếu bạn muốn import nhanh bằng script, có thể dùng Node.js script sau:

### Tạo file `import_level_skip_tests.js`:

```javascript
const admin = require('firebase-admin');
const fs = require('fs');

// Khởi tạo Firebase Admin SDK
const serviceAccount = require('./path-to-your-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importLevelSkipTests() {
  const files = [
    'level_skip_test_A2.json',
    'level_skip_test_B1.json',
    'level_skip_test_B2.json',
    'level_skip_test_C1.json',
    'level_skip_test_C2.json'
  ];

  for (const file of files) {
    console.log(`Importing ${file}...`);
    const jsonData = JSON.parse(fs.readFileSync(file, 'utf8'));
    const questions = jsonData.levelSkipTest;

    for (const [questionId, questionData] of Object.entries(questions)) {
      await db.collection('levelSkipTests').doc(questionId).set(questionData);
      console.log(`  ✓ Imported ${questionId}`);
    }
  }

  console.log('Done!');
}

importLevelSkipTests().catch(console.error);
```

### Chạy script:
```bash
npm install firebase-admin
node import_level_skip_tests.js
```

## Kiểm tra sau khi import

1. Vào Firestore Console
2. Mở collection `levelSkipTests`
3. Kiểm tra:
   - Có 75 documents (15 questions × 5 levels)
   - Mỗi document có đầy đủ fields: `category`, `level`, `type`, `question`, `options`, `correctAnswers`, `explanation`, `points`, `difficulty`
   - Field `level` phải match với level trong tên file (A2, B1, B2, C1, C2)

## Test trong App

Sau khi import xong:
1. Restart app
2. Click nút "Skip to A2" trong Home screen
3. App sẽ load được questions từ Firestore

## Lưu ý

- Document ID phải chính xác (lst_a2_001, lst_a2_002, etc.)
- Field `level` phải là uppercase (A2, B1, B2, C1, C2) để match với query trong code
- Field `type` phải là snake_case (single_choice, multiple_choice, fill_blank)
