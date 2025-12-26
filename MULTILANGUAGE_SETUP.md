# Hướng Dẫn Setup Multi-Language - Sarah Edu Complete

## Tổng Quan

Ứng dụng hỗ trợ đa ngôn ngữ cho:
1. **UI Labels**: Tất cả text trong giao diện (buttons, labels, messages)
2. **Content**: Nội dung bài học, câu hỏi, giải thích trong Firestore

## Ngôn Ngữ Hỗ Trợ

- 🇻🇳 Tiếng Việt (vi) - Default
- 🇬🇧 English (en)
- 🇰🇷 한국어 (ko)
- 🇯🇵 日本語 (ja)
- 🇫🇷 Français (fr)
- 🇩🇪 Deutsch (de)
- 🇨🇳 中文 (zh) - Chinese (Simplified)
- 🇷🇺 Русский (ru) - Russian
- 🇪🇸 Español (es) - Spanish
- 🇵🇹 Português (pt) - Portuguese
- 🇮🇳 हिन्दी (hi) - Hindi

## Cấu Trúc Đã Tạo

### 1. Localization Files
- `lib/core/localization/app_localizations.dart` - Chứa tất cả translations cho UI
- `lib/core/localization/app_localizations_delegate.dart` - Delegate cho Flutter localization

### 2. Language Service
- `lib/core/services/language_service.dart` - Quản lý language selection và persistence

### 3. Language Provider
- `lib/providers/language_provider.dart` - State management cho language

## Database Schema cho Multi-Language Content

### Cấu Trúc Mới cho Firestore

Thay vì lưu content trực tiếp, chúng ta sẽ lưu dưới dạng object với các language keys:

#### Levels Collection
```javascript
{
  id: "A1",
  name: {
    vi: "Cơ bản A1",
    en: "Beginner A1",
    ko: "초급 A1",
    ja: "初級 A1",
    fr: "Débutant A1",
    de: "Anfänger A1"
  },
  description: {
    vi: "Cấp độ cơ bản nhất...",
    en: "The most basic level...",
    ko: "가장 기본적인 수준...",
    // ... các ngôn ngữ khác
  },
  order: 1,
  totalUnits: 5,
  estimatedHours: 40
}
```

#### Units Collection
```javascript
{
  id: "unit_a1_1",
  levelId: "A1",
  title: {
    vi: "Unit 1: Present Simple",
    en: "Unit 1: Present Simple",
    ko: "1단원: 현재 단순형",
    // ...
  },
  description: {
    vi: "Học về thì hiện tại đơn...",
    en: "Learn about present simple...",
    // ...
  },
  order: 1,
  estimatedTime: 60,
  lessons: ["lesson_a1_1_1", "lesson_a1_1_2"],
  prerequisites: []
}
```

#### Lessons Collection
```javascript
{
  id: "lesson_a1_1_1",
  unitId: "unit_a1_1",
  levelId: "A1",
  title: {
    vi: "Present Simple - Khẳng định",
    en: "Present Simple - Affirmative",
    // ...
  },
  type: "grammar",
  order: 1,
  content: {
    theory: {
      title: {
        vi: "Present Simple",
        en: "Present Simple",
        // ...
      },
      description: {
        vi: "Thì hiện tại đơn được dùng để...",
        en: "Present simple is used to...",
        // ...
      },
      usage: {
        vi: "Dùng để diễn tả thói quen...",
        en: "Used to express habits...",
        // ...
      },
      forms: {
        affirmative: {
          vi: "Subject + Verb (s/es cho ngôi thứ 3 số ít)",
          en: "Subject + Verb (s/es for third person singular)",
          // ...
        },
        negative: {
          vi: "Subject + do/does + not + Verb",
          en: "Subject + do/does + not + Verb",
          // ...
        },
        interrogative: {
          vi: "Do/Does + Subject + Verb?",
          en: "Do/Does + Subject + Verb?",
          // ...
        }
      },
      examples: [
        {
          sentence: {
            vi: "Tôi đi học mỗi ngày.",
            en: "I go to school every day.",
            // ...
          },
          explanation: {
            vi: "Tôi đi học mỗi ngày",
            en: "I go to school every day",
            // ...
          },
          audioUrl: null
        }
      ]
    },
    exercises: ["exercise_a1_1_1_1", "exercise_a1_1_1_2"]
  }
}
```

#### Exercises Collection
```javascript
{
  id: "exercise_a1_1_1_1",
  lessonId: "lesson_a1_1_1",
  unitId: "unit_a1_1",
  levelId: "A1",
  type: "single_choice",
  question: {
    vi: "Chọn dạng đúng: Tôi ___ đi học mỗi ngày.",
    en: "Choose the correct form: I ___ to school every day.",
    ko: "올바른 형태를 선택하세요: 나는 매일 학교에 ___ 간다.",
    // ...
  },
  points: 10,
  timeLimit: 30,
  difficulty: "easy",
  explanation: {
    vi: "Với chủ ngữ 'I', ta dùng 'go' (không thêm 's')",
    en: "With subject 'I', we use 'go' (no 's' added)",
    // ...
  },
  content: {
    options: {
      vi: ["đi", "đi", "đang đi", "đã đi"],
      en: ["go", "goes", "going", "went"],
      ko: ["가다", "간다", "가고 있다", "갔다"],
      // ...
    },
    correctAnswers: ["go"] // Same for all languages
  }
}
```

## Cách Sử Dụng trong Code

### 1. UI Labels

```dart
import 'package:sarah_edu_complete/core/localization/app_localizations.dart';

// Trong widget
Text(AppLocalizations.of(context)!.welcome)
Text(AppLocalizations.of(context)!.login)
```

### 2. Content từ Firestore

```dart
// Get content theo language hiện tại
final languageCode = AppLocalizations.of(context)!.languageCode;
final title = lesson.title[languageCode] ?? lesson.title['en'] ?? '';
```

### 3. Change Language

```dart
// Trong Settings
final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
await languageProvider.setLanguage('en');
```

## Update Models để Hỗ Trợ Multi-Language

Cần update các models để hỗ trợ Map<String, String> cho các fields có text:

- `LevelModel`: name, description
- `UnitModel`: title, description
- `LessonModel`: title, theory.title, theory.description, etc.
- `ExerciseModel`: question, explanation

## Migration Plan

### Phase 1: UI Localization (Đã hoàn thành)
- ✅ Setup Flutter localization
- ✅ Tạo translation files
- ✅ Language provider
- ⏳ Update UI screens để dùng translations

### Phase 2: Database Migration
- ⏳ Update Firestore schema
- ⏳ Migrate existing data
- ⏳ Update models

### Phase 3: Content Translation
- ⏳ Translate existing content
- ⏳ Add new content với multi-language
- ⏳ Update services để load content theo language

## Next Steps

1. **Update UI Screens**: Thay hardcoded text bằng AppLocalizations
2. **Update Models**: Thêm support cho Map<String, String>
3. **Update Firestore Service**: Load content theo language
4. **Create Language Selector**: UI để chọn language trong Settings
5. **Migrate Existing Data**: Convert current data sang multi-language format

## Lưu Ý

1. **Fallback**: Luôn có fallback về English nếu translation thiếu
2. **Performance**: Cache translations để tránh load lại
3. **Content Management**: Cần tool/admin để manage translations
4. **Testing**: Test với tất cả languages trước khi release

