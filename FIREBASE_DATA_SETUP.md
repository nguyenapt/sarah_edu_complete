# Hướng Dẫn Tạo Collections trong Firebase Firestore

## 📋 Tổng Quan

Bạn cần tạo 7 collections chính:
1. **users** - Thông tin người dùng
2. **userProgress** - Tiến độ học tập
3. **levels** - Các cấp độ (A1-C2)
4. **units** - Các unit trong mỗi level
5. **lessons** - Các bài học
6. **exercises** - Các bài tập
7. **aiPractice** - Sessions luyện tập AI (tùy chọn, sẽ tự động tạo khi cần)

## 🚀 Cách 1: Tạo Thủ Công trong Firebase Console

### Bước 1: Truy cập Firestore

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Firestore Database** ở menu bên trái
4. Click **Start collection** (nếu chưa có collection nào)

---

## 📚 Collection 1: levels

### Tạo Collection "levels"

1. Click **Start collection** hoặc **Add collection**
2. Collection ID: `levels`
3. Click **Next**

### Tạo Document đầu tiên: A1

**Document ID**: `A1` (nhập thủ công)

**Fields**:
```
name (string): "Beginner A1"
description (string): "Cấp độ cơ bản nhất, dành cho người mới bắt đầu học tiếng Anh"
order (number): 1
totalUnits (number): 5
estimatedHours (number): 40
iconUrl (string): null (để trống hoặc không thêm field này)
```

Click **Save**

### Tạo các Documents còn lại:

**A2**:
```
name (string): "Elementary A2"
description (string): "Cấp độ sơ cấp, mở rộng vốn từ và ngữ pháp cơ bản"
order (number): 2
totalUnits (number): 6
estimatedHours (number): 50
```

**B1**:
```
name (string): "Intermediate B1"
description (string): "Cấp độ trung cấp, có thể giao tiếp trong các tình huống quen thuộc"
order (number): 3
totalUnits (number): 7
estimatedHours (number): 60
```

**B2**:
```
name (string): "Upper Intermediate B2"
description (string): "Cấp độ trung cấp cao, giao tiếp tự tin trong hầu hết các tình huống"
order (number): 4
totalUnits (number): 8
estimatedHours (number): 70
```

**C1**:
```
name (string): "Advanced C1"
description (string): "Cấp độ cao cấp, sử dụng tiếng Anh linh hoạt và hiệu quả"
order (number): 5
totalUnits (number): 9
estimatedHours (number): 80
```

**C2**:
```
name (string): "Proficient C2"
description (string): "Cấp độ thành thạo, sử dụng tiếng Anh như người bản ngữ"
order (number): 6
totalUnits (number): 10
estimatedHours (number): 90
```

---

## 📚 Collection 2: units

### Tạo Collection "units"

### Unit mẫu cho Level A1:

**Document ID**: `unit_a1_1` (tự tạo)

**Fields**:
```
levelId (string): "A1"
title (string): "Unit 1: Present Simple"
description (string): "Học về thì hiện tại đơn - cách dùng cơ bản nhất trong tiếng Anh"
order (number): 1
estimatedTime (number): 60
lessons (array): ["lesson_a1_1_1", "lesson_a1_1_2"]
prerequisites (array): [] (để trống)
```

**Document ID**: `unit_a1_2`

**Fields**:
```
levelId (string): "A1"
title (string): "Unit 2: Present Continuous"
description (string): "Học về thì hiện tại tiếp diễn"
order (number): 2
estimatedTime (number): 60
lessons (array): ["lesson_a1_2_1", "lesson_a1_2_2"]
prerequisites (array): ["unit_a1_1"]
```

**Tạo thêm 3 units nữa cho A1** (unit_a1_3, unit_a1_4, unit_a1_5) với tương tự.

**Lưu ý**: 
- `lessons` là array of strings, click **Add field** > chọn type **array** > thêm các string
- `prerequisites` cũng là array, có thể để trống hoặc thêm unit ID cần hoàn thành trước

---

## 📚 Collection 3: lessons

### Tạo Collection "lessons"

### Lesson mẫu: Present Simple - Affirmative

**Document ID**: `lesson_a1_1_1`

**Fields**:
```
unitId (string): "unit_a1_1"
levelId (string): "A1"
title (string): "Present Simple - Affirmative"
type (string): "grammar"
order (number): 1
content (map): 
  - Click "Add field" > chọn type "map"
  - Trong map "content", thêm:
    theory (map):
      title (string): "Present Simple"
      description (string): "Thì hiện tại đơn (Present Simple) được dùng để diễn tả thói quen, sự thật hiển nhiên, và các hành động lặp đi lặp lại."
      usage (string): "Dùng để diễn tả: thói quen hàng ngày, sự thật hiển nhiên, lịch trình cố định"
      forms (map):
        affirmative (string): "Subject + Verb (s/es cho ngôi thứ 3 số ít)"
        negative (string): "Subject + do/does + not + Verb"
        interrogative (string): "Do/Does + Subject + Verb?"
      examples (array):
        - sentence (string): "I go to school every day."
          explanation (string): "Tôi đi học mỗi ngày"
        - sentence (string): "She works in a hospital."
          explanation (string): "Cô ấy làm việc ở bệnh viện"
    exercises (array): ["exercise_a1_1_1_1", "exercise_a1_1_1_2", "exercise_a1_1_1_3"]
```

**Cách tạo Map lồng nhau trong Firebase Console**:
1. Click **Add field**
2. Field name: `content`
3. Type: chọn **map**
4. Click vào map vừa tạo để mở rộng
5. Thêm các field bên trong map:
   - `theory` (type: map)
   - `exercises` (type: array)

**Lesson thứ 2**: `lesson_a1_1_2` - "Present Simple - Negative and Questions"

**Fields**:
```
unitId (string): "unit_a1_1"
levelId (string): "A1"
title (string): "Present Simple - Negative and Questions"
type (string): "grammar"
order (number): 2
content (map):
  theory (map):
    title (string): "Present Simple - Negative and Questions"
    description (string): "Học cách tạo câu phủ định và câu hỏi với thì hiện tại đơn"
    usage (string): "Dùng do/does cho câu hỏi và phủ định"
    forms (map):
      negative (string): "Subject + do/does + not + Verb"
      interrogative (string): "Do/Does + Subject + Verb?"
    examples (array):
      - sentence (string): "I don't like coffee."
        explanation (string): "Tôi không thích cà phê"
      - sentence (string): "Do you speak English?"
        explanation (string): "Bạn có nói tiếng Anh không?"
  exercises (array): ["exercise_a1_1_2_1", "exercise_a1_1_2_2"]
```

---

## 📚 Collection 4: exercises

### Tạo Collection "exercises"

### Exercise 1: Single Choice

**Document ID**: `exercise_a1_1_1_1`

**Fields**:
```
lessonId (string): "lesson_a1_1_1"
unitId (string): "unit_a1_1"
levelId (string): "A1"
type (string): "single_choice"
question (string): "Choose the correct form: I ___ to school every day."
points (number): 10
timeLimit (number): 30
difficulty (string): "easy"
explanation (string): "Với chủ ngữ 'I', ta dùng 'go' (không thêm 's')"
content (map):
  options (array): ["go", "goes", "going", "went"]
  correctAnswers (array): ["go"]
```

### Exercise 2: Multiple Choice

**Document ID**: `exercise_a1_1_1_2`

**Fields**:
```
lessonId (string): "lesson_a1_1_1"
unitId (string): "unit_a1_1"
levelId (string): "A1"
type (string): "multiple_choice"
question (string): "Which sentences are correct? (Select all that apply)"
points (number): 15
timeLimit (number): 45
difficulty (string): "medium"
explanation (string): "Câu 1 và 3 đúng vì 'I' và 'They' không cần thêm 's'"
content (map):
  options (array): 
    - "I goes to school"
    - "I go to school"
    - "They play football"
    - "She go to work"
  correctAnswers (array): ["I go to school", "They play football"]
```

### Exercise 3: Fill in the Blank

**Document ID**: `exercise_a1_1_1_3`

**Fields**:
```
lessonId (string): "lesson_a1_1_1"
unitId (string): "unit_a1_1"
levelId (string): "A1"
type (string): "fill_blank"
question (string): "Fill in the blanks with the correct form of the verb"
points (number): 20
timeLimit (number): 60
difficulty (string): "medium"
explanation (string): "Nhớ thêm 's' cho ngôi thứ 3 số ít (he, she, it)"
content (map):
  text (string): "She ___ (work) in a hospital. They ___ (work) in an office."
  blanks (array):
    - position (number): 0
      correctAnswer (string): "works"
      hints (array): ["Ngôi thứ 3 số ít cần thêm 's'"]
    - position (number): 1
      correctAnswer (string): "work"
      hints (array): ["Ngôi thứ 3 số nhiều không thêm 's'"]
```

### Exercise 4: Matching

**Document ID**: `exercise_a1_1_2_1`

**Fields**:
```
lessonId (string): "lesson_a1_1_2"
unitId (string): "unit_a1_1"
levelId (string): "A1"
type (string): "matching"
question (string): "Match the questions with the correct answers"
points (number): 15
timeLimit (number): 45
difficulty (string): "easy"
explanation (string): "Câu hỏi với 'Do' dùng cho ngôi thứ nhất, thứ hai và số nhiều"
content (map):
  leftItems (array): 
    - "Do you like coffee?"
    - "Does she work here?"
    - "Do they play football?"
  rightItems (array):
    - "Yes, I do"
    - "Yes, she does"
    - "Yes, they do"
  correctPairs (array):
    - left (string): "Do you like coffee?"
      right (string): "Yes, I do"
    - left (string): "Does she work here?"
      right (string): "Yes, she does"
    - left (string): "Do they play football?"
      right (string): "Yes, they do"
```

---

## 📚 Collection 5: users (Tự động tạo khi đăng ký)

Collection này sẽ được tạo tự động khi user đăng ký qua `AuthService`. 

Nhưng bạn có thể tạo một document mẫu để test:

**Document ID**: `test_user_123` (hoặc bất kỳ ID nào)

**Fields**:
```
email (string): "test@example.com"
displayName (string): "Test User"
photoUrl (string): null
createdAt (timestamp): [Click và chọn timestamp, chọn thời gian hiện tại]
currentLevel (string): "A1"
totalXP (number): 0
streak (number): 0
lastActiveDate (timestamp): null
```

---

## 📚 Collection 6: userProgress (Tự động tạo khi cần)

Collection này cũng sẽ được tạo tự động. Document mẫu:

**Document ID**: `test_user_123` (cùng ID với user)

**Fields**:
```
userId (string): "test_user_123"
levelProgress (map):
  A1 (map):
    completedUnits (array): []
    currentUnit (string): "unit_a1_1"
    mastery (number): 0.0
weakPoints (map):
  grammarTopics (array): []
  skillTypes (array): []
exerciseHistory (array): []
lastUpdated (timestamp): [Thời gian hiện tại]
```

---

## 🎯 Cách 2: Import bằng JSON (Nhanh hơn)

### Bước 1: Tạo file JSON

Tôi sẽ tạo file `firestore_data.json` để bạn có thể import (nếu Firebase hỗ trợ) hoặc dùng làm reference.

### Bước 2: Sử dụng Firebase CLI (Khuyến nghị)

1. Cài đặt Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login:
```bash
firebase login
```

3. Init project:
```bash
firebase init firestore
```

4. Tạo file `firestore.rules` và `firestore.indexes.json` nếu cần

5. Import data (nếu có file JSON):
```bash
firebase firestore:delete --all-collections  # Xóa hết (cẩn thận!)
# Hoặc import từ file
```

---

## 📝 Lưu Ý Quan Trọng

1. **Document IDs**: 
   - Có thể tự tạo hoặc để Firebase tự generate
   - Nên dùng ID có ý nghĩa như `A1`, `unit_a1_1` để dễ quản lý

2. **Arrays trong Firebase Console**:
   - Click "Add field" > chọn type "array"
   - Click vào array để thêm items
   - Với array of strings, chỉ cần nhập text

3. **Maps (Objects) lồng nhau**:
   - Tạo field type "map"
   - Click vào map để mở rộng và thêm fields bên trong

4. **Timestamps**:
   - Chọn type "timestamp"
   - Có thể chọn thời gian hiện tại hoặc nhập thủ công

5. **Order quan trọng**:
   - Field `order` rất quan trọng để sắp xếp
   - Đảm bảo tạo index cho queries có `orderBy`

---

## 🔥 Tạo Indexes

Sau khi tạo data, bạn cần tạo indexes cho các queries:

1. Vào **Firestore Database** > **Indexes** tab
2. Click **Create Index**

**Index 1**: units collection
- Collection: `units`
- Fields: `levelId` (Ascending), `order` (Ascending)
- Query scope: Collection

**Index 2**: lessons collection
- Collection: `lessons`
- Fields: `unitId` (Ascending), `order` (Ascending)
- Query scope: Collection

**Index 3**: exercises collection
- Collection: `exercises`
- Fields: `lessonId` (Ascending)
- Query scope: Collection

**Index 4**: userProgress collection
- Collection: `userProgress`
- Fields: `exerciseHistory.completedAt` (Descending)
- Query scope: Collection

---

## ✅ Checklist

- [ ] Tạo collection `levels` với 6 documents (A1-C2)
- [ ] Tạo collection `units` với ít nhất 2 units cho A1
- [ ] Tạo collection `lessons` với ít nhất 2 lessons cho unit đầu tiên
- [ ] Tạo collection `exercises` với ít nhất 4 exercises (các loại khác nhau)
- [ ] Tạo indexes cho các queries
- [ ] Test query trong Firebase Console
- [ ] Cập nhật Security Rules (xem ARCHITECTURE_DESIGN.md)

---

## 🧪 Test Queries

Sau khi tạo data, test các queries sau trong Firebase Console:

1. **Lấy tất cả levels**:
   - Collection: `levels`
   - Order by: `order` (Ascending)

2. **Lấy units của level A1**:
   - Collection: `units`
   - Filter: `levelId == "A1"`
   - Order by: `order` (Ascending)

3. **Lấy lessons của unit**:
   - Collection: `lessons`
   - Filter: `unitId == "unit_a1_1"`
   - Order by: `order` (Ascending)

4. **Lấy exercises của lesson**:
   - Collection: `exercises`
   - Filter: `lessonId == "lesson_a1_1_1"`

---

## 📞 Cần Hỗ Trợ?

Nếu gặp khó khăn:
1. Xem lại cấu trúc trong `ARCHITECTURE_DESIGN.md`
2. Kiểm tra Security Rules đã đúng chưa
3. Đảm bảo đã tạo đủ indexes
4. Test queries trước khi code


