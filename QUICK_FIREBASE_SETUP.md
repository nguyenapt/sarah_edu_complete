# Hướng Dẫn Nhanh - Tạo Data trong Firebase

## 🚀 Cách Nhanh Nhất: Copy-Paste từng Document

### Bước 1: Tạo Collection "levels"

1. Vào Firestore Database
2. Click **Start collection**
3. Collection ID: `levels`
4. Click **Next**

#### Document 1: A1
- **Document ID**: `A1` (tự nhập)
- Click **Add field** và thêm từng field:

| Field Name | Type | Value |
|------------|------|-------|
| name | string | Beginner A1 |
| description | string | Cấp độ cơ bản nhất, dành cho người mới bắt đầu học tiếng Anh |
| order | number | 1 |
| totalUnits | number | 5 |
| estimatedHours | number | 40 |

Click **Save**

#### Lặp lại cho A2, B1, B2, C1, C2 (xem file `FIREBASE_DATA_SETUP.md`)

---

### Bước 2: Tạo Collection "units"

1. Click **Start collection**
2. Collection ID: `units`

#### Document: unit_a1_1
- **Document ID**: `unit_a1_1`

| Field Name | Type | Value |
|------------|------|-------|
| levelId | string | A1 |
| title | string | Unit 1: Present Simple |
| description | string | Học về thì hiện tại đơn - cách dùng cơ bản nhất trong tiếng Anh |
| order | number | 1 |
| estimatedTime | number | 60 |
| lessons | array | Thêm: `lesson_a1_1_1`, `lesson_a1_1_2` |
| prerequisites | array | (để trống) |

**Cách thêm Array**:
1. Click **Add field**
2. Field name: `lessons`
3. Type: chọn **array**
4. Click vào array để mở
5. Click **Add item** và nhập: `lesson_a1_1_1`
6. Click **Add item** lần nữa và nhập: `lesson_a1_1_2`

---

### Bước 3: Tạo Collection "lessons"

#### Document: lesson_a1_1_1

**Fields đơn giản trước**:
- `unitId` (string): `unit_a1_1`
- `levelId` (string): `A1`
- `title` (string): `Present Simple - Affirmative`
- `type` (string): `grammar`
- `order` (number): `1`

**Field phức tạp: content (map)**

1. Click **Add field**
2. Field name: `content`
3. Type: **map**
4. Click vào map `content` để mở rộng

**Trong map content, thêm:**

5. Field: `theory` (type: **map**)
   - Click vào map `theory` để mở
   - Thêm các fields:
     - `title` (string): `Present Simple`
     - `description` (string): `Thì hiện tại đơn (Present Simple) được dùng để diễn tả thói quen, sự thật hiển nhiên, và các hành động lặp đi lặp lại.`
     - `usage` (string): `Dùng để diễn tả: thói quen hàng ngày, sự thật hiển nhiên, lịch trình cố định`
     - `forms` (type: **map**):
       - Trong `forms`, thêm:
         - `affirmative` (string): `Subject + Verb (s/es cho ngôi thứ 3 số ít)`
         - `negative` (string): `Subject + do/does + not + Verb`
         - `interrogative` (string): `Do/Does + Subject + Verb?`
     - `examples` (type: **array**):
       - Item 1 (type: **map**):
         - `sentence` (string): `I go to school every day.`
         - `explanation` (string): `Tôi đi học mỗi ngày`
       - Item 2 (type: **map**):
         - `sentence` (string): `She works in a hospital.`
         - `explanation` (string): `Cô ấy làm việc ở bệnh viện`

6. Field: `exercises` (type: **array**)
   - Thêm items: `exercise_a1_1_1_1`, `exercise_a1_1_1_2`, `exercise_a1_1_1_3`

---

### Bước 4: Tạo Collection "exercises"

#### Document: exercise_a1_1_1_1

**Fields đơn giản**:
- `lessonId` (string): `lesson_a1_1_1`
- `unitId` (string): `unit_a1_1`
- `levelId` (string): `A1`
- `type` (string): `single_choice`
- `question` (string): `Choose the correct form: I ___ to school every day.`
- `points` (number): `10`
- `timeLimit` (number): `30`
- `difficulty` (string): `easy`
- `explanation` (string): `Với chủ ngữ 'I', ta dùng 'go' (không thêm 's')`

**Field: content (map)**
- Trong map `content`:
  - `options` (array): `go`, `goes`, `going`, `went`
  - `correctAnswers` (array): `go`

---

## 💡 Mẹo Nhanh

### Tạo nhiều Documents cùng lúc:
1. Tạo document đầu tiên
2. Click vào document đó
3. Click **Duplicate** (nếu có) hoặc copy fields
4. Tạo document mới và paste

### Tạo Array nhanh:
- Với array of strings đơn giản, chỉ cần:
  1. Tạo field type array
  2. Click vào array
  3. Nhập text và Enter
  4. Lặp lại

### Tạo Map lồng nhau:
- Luôn nhớ: Click vào map để mở rộng trước khi thêm fields bên trong

---

## ⚡ Script Tự Động (Nâng cao)

Nếu bạn biết JavaScript, có thể dùng Firebase Admin SDK để import:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Import levels
const levels = require('./firestore_sample_data.json').levels;
for (const [id, data] of Object.entries(levels)) {
  await db.collection('levels').doc(id).set(data);
}

// Tương tự cho units, lessons, exercises...
```

---

## ✅ Checklist Nhanh

Sau khi tạo xong, kiểm tra:

- [ ] Collection `levels` có 6 documents (A1-C2)
- [ ] Collection `units` có ít nhất 2 units
- [ ] Collection `lessons` có ít nhất 2 lessons
- [ ] Collection `exercises` có ít nhất 4 exercises
- [ ] Tất cả fields đúng type (string, number, array, map)
- [ ] Arrays có đủ items
- [ ] Maps lồng nhau đã mở rộng đúng

---

## 🆘 Gặp Vấn Đề?

1. **Không thấy type "map"**: Đảm bảo đang dùng Firestore (không phải Realtime Database)
2. **Array không lưu được**: Click vào array để mở, sau đó mới add items
3. **Map lồng nhau không hiện**: Click vào map cha để mở rộng trước
4. **Quên field nào đó**: Xem lại `FIREBASE_DATA_SETUP.md` để check

---

## 📱 Test Ngay

Sau khi tạo xong, test trong app Flutter:

```dart
final firestoreService = FirestoreService();
final levels = await firestoreService.getLevels();
print('Levels: ${levels.length}'); // Should be 6
```


