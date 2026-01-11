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
        private List<List<int?>> _contentGrid;
        private Dictionary<string, dynamic> _contentWordsDictionary;
        private bool _isGroupQuestionMode;

        // Event để gửi GroupQuestion về form cha khi Save and Add New
        public event EventHandler<GroupQuestion>? GroupQuestionSaved;

        public ExerciseForm(bool isGroupQuestionMode = false)
        {
            InitializeComponent();
            _isGroupQuestionMode = isGroupQuestionMode;
            _questionDictionary = new Dictionary<string, string>();
            _explanationDictionary = new Dictionary<string, string>();
            _content = new Dictionary<string, dynamic>();
            _contentGrid = new List<List<int?>>();
            _contentWordsDictionary = new Dictionary<string, dynamic>();
            SetupDataGridViews();
            SetupGroupQuestionMode();
            SetupAutoBuildIds();
            SetupTypeChangedHandler();
        }
        
        private void SetupTypeChangedHandler()
        {
            cbType.SelectedIndexChanged += CbType_SelectedIndexChanged;
            // Set initial state
            CbType_SelectedIndexChanged(null, EventArgs.Empty);
        }
        
        private void CbType_SelectedIndexChanged(object? sender, EventArgs e)
        {
            string? selectedType = cbType.SelectedItem?.ToString();
            bool isCrossword = selectedType == "crossword";
            
            // Ẩn/hiện tabs
            if (isCrossword)
            {
                // Ẩn Questions, Explanation, Content tabs
                if (tabControl1.TabPages.Contains(tabPage1))
                    tabControl1.TabPages.Remove(tabPage1);
                if (tabControl1.TabPages.Contains(tabPage2))
                    tabControl1.TabPages.Remove(tabPage2);
                if (tabControl1.TabPages.Contains(tabPage3))
                    tabControl1.TabPages.Remove(tabPage3);
                
                // Hiển thị Crossword Content tab
                if (!tabControl1.TabPages.Contains(tabPage4))
                {
                    tabControl1.TabPages.Add(tabPage4);
                    tabControl1.SelectedTab = tabPage4;
                }
            }
            else
            {
                // Ẩn Crossword Content tab
                if (tabControl1.TabPages.Contains(tabPage4))
                    tabControl1.TabPages.Remove(tabPage4);
                
                // Hiển thị Questions, Explanation, Content tabs (thêm lại theo thứ tự)
                if (!tabControl1.TabPages.Contains(tabPage1))
                {
                    tabControl1.TabPages.Insert(0, tabPage1);
                }
                if (!tabControl1.TabPages.Contains(tabPage2))
                {
                    int index = tabControl1.TabPages.IndexOf(tabPage1);
                    tabControl1.TabPages.Insert(index + 1, tabPage2);
                }
                if (!tabControl1.TabPages.Contains(tabPage3))
                {
                    int index = tabControl1.TabPages.IndexOf(tabPage2);
                    tabControl1.TabPages.Insert(index + 1, tabPage3);
                }
                
                // Set selected tab về tab đầu tiên nếu không có tab nào được chọn
                if (tabControl1.SelectedTab == null && tabControl1.TabPages.Count > 0)
                {
                    tabControl1.SelectedIndex = 0;
                }
            }
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
                Width = 490,
                ReadOnly = true
            });
            grvQuestion.AllowUserToAddRows = false;
            grvQuestion.AllowUserToDeleteRows = false;
            grvQuestion.ReadOnly = true;
            grvQuestion.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvQuestion.CellContentClick += GrvQuestion_CellContentClick;

            // Setup grvExplanation
            grvExplanation.AutoGenerateColumns = false;
            grvExplanation.Columns.Clear();

            // Delete button column
            var deleteColumnExplanation = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvExplanation.Columns.Add(deleteColumnExplanation);

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
                Width = 490,
                ReadOnly = true
            });
            grvExplanation.AllowUserToAddRows = false;
            grvExplanation.AllowUserToDeleteRows = false;
            grvExplanation.ReadOnly = true;
            grvExplanation.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvExplanation.CellContentClick += GrvExplanation_CellContentClick;

            // Setup grvContent
            grvContent.AutoGenerateColumns = false;
            grvContent.Columns.Clear();

            // Delete button column
            var deleteColumnContent = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvContent.Columns.Add(deleteColumnContent);

            grvContent.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPropertyName",
                HeaderText = "Property Name",
                DataPropertyName = "PropertyName",
                Width = 180,
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
                Width = 360,
                ReadOnly = true
            });
            grvContent.AllowUserToAddRows = false;
            grvContent.AllowUserToDeleteRows = false;
            grvContent.ReadOnly = true;
            grvContent.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvContent.CellContentClick += GrvContent_CellContentClick;

            // Setup grvGrid (Crossword Grid)
            grvGrid.AutoGenerateColumns = false;
            grvGrid.Columns.Clear();

            // Delete button column
            var deleteColumnGrid = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvGrid.Columns.Add(deleteColumnGrid);

            grvGrid.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colRow",
                HeaderText = "Row",
                DataPropertyName = "Row",
                Width = 60,
                ReadOnly = true
            });
            grvGrid.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValues",
                HeaderText = "Values",
                DataPropertyName = "Values",
                Width = 600,
                ReadOnly = true
            });
            grvGrid.AllowUserToAddRows = false;
            grvGrid.AllowUserToDeleteRows = false;
            grvGrid.ReadOnly = true;
            grvGrid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvGrid.CellContentClick += GrvGrid_CellContentClick;

            // Setup grvWord (Crossword Words)
            grvWord.AutoGenerateColumns = false;
            grvWord.Columns.Clear();

            // Delete button column
            var deleteColumnWord = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvWord.Columns.Add(deleteColumnWord);

            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colNumber",
                HeaderText = "Number",
                DataPropertyName = "Number",
                Width = 70,
                ReadOnly = true
            });
            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDirection",
                HeaderText = "Direction",
                DataPropertyName = "Direction",
                Width = 80,
                ReadOnly = true
            });
            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colStartRow",
                HeaderText = "Start Row",
                DataPropertyName = "StartRow",
                Width = 80,
                ReadOnly = true
            });
            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colStartCol",
                HeaderText = "Start Col",
                DataPropertyName = "StartCol",
                Width = 80,
                ReadOnly = true
            });
            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colClue",
                HeaderText = "Clue",
                DataPropertyName = "Clue",
                Width = 200,
                ReadOnly = true
            });
            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colAnswer",
                HeaderText = "Answer",
                DataPropertyName = "Answer",
                Width = 100,
                ReadOnly = true
            });
            grvWord.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLength",
                HeaderText = "Length",
                DataPropertyName = "Length",
                Width = 70,
                ReadOnly = true
            });
            grvWord.AllowUserToAddRows = false;
            grvWord.AllowUserToDeleteRows = false;
            grvWord.ReadOnly = true;
            grvWord.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvWord.CellContentClick += GrvWord_CellContentClick;
        }

        // Helper class để bind vào DataGridView
        private class ContentGridItem
        {
            public string PropertyName { get; set; } = string.Empty;
            public string Type { get; set; } = string.Empty;
            public string Value { get; set; } = string.Empty;
        }

        private void GrvQuestion_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvQuestion.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _questionDictionary.Remove(kvp.Key);
                    RefreshQuestionGrid();
                }
            }
        }

        private void GrvExplanation_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvExplanation.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _explanationDictionary.Remove(kvp.Key);
                    RefreshExplanationGrid();
                }
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

        private void GrvContent_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvContent.Rows[e.RowIndex].DataBoundItem is ContentGridItem item)
                {
                    _content.Remove(item.PropertyName);
                    RefreshContentGrid();
                }
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
            // Nếu là crossword type, build content với grid và words
            // LƯU Ý: Convert List<List<int?>> thành List<List<object>> nhưng GIỮ NGUYÊN null values
            // ToFirestore() sẽ xử lý conversion null -> -1
            if (exercise.Type == "crossword" && _contentGrid != null && _contentGrid.Count > 0)
            {
                // Convert List<List<int?>> thành List<object> (outer list)
                // Mỗi inner list sẽ là List<object> với null values được giữ nguyên
                var gridAsObjects = _contentGrid.Select(row => 
                    (object)row.Select(cell => cell.HasValue ? (object)cell.Value : (object?)null).ToList<object?>()
                ).ToList<object>();
                
                var crosswordContent = new Dictionary<string, object>
                {
                    { "rows", (int)numRows.Value },
                    { "cols", (int)numCols.Value },
                    { "grid", gridAsObjects },
                    { "words", _contentWordsDictionary.Values.ToList() }
                };
                exercise.Content = crosswordContent;
            }
            else if (_content.Count > 0)
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
            if (string.IsNullOrWhiteSpace(cbPropertyName.Text))
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

            string propertyName = cbPropertyName.Text.Trim();
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
            cbPropertyName.SelectedIndex = 0;
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
            // Nếu là crossword type, build content với grid và words
            // LƯU Ý: Convert List<List<int?>> thành List<List<object>> nhưng GIỮ NGUYÊN null values
            // ToFirestore() sẽ xử lý conversion null -> -1
            if (groupQuestion.Type == "crossword" && _contentGrid != null && _contentGrid.Count > 0)
            {
                // Convert List<List<int?>> thành List<object> (outer list)
                // Mỗi inner list sẽ là List<object> với null values được giữ nguyên
                var gridAsObjects = _contentGrid.Select(row => 
                    (object)row.Select(cell => (object?)(cell.HasValue ? (object)cell.Value : null)).ToList<object?>()
                ).ToList<object>();
                
                var crosswordContent = new Dictionary<string, object>
                {
                    { "rows", (int)numRows.Value },
                    { "cols", (int)numCols.Value },
                    { "grid", gridAsObjects },
                    { "words", _contentWordsDictionary.Values.ToList() }
                };
                groupQuestion.Content = crosswordContent;
            }
            else if (_content.Count > 0)
            {
                groupQuestion.Content = new Dictionary<string, object>();
                foreach (var kvp in _content)
                {
                    groupQuestion.Content[kvp.Key] = kvp.Value;
                }
            }

            return groupQuestion;
        }

        private async void btnSaveAndAddNew_Click(object sender, EventArgs e)
        {
            try
            {
                if (_isGroupQuestionMode)
                {
                    // Mode GroupQuestion: Validate và gửi về ExerciseGroupForm
                    if (_questionDictionary.Count == 0)
                    {
                        MessageBox.Show("Vui lòng nhập ít nhất một Question!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }

                    // Tạo GroupQuestion từ dữ liệu form
                    var groupQuestion = CreateGroupQuestionFromInputs();

                    // Trigger event để gửi về form cha
                    GroupQuestionSaved?.Invoke(this, groupQuestion);

                    // Clear các controls trong tab question, explanation, content
                    ClearQuestionExplanationContentTabs();
                }
                else
                {
                    // Mode Exercise thông thường: Validate và export JSON
                    if (string.IsNullOrWhiteSpace(txtId.Text))
                    {
                        MessageBox.Show("Vui lòng nhập Exercise ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }

                    if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                    {
                        MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }

                    if (_questionDictionary.Count == 0)
                    {
                        MessageBox.Show("Vui lòng nhập ít nhất một Question!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }

                    // Export JSON (lưu vào clipboard hoặc file)
                    var jsonResult = ExportJson();
                    Clipboard.SetText(jsonResult);
                    MessageBox.Show("Đã lưu Exercise và copy JSON vào clipboard!\nBạn có thể paste vào form chính.",
                        "Thành công",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    // Tăng exercise number để tạo exercise mới
                    if (numExercise.Value < numExercise.Maximum)
                    {
                        numExercise.Value++;
                    }
                    else
                    {
                        // Nếu đã đạt max, tăng lesson
                        if (numLesson.Value < numLesson.Maximum)
                        {
                            numLesson.Value++;
                            numExercise.Value = 1;
                        }
                    }

                    // Clear các controls trong tab question, explanation, content
                    ClearQuestionExplanationContentTabs();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi lưu: {ex.Message}",
                    "Lỗi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            // Clear các controls trong tab question, explanation, content
            ClearQuestionExplanationContentTabs();
        }

        private List<List<object>> ConvertGridForFirestore(List<List<int?>> grid)
        {
            // Convert List<List<int?>> thành List<List<object>> với null -> -1
            // Firestore không hỗ trợ null values trong arrays
            return grid.Select(row =>
            {
                return row.Select(cell =>
                {
                    if (cell.HasValue)
                        return (object)cell.Value;
                    else
                        return (object)(-1); // Convert null thành -1
                }).ToList<object>();
            }).ToList();
        }

        private void ClearQuestionExplanationContentTabs()
        {
            // Clear dictionaries
            _questionDictionary.Clear();
            _explanationDictionary.Clear();
            _content.Clear();
            _contentGrid?.Clear();
            _contentWordsDictionary?.Clear();

            // Clear textboxes
            txtLanguageQuestionValue.Clear();
            txtLanguageExplanationValue.Clear();
            cbPropertyName.SelectedIndex = 0;
            txtPropertyValue.Clear();
            txtGridArrayValue.Clear();
            txtClue.Clear();
            txtAnswer.Clear();

            // Clear combobox selections
            //cbLanguageCodeQuestion.SelectedIndex = -1;
            //cbLanguageCodeExplanation.SelectedIndex = -1;
            //cbPropertyType.SelectedIndex = -1;

            // Refresh grids để hiển thị empty
            RefreshQuestionGrid();
            RefreshExplanationGrid();
            RefreshContentGrid();
            RefreshGridDisplay();
            RefreshWordDisplay();
        }

        private void btnAddGridValue_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtGridArrayValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Grid Row!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                // Parse string input: "1, 2, null, 3, null, null, null, null, null, null"
                string input = txtGridArrayValue.Text.Trim();
                
                // Remove brackets if present
                input = input.TrimStart('[').TrimEnd(']');
                
                // Split by comma
                string[] parts = input.Split(',');
                
                List<int?> row = new List<int?>();
                foreach (string part in parts)
                {
                    string trimmedPart = part.Trim();
                    if (string.IsNullOrWhiteSpace(trimmedPart))
                        continue;
                    
                    if (trimmedPart.Equals("null", StringComparison.OrdinalIgnoreCase))
                    {
                        row.Add(null);
                    }
                    else if (int.TryParse(trimmedPart, out int value))
                    {
                        row.Add(value);
                    }
                    else
                    {
                        MessageBox.Show($"Giá trị không hợp lệ: {trimmedPart}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }
                }
                
                // Add row to grid
                _contentGrid.Add(row);
                
                // Update content dictionary với grid mới
                UpdateCrosswordContent();
                
                // Refresh grid display
                RefreshGridDisplay();
                
                // Clear input
                txtGridArrayValue.Clear();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi parse grid row: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void UpdateCrosswordContent()
        {
            if (_contentGrid == null || _contentGrid.Count == 0)
                return;
            
            // Tạo content dictionary cho crossword
            var crosswordContent = new Dictionary<string, object>
            {
                { "rows", (int)numRows.Value },
                { "cols", (int)numCols.Value },
                { "grid", _contentGrid },
                { "words", _contentWordsDictionary.Values.ToList() }
            };
            
            // Update _content dictionary
            _content["rows"] = (int)numRows.Value;
            _content["cols"] = (int)numCols.Value;
            _content["grid"] = _contentGrid;
            _content["words"] = _contentWordsDictionary.Values.ToList();
            
            // Refresh content grid
            RefreshContentGrid();
        }

        private void RefreshGridDisplay()
        {
            grvGrid.DataSource = null;
            if (_contentGrid != null && _contentGrid.Count > 0)
            {
                // Convert to display format
                var displayData = _contentGrid.Select((row, index) => new GridDisplayItem
                {
                    Row = index,
                    Values = string.Join(", ", row.Select(cell => cell.HasValue ? cell.Value.ToString() : "null"))
                }).ToList();
                
                grvGrid.DataSource = displayData;
            }
        }

        // Helper class để bind vào DataGridView
        private class GridDisplayItem
        {
            public int Row { get; set; }
            public string Values { get; set; } = string.Empty;
        }

        private void btnAddWordValue_Click(object sender, EventArgs e)
        {
            // Validate required fields
            if (numNumber.Value <= 0)
            {
                MessageBox.Show("Vui lòng nhập Number (phải > 0)!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            
            if (cbDirection.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Direction!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            
            if (string.IsNullOrWhiteSpace(txtClue.Text))
            {
                MessageBox.Show("Vui lòng nhập Clue!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            
            if (string.IsNullOrWhiteSpace(txtAnswer.Text))
            {
                MessageBox.Show("Vui lòng nhập Answer!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            
            try
            {
                int number = (int)numNumber.Value;
                string direction = cbDirection.SelectedItem.ToString()!;
                int startRow = (int)numStartRow.Value;
                int startCol = (int)numStartCol.Value;
                string clue = txtClue.Text.Trim();
                string answer = txtAnswer.Text.Trim().ToUpper();
                int length = answer.Length;
                
                // Tạo word dictionary
                var wordDict = new Dictionary<string, object>
                {
                    { "number", number },
                    { "direction", direction },
                    { "startRow", startRow },
                    { "startCol", startCol },
                    { "clue", clue },
                    { "answer", answer },
                    { "length", length }
                };
                
                // Add vào dictionary với key là number để dễ quản lý
                string key = $"word_{number}";
                _contentWordsDictionary[key] = wordDict;
                
                // Update crossword content
                UpdateCrosswordContent();
                
                // Refresh word display
                RefreshWordDisplay();
                
                // Clear inputs (optional - có thể giữ lại để add word tiếp theo)
                // numNumber.Value = numNumber.Value + 1;
                // txtClue.Clear();
                // txtAnswer.Clear();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi add word: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void RefreshWordDisplay()
        {
            grvWord.DataSource = null;
            if (_contentWordsDictionary != null && _contentWordsDictionary.Count > 0)
            {
                // Helper class để hiển thị
                var displayList = new List<WordDisplayItem>();
                
                foreach (var wordObj in _contentWordsDictionary.Values)
                {
                    if (wordObj is Dictionary<string, object> word)
                    {
                        string clueText = word.ContainsKey("clue") ? (word["clue"]?.ToString() ?? "") : "";
                        if (clueText.Length > 50)
                            clueText = clueText.Substring(0, 50) + "...";
                        
                        displayList.Add(new WordDisplayItem
                        {
                            Number = word.ContainsKey("number") ? Convert.ToInt32(word["number"]) : 0,
                            Direction = word.ContainsKey("direction") ? word["direction"]?.ToString() ?? "" : "",
                            StartRow = word.ContainsKey("startRow") ? Convert.ToInt32(word["startRow"]) : 0,
                            StartCol = word.ContainsKey("startCol") ? Convert.ToInt32(word["startCol"]) : 0,
                            Clue = clueText,
                            Answer = word.ContainsKey("answer") ? word["answer"]?.ToString() ?? "" : "",
                            Length = word.ContainsKey("length") ? Convert.ToInt32(word["length"]) : 0
                        });
                    }
                }
                
                // Sort by number
                displayList = displayList.OrderBy(w => w.Number).ToList();
                
                grvWord.DataSource = displayList;
            }
        }

        private void GrvGrid_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvGrid.Rows[e.RowIndex].DataBoundItem is GridDisplayItem item)
                {
                    if (item.Row >= 0 && item.Row < _contentGrid.Count)
                    {
                        _contentGrid.RemoveAt(item.Row);
                        UpdateCrosswordContent();
                        RefreshGridDisplay();
                    }
                }
            }
        }

        private void GrvWord_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvWord.Rows[e.RowIndex].DataBoundItem is WordDisplayItem item)
                {
                    string keyToRemove = $"word_{item.Number}";
                    if (_contentWordsDictionary.ContainsKey(keyToRemove))
                    {
                        _contentWordsDictionary.Remove(keyToRemove);
                        UpdateCrosswordContent();
                        RefreshWordDisplay();
                    }
                }
            }
        }

        
        // Helper class để bind vào DataGridView
        private class WordDisplayItem
        {
            public int Number { get; set; }
            public string Direction { get; set; } = string.Empty;
            public int StartRow { get; set; }
            public int StartCol { get; set; }
            public string Clue { get; set; } = string.Empty;
            public string Answer { get; set; } = string.Empty;
            public int Length { get; set; }
        }
    }
}
