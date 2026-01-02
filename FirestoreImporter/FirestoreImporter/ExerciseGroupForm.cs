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
    public partial class ExerciseGroupForm : Form
    {
        private List<GroupQuestion> _groupQuestions;
        private Dictionary<string, string> _titleDictionary;

        public ExerciseGroupForm()
        {
            InitializeComponent();
            _groupQuestions = new List<GroupQuestion>();
            _titleDictionary = new Dictionary<string, string>();
            SetupDataGridViews();
            SetupAutoBuildIds();
        }

        private void SetupAutoBuildIds()
        {
            cbLevelId.SelectedIndexChanged += OnIdControlsChanged;
            numUnit.ValueChanged += OnIdControlsChanged;
            numLesson.ValueChanged += OnIdControlsChanged;
            numExercise.ValueChanged += OnIdControlsChanged;
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

        private void SetupDataGridViews()
        {
            // Setup grvTitle
            grvTitle.AutoGenerateColumns = false;
            grvTitle.Columns.Clear();
            
            // Delete button column
            var deleteColumnTitle = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvTitle.Columns.Add(deleteColumnTitle);
            
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
                Width = 490,
                ReadOnly = true
            });
            grvTitle.AllowUserToAddRows = false;
            grvTitle.AllowUserToDeleteRows = false;
            grvTitle.ReadOnly = true;
            grvTitle.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvTitle.CellContentClick += GrvTitle_CellContentClick;

            // Setup grvQuestion
            grvQuestion.AutoGenerateColumns = false;
            grvQuestion.Columns.Clear();
            
            // Delete button column
            var deleteColumnQuestion = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvQuestion.Columns.Add(deleteColumnQuestion);
            
            grvQuestion.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colIndex",
                HeaderText = "#",
                DataPropertyName = "Index",
                Width = 50,
                ReadOnly = true
            });
            grvQuestion.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colType",
                HeaderText = "Type",
                DataPropertyName = "Type",
                Width = 130,
                ReadOnly = true
            });
            grvQuestion.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colQuestion",
                HeaderText = "Question",
                DataPropertyName = "Question",
                Width = 350,
                ReadOnly = true
            });
            grvQuestion.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPoint",
                HeaderText = "Point",
                DataPropertyName = "Point",
                Width = 80,
                ReadOnly = true
            });
            grvQuestion.AllowUserToAddRows = false;
            grvQuestion.AllowUserToDeleteRows = false;
            grvQuestion.ReadOnly = true;
            grvQuestion.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvQuestion.CellContentClick += GrvQuestion_CellContentClick;
        }

        // Helper class để bind vào DataGridView
        private class QuestionGridItem
        {
            public int Index { get; set; }
            public string Type { get; set; } = string.Empty;
            public string Question { get; set; } = string.Empty;
            public int Point { get; set; }
        }

        // Helper class để bind vào DataGridView
        private class ContentGridItem
        {
            public string PropertyName { get; set; } = string.Empty;
            public string Type { get; set; } = string.Empty;
            public string Value { get; set; } = string.Empty;
        }

        private void GrvTitle_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvTitle.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _titleDictionary.Remove(kvp.Key);
                    RefreshTitleGrid();
                }
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

        private void RefreshQuestionGrid()
        {
            grvQuestion.DataSource = null;
            if (_groupQuestions.Count > 0)
            {
                var dataSource = _groupQuestions.Select((gq, index) => new QuestionGridItem
                {
                    Index = index + 1,
                    Type = gq.Type,
                    Question = gq.Question is Dictionary<string, string> dict 
                        ? (dict.ContainsKey("en") ? dict["en"] : dict.Values.FirstOrDefault() ?? "") 
                        : (gq.Question?.ToString() ?? ""),
                    Point = gq.Point
                }).ToList();
                grvQuestion.DataSource = dataSource;
            }
        }

        private void GrvQuestion_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvQuestion.Rows[e.RowIndex].DataBoundItem is QuestionGridItem item)
                {
                    int index = item.Index - 1;
                    if (index >= 0 && index < _groupQuestions.Count)
                    {
                        _groupQuestions.RemoveAt(index);
                        RefreshQuestionGrid();
                    }
                }
            }
        }

        private void btnAddQuestion_Click(object sender, EventArgs e)
        {

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
                //Type = cbType.SelectedItem?.ToString() ?? "single_choice",
                Points = (int)numPoints.Value,
                Difficulty = cbDifficulty.SelectedItem?.ToString() ?? "easy"
            };

            // Time Limit
            if (numTimeLimit.Value > 0)
            {
                exercise.TimeLimit = (int)numTimeLimit.Value;
            }

            // Title từ dictionary
            if (_titleDictionary.Count > 0)
            {
                exercise.Title = new Dictionary<string, string>(_titleDictionary);
            }

            // GroupQuestions
            if (_groupQuestions.Count > 0)
            {
                exercise.GroupQuestions = _groupQuestions;
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

            // Exercise với groupQuestions không cần Content ở level exercise
            // Content sẽ nằm trong từng GroupQuestion

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

        private void btnAddQuestion_Click_1(object sender, EventArgs e)
        {
            // Mở ExerciseForm để tạo GroupQuestion với mode = true
            using var exerciseForm = new ExerciseForm(isGroupQuestionMode: true);
            exerciseForm.Text = "Tạo Group Question";
            
            // Subscribe event để nhận GroupQuestion khi Save and Add New
            exerciseForm.GroupQuestionSaved += (s, groupQuestion) =>
            {
                _groupQuestions.Add(groupQuestion);
                RefreshQuestionGrid();
            };
            
            // Hiển thị form
            if (exerciseForm.ShowDialog() == DialogResult.OK)
            {
                // Lấy GroupQuestion từ ExerciseForm (khi click Save)
                var groupQuestion = exerciseForm.GetGroupQuestion();
                if (groupQuestion != null)
                {
                    _groupQuestions.Add(groupQuestion);
                    RefreshQuestionGrid();
                }
            }
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
    }
}
