using FirestoreImporter.Models;
using FirestoreImporter.Services;
using Newtonsoft.Json;

namespace FirestoreImporter;

public class GrammarAiForm : Form
{
    private readonly FirestoreService _firestoreService;
    private readonly string _projectId;
    private readonly string _credentialsPath;

    private ImportData? _importData;
    private string _jsonPath = string.Empty;
    private readonly GrammarAiConfig _config;
    private readonly GrammarTopicRegistry _topicRegistry;
    private readonly GrammarJsonValidator _validator;
    private IAiGrammarClient _aiClient = null!;
    private UnitGrammarScopeService _unitScopeService = null!;
    private GrammarEnrichmentPipeline _enrichmentPipeline = null!;
    private GrammarCheckpointPipeline _checkpointPipeline = null!;

    private readonly ComboBox _cmbProvider = new() { Width = 100, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly ComboBox _cmbDataSource = new() { Width = 110, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly TextBox _txtJsonFile = new() { Width = 240 };
    private readonly TextBox _txtDocId = new() { Width = 200, PlaceholderText = "unit_a1_1" };
    private readonly TextBox _txtApiKey = new() { Width = 320, UseSystemPasswordChar = true };
    private readonly ComboBox _cmbUnitFilter = new() { Width = 200, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly CheckBox _chkEnrich = new() { Text = "Phase 1: Grammar note (câu neo)", Checked = true, AutoSize = true };
    private readonly CheckBox _chkCheckpoints = new() { Text = "Phase 2: Chèn grammar checkpoint", AutoSize = true };
    private readonly NumericUpDown _numEveryN = new() { Minimum = 2, Maximum = 10, Value = 4, Width = 60 };
    private readonly ComboBox _cmbEnrichModel = new() { Width = 140, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly ComboBox _cmbCheckpointModel = new() { Width = 140, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly DataGridView _dgv = new();
    private readonly RichTextBox _rtbLog = new() { Height = 120, Dock = DockStyle.Bottom };
    private readonly ProgressBar _progress = new() { Style = ProgressBarStyle.Marquee, Visible = false, Dock = DockStyle.Bottom, Height = 8 };

    private readonly List<TopicAnchorExercisePreview> _topicPreviews = new();
    private readonly List<CheckpointPreview> _checkpointRows = new();
    private Label? _lblJson;
    private Label? _lblDocId;
    private Button? _btnBrowseJson;

    public GrammarAiForm(FirestoreService firestoreService, string projectId, string credentialsPath, string? initialJsonPath)
    {
        _firestoreService = firestoreService;
        _projectId = projectId;
        _credentialsPath = credentialsPath;

        _config = GrammarAiConfig.Load();
        _topicRegistry = GrammarTopicRegistry.LoadDefault();
        _validator = new GrammarJsonValidator();
        RebuildAiClients();

        Text = "AI Grammar — Firestore Importer";
        Size = new Size(980, 640);
        StartPosition = FormStartPosition.CenterParent;
        FormBorderStyle = FormBorderStyle.Sizable;
        MinimumSize = new Size(800, 500);

        BuildUi();

        _cmbProvider.Items.AddRange(new object[] { "OpenAI", "Gemini" });
        _cmbProvider.SelectedIndex =
            string.Equals(_config.DefaultProvider, AiGrammarProviders.Gemini, StringComparison.OrdinalIgnoreCase)
                ? 1
                : 0;
        _cmbProvider.SelectedIndexChanged += (_, _) => OnProviderChanged();

        OnProviderChanged();

        if (!string.IsNullOrWhiteSpace(initialJsonPath) && File.Exists(initialJsonPath))
        {
            _txtJsonFile.Text = initialJsonPath;
            _ = LoadDataAsync();
        }

        UpdateDataSourceUi();
    }

    private void RebuildAiClients()
    {
        var provider = GetSelectedProvider();
        _aiClient = AiGrammarClientFactory.Create(provider, _config);
        _unitScopeService = new UnitGrammarScopeService(_aiClient, _topicRegistry, _validator, _config);
        _enrichmentPipeline = new GrammarEnrichmentPipeline(
            _aiClient, _topicRegistry, _validator, _config, _unitScopeService);
        _checkpointPipeline = new GrammarCheckpointPipeline(_aiClient, _topicRegistry, _validator, _config);
    }

    private string GetSelectedProvider() =>
        _cmbProvider.SelectedIndex == 1 ? AiGrammarProviders.Gemini : AiGrammarProviders.OpenAi;

    private void OnProviderChanged()
    {
        RebuildAiClients();
        var provider = GetSelectedProvider();
        var settings = provider == AiGrammarProviders.Gemini ? _config.Gemini : _config.OpenAi;

        _txtApiKey.Text = settings.ApiKey;

        _cmbEnrichModel.Items.Clear();
        _cmbCheckpointModel.Items.Clear();
        foreach (var m in AiGrammarClientFactory.GetModelsForProvider(provider))
        {
            _cmbEnrichModel.Items.Add(m);
            _cmbCheckpointModel.Items.Add(m);
        }
        _cmbEnrichModel.SelectedItem = settings.EnrichmentModel;
        _cmbCheckpointModel.SelectedItem = settings.CheckpointModel;
        if (_cmbEnrichModel.SelectedIndex < 0 && _cmbEnrichModel.Items.Count > 0)
            _cmbEnrichModel.SelectedIndex = 0;
        if (_cmbCheckpointModel.SelectedIndex < 0 && _cmbCheckpointModel.Items.Count > 0)
            _cmbCheckpointModel.SelectedIndex = 0;
    }

    private void UpdateDataSourceUi()
    {
        var fromFirestore = _cmbDataSource.SelectedIndex == 1;
        _txtJsonFile.Enabled = !fromFirestore;
        _btnBrowseJson!.Enabled = !fromFirestore;
        _lblJson!.Visible = !fromFirestore;
        _lblDocId!.Visible = fromFirestore;
        _txtDocId.Visible = fromFirestore;
        _txtDocId.Enabled = fromFirestore;
    }

    private async Task LoadDataAsync()
    {
        if (_cmbDataSource.SelectedIndex == 1)
            await LoadFromFirestoreAsync();
        else
            TryLoadJson();
    }

    private void BuildUi()
    {
        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 4,
            Padding = new Padding(12)
        };
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 140));

        _cmbDataSource.Items.AddRange(new object[] { "JSON file", "Firestore" });
        _cmbDataSource.SelectedIndex = 0;
        _cmbDataSource.SelectedIndexChanged += (_, _) => UpdateDataSourceUi();

        var row1 = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = true };
        row1.Controls.Add(new Label { Text = "Nguồn:", AutoSize = true, Padding = new Padding(0, 6, 0, 0) });
        row1.Controls.Add(_cmbDataSource);
        _lblJson = new Label { Text = "JSON:", AutoSize = true, Padding = new Padding(4, 6, 0, 0) };
        row1.Controls.Add(_lblJson);
        row1.Controls.Add(_txtJsonFile);
        _btnBrowseJson = new Button { Text = "...", Width = 36 };
        _btnBrowseJson.Click += (_, _) => BrowseJson();
        row1.Controls.Add(_btnBrowseJson);
        _lblDocId = new Label { Text = "Doc ID:", AutoSize = true, Padding = new Padding(4, 6, 0, 0), Visible = false };
        row1.Controls.Add(_lblDocId);
        row1.Controls.Add(_txtDocId);
        _txtDocId.Visible = false;
        var btnLoad = new Button { Text = "Load" };
        btnLoad.Click += async (_, _) => await LoadDataAsync();
        row1.Controls.Add(btnLoad);
        row1.Controls.Add(new Label { Text = "Unit:", AutoSize = true, Padding = new Padding(8, 6, 0, 0) });
        _cmbUnitFilter.Items.Add("(Tất cả)");
        _cmbUnitFilter.SelectedIndex = 0;
        row1.Controls.Add(_cmbUnitFilter);

        var row2 = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = true };
        row2.Controls.Add(new Label { Text = "AI:", AutoSize = true, Padding = new Padding(0, 6, 0, 0) });
        row2.Controls.Add(_cmbProvider);
        row2.Controls.Add(new Label { Text = "API Key:", AutoSize = true, Padding = new Padding(8, 6, 0, 0) });
        row2.Controls.Add(_txtApiKey);
        row2.Controls.Add(new Label { Text = "Enrich model:", AutoSize = true, Padding = new Padding(8, 6, 0, 0) });
        row2.Controls.Add(_cmbEnrichModel);
        row2.Controls.Add(new Label { Text = "Checkpoint model:", AutoSize = true, Padding = new Padding(8, 6, 0, 0) });
        row2.Controls.Add(_cmbCheckpointModel);

        var row3 = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = true };
        row3.Controls.Add(_chkEnrich);
        row3.Controls.Add(_chkCheckpoints);
        row3.Controls.Add(new Label { Text = "Checkpoint mỗi N bài:", AutoSize = true, Padding = new Padding(8, 4, 0, 0) });
        row3.Controls.Add(_numEveryN);
        var btnRun = new Button { Text = "Chạy AI", Width = 100 };
        btnRun.Click += async (_, _) => await RunAiAsync();
        row3.Controls.Add(btnRun);
        var btnApply = new Button { Text = "Áp dụng đã chọn", Width = 110 };
        btnApply.Click += (_, _) => ApplyAccepted();
        row3.Controls.Add(btnApply);
        var btnExport = new Button { Text = "Export JSON", Width = 100 };
        btnExport.Click += (_, _) => ExportJson();
        row3.Controls.Add(btnExport);
        var btnUpload = new Button { Text = "Upload Firestore", Width = 120 };
        btnUpload.Click += async (_, _) => await UploadAsync();
        row3.Controls.Add(btnUpload);

        _dgv.Dock = DockStyle.Fill;
        _dgv.AutoGenerateColumns = false;
        _dgv.AllowUserToAddRows = false;
        _dgv.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
        _dgv.Columns.Add(new DataGridViewCheckBoxColumn { Name = "Accepted", HeaderText = "OK", Width = 36 });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "ExerciseId", HeaderText = "Exercise", Width = 140, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "Index", HeaderText = "#", Width = 32, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "Topic", HeaderText = "Topic", Width = 110, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "Anchor", HeaderText = "Neo", Width = 40, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "Kind", HeaderText = "Loại", Width = 70, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "Before", HeaderText = "Trước", Width = 140, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "After", HeaderText = "Sau", Width = 180, ReadOnly = true });
        _dgv.Columns.Add(new DataGridViewTextBoxColumn { Name = "Error", HeaderText = "Lỗi", Width = 100, ReadOnly = true });

        _rtbLog.ReadOnly = true;
        _rtbLog.Font = new Font(Font.FontFamily, 9f);

        root.Controls.Add(row1, 0, 0);
        root.Controls.Add(row2, 0, 1);
        root.Controls.Add(row3, 0, 2);
        root.Controls.Add(_dgv, 0, 3);

        Controls.Add(root);
        Controls.Add(_progress);
        Controls.Add(_rtbLog);
    }

    private void Log(string message)
    {
        _rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}\n");
        _rtbLog.ScrollToCaret();
    }

    private void BrowseJson()
    {
        using var dlg = new OpenFileDialog { Filter = "JSON|*.json" };
        if (dlg.ShowDialog() == DialogResult.OK)
        {
            _txtJsonFile.Text = dlg.FileName;
            TryLoadJson();
        }
    }

    private void TryLoadJson()
    {
        try
        {
            _jsonPath = _txtJsonFile.Text.Trim();
            if (!File.Exists(_jsonPath))
            {
                MessageBox.Show("Chọn file JSON hợp lệ.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            _importData = JsonParser.ParseJsonFile(_jsonPath);
            AfterDataLoaded($"file JSON");
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private async Task LoadFromFirestoreAsync()
    {
        var docInput = _txtDocId.Text.Trim();
        if (string.IsNullOrEmpty(docInput))
        {
            MessageBox.Show(
                "Nhập Document ID.\nVí dụ: unit_a1_1, lesson_a1_1_1, exercise_a1_1_1_1, A1\nHoặc: units/unit_a1_1",
                "Firestore",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
            return;
        }

        if (string.IsNullOrWhiteSpace(_projectId))
        {
            MessageBox.Show("Cần Project ID từ màn hình chính.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        _progress.Visible = true;
        try
        {
            await _firestoreService.InitializeAsync(_projectId, _credentialsPath);
            var export = new FirestoreExportService(_firestoreService);
            var progress = new Progress<string>(Log);
            _importData = await export.LoadByDocumentIdAsync(docInput, progress);

            var (_, _, docId) = FirestoreExportService.ResolveDocument(docInput);
            _jsonPath = Path.Combine(
                Path.GetTempPath(),
                $"firestore_export_{docId}_{DateTime.Now:yyyyMMddHHmmss}.json");
            ImportDataExporter.ExportToFile(_importData, _jsonPath, suffix: "");

            AfterDataLoaded($"Firestore ({docId})");
            Log($"Đã lưu snapshot tạm: {_jsonPath}");
        }
        catch (Exception ex)
        {
            Log($"Firestore load lỗi: {ex.Message}");
            MessageBox.Show(ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            _progress.Visible = false;
        }
    }

    private void AfterDataLoaded(string source)
    {
        PopulateUnitFilter();
        _topicPreviews.Clear();
        _checkpointRows.Clear();
        RefreshGrid();
        Log($"Đã load từ {source}: {_importData?.Exercises?.Count ?? 0} exercises, {_importData?.Lessons?.Count ?? 0} lessons.");
    }

    private void PopulateUnitFilter()
    {
        _cmbUnitFilter.Items.Clear();
        _cmbUnitFilter.Items.Add("(Tất cả)");
        if (_importData?.Exercises != null)
        {
            foreach (var unitId in _importData.Exercises.Values.Select(e => e.UnitId).Distinct().OrderBy(u => u))
                _cmbUnitFilter.Items.Add(unitId);
        }
        _cmbUnitFilter.SelectedIndex = 0;
    }

    private string? SelectedUnitFilter()
    {
        if (_cmbUnitFilter.SelectedIndex <= 0) return null;
        return _cmbUnitFilter.SelectedItem?.ToString();
    }

    private IEnumerable<KeyValuePair<string, ExerciseModel>> FilteredExercises()
    {
        if (_importData?.Exercises == null) yield break;
        var unit = SelectedUnitFilter();
        foreach (var kvp in _importData.Exercises)
        {
            if (unit == null || kvp.Value.UnitId == unit)
                yield return kvp;
        }
    }

    private async Task RunAiAsync()
    {
        if (_importData?.Exercises == null)
        {
            MessageBox.Show("Load JSON trước.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        ApplyApiKeyFromUi();
        RebuildAiClients();
        var provider = GetSelectedProvider();
        var ps = provider == AiGrammarProviders.Gemini ? _config.Gemini : _config.OpenAi;
        ps.EnrichmentModel = _cmbEnrichModel.SelectedItem?.ToString() ?? ps.EnrichmentModel;
        ps.CheckpointModel = _cmbCheckpointModel.SelectedItem?.ToString() ?? ps.CheckpointModel;
        _config.CheckpointEveryN = (int)_numEveryN.Value;

        _topicPreviews.Clear();
        _checkpointRows.Clear();
        _progress.Visible = true;

        try
        {
            if (_chkEnrich.Checked)
                await RunPhase1Async();

            if (_chkCheckpoints.Checked)
                await RunPhase2Async();

            RefreshGrid();
            Log("Hoàn thành chạy AI. Xem preview và bấm 'Áp dụng đã chọn'.");
        }
        catch (Exception ex)
        {
            Log($"Lỗi: {ex.Message}");
            MessageBox.Show(ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            _progress.Visible = false;
        }
    }

    private void ApplyApiKeyFromUi()
    {
        if (string.IsNullOrWhiteSpace(_txtApiKey.Text)) return;
        var key = _txtApiKey.Text.Trim();
        if (GetSelectedProvider() == AiGrammarProviders.Gemini)
            _config.Gemini.ApiKey = key;
        else
            _config.OpenAi.ApiKey = key;
    }

    private UnitModel? ResolveUnit(string unitId)
    {
        if (_importData?.Units != null && _importData.Units.TryGetValue(unitId, out var u))
            return u;
        return _importData?.Units?.Values.FirstOrDefault(x => x.Id == unitId);
    }

    private async Task RunPhase1Async()
    {
        var lessons = _importData!.Lessons ?? new Dictionary<string, LessonModel>();
        var list = FilteredExercises().ToList();
        var enrichModel = _cmbEnrichModel.SelectedItem?.ToString()
            ?? _config.GetEnrichmentModel(GetSelectedProvider());

        Log($"Phase 1 (topic-anchor): {_aiClient.ProviderName}, {list.Count} exercises...");

        foreach (var kvp in list)
        {
            lessons.TryGetValue(kvp.Value.LessonId, out var lesson);
            lesson ??= lessons.Values.FirstOrDefault(l => l.Id == kvp.Value.LessonId);

            UnitModel? unit = null;
            if (!string.IsNullOrEmpty(kvp.Value.UnitId))
                unit = ResolveUnit(kvp.Value.UnitId);

            var preview = await _enrichmentPipeline.EnrichExerciseWithTopicAnchorsAsync(
                kvp.Value, unit, lesson, enrichModel);
            _topicPreviews.Add(preview);
            RefreshGrid();
            Application.DoEvents();
        }
    }

    private async Task RunPhase2Async()
    {
        if (_importData?.Exercises == null) return;

        var unit = SelectedUnitFilter();
        var byLesson = _importData.Exercises.Values
            .Where(e => unit == null || e.UnitId == unit)
            .GroupBy(e => e.LessonId);

        foreach (var group in byLesson)
        {
            var lessonId = group.Key;
            var exercises = group.OrderBy(e => e.Id, Comparer<string>.Create(ExerciseIdPlanner.CompareExerciseIds)).ToList();
            if (exercises.Count == 0) continue;

            LessonModel? lesson = null;
            if (_importData.Lessons != null)
                _importData.Lessons.TryGetValue(lessonId, out lesson);
            lesson ??= _importData.Lessons?.Values.FirstOrDefault(l => l.Id == lessonId);

            var sortedIds = exercises.Select(e => e.Id).ToList();
            var anchors = ExerciseIdPlanner.SuggestCheckpointAnchors(
                sortedIds,
                _config.CheckpointEveryN,
                _config.MaxCheckpointsPerLesson);

            Log($"Phase 2: phân tích lesson {lessonId} ({exercises.Count} bài)...");
            var analysis = await _checkpointPipeline.AnalyzeLessonAsync(
                lessonId,
                exercises,
                lesson,
                anchors);

            if (analysis == null || analysis.Checkpoints.Count == 0)
            {
                Log($"  Bỏ qua {lessonId}: không có checkpoint.");
                continue;
            }

            var cumulativeRenames = new Dictionary<string, string>();
            foreach (var placement in analysis.Checkpoints.OrderBy(c => ExerciseIdPlanner.GetExerciseOrderNumber(c.AfterExerciseId)))
            {
                var anchorId = placement.AfterExerciseId;
                var currentIds = exercises.Select(e =>
                    cumulativeRenames.TryGetValue(e.Id, out var mapped) ? mapped : e.Id).ToList();

                if (!currentIds.Contains(anchorId))
                    continue;

                IdInsertPlan plan;
                try
                {
                    plan = ExerciseIdPlanner.PlanInsertAfter(anchorId, currentIds);
                }
                catch (Exception ex)
                {
                    Log($"  Plan lỗi {anchorId}: {ex.Message}");
                    continue;
                }

                foreach (var rename in plan.Renames)
                {
                    cumulativeRenames[rename.Key] = rename.Value;
                    if (_importData.Exercises.TryGetValue(rename.Key, out var exModel))
                    {
                        _importData.Exercises.Remove(rename.Key);
                        exModel.Id = rename.Value;
                        _importData.Exercises[rename.Value] = exModel;
                        var idx = exercises.FindIndex(e => e.Id == rename.Key);
                        if (idx >= 0)
                            exercises[idx] = exModel;
                    }
                }

                var anchor = _importData.Exercises[anchorId];
                ExerciseModel generated;
                try
                {
                    generated = await _checkpointPipeline.GenerateCheckpointAsync(analysis, anchor);
                }
                catch (Exception ex)
                {
                    Log($"  Generate lỗi: {ex.Message}");
                    continue;
                }

                var preview = new CheckpointPreview
                {
                    NewExerciseId = plan.NewExerciseId,
                    AfterExerciseId = anchorId,
                    LessonId = lessonId,
                    IdRenames = plan.Renames,
                    Exercise = generated,
                    Summary = ExerciseTextHelper.ToDisplayText(generated.Question, "vi")
                };
                _checkpointRows.Add(preview);
                Log($"  Checkpoint: {plan.NewExerciseId} sau {anchorId}");
            }
        }
    }

    private void RefreshGrid()
    {
        _dgv.Rows.Clear();
        foreach (var preview in _topicPreviews)
        {
            if (preview.Rows.Count == 0)
            {
                _dgv.Rows.Add(
                    !preview.Skipped,
                    preview.ExerciseId,
                    "",
                    "",
                    "",
                    preview.Skipped ? "Lỗi" : "Exercise",
                    "",
                    preview.Error ?? (preview.Skipped ? "skipped" : ""),
                    preview.Error ?? "");
                continue;
            }

            foreach (var row in preview.Rows)
            {
                var kind = row.IsAnchor ? "Neo" : "Giữ";
                _dgv.Rows.Add(
                    row.Accepted && !row.Skipped,
                    row.ExerciseId,
                    row.Index.ToString(),
                    row.TopicId,
                    row.IsAnchor ? "✓" : "",
                    kind,
                    Truncate(row.BeforeExplanation, 80),
                    Truncate(row.AfterExplanation, 120),
                    row.Error ?? preview.Error ?? "");
            }
        }

        foreach (var row in _checkpointRows)
        {
            _dgv.Rows.Add(
                row.Accepted,
                row.NewExerciseId,
                "",
                "",
                "",
                "Checkpoint",
                Truncate($"Sau {row.AfterExerciseId}", 80),
                Truncate(row.Summary, 120),
                "");
        }
    }

    private static string Truncate(string s, int max)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Length <= max ? s : s[..max] + "...";
    }

    private void SyncAcceptedFromGrid()
    {
        var checkpointIndex = 0;
        foreach (DataGridViewRow gridRow in _dgv.Rows)
        {
            if (gridRow.IsNewRow) continue;
            var accepted = gridRow.Cells["Accepted"].Value is true;
            var kind = gridRow.Cells["Kind"].Value?.ToString();

            if (kind is "Neo" or "Giữ" or "Lỗi")
            {
                var exerciseId = gridRow.Cells["ExerciseId"].Value?.ToString() ?? "";
                var indexText = gridRow.Cells["Index"].Value?.ToString();
                var preview = _topicPreviews.FirstOrDefault(p => p.ExerciseId == exerciseId);
                if (preview == null) continue;

                if (string.IsNullOrEmpty(indexText))
                {
                    foreach (var r in preview.Rows)
                        r.Accepted = accepted;
                    continue;
                }

                if (int.TryParse(indexText, out var idx))
                {
                    var row = preview.Rows.FirstOrDefault(r => r.Index == idx);
                    if (row != null)
                        row.Accepted = accepted;
                }
            }
            else if (kind == "Checkpoint" && checkpointIndex < _checkpointRows.Count)
            {
                _checkpointRows[checkpointIndex].Accepted = accepted;
                checkpointIndex++;
            }
        }
    }

    private void ApplyAccepted()
    {
        if (_importData?.Exercises == null) return;
        SyncAcceptedFromGrid();

        var applied = 0;
        foreach (var preview in _topicPreviews)
        {
            if (preview.Skipped) continue;
            if (!preview.Rows.Any(r => r.Accepted && r.IsAnchor && r.PatchExplanation != null))
                continue;
            if (!_importData.Exercises.TryGetValue(preview.ExerciseId, out var ex))
                continue;
            _enrichmentPipeline.ApplyTopicAnchorPreview(ex, preview);
            applied++;
        }

        foreach (var row in _checkpointRows)
        {
            if (!row.Accepted || row.Exercise == null) continue;
            _checkpointPipeline.ApplyCheckpointToData(_importData, row, row.Exercise);
            applied++;
        }

        Log($"Đã áp dụng {applied} thay đổi vào bộ nhớ.");
        MessageBox.Show($"Đã áp dụng {applied} mục. Export hoặc Upload để lưu.", "OK",
            MessageBoxButtons.OK, MessageBoxIcon.Information);
    }

    private void ExportJson()
    {
        if (_importData == null || string.IsNullOrEmpty(_jsonPath))
        {
            MessageBox.Show("Không có dữ liệu.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }
        var path = ImportDataExporter.ExportToFile(_importData, _jsonPath);
        Log($"Đã export: {path}");
        MessageBox.Show($"Đã lưu:\n{path}", "Export", MessageBoxButtons.OK, MessageBoxIcon.Information);
    }

    private async Task UploadAsync()
    {
        if (_importData == null)
        {
            MessageBox.Show("Không có dữ liệu.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        var uploadLessons = _checkpointRows.Any(r => r.Accepted);
        if (MessageBox.Show(
                uploadLessons
                    ? "Upload exercises + lessons đã sửa lên Firestore?"
                    : "Upload các exercise đã chọn lên Firestore?",
                "Xác nhận",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question) != DialogResult.Yes)
            return;

        _progress.Visible = true;
        try
        {
            await _firestoreService.InitializeAsync(_projectId, _credentialsPath);
            var progress = new Progress<string>(m => Log(m));

            // Chỉ upload lesson khi Phase 2 đã chèn checkpoint (có thể đổi danh sách exercises trong lesson)
            if (_checkpointRows.Any(r => r.Accepted)
                && _importData.Lessons != null
                && _importData.Lessons.Count > 0)
            {
                var lessonList = _importData.Lessons.Values.ToList();
                await _firestoreService.ImportLessonsAsync(lessonList, progress);
            }

            if (_importData.Exercises != null && _importData.Exercises.Count > 0)
            {
                var toUpload = new List<ExerciseModel>();
                foreach (var preview in _topicPreviews)
                {
                    if (preview.Skipped) continue;
                    if (!preview.Rows.Any(r => r.Accepted && r.IsAnchor))
                        continue;
                    if (_importData.Exercises.TryGetValue(preview.ExerciseId, out var ex))
                        toUpload.Add(ex);
                }
                foreach (var row in _checkpointRows.Where(r => r.Accepted && r.Exercise != null))
                {
                    if (_importData.Exercises.TryGetValue(row.NewExerciseId, out var ex))
                        toUpload.Add(ex);
                }

                if (toUpload.Count == 0)
                    toUpload = FilteredExercises().Select(k => k.Value).ToList();

                await _firestoreService.ImportExercisesAsync(toUpload, progress);
            }

            Log("Upload hoàn tất.");
            MessageBox.Show("Upload hoàn tất.", "OK", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        catch (Exception ex)
        {
            Log($"Upload lỗi: {ex.Message}");
            MessageBox.Show(ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            _progress.Visible = false;
        }
    }
}
