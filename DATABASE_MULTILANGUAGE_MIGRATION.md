# Hướng Dẫn Migration Database cho Multi-Language

## Tổng Quan

Để hỗ trợ multi-language cho content (không chỉ UI), cần migrate database structure từ:
```
title: "Unit 1: Present Simple"
```
Sang:
```
title: {
  vi: "Unit 1: Thì hiện tại đơn",
  en: "Unit 1: Present Simple",
  ko: "1단원: 현재 단순형",
  ...
}
```

## Cấu Trúc Mới cho Firestore

### 1. Levels Collection

**Cũ**:
```javascript
{
  name: "Beginner A1",
  description: "Cấp độ cơ bản nhất"
}
```

**Mới**:
```javascript
{
  name: {
    vi: "Cơ bản A1",
    en: "Beginner A1",
    ko: "초급 A1",
    ja: "初級 A1",
    fr: "Débutant A1",
    de: "Anfänger A1",
    zh: "初级 A1",
    ru: "Начальный A1",
    es: "Principiante A1",
    pt: "Iniciante A1",
    hi: "शुरुआती A1"
  },
  description: {
    vi: "Cấp độ cơ bản nhất, dành cho người mới bắt đầu",
    en: "The most basic level, for beginners",
    ko: "가장 기본적인 수준, 초보자를 위한",
    ja: "最も基本的なレベル、初心者向け",
    fr: "Niveau le plus basique, pour les débutants",
    de: "Das grundlegendste Niveau, für Anfänger"
  }
}
```

### 2. Units Collection

**Cũ**:
```javascript
{
  title: "Unit 1: Present Simple",
  description: "Học về thì hiện tại đơn"
}
```

**Mới**:
```javascript
{
  title: {
    vi: "Unit 1: Thì hiện tại đơn",
    en: "Unit 1: Present Simple",
    ko: "1단원: 현재 단순형",
    ja: "ユニット1: 現在形",
    fr: "Unité 1: Présent simple",
    de: "Einheit 1: Einfache Gegenwart"
  },
  description: {
    vi: "Học về thì hiện tại đơn - cách dùng cơ bản nhất",
    en: "Learn about present simple - the most basic usage",
    // ... các ngôn ngữ khác
  }
}
```

### 3. Lessons Collection

**Cũ**:
```javascript
{
  title: "Present Simple - Affirmative",
  content: {
    theory: {
      title: "Present Simple",
      description: "Thì hiện tại đơn được dùng để...",
      usage: "Dùng để diễn tả thói quen...",
      forms: {
        affirmative: "Subject + Verb (s/es)",
        negative: "Subject + do/does + not + Verb",
        interrogative: "Do/Does + Subject + Verb?"
      },
      examples: [
        {
          sentence: "I go to school every day.",
          explanation: "Tôi đi học mỗi ngày"
        }
      ]
    }
  }
}
```

**Mới**:
```javascript
{
  title: {
    vi: "Thì hiện tại đơn - Khẳng định",
    en: "Present Simple - Affirmative",
    // ...
  },
  content: {
    theory: {
      title: {
        vi: "Thì hiện tại đơn",
        en: "Present Simple",
        // ...
      },
      description: {
        vi: "Thì hiện tại đơn được dùng để diễn tả thói quen...",
        en: "Present simple is used to express habits...",
        // ...
      },
      usage: {
        vi: "Dùng để diễn tả: thói quen hàng ngày, sự thật hiển nhiên",
        en: "Used to express: daily habits, general truths",
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
            ko: "나는 매일 학교에 간다.",
            // ...
          },
          explanation: {
            vi: "Tôi đi học mỗi ngày",
            en: "I go to school every day",
            ko: "나는 매일 학교에 간다",
            // ...
          },
          audioUrl: null
        }
      ]
    }
  }
}
```

### 4. Exercises Collection

**Cũ**:
```javascript
{
  question: "Choose the correct form: I ___ to school every day.",
  explanation: "Với chủ ngữ 'I', ta dùng 'go'",
  content: {
    options: ["go", "goes", "going", "went"],
    correctAnswers: ["go"]
  }
}
```

**Mới**:
```javascript
{
  question: {
    vi: "Chọn dạng đúng: Tôi ___ đi học mỗi ngày.",
    en: "Choose the correct form: I ___ to school every day.",
    ko: "올바른 형태를 선택하세요: 나는 매일 학교에 ___ 간다.",
    // ...
  },
  explanation: {
    vi: "Với chủ ngữ 'I', ta dùng 'go' (không thêm 's')",
    en: "With subject 'I', we use 'go' (no 's' added)",
    ko: "주어 'I'와 함께 'go'를 사용합니다 (s 추가 안 함)",
    // ...
  },
  content: {
    options: {
      vi: ["đi", "đi", "đang đi", "đã đi"],
      en: ["go", "goes", "going", "went"],
      ko: ["가다", "간다", "가고 있다", "갔다"],
      // ...
    },
    correctAnswers: ["go"] // Same for all languages (key)
  }
}
```

## Migration Script (JavaScript - Chạy trong Firebase Console hoặc Cloud Functions)

```javascript
// Migration script để convert existing data
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

async function migrateLevels() {
  const levelsRef = db.collection('levels');
  const snapshot = await levelsRef.get();
  
  const batch = db.batch();
  
  snapshot.forEach((doc) => {
    const data = doc.data();
    
    // Convert name
    if (typeof data.name === 'string') {
      data.name = {
        vi: data.name,
        en: data.name, // Keep original as English
      };
    }
    
    // Convert description
    if (typeof data.description === 'string') {
      data.description = {
        vi: data.description,
        en: data.description,
      };
    }
    
    batch.update(doc.ref, data);
  });
  
  await batch.commit();
  console.log('Levels migrated');
}

// Tương tự cho units, lessons, exercises
```

## Cách Thêm Translation Mới

### Trong Firebase Console:

1. Vào document cần translate
2. Tìm field cần translate (ví dụ: `title`)
3. Nếu là string, chuyển thành map:
   - Click vào field
   - Change type từ "string" → "map"
   - Thêm các keys: `vi`, `en`, `ko`, `ja`, `fr`, `de`
   - Điền giá trị cho từng ngôn ngữ

### Ví dụ: Translate một Unit

1. Mở document `unit_a1_1`
2. Tìm field `title`
3. Nếu hiện tại là: `"Unit 1: Present Simple"`
4. Chuyển thành map:
   ```
   title (map):
     vi: "Unit 1: Thì hiện tại đơn"
     en: "Unit 1: Present Simple"
     ko: "1단원: 현재 단순형"
     ja: "ユニット1: 現在形"
     fr: "Unité 1: Présent simple"
     de: "Einheit 1: Einfache Gegenwart"
   ```

## Best Practices

1. **Luôn có English**: English là fallback language, luôn phải có
2. **Vietnamese là default**: Vì app chủ yếu cho người Việt
3. **Consistent keys**: Dùng cùng language codes: vi, en, ko, ja, fr, de
4. **Fallback logic**: Code sẽ tự động fallback nếu translation thiếu
5. **Content review**: Review translations trước khi publish

## Testing

Sau khi migrate:
1. Test với từng language
2. Kiểm tra fallback hoạt động đúng
3. Đảm bảo không có field nào bị mất data
4. Test performance (query với language filter)

