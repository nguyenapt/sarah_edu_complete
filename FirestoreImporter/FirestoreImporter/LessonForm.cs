using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using FirestoreImporter.Models;
using FirestoreImporter.Services;
using Newtonsoft.Json;

namespace FirestoreImporter
{
    public partial class LessonForm : Form
    {
        // Lesson Title
        private Dictionary<string, string> _titleDictionary;
        
        // Theory Content
        private Dictionary<string, string> _theoryDescriptionDictionary;
        private Dictionary<string, string> _currentExampleExplanationDictionary;
        private List<Example> _examples;
        private Dictionary<string, List<string>> _hintsDictionary; // language code -> list of hints
        private List<Dictionary<string, object>> _usageItems; // List of usage items with language keys

        public LessonForm()
        {
            InitializeComponent();
            _titleDictionary = new Dictionary<string, string>();
            _theoryDescriptionDictionary = new Dictionary<string, string>();
            _currentExampleExplanationDictionary = new Dictionary<string, string>();
            _examples = new List<Example>();
            _hintsDictionary = new Dictionary<string, List<string>>();
            _usageItems = new List<Dictionary<string, object>>();
            SetupDataGridViews();
            SetupAutoBuildIds();
        }

        private void SetupAutoBuildIds()
        {
            cbLevelId.SelectedIndexChanged += OnIdControlsChanged;
            numUnit.ValueChanged += OnIdControlsChanged;
            numLesson.ValueChanged += OnIdControlsChanged;
        }

        private void OnIdControlsChanged(object? sender, EventArgs e)
        {
            BuildIds();
        }

        private void BuildIds()
        {
            // Lấy level ID (lowercase)
            string levelId = cbLevelId.SelectedItem?.ToString()?.ToLower() ?? "";
            
            // Lấy các giá trị numeric
            int unitValue = (int)numUnit.Value;
            int lessonValue = (int)numLesson.Value;

            // Build Unit ID: unit_{levelId}_{unitValue}
            if (!string.IsNullOrEmpty(levelId) && unitValue > 0)
            {
                txtUnitId.Text = $"unit_{levelId}_{unitValue}";
            }

            // Build Lesson ID: lesson_{levelId}_{unitValue}_{lessonValue}
            if (!string.IsNullOrEmpty(levelId) && unitValue > 0 && lessonValue > 0)
            {
                txtLessonId.Text = $"lesson_{levelId}_{unitValue}_{lessonValue}";
            }
        }

        private void SetupDataGridViews()
        {
            // Setup grvTitle (Lesson Title)
            SetupTitleGrid();
            
            // Setup dataGridView1 (Theory Description)
            SetupDescriptionGrid();
            
            // Setup grvExplanation (Example Explanation)
            SetupExplanationGrid();
            
            // Setup grvExample (Examples)
            SetupExampleGrid();
            
            // Setup grvHint (Hints)
            SetupHintGrid();
            
            // Setup grvUsageLanguage (Usage Language)
            SetupUsageLanguageGrid();
            
            // Setup grvUsage (Usage Items)
            SetupUsageGrid();
        }

        private void SetupTitleGrid()
        {
            grvTitle.AutoGenerateColumns = false;
            grvTitle.Columns.Clear();
            grvTitle.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            grvTitle.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 550,
                ReadOnly = true
            });
            grvTitle.AllowUserToAddRows = false;
            grvTitle.AllowUserToDeleteRows = true;
            grvTitle.ReadOnly = true;
            grvTitle.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvTitle.UserDeletingRow += GrvTitle_UserDeletingRow;
        }

        private void SetupDescriptionGrid()
        {
            dataGridView1.AutoGenerateColumns = false;
            dataGridView1.Columns.Clear();
            dataGridView1.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            dataGridView1.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 550,
                ReadOnly = true
            });
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.AllowUserToDeleteRows = true;
            dataGridView1.ReadOnly = true;
            dataGridView1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dataGridView1.UserDeletingRow += GrvDescription_UserDeletingRow;
        }

        private void SetupExplanationGrid()
        {
            grvExplanation.AutoGenerateColumns = false;
            grvExplanation.Columns.Clear();
            grvExplanation.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            grvExplanation.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 500,
                ReadOnly = true
            });
            grvExplanation.AllowUserToAddRows = false;
            grvExplanation.AllowUserToDeleteRows = true;
            grvExplanation.ReadOnly = true;
            grvExplanation.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvExplanation.UserDeletingRow += GrvExplanation_UserDeletingRow;
        }

        private void SetupExampleGrid()
        {
            grvExample.AutoGenerateColumns = false;
            grvExample.Columns.Clear();
            grvExample.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colIndex",
                HeaderText = "#",
                DataPropertyName = "Index",
                Width = 50,
                ReadOnly = true
            });
            grvExample.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colSentence",
                HeaderText = "Sentence",
                DataPropertyName = "Sentence",
                Width = 400,
                ReadOnly = true
            });
            grvExample.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colExplanation",
                HeaderText = "Explanation",
                DataPropertyName = "Explanation",
                Width = 250,
                ReadOnly = true
            });
            grvExample.AllowUserToAddRows = false;
            grvExample.AllowUserToDeleteRows = true;
            grvExample.ReadOnly = true;
            grvExample.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvExample.UserDeletingRow += GrvExample_UserDeletingRow;
        }

        private void SetupHintGrid()
        {
            grvHint.AutoGenerateColumns = false;
            grvHint.Columns.Clear();
            grvHint.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvHint.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colHints",
                HeaderText = "Hints",
                DataPropertyName = "Hints",
                Width = 550,
                ReadOnly = true
            });
            grvHint.AllowUserToAddRows = false;
            grvHint.AllowUserToDeleteRows = true;
            grvHint.ReadOnly = true;
            grvHint.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvHint.UserDeletingRow += GrvHint_UserDeletingRow;
        }

        private void SetupUsageLanguageGrid()
        {
            grvUsageLanguage.AutoGenerateColumns = false;
            grvUsageLanguage.Columns.Clear();
            grvUsageLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvUsageLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colTitle",
                HeaderText = "Title",
                DataPropertyName = "Title",
                Width = 250,
                ReadOnly = true
            });
            grvUsageLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colExample",
                HeaderText = "Example",
                DataPropertyName = "Example",
                Width = 300,
                ReadOnly = true
            });
            grvUsageLanguage.AllowUserToAddRows = false;
            grvUsageLanguage.AllowUserToDeleteRows = true;
            grvUsageLanguage.ReadOnly = true;
            grvUsageLanguage.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvUsageLanguage.UserDeletingRow += GrvUsageLanguage_UserDeletingRow;
        }

        private void SetupUsageGrid()
        {
            grvUsage.AutoGenerateColumns = false;
            grvUsage.Columns.Clear();
            grvUsage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colIndex",
                HeaderText = "#",
                DataPropertyName = "Index",
                Width = 50,
                ReadOnly = true
            });
            grvUsage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colUsage",
                HeaderText = "Usage",
                DataPropertyName = "Usage",
                Width = 650,
                ReadOnly = true
            });
            grvUsage.AllowUserToAddRows = false;
            grvUsage.AllowUserToDeleteRows = true;
            grvUsage.ReadOnly = true;
            grvUsage.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvUsage.UserDeletingRow += GrvUsage_UserDeletingRow;
        }

        // Helper classes để bind vào DataGridView
        private class ExampleGridItem
        {
            public int Index { get; set; }
            public string Sentence { get; set; } = string.Empty;
            public string Explanation { get; set; } = string.Empty;
        }

        private class HintGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Hints { get; set; } = string.Empty;
        }

        private class UsageLanguageGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Title { get; set; } = string.Empty;
            public string Example { get; set; } = string.Empty;
        }

        private class UsageGridItem
        {
            public int Index { get; set; }
            public string Usage { get; set; } = string.Empty;
        }

        private void GrvTitle_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is KeyValuePair<string, string> kvp)
            {
                _titleDictionary.Remove(kvp.Key);
            }
        }

        private void RefreshTitleGrid()
        {
            grvTitle.DataSource = null;
            if (_titleDictionary.Count > 0)
            {
                grvTitle.DataSource = _titleDictionary.ToList();
            }
        }

        private void RefreshDescriptionGrid()
        {
            dataGridView1.DataSource = null;
            if (_theoryDescriptionDictionary.Count > 0)
            {
                dataGridView1.DataSource = _theoryDescriptionDictionary.ToList();
            }
        }

        private void GrvDescription_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is KeyValuePair<string, string> kvp)
            {
                _theoryDescriptionDictionary.Remove(kvp.Key);
            }
        }

        private void RefreshExplanationGrid()
        {
            grvExplanation.DataSource = null;
            if (_currentExampleExplanationDictionary.Count > 0)
            {
                grvExplanation.DataSource = _currentExampleExplanationDictionary.ToList();
            }
        }

        private void GrvExplanation_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is KeyValuePair<string, string> kvp)
            {
                _currentExampleExplanationDictionary.Remove(kvp.Key);
            }
        }

        private void RefreshExampleGrid()
        {
            grvExample.DataSource = null;
            if (_examples.Count > 0)
            {
                var dataSource = _examples.Select((ex, index) => new ExampleGridItem
                {
                    Index = index + 1,
                    Sentence = ex.Sentence,
                    Explanation = ex.Explanation != null && ex.Explanation.Count > 0
                        ? (ex.Explanation.ContainsKey("en") ? ex.Explanation["en"] : ex.Explanation.Values.FirstOrDefault() ?? "")
                        : ""
                }).ToList();
                grvExample.DataSource = dataSource;
            }
        }

        private void GrvExample_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is ExampleGridItem item)
            {
                int index = item.Index - 1;
                if (index >= 0 && index < _examples.Count)
                {
                    _examples.RemoveAt(index);
                    RefreshExampleGrid();
                }
            }
        }

        private void RefreshHintGrid()
        {
            grvHint.DataSource = null;
            if (_hintsDictionary.Count > 0)
            {
                var dataSource = _hintsDictionary.Select(kvp => new HintGridItem
                {
                    LanguageCode = kvp.Key,
                    Hints = string.Join("\n", kvp.Value)
                }).ToList();
                grvHint.DataSource = dataSource;
            }
        }

        private void GrvHint_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is HintGridItem item)
            {
                _hintsDictionary.Remove(item.LanguageCode);
            }
        }

        private void RefreshUsageLanguageGrid()
        {
            grvUsageLanguage.DataSource = null;
            // Usage language grid sẽ được refresh khi add language usage
        }

        private Dictionary<string, object>? _currentUsageLanguageData;

        private void GrvUsageLanguage_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is UsageLanguageGridItem item)
            {
                if (_currentUsageLanguageData != null)
                {
                    _currentUsageLanguageData.Remove(item.LanguageCode);
                    RefreshUsageLanguageGrid();
                }
            }
        }

        private void RefreshUsageGrid()
        {
            grvUsage.DataSource = null;
            if (_usageItems.Count > 0)
            {
                var dataSource = _usageItems.Select((usage, index) => new UsageGridItem
                {
                    Index = index + 1,
                    Usage = JsonConvert.SerializeObject(usage, Formatting.None)
                }).ToList();
                grvUsage.DataSource = dataSource;
            }
        }

        private void GrvUsage_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is UsageGridItem item)
            {
                int index = item.Index - 1;
                if (index >= 0 && index < _usageItems.Count)
                {
                    _usageItems.RemoveAt(index);
                    RefreshUsageGrid();
                }
            }
        }

        private void btnExportJson_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtUnitId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Unit ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Get JSON string
                string jsonContent = ExportJson();

                // Get Desktop path
                string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                string filePath = Path.Combine(desktopPath, "lesson.json");

                // Write file
                File.WriteAllText(filePath, jsonContent, Encoding.UTF8);

                // Show success message
                MessageBox.Show($"Đã export JSON thành công!\nFile đã được lưu tại: {filePath}",
                    "Thành công",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi export JSON: {ex.Message}",
                    "Lỗi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        private async void btnExportJsonFireStore_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtUnitId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Unit ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Kiểm tra xem có file serviceAccountKey.json trong thư mục ứng dụng không
                string credentialsPath = string.Empty;
                string appDirectory = AppDomain.CurrentDomain.BaseDirectory;
                string defaultCredentialsPath = Path.Combine(appDirectory, "serviceAccountKey.json");

                if (File.Exists(defaultCredentialsPath))
                {
                    // Sử dụng file có sẵn trong thư mục ứng dụng
                    credentialsPath = defaultCredentialsPath;
                }
                else
                {
                    // Mở dialog để chọn file
                    using var openFileDialog = new OpenFileDialog
                    {
                        Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*",
                        Title = "Chọn Firebase Service Account Key File",
                        FileName = "serviceAccountKey.json"
                    };

                    if (openFileDialog.ShowDialog() != DialogResult.OK)
                    {
                        return; // User đã hủy
                    }

                    credentialsPath = openFileDialog.FileName;
                }

                // Đọc project_id từ file JSON
                string projectId = string.Empty;
                try
                {
                    string jsonContent = File.ReadAllText(credentialsPath);
                    dynamic? jsonObj = JsonConvert.DeserializeObject(jsonContent);
                    projectId = jsonObj?.project_id?.ToString() ?? string.Empty;
                }
                catch
                {
                    // Nếu không đọc được từ file, yêu cầu user nhập
                }

                // Nếu không có project_id từ file, yêu cầu user nhập
                if (string.IsNullOrWhiteSpace(projectId))
                {
                    using var inputDialog = new Form
                    {
                        Text = "Nhập Project ID",
                        Size = new Size(400, 150),
                        StartPosition = FormStartPosition.CenterParent,
                        FormBorderStyle = FormBorderStyle.FixedDialog,
                        MaximizeBox = false,
                        MinimizeBox = false
                    };

                    var lblProjectId = new Label
                    {
                        Text = "Project ID:",
                        Location = new Point(20, 25),
                        Size = new Size(80, 20)
                    };

                    var txtProjectId = new TextBox
                    {
                        Location = new Point(100, 22),
                        Size = new Size(250, 23)
                    };

                    var btnOk = new Button
                    {
                        Text = "OK",
                        DialogResult = DialogResult.OK,
                        Location = new Point(200, 60),
                        Size = new Size(75, 30)
                    };

                    var btnCancel = new Button
                    {
                        Text = "Cancel",
                        DialogResult = DialogResult.Cancel,
                        Location = new Point(285, 60),
                        Size = new Size(75, 30)
                    };

                    inputDialog.Controls.AddRange(new Control[] { lblProjectId, txtProjectId, btnOk, btnCancel });
                    inputDialog.AcceptButton = btnOk;
                    inputDialog.CancelButton = btnCancel;

                    if (inputDialog.ShowDialog() != DialogResult.OK)
                    {
                        return; // User đã hủy
                    }

                    projectId = txtProjectId.Text.Trim();
                    if (string.IsNullOrWhiteSpace(projectId))
                    {
                        MessageBox.Show("Vui lòng nhập Project ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }
                }

                // Disable button để tránh click nhiều lần
                btnExportJsonFireStore.Enabled = false;
                btnExportJsonFireStore.Text = "Đang upload...";

                // Khởi tạo FirestoreService
                var firestoreService = new FirestoreService();
                await firestoreService.InitializeAsync(projectId, credentialsPath);

                // Test connection
                bool isConnected = await firestoreService.TestConnectionAsync();
                if (!isConnected)
                {
                    MessageBox.Show("Không thể kết nối đến Firestore. Vui lòng kiểm tra Project ID và Credentials.",
                        "Lỗi",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return;
                }

                // Tạo LessonModel từ dữ liệu form
                var lesson = CreateLessonFromInputs();

                // Upload lên Firestore
                await firestoreService.ImportLessonAsync(lesson);

                // Thông báo thành công
                MessageBox.Show($"Đã upload Lesson lên Firestore thành công!\nLesson ID: {lesson.Id}",
                    "Thành công",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi upload lên Firestore: {ex.Message}",
                    "Lỗi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                // Restore button
                btnExportJsonFireStore.Enabled = true;
                btnExportJsonFireStore.Text = "Export Json FireStore";
            }
        }

        private LessonModel CreateLessonFromInputs()
        {
            var lesson = new LessonModel
            {
                Id = txtLessonId.Text.Trim(),
                UnitId = txtUnitId.Text.Trim(),
                LevelId = cbLevelId.SelectedItem?.ToString() ?? string.Empty,
                Type = cbType.SelectedItem?.ToString() ?? "grammar",
                Order = (int)numOrder.Value
            };

            // Title từ dictionary
            if (_titleDictionary.Count > 0)
            {
                lesson.Title = new Dictionary<string, string>(_titleDictionary);
            }

            // Content
            var content = new LessonContent();

            // Exercises: split theo dấu phẩy
            if (!string.IsNullOrWhiteSpace(txtExercises.Text))
            {
                content.Exercises = txtExercises.Text.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }

            // Theory Content
            var theory = new TheoryContent();

            // Description từ dictionary
            if (_theoryDescriptionDictionary.Count > 0)
            {
                theory.Description = new Dictionary<string, string>(_theoryDescriptionDictionary);
            }

            // Examples
            if (_examples.Count > 0)
            {
                theory.Examples = _examples;
            }

            // Forms: split theo newline
            var forms = new GrammarForms();
            if (!string.IsNullOrWhiteSpace(txtStatement.Text))
            {
                forms.Statement = txtStatement.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (!string.IsNullOrWhiteSpace(txtNegative.Text))
            {
                forms.Negative = txtNegative.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (!string.IsNullOrWhiteSpace(txtQuestion.Text))
            {
                forms.Question = txtQuestion.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (forms.Statement != null || forms.Negative != null || forms.Question != null)
            {
                theory.Forms = forms;
            }

            // Hints: convert từ dictionary sang object
            if (_hintsDictionary.Count > 0)
            {
                // Hints được lưu dưới dạng Dictionary<string, List<string>>
                var hintsObject = new Dictionary<string, object>();
                foreach (var kvp in _hintsDictionary)
                {
                    hintsObject[kvp.Key] = kvp.Value;
                }
                // Note: TheoryContent không có field Hints trong model hiện tại
                // Có thể cần thêm vào model hoặc lưu vào một field khác
            }

            // Usage: convert từ list sang object
            if (_usageItems.Count > 0)
            {
                // Usage là List<Dictionary<string, object>>
                theory.Usage = _usageItems;
            }

            // Chỉ thêm theory nếu có ít nhất một field
            if (theory.Description != null || theory.Examples.Count > 0 || theory.Forms != null || theory.Usage != null)
            {
                content.Theory = theory;
            }

            lesson.Content = content;

            return lesson;
        }

        public string ExportJson()
        {
            var lesson = CreateLessonFromInputs();

            var jsonData = new Dictionary<string, object>
            {
                { "lessons", new Dictionary<string, LessonModel> { { lesson.Id, lesson } } }
            };
            var jsonResult = JsonConvert.SerializeObject(jsonData, Formatting.Indented);

            return jsonResult;
        }

        private void btnAddTitle_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeTitle.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageTitleValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeTitle.SelectedItem.ToString()!;
            string value = txtLanguageTitleValue.Text.Trim();

            // Update hoặc thêm mới
            _titleDictionary[languageCode] = value;

            // Refresh grid
            RefreshTitleGrid();

            // Clear input
            txtLanguageTitleValue.Clear();
        }

        private void btnAddDescription_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeDescription.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageDescriptionValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Description!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeDescription.SelectedItem.ToString()!;
            string value = txtLanguageDescriptionValue.Text.Trim();

            // Update hoặc thêm mới
            _theoryDescriptionDictionary[languageCode] = value;

            // Refresh grid
            RefreshDescriptionGrid();

            // Clear input
            txtLanguageDescriptionValue.Clear();
        }

        private void btnAddExplanation_Click(object sender, EventArgs e)
        {
            if (cbLanuageCodeExplanation.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageValueExplanation.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Explanation!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanuageCodeExplanation.SelectedItem.ToString()!;
            string value = txtLanguageValueExplanation.Text.Trim();

            // Update hoặc thêm mới vào current example explanation
            _currentExampleExplanationDictionary[languageCode] = value;

            // Refresh grid
            RefreshExplanationGrid();

            // Clear input
            txtLanguageValueExplanation.Clear();
        }

        private void btnAddExample_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSentence.Text))
            {
                MessageBox.Show("Vui lòng nhập Sentence!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var example = new Example
            {
                Sentence = txtSentence.Text.Trim()
            };

            // Thêm explanation nếu có
            if (_currentExampleExplanationDictionary.Count > 0)
            {
                example.Explanation = new Dictionary<string, string>(_currentExampleExplanationDictionary);
            }

            // Thêm vào list
            _examples.Add(example);

            // Refresh grid
            RefreshExampleGrid();

            // Clear inputs
            txtSentence.Clear();
            _currentExampleExplanationDictionary.Clear();
            RefreshExplanationGrid();
        }

        private void btnAddHint_Click(object sender, EventArgs e)
        {
            if (cbHintLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtHintVaue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Hint!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbHintLanguageCode.SelectedItem.ToString()!;
            string value = txtHintVaue.Text.Trim();

            // Split theo newline và tạo list
            var hints = value.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                .Select(s => s.Trim())
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();

            // Update hoặc thêm mới
            _hintsDictionary[languageCode] = hints;

            // Refresh grid
            RefreshHintGrid();

            // Clear input
            txtHintVaue.Clear();
        }

        private void btnAddLanguageUsage_Click(object sender, EventArgs e)
        {
            if (cbUsageLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtUsageTitle.Text))
            {
                MessageBox.Show("Vui lòng nhập Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtUsageExample.Text))
            {
                MessageBox.Show("Vui lòng nhập Example!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbUsageLanguageCode.SelectedItem.ToString()!;
            string title = txtUsageTitle.Text.Trim();
            string example = txtUsageExample.Text.Trim();

            // Khởi tạo _currentUsageLanguageData nếu chưa có
            if (_currentUsageLanguageData == null)
            {
                _currentUsageLanguageData = new Dictionary<string, object>();
            }

            // Thêm/update language data
            _currentUsageLanguageData[languageCode] = new Dictionary<string, string>
            {
                { "title", title },
                { "example", example }
            };

            // Refresh usage language grid
            RefreshUsageLanguageGrid();
            if (_currentUsageLanguageData.Count > 0)
            {
                var dataSource = _currentUsageLanguageData.Select(kvp =>
                {
                    var langData = kvp.Value as Dictionary<string, string>;
                    return new UsageLanguageGridItem
                    {
                        LanguageCode = kvp.Key,
                        Title = langData?.GetValueOrDefault("title") ?? "",
                        Example = langData?.GetValueOrDefault("example") ?? ""
                    };
                }).ToList();
                grvUsageLanguage.DataSource = dataSource;
            }

            // Clear inputs
            txtUsageTitle.Clear();
            txtUsageExample.Clear();
        }

        private void btnAddToUsage_Click(object sender, EventArgs e)
        {
            if (_currentUsageLanguageData == null || _currentUsageLanguageData.Count == 0)
            {
                MessageBox.Show("Vui lòng thêm ít nhất một Language Usage trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Thêm usage item vào list
            _usageItems.Add(new Dictionary<string, object>(_currentUsageLanguageData));

            // Refresh usage grid
            RefreshUsageGrid();

            // Clear current usage language data
            _currentUsageLanguageData = null;
            grvUsageLanguage.DataSource = null;
        }
    }
}
