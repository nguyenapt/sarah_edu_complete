# Tài Liệu Thiết Kế Kiến Trúc - Sarah Edu Complete

## 1. Lựa Chọn Database: Firestore vs Realtime Database

### ✅ **KHUYẾN NGHỊ: SỬ DỤNG FIRESTORE**

**Lý do:**

#### Firestore phù hợp hơn vì:
- **Cấu trúc dữ liệu phức tạp**: Ứng dụng cần lưu trữ nhiều loại dữ liệu có cấu trúc (Levels, Units, Lessons, Exercises, User Progress)
- **Query linh hoạt**: Cần query theo nhiều điều kiện (level, unit, user progress, weak points)
- **Offline support**: Firestore có offline persistence tốt hơn
- **Scalability**: Dễ mở rộng khi số lượng người dùng tăng
- **Security Rules**: Firestore có security rules mạnh mẽ hơn
- **Real-time updates**: Vẫn hỗ trợ real-time listeners khi cần

#### Realtime Database phù hợp khi:
- Dữ liệu đơn giản, cấu trúc phẳng
- Cần real-time sync với độ trễ thấp (chat, game)
- Dữ liệu ít, không cần query phức tạp

## 2. Database Schema Design (Firestore)

### 2.1. Collection Structure

```
users/{userId}
  - email: string
  - displayName: string
  - photoUrl: string
  - createdAt: timestamp
  - currentLevel: string (A1, A2, B1, B2, C1, C2)
  - totalXP: number
  - streak: number
  - lastActiveDate: timestamp

userProgress/{userId}
  - userId: string
  - levelProgress: {
      A1: { completedUnits: [], currentUnit: string, mastery: number },
      A2: { ... },
      ...
    }
  - weakPoints: {
      grammarTopics: [string], // IDs của các topics yếu
      skillTypes: [string] // listening, speaking, reading, writing
    }
  - exerciseHistory: [
      {
        exerciseId: string,
        unitId: string,
        level: string,
        score: number,
        completedAt: timestamp,
        timeSpent: number,
        mistakes: [string]
      }
    ]
  - lastUpdated: timestamp

levels/{levelId} // A1, A2, B1, B2, C1, C2
  - id: string
  - name: string
  - description: string
  - order: number
  - totalUnits: number
  - estimatedHours: number
  - iconUrl: string

units/{unitId}
  - id: string
  - levelId: string
  - title: string
  - description: string
  - order: number
  - estimatedTime: number (minutes)
  - lessons: [lessonId1, lessonId2, ...]
  - prerequisites: [unitId] // Units cần hoàn thành trước

lessons/{lessonId}
  - id: string
  - unitId: string
  - levelId: string
  - title: string
  - type: string (grammar, vocabulary, listening, speaking, reading, writing)
  - content: {
      theory: {
        title: string,
        description: string,
        examples: [
          {
            sentence: string,
            explanation: string,
            audioUrl: string (optional)
          }
        ],
        usage: string, // Cách dùng
        forms: {
          affirmative: string,
          negative: string,
          interrogative: string
        }
      },
      exercises: [exerciseId1, exerciseId2, ...]
    }
  - order: number

exercises/{exerciseId}
  - id: string
  - lessonId: string
  - unitId: string
  - levelId: string
  - type: string (single_choice, multiple_choice, fill_blank, matching, listening, speaking)
  - question: string
  - content: {
      // Cho single_choice, multiple_choice
      options: [string],
      correctAnswers: [string] // Array cho multiple choice
      
      // Cho fill_blank
      text: string, // Text với ___ để điền
      blanks: [
        {
          position: number,
          correctAnswer: string,
          hints: [string]
        }
      ]
      
      // Cho matching
      leftItems: [string],
      rightItems: [string],
      correctPairs: [{left: string, right: string}]
      
      // Cho listening
      audioUrl: string,
      transcript: string
      
      // Cho speaking
      prompt: string,
      expectedKeywords: [string]
    }
  - points: number
  - timeLimit: number (seconds, optional)
  - difficulty: string (easy, medium, hard)
  - explanation: string // Giải thích sau khi làm xong

aiPractice/{sessionId}
  - userId: string
  - weakPointId: string // Topic hoặc skill type
  - exercises: [exerciseId]
  - createdAt: timestamp
  - completedAt: timestamp
  - score: number
```

### 2.2. Indexes cần tạo trong Firestore

```
- userProgress/{userId}/exerciseHistory: [completedAt DESC]
- exercises: [levelId, unitId, lessonId]
- lessons: [levelId, unitId, order]
- units: [levelId, order]
```

## 3. Authentication Strategy

### Sử dụng Firebase Authentication với:
1. **Email/Password**: Đăng ký và đăng nhập cơ bản
2. **Google Sign-In**: Đăng nhập nhanh với Google
3. **Anonymous Auth** (tùy chọn): Cho phép dùng thử không cần đăng ký

### Security Rules mẫu:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users chỉ đọc được thông tin công khai của users khác
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User progress chỉ user đó mới đọc/ghi được
    match /userProgress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Levels, Units, Lessons, Exercises: Tất cả user đã đăng nhập đều đọc được
    match /levels/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Chỉ admin mới được ghi
    }
    
    match /units/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    match /lessons/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    match /exercises/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    // AI Practice sessions
    match /aiPractice/{sessionId} {
      allow read, write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
  }
}
```

## 4. Tích Hợp AI và Azure Speech Service

### 4.1. OpenAI Integration
- **Mục đích**: 
  - Tạo bài tập động dựa trên điểm yếu
  - Giải thích ngữ pháp cá nhân hóa
  - Tạo ví dụ theo ngữ cảnh
  - Đánh giá câu trả lời tự do (writing, speaking)

- **API Endpoints sử dụng**:
  - GPT-4 hoặc GPT-3.5-turbo cho text generation
  - Embeddings để phân tích điểm yếu

### 4.2. Azure Speech Service
- **Mục đích**:
  - Text-to-Speech: Đọc ví dụ, câu hỏi
  - Speech-to-Text: Nhận diện giọng nói trong bài tập speaking
  - Pronunciation assessment: Đánh giá phát âm

- **Implementation**:
  - Sử dụng package `speech_to_text` và `flutter_tts` cho client-side
  - Hoặc gọi Azure Speech API qua backend/Cloud Functions

## 5. Kiến Trúc Ứng Dụng (Flutter)

### 5.1. Cấu Trúc Thư Mục

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── firebase_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── services/
│       ├── firebase_service.dart
│       ├── auth_service.dart
│       ├── firestore_service.dart
│       ├── openai_service.dart
│       └── azure_speech_service.dart
├── models/
│   ├── user_model.dart
│   ├── level_model.dart
│   ├── unit_model.dart
│   ├── lesson_model.dart
│   ├── exercise_model.dart
│   └── progress_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── progress_provider.dart
│   ├── learning_provider.dart
│   └── ai_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── dashboard_screen.dart
│   ├── learning/
│   │   ├── level_selection_screen.dart
│   │   ├── unit_list_screen.dart
│   │   ├── lesson_detail_screen.dart
│   │   └── exercise_screen.dart
│   ├── progress/
│   │   ├── progress_screen.dart
│   │   └── weak_points_screen.dart
│   └── practice/
│       ├── ai_practice_screen.dart
│       └── custom_practice_screen.dart
├── widgets/
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_indicator.dart
│   ├── learning/
│   │   ├── level_card.dart
│   │   ├── unit_card.dart
│   │   ├── exercise_widgets/
│   │   │   ├── single_choice_widget.dart
│   │   │   ├── multiple_choice_widget.dart
│   │   │   ├── fill_blank_widget.dart
│   │   │   └── matching_widget.dart
│   │   └── theory_section.dart
│   └── progress/
│       ├── progress_chart.dart
│       └── weak_point_card.dart
└── routes/
    └── app_router.dart
```

## 6. Thiết Kế Giao Diện (UI/UX)

### 6.1. Màn Hình Chính (Home/Dashboard)
- **Header**: Avatar, tên, XP, streak
- **Quick Stats**: 
  - Level hiện tại với progress bar
  - Số unit đã hoàn thành
  - Điểm yếu cần luyện tập
- **Continue Learning**: Button tiếp tục bài học đang dở
- **Level Cards**: Grid hiển thị 6 levels (A1-C2) với:
  - Icon/Color phân biệt
  - Progress indicator
  - Lock/Unlock status
  - Số unit đã hoàn thành / tổng số unit

### 6.2. Level Selection Screen
- **Level Overview**: 
  - Mô tả level
  - Estimated time
  - Skills sẽ học
- **Unit List**: 
  - List các units với:
    - Order number
    - Title
    - Progress (completed/not started/locked)
    - Estimated time
    - Checkmark nếu đã hoàn thành

### 6.3. Lesson Detail Screen
- **Theory Section**:
  - Title và description
  - Forms (affirmative, negative, interrogative) với examples
  - Usage guide
  - Audio button để nghe ví dụ
- **Examples Section**:
  - List examples với explanation
  - Interactive examples (tap để nghe)
- **Exercises Section**:
  - List exercises với:
    - Type icon
    - Title
    - Points
    - Status (not started/completed)
    - Difficulty badge

### 6.4. Exercise Screen
- **Question Header**: 
  - Exercise number / total
  - Points
  - Timer (nếu có)
- **Question Content**: 
  - Text, audio, image tùy loại
- **Answer Input**: 
  - Tùy loại exercise (radio, checkbox, text field, drag-drop)
- **Navigation**: 
  - Previous/Next buttons
  - Submit button
- **Result Modal**: 
  - Correct/Incorrect
  - Explanation
  - Points earned
  - Next button

### 6.5. Progress Screen
- **Overall Stats**:
  - Current level với progress
  - Total XP
  - Streak
  - Time spent learning
- **Level Progress**: 
  - Progress bars cho từng level
  - Units completed
- **Weak Points Section**:
  - List các topics/skills yếu
  - Button "Practice Now" cho mỗi điểm yếu
  - Progress improvement chart

### 6.6. AI Practice Screen
- **Weak Point Info**: 
  - Topic/skill đang luyện
  - Mục tiêu cải thiện
- **Exercise Flow**: 
  - Tương tự Exercise Screen
  - Exercises được tạo động bởi AI
- **Results**: 
  - Score
  - Improvement suggestions
  - Recommendations

### 6.7. Color Scheme & Design
- **Primary Colors**: 
  - Blue (#2196F3) cho learning
  - Green (#4CAF50) cho completed
  - Orange (#FF9800) cho practice
  - Red (#F44336) cho weak points
- **Design Style**: 
  - Modern, clean, Material Design 3
  - Rounded corners
  - Smooth animations
  - Card-based layout
  - Gradient accents

## 7. Tính Năng Cá Nhân Hóa

### 7.1. Phân Tích Điểm Yếu
- **Thu thập dữ liệu**:
  - Track mistakes trong exercises
  - Track time spent trên mỗi topic
  - Track accuracy rate
- **Phân tích**:
  - Identify patterns trong mistakes
  - Xác định topics có accuracy < 70%
  - Xác định skills cần cải thiện

### 7.2. Adaptive Learning
- **Đề xuất bài học**:
  - Ưu tiên units liên quan đến điểm yếu
  - Suggest review cho topics đã học lâu
- **AI Practice**:
  - Tạo exercises tập trung vào điểm yếu
  - Điều chỉnh difficulty dựa trên performance
  - Provide personalized explanations

## 8. Dependencies Cần Thiết

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  
  # State Management
  provider: ^6.1.0
  # hoặc riverpod: ^2.4.0
  
  # UI
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  lottie: ^3.0.0
  
  # Audio
  audioplayers: ^6.0.0
  speech_to_text: ^7.0.0
  flutter_tts: ^4.0.0
  
  # HTTP & API
  http: ^1.2.0
  dio: ^5.4.0
  
  # Utils
  shared_preferences: ^2.2.0
  intl: ^0.19.0
  uuid: ^4.3.0
  
  # Charts
  fl_chart: ^0.66.0
  
  # Google Sign In
  google_sign_in: ^6.2.0
```

## 9. Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- Setup Firebase project
- Authentication (Email/Password, Google)
- Basic UI structure
- Models và services cơ bản

### Phase 2: Core Learning (Week 3-4)
- Level/Unit/Lesson screens
- Exercise widgets (single choice, multiple choice)
- Progress tracking
- Firestore integration

### Phase 3: Advanced Features (Week 5-6)
- Fill blank, matching exercises
- Audio integration
- Progress analytics
- Weak points detection

### Phase 4: AI & Personalization (Week 7-8)
- OpenAI integration
- AI practice generation
- Azure Speech Service
- Adaptive learning

### Phase 5: Polish (Week 9-10)
- UI/UX improvements
- Animations
- Performance optimization
- Testing

## 10. Best Practices

1. **Offline Support**: Enable Firestore offline persistence
2. **Caching**: Cache levels, units, lessons để giảm reads
3. **Error Handling**: Comprehensive error handling và user feedback
4. **Loading States**: Show loading indicators cho mọi async operations
5. **Analytics**: Track user behavior để cải thiện app
6. **Security**: Never expose API keys trong client code, use Cloud Functions
7. **Testing**: Unit tests cho business logic, widget tests cho UI


