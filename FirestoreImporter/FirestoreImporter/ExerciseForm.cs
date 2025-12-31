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
    public partial class ExerciseForm : Form
    {
        private Dictionary<string, string> _questionDictionary;
        private Dictionary<string, string> _explanationDictionary;
        private Dictionary<string, dynamic> _content;
        private bool _isGroupQuestionMode;

        public ExerciseForm(bool isGroupQuestionMode = false)
        {
            InitializeComponent();
            _isGroupQuestionMode = isGroupQuestionMode;
            _questionDictionary = new Dictionary<string, string>();
            _explanationDictionary = new Dictionary<string, string>();
            _content = new Dictionary<string, dynamic>();
            SetupDataGridViews();
            SetupGroupQuestionMode();
            SetupAutoBuildIds();
        }

        private void SetupAutoBuildIds()
        {
            // Chỉ setup auto build IDs khi không phải GroupQuestion mode
            if (!_isGroupQuestionMode)
            {
                cbLevelId.SelectedIndexChanged += OnIdControlsChanged;
                numUnit.ValueChanged += OnIdControlsChanged;
                numLesson.ValueChanged += OnIdControlsChanged;
                numExercise.ValueChanged += OnIdControlsChanged;
            }
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
            int exerciseValue = (int)numExercise.Value;

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

            // Build Exercise ID: exercise_{levelId}_{unitValue}_{lessonValue}_{exerciseValue}
            if (!string.IsNullOrEmpty(levelId) && unitValue > 0 && lessonValue > 0 && exerciseValue > 0)
            {
                txtId.Text = $"exercise_{levelId}_{unitValue}_{lessonValue}_{exerciseValue}";
            }
        }

        private void SetupGroupQuestionMode()
        {
            if (_isGroupQuestionMode)
            {
                // Disable các field không cần thiết khi tạo GroupQuestion
                txtId.Enabled = false;
                txtLessonId.Enabled = false;
                txtUnitId.Enabled = false;
                cbLevelId.Enabled = false;
                numExercise.Enabled = false;
                numLesson.Enabled = false;
                numUnit.Enabled = false;

                // Ẩn nút Export Json và Export Json FireStore, chỉ hiển thị nút Save
                btnExportJson.Visible = false;
                btnExportJsonFireStore.Visible = false;
                btnSave.Visible = true;
            }
            else
            {
                // Ẩn nút Save khi tạo Exercise thông thường
                btnSave.Visible = false;
            }
        }

        private void SetupDataGridViews()
        {
            // Setup grvQuestion
            grvQuestion.AutoGenerateColumns = false;
            grvQuestion.Columns.Clear();
            grvQuestion.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            grvQuestion.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 550,
                ReadOnly = true
            });
            grvQuestion.AllowUserToAddRows = false;
            grvQuestion.AllowUserToDeleteRows = true;
            grvQuestion.ReadOnly = true;
            grvQuestion.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvQuestion.UserDeletingRow += GrvQuestion_UserDeletingRow;

            // Setup grvExplanation
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
                Width = 550,
                ReadOnly = true
            });
            grvExplanation.AllowUserToAddRows = false;
            grvExplanation.AllowUserToDeleteRows = true;
            grvExplanation.ReadOnly = true;
            grvExplanation.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvExplanation.UserDeletingRow += GrvExplanation_UserDeletingRow;

            // Setup grvContent
            grvContent.AutoGenerateColumns = false;
            grvContent.Columns.Clear();
            grvContent.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPropertyName",
                HeaderText = "Property Name",
                DataPropertyName = "PropertyName",
                Width = 200,
                ReadOnly = true
            });
            grvContent.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPropertyType",
                HeaderText = "Type",
                DataPropertyName = "Type",
                Width = 100,
                ReadOnly = true
            });
            grvContent.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPropertyValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 400,
                ReadOnly = true
            });
            grvContent.AllowUserToAddRows = false;
            grvContent.AllowUserToDeleteRows = true;
            grvContent.ReadOnly = true;
            grvContent.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvContent.UserDeletingRow += GrvContent_UserDeletingRow;
        }

        // Helper class để bind vào DataGridView
        private class ContentGridItem
        {
            public string PropertyName { get; set; } = string.Empty;
            public string Type { get; set; } = string.Empty;
            public string Value { get; set; } = string.Empty;
        }

        private void GrvQuestion_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is KeyValuePair<string, string> kvp)
            {
                _questionDictionary.Remove(kvp.Key);
            }
        }

        private void GrvExplanation_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is KeyValuePair<string, string> kvp)
            {
                _explanationDictionary.Remove(kvp.Key);
            }
        }

        private void RefreshQuestionGrid()
        {
            grvQuestion.DataSource = null;
            if (_questionDictionary.Count > 0)
            {
                grvQuestion.DataSource = _questionDictionary.ToList();
            }
        }

        private void RefreshExplanationGrid()
        {
            grvExplanation.DataSource = null;
            if (_explanationDictionary.Count > 0)
            {
                grvExplanation.DataSource = _explanationDictionary.ToList();
            }
        }

        private void RefreshContentGrid()
        {
            grvContent.DataSource = null;
            if (_content.Count > 0)
            {
                var dataSource = _content.Select(kvp => new ContentGridItem
                {
                    PropertyName = kvp.Key,
                    Type = kvp.Value is List<string> ? "array" : "string",
                    Value = kvp.Value is List<string> list ? string.Join(", ", list) : kvp.Value?.ToString() ?? ""
                }).ToList();
                grvContent.DataSource = dataSource;
            }
        }

        private void GrvContent_UserDeletingRow(object? sender, DataGridViewRowCancelEventArgs e)
        {
            if (e.Row.DataBoundItem is ContentGridItem item)
            {
                _content.Remove(item.PropertyName);
            }
        }

        private void btnAddQuestion_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeQuestion.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageQuestionValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Question!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeQuestion.SelectedItem.ToString()!;
            string value = txtLanguageQuestionValue.Text.Trim();

            // Update hoặc thêm mới
            _questionDictionary[languageCode] = value;

            // Refresh grid
            RefreshQuestionGrid();

            // Clear input
            txtLanguageQuestionValue.Clear();
        }

        private void btnAddExplanation_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeExplanation.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageExplanationValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Explanation!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeExplanation.SelectedItem.ToString()!;
            string value = txtLanguageExplanationValue.Text.Trim();

            // Update hoặc thêm mới
            _explanationDictionary[languageCode] = value;

            // Refresh grid
            RefreshExplanationGrid();

            // Clear input
            txtLanguageExplanationValue.Clear();
        }

        private void btnExportJson_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtId.Text))
                {
                    MessageBox.Show("Vui lòng nhập ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Get JSON string
                string jsonContent = ExportJson();

                // Get Desktop path
                string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                string filePath = Path.Combine(desktopPath, "exercise.json");

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
                if (string.IsNullOrWhiteSpace(txtId.Text))
                {
                    MessageBox.Show("Vui lòng nhập ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
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

                // Tạo ExerciseModel từ dữ liệu form
                var exercise = CreateExerciseFromInputs();

                // Upload lên Firestore
                await firestoreService.ImportExerciseAsync(exercise);

                // Thông báo thành công
                MessageBox.Show($"Đã upload Exercise lên Firestore thành công!\nExercise ID: {exercise.Id}",
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

        private ExerciseModel CreateExerciseFromInputs()
        {
            var exercise = new ExerciseModel
            {
                Id = txtId.Text.Trim(),
                LessonId = txtLessonId.Text.Trim(),
                UnitId = txtUnitId.Text.Trim(),
                LevelId = cbLevelId.SelectedItem?.ToString() ?? string.Empty,
                Type = cbType.SelectedItem?.ToString() ?? "single_choice",
                Points = (int)numPoints.Value,
                Difficulty = cbDifficulty.SelectedItem?.ToString() ?? "easy"
            };

            // Time Limit
            if (numTimeLimit.Value > 0)
            {
                exercise.TimeLimit = (int)numTimeLimit.Value;
            }

            // Question từ dictionary
            if (_questionDictionary.Count > 0)
            {
                if (_questionDictionary.Count == 1)
                {
                    // Nếu chỉ có 1 language, lưu dưới dạng string
                    exercise.Question = _questionDictionary.Values.First();
                }
                else
                {
                    // Nếu có nhiều language, lưu dưới dạng dictionary
                    exercise.Question = new Dictionary<string, string>(_questionDictionary);
                }
            }

            // Explanation từ dictionary
            if (_explanationDictionary.Count > 0)
            {
                if (_explanationDictionary.Count == 1)
                {
                    // Nếu chỉ có 1 language, lưu dưới dạng string
                    exercise.Explanation = _explanationDictionary.Values.First();
                }
                else
                {
                    // Nếu có nhiều language, lưu dưới dạng dictionary
                    exercise.Explanation = new Dictionary<string, string>(_explanationDictionary);
                }
            }

            // Audio URL
            if (!string.IsNullOrWhiteSpace(txtAudioUrl.Text))
            {
                exercise.AudioUrl = txtAudioUrl.Text.Trim();
            }

            // Image URL
            if (!string.IsNullOrWhiteSpace(txtImageUrl.Text))
            {
                exercise.ImageUrl = txtImageUrl.Text.Trim();
            }

            // Content từ dictionary
            if (_content.Count > 0)
            {
                exercise.Content = new Dictionary<string, object>();
                foreach (var kvp in _content)
                {
                    exercise.Content[kvp.Key] = kvp.Value;
                }
            }

            return exercise;
        }

        public string ExportJson()
        {
            var exercise = CreateExerciseFromInputs();

            var jsonData = new Dictionary<string, object>
            {
                { "exercises", new Dictionary<string, ExerciseModel> { { exercise.Id, exercise } } }
            };
            var jsonResult = JsonConvert.SerializeObject(jsonData, Formatting.Indented);

            return jsonResult;
        }

        private void btnContentAdd_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPropertyName.Text))
            {
                MessageBox.Show("Vui lòng nhập Property Name!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtPropertyValue.Text))
            {
                MessageBox.Show("Vui lòng nhập Property Value!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (cbPropertyType.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Property Type!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string propertyName = txtPropertyName.Text.Trim();
            string propertyType = cbPropertyType.SelectedItem.ToString()!;
            string propertyValue = txtPropertyValue.Text.Trim();

            dynamic value;

            if (propertyType == "array")
            {
                // Split theo dấu phẩy và tạo List<string>
                value = propertyValue.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList<string>();
            }
            else // string
            {
                // Lưu dưới dạng string
                value = propertyValue;
            }

            // Update hoặc thêm mới
            _content[propertyName] = value;

            // Refresh grid
            RefreshContentGrid();

            // Clear input
            txtPropertyName.Clear();
            txtPropertyValue.Clear();
        }

        private GroupQuestion? _savedGroupQuestion;

        public GroupQuestion? GetGroupQuestion()
        {
            return _savedGroupQuestion;
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields - không cần Id, LessonId khi tạo GroupQuestion
                // Chỉ validate các field cần thiết cho GroupQuestion
                if (_questionDictionary.Count == 0)
                {
                    MessageBox.Show("Vui lòng nhập ít nhất một Question!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Tạo GroupQuestion từ dữ liệu form
                var groupQuestion = CreateGroupQuestionFromInputs();
                _savedGroupQuestion = groupQuestion;

                // Đóng form với DialogResult.OK
                DialogResult = DialogResult.OK;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi tạo Group Question: {ex.Message}",
                    "Lỗi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        private GroupQuestion CreateGroupQuestionFromInputs()
        {
            var groupQuestion = new GroupQuestion
            {
                Type = cbType.SelectedItem?.ToString() ?? "button_single_choice",
                Point = (int)numPoints.Value,
                Difficulty = cbDifficulty.SelectedItem?.ToString() ?? "easy"
            };

            // Time Limit
            if (numTimeLimit.Value > 0)
            {
                groupQuestion.TimeLimit = (int)numTimeLimit.Value;
            }

            // Question từ dictionary
            if (_questionDictionary.Count > 0)
            {
                if (_questionDictionary.Count == 1)
                {
                    // Nếu chỉ có 1 language, lưu dưới dạng string
                    groupQuestion.Question = _questionDictionary.Values.First();
                }
                else
                {
                    // Nếu có nhiều language, lưu dưới dạng dictionary
                    groupQuestion.Question = new Dictionary<string, string>(_questionDictionary);
                }
            }

            // Explanation từ dictionary
            if (_explanationDictionary.Count > 0)
            {
                groupQuestion.Explanation = new Dictionary<string, string>(_explanationDictionary);
            }

            // Audio URL
            if (!string.IsNullOrWhiteSpace(txtAudioUrl.Text))
            {
                groupQuestion.AudioUrl = txtAudioUrl.Text.Trim();
            }

            // Image URL
            if (!string.IsNullOrWhiteSpace(txtImageUrl.Text))
            {
                groupQuestion.ImageUrl = txtImageUrl.Text.Trim();
            }

            // Content từ dictionary
            if (_content.Count > 0)
            {
                groupQuestion.Content = new Dictionary<string, object>();
                foreach (var kvp in _content)
                {
                    groupQuestion.Content[kvp.Key] = kvp.Value;
                }
            }

            return groupQuestion;
        }
    }
}
