# 🐛 Debug Audio Player Error

## Các bước debug

### 1. Xem error message trong console

Mở DevTools/Console và tìm các message bắt đầu với `❌ Error`:
- `❌ Error in _generateAndPlayAudio: ...`
- `❌ Error in _playAudio: ...`

### 2. Kiểm tra platform

**Trên Web:**
- Audio cache sẽ không hoạt động (đã được handle)
- Audio sẽ được generate mỗi lần play
- Có thể gặp CORS issues với Azure API

**Trên Android/iOS:**
- Audio cache sẽ hoạt động bình thường
- Cần kiểm tra permissions

### 3. Các lỗi thường gặp

#### a) Azure Speech API Error (401 Unauthorized)
**Nguyên nhân:** Subscription key không đúng hoặc hết hạn
**Giải pháp:** 
- Kiểm tra `azure_speech_config.dart`
- Đảm bảo key và region đúng
- Kiểm tra trong Azure Portal

#### b) Network Error
**Nguyên nhân:** Không có internet hoặc firewall block
**Giải pháp:**
- Kiểm tra internet connection
- Test với curl/Postman

#### c) SSML Format Error (400 Bad Request)
**Nguyên nhân:** SSML XML không đúng format
**Giải pháp:**
- Kiểm tra text có special characters không
- Xem error message từ Azure API

#### d) Audio Playback Error
**Nguyên nhân:** 
- Platform compatibility (web vs native)
- Audio format không được support
- File system permission (Android)

**Giải pháp:**
- Trên web: Đảm bảo dùng BytesSource
- Trên Android: Kiểm tra permissions

### 4. Test Azure Speech API trực tiếp

Sử dụng curl để test:

```bash
curl -X POST "https://westus.tts.speech.microsoft.com/cognitiveservices/v1" \
  -H "Ocp-Apim-Subscription-Key: YOUR_KEY" \
  -H "Content-Type: application/ssml+xml; charset=utf-8" \
  -H "X-Microsoft-OutputFormat: audio-16khz-128kbitrate-mono-mp3" \
  -d '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
  <voice name="en-US-JennyNeural">
    <prosody rate="1.0" pitch="0st">
      Hello, this is a test.
    </prosody>
  </voice>
</speak>' \
  --output test.mp3
```

### 5. Temporary fix: Disable cache

Nếu cache service gây lỗi, có thể tạm thời disable bằng cách:

Trong `question_audio_player.dart`, comment out cache logic:

```dart
// Skip cache for now
Uint8List? audioBytes = null; // await _cacheService.getCachedAudio(cacheKey);

if (audioBytes == null) {
  audioBytes = await _speechService.synthesizeSpeech(...);
  // await _cacheService.saveAudio(cacheKey, audioBytes);
}
```

## Error Codes

- **401**: Unauthorized - Check subscription key
- **400**: Bad Request - Check SSML format
- **403**: Forbidden - Check permissions/quota
- **429**: Too Many Requests - Rate limit exceeded
- **500**: Internal Server Error - Azure service issue








