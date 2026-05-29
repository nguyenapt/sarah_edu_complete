# Pipeline AI Grammar (FirestoreImporter)

Lồng ghép ngữ pháp vào bài luyện tập qua batch AI trong công cụ **FirestoreImporter** — không cần sửa app Flutter.

## Yêu cầu

- .NET 9 SDK
- API key **OpenAI** hoặc **Gemini** (xem cấu hình bên dưới)
- File curriculum JSON hoặc load trực tiếp từ Firestore
- Firebase service account (chỉ khi Upload Firestore)

## Cấu hình API key

1. Sao chép `FirestoreImporter/FirestoreImporter/appsettings.local.example.json` → `appsettings.local.json`
2. Điền key theo provider, hoặc biến môi trường:

```powershell
$env:OPENAI_API_KEY = "sk-..."
$env:GEMINI_API_KEY = "..."   # hoặc GOOGLE_API_KEY
```

Trong UI chọn **OpenAI** / **Gemini**; model enrich/checkpoint tải theo provider.

`GrammarAi.DefaultProvider` trong `appsettings.json`: `openai` hoặc `gemini`.

## Chạy công cụ

```powershell
cd FirestoreImporter\FirestoreImporter
dotnet run
```

1. Nhập **Project ID** + **Credentials** → Test Connection (nếu sẽ upload)
2. Bấm **AI Grammar**
3. Chọn nguồn dữ liệu:
   - **JSON file** — chọn file curriculum local
   - **Firestore** — nhập Document ID → **Load** (tự tải unit/lesson/exercise + liên quan)

### Load trực tiếp từ Firestore (không cần JSON sẵn)

| Document ID | Dữ liệu tải về |
|-------------|----------------|
| `unit_a1_1` | Unit + lessons (`unitId`) + exercises (`unitId`) |
| `lesson_a1_1_1` | Lesson + unit (nếu có) + exercises (`lessonId`) |
| `exercise_a1_1_1_1` | Exercise + lesson + unit |
| `A1` hoặc `levels/A1` | Level + tất cả units/lessons/exercises trong level |

Ví dụ nhập: `unit_b1_3` hoặc `units/unit_b1_3`

Sau khi load, tool lưu snapshot JSON tạm trong `%TEMP%` để Export/backup.

## Phase 1 — Topic-anchor grammar note

**Không** enrich mọi câu trong `groupQuestions`. Luồng:

1. **Unit scope** — từ `title` / `description` của unit → danh sách `allowedTopicIds` (AI + cache, schema `phase1_unit_scope.json`).
2. **Segmentation** — gán `topicId` cho từng `groupQuestions[i]` (schema `phase1_segmentation.json`).
3. **Câu neo** — chỉ **câu đầu tiên** của mỗi topic trong exercise nhận `explanation` mới (grammar-only, EN/VI; schema `phase1_anchor_explanations.json`).
4. **Câu không neo** — giữ nguyên explanation cũ (cột **Giữ** trên grid).

**Định dạng explanation (en + vi):**

- HTML nhẹ: `<p>`, `<ul>/<li>`, `<b>` — không phải một khối text thuần.
- Bản **vi**: chỉ phần “glue” bằng tiếng Việt; mọi **tài liệu học tiếng Anh** (câu ví dụ, cụm trong ngoặc, danh sách từ, form ngữ pháp, marker…) **giữ nguyên EN** — copy từ bản `en`, không dịch. Nhãn topic EN lấy động từ `grammar_topics.json` theo từng anchor.

**Trong app:** với `button_single_choice`, `groupQuestions[i].explanation` hiển thị **Ghi chú ngữ pháp trước** khi làm bài (`exercise_screen.dart`).

### Grid preview

| Cột | Ý nghĩa |
|-----|---------|
| Topic | `topicId` từ taxonomy |
| Neo | ✓ = câu anchor sẽ được ghi explanation mới |
| Loại | `Neo` / `Giữ` |
| Trước / Sau | explanation VI (preview) |

Chỉ tick **OK** trên dòng **Neo** muốn áp dụng → **Áp dụng đã chọn** → **Upload** chỉ các exercise đã chọn.

### Ví dụ B1 (`unit_b1_3`)

Unit mô tả past simple / past continuous → allowed topics tương ứng. Exercise 6 câu: Q0 neo `past_simple`, Q1 neo `past_continuous`, các câu còn lại giữ explanation cũ.

## Phase 2 — Grammar checkpoint

- Phân tích theo `lessonId`, chèn exercise mới loại `button_single_choice`
- `explanation` = mini-lesson; `contentMeta.role` = `grammar_checkpoint`
- ID mới theo quy tắc `exercise_{level}_{unit}_{lesson}_{n}`; có thể đánh số lại bài phía sau khi chèn giữa lesson

**Trong app:** thẻ **Ghi chú ngữ pháp** hiện **trước** khi làm bài checkpoint.

## Quy trình khuyến nghị

1. Load JSON hoặc Firestore → filter unit (vd. `unit_b1_3`)
2. Chọn provider + model → **Chạy AI** (Phase 1)
3. Review grid (Topic / Neo) → bỏ tick dòng không muốn
4. (Tuỳ chọn) Phase 2 checkpoint → review
5. **Áp dụng đã chọn**
6. **Export JSON** → backup
7. Kiểm tra trên app Flutter
8. **Upload Firestore** khi đã hài lòng

## File kỹ thuật

| Thành phần | Đường dẫn |
|------------|-----------|
| Taxonomy topics | `FirestoreImporter/FirestoreImporter/Data/grammar_topics.json` |
| JSON schemas | `FirestoreImporter/FirestoreImporter/Data/Schemas/` |
| AI clients | `Services/IAiGrammarClient.cs`, `OpenAiGrammarClient.cs`, `GeminiGrammarClient.cs` |
| Unit scope | `Services/UnitGrammarScopeService.cs` |
| Anchor resolver | `Services/TopicAnchorResolver.cs` |
| Phase 1 pipeline | `Services/GrammarEnrichmentPipeline.cs` |
| Phase 2 pipeline | `Services/GrammarCheckpointPipeline.cs` |
| ID planner | `Services/ExerciseIdPlanner.cs` |
| UI | `GrammarAiForm.cs` |

## Lưu ý

- **Không commit** `appsettings.local.json` (chứa API key).
- Phase 1 cần **unit** trong dữ liệu load (load theo `unit_*` hoặc JSON đủ `units`).
- Renumber exercise ID ảnh hưởng `userProgress` nếu đã có người dùng — ưu tiên pilot trên dev.
- Chi phí AI: Phase 1 ≈ 1 unit-scope (cache) + 1 segmentation + 1 anchor batch / exercise; Phase 2 ≈ 2 request/checkpoint + 1 request/lesson.
