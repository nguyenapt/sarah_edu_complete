# 🔍 Troubleshooting: Icon loa không hiển thị

## Nguyên nhân

Icon loa chỉ hiển thị khi có `voiceConfig` (từ `speakerVoices` hoặc `defaultVoice`). Nếu widget không tìm thấy voice config, nó sẽ trả về `SizedBox.shrink()` và không hiển thị gì.

## Kiểm tra

### 1. Kiểm tra data trong Firestore

Đảm bảo exercise document có một trong hai field sau:

#### Option 1: Có `speakerVoices` (recommended)
```json
{
  "speakerVoices": {
    "Diana": {
      "gender": "female",
      "age": "young",
      "languageCode": "en-US",
      "rate": 1.0,
      "pitch": 0.0
    }
  },
  "defaultVoice": {
    "gender": "female",
    "age": "young",
    "languageCode": "en-US",
    "rate": 1.0,
    "pitch": 0.0
  }
}
```

#### Option 2: Chỉ có `defaultVoice`
```json
{
  "defaultVoice": {
    "gender": "female",
    "age": "young",
    "languageCode": "en-US",
    "rate": 1.0,
    "pitch": 0.0
  }
}
```

### 2. Kiểm tra format đúng

- `gender`: `"female"` hoặc `"male"`
- `age`: `"young"`, `"adult"`, hoặc `"senior"`
- `languageCode`: `"en-US"` (hoặc language code khác)
- `rate`: `1.0` (number, không phải string)
- `pitch`: `0.0` (number, không phải string)

### 3. Kiểm tra speaker name trong question

Widget sẽ parse speaker name từ format: `"SpeakerName: dialogue text"`

Ví dụ:
- ✅ `"Diana: Hello, is that Jenny?"` → Tìm voice cho "Diana"
- ✅ `"Mike: I'm fine, thanks"` → Tìm voice cho "Mike"
- ❌ `"Hello, is that Jenny?"` → Không có speaker, dùng `defaultVoice`

### 4. Test với sample data

Sử dụng file `azure_speech_single_exercise_sample.json` làm mẫu để thêm vào Firestore.

## Debug steps

1. **Kiểm tra data trong Firestore Console:**
   - Mở exercise document
   - Kiểm tra có field `speakerVoices` hoặc `defaultVoice` không
   - Kiểm tra format đúng không

2. **Test với data mẫu:**
   - Copy nội dung từ `azure_speech_single_exercise_sample.json`
   - Paste vào một exercise document mới trong Firestore
   - Reload app và kiểm tra icon loa

3. **Kiểm tra console logs:**
   - Mở DevTools/Console
   - Xem có error nào không
   - Widget `QuestionAudioPlayer` sẽ không hiển thị nếu `voiceConfig` là null

## Quick fix

Nếu muốn test nhanh, thêm `defaultVoice` vào exercise:

```json
{
  "defaultVoice": {
    "gender": "female",
    "age": "young",
    "languageCode": "en-US",
    "rate": 1.0,
    "pitch": 0.0
  }
}
```

Icon loa sẽ hiển thị cho TẤT CẢ questions trong exercise đó.



