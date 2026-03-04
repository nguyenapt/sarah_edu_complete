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
        private Dictionary<string, VoiceConfig> _speakerVoices;

        public ExerciseGroupForm()
        {
            InitializeComponent();
            _groupQuestions = new List<GroupQuestion>();
            _titleDictionary = new Dictionary<string, string>();
            _speakerVoices = new Dictionary<string, VoiceConfig>();
            SetupDataGridViews();
            SetupAutoBuildIds();
            SetupVoiceControls();
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

            // Setup grvSpeakerVoices
            grvSpeakerVoices.AutoGenerateColumns = false;
            grvSpeakerVoices.Columns.Clear();
            
            // Delete button column
            var deleteColumnVoice = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvSpeakerVoices.Columns.Add(deleteColumnVoice);
            
            grvSpeakerVoices.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colName",
                HeaderText = "Name",
                DataPropertyName = "Name",
                Width = 100,
                ReadOnly = true
            });
            grvSpeakerVoices.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colGender",
                HeaderText = "Gender",
                DataPropertyName = "Gender",
                Width = 70,
                ReadOnly = true
            });
            grvSpeakerVoices.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colAge",
                HeaderText = "Age",
                DataPropertyName = "Age",
                Width = 70,
                ReadOnly = true
            });
            grvSpeakerVoices.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language",
                DataPropertyName = "LanguageCode",
                Width = 80,
                ReadOnly = true
            });
            grvSpeakerVoices.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colRate",
                HeaderText = "Rate",
                DataPropertyName = "Rate",
                Width = 60,
                ReadOnly = true
            });
            grvSpeakerVoices.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPitch",
                HeaderText = "Pitch",
                DataPropertyName = "Pitch",
                Width = 60,
                ReadOnly = true
            });
            grvSpeakerVoices.AllowUserToAddRows = false;
            grvSpeakerVoices.AllowUserToDeleteRows = false;
            grvSpeakerVoices.ReadOnly = true;
            grvSpeakerVoices.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvSpeakerVoices.CellContentClick += GrvSpeakerVoices_CellContentClick;
        }

        private void SetupVoiceControls()
        {
            // Setup default values cho voice controls
            numRate.Value = 1.0m;
            numPitch.Value = 0.0m;
            numVoicePitch.Value = 0.0m;
            numVoiceAge.Value = 1.0m; // Note: This is actually Rate, not Age (based on Designer)
            
            // Set default selections
            if (cboDefaultVoiceGender.Items.Count > 0)
                cboDefaultVoiceGender.SelectedIndex = 0; // female
            if (cboDefaultVoiceAge.Items.Count > 0)
                cboDefaultVoiceAge.SelectedIndex = 1; // adult
            if (cboDefaultVoiceLanguageCode.Items.Count > 0)
                cboDefaultVoiceLanguageCode.SelectedIndex = 0; // en-US

            if (cboVoiceGender.Items.Count > 0)
                cboVoiceGender.SelectedIndex = 0; // female
            if (cboVoiceAge.Items.Count > 0)
                cboVoiceAge.SelectedIndex = 1; // adult
            if (cboVoiceLanguageCode.Items.Count > 0)
                cboVoiceLanguageCode.SelectedIndex = 0; // en-US

            // Attach event handlers
            btnAddVoice.Click += BtnAddVoice_Click;
            cbHasVoice.CheckedChanged += CbHasVoice_CheckedChanged;
            
            // Ban đầu disable các controls voice (vì checkbox chưa được check)
            EnableVoiceControls(false);
        }

        private void CbHasVoice_CheckedChanged(object? sender, EventArgs e)
        {
            bool isEnabled = cbHasVoice.Checked;
            EnableVoiceControls(isEnabled);
        }

        private void EnableVoiceControls(bool enabled)
        {
            // Enable/Disable Default Voice controls (groupBox2)
            groupBox2.Enabled = enabled;
            cboDefaultVoiceAge.Enabled = enabled;
            cboDefaultVoiceGender.Enabled = enabled;
            cboDefaultVoiceLanguageCode.Enabled = enabled;
            numRate.Enabled = enabled;
            numPitch.Enabled = enabled;

            // Enable/Disable Speaker Voices controls (groupBox3)
            groupBox3.Enabled = enabled;
            txtVoiceName.Enabled = enabled;
            cboVoiceAge.Enabled = enabled;
            cboVoiceGender.Enabled = enabled;
            cboVoiceLanguageCode.Enabled = enabled;
            numVoiceAge.Enabled = enabled; // Note: This is actually Rate
            numVoicePitch.Enabled = enabled;
            btnAddVoice.Enabled = enabled;
            grvSpeakerVoices.Enabled = enabled;
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

        // Helper class để bind vào DataGridView cho SpeakerVoices
        private class SpeakerVoiceGridItem
        {
            public string Name { get; set; } = string.Empty;
            public string Gender { get; set; } = string.Empty;
            public string Age { get; set; } = string.Empty;
            public string LanguageCode { get; set; } = string.Empty;
            public double Rate { get; set; }
            public double Pitch { get; set; }
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

        private void GrvSpeakerVoices_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvSpeakerVoices.Rows[e.RowIndex].DataBoundItem is SpeakerVoiceGridItem item)
                {
                    _speakerVoices.Remove(item.Name);
                    RefreshSpeakerVoicesGrid();
                }
            }
        }

        private void RefreshSpeakerVoicesGrid()
        {
            grvSpeakerVoices.DataSource = null;
            if (_speakerVoices.Count > 0)
            {
                var dataSource = _speakerVoices.Select(kvp => new SpeakerVoiceGridItem
                {
                    Name = kvp.Key,
                    Gender = kvp.Value.Gender,
                    Age = kvp.Value.Age,
                    LanguageCode = kvp.Value.LanguageCode,
                    Rate = kvp.Value.Rate,
                    Pitch = kvp.Value.Pitch
                }).ToList();
                grvSpeakerVoices.DataSource = dataSource;
            }
        }

        private void BtnAddVoice_Click(object? sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtVoiceName.Text))
            {
                MessageBox.Show("Vui lòng nhập tên speaker!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string name = txtVoiceName.Text.Trim();
            
            // Validate các fields
            if (cboVoiceAge.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Age!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (cboVoiceGender.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Gender!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (cboVoiceLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var voiceConfig = new VoiceConfig
            {
                Age = cboVoiceAge.SelectedItem.ToString()!,
                Gender = cboVoiceGender.SelectedItem.ToString()!,
                LanguageCode = cboVoiceLanguageCode.SelectedItem.ToString()!,
                Rate = (double)numVoiceAge.Value, // Note: numVoiceAge is actually Rate based on Designer
                Pitch = (double)numVoicePitch.Value
            };

            // Update hoặc thêm mới
            _speakerVoices[name] = voiceConfig;

            // Refresh grid
            RefreshSpeakerVoicesGrid();

            // Clear input
            txtVoiceName.Clear();
            numVoiceAge.Value = 1.0m;
            numVoicePitch.Value = 0.0m;
            if (cboVoiceAge.Items.Count > 0)
                cboVoiceAge.SelectedIndex = 1; // adult
            if (cboVoiceGender.Items.Count > 0)
                cboVoiceGender.SelectedIndex = 0; // female
            if (cboVoiceLanguageCode.Items.Count > 0)
                cboVoiceLanguageCode.SelectedIndex = 0; // en-US
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
                Type = cbType.SelectedItem?.ToString() ?? "single_choice",
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
            // split theo dấu phẩy
            if (!string.IsNullOrWhiteSpace(txtGrammarTopics.Text))
            {
                exercise.GrammarTopics = txtGrammarTopics.Text.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }

            if (!string.IsNullOrWhiteSpace(txtSkillTopics.Text))
            {
                exercise.SkillTypes = txtSkillTopics.Text.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }

            // Has Voice - chỉ import khi checkbox được checked
            if (cbHasVoice.Checked)
            {
                exercise.HasVoice = true;

                // Default Voice - chỉ import khi hasVoice được checked và có đủ dữ liệu
                if (cboDefaultVoiceAge.SelectedItem != null &&
                    cboDefaultVoiceGender.SelectedItem != null &&
                    cboDefaultVoiceLanguageCode.SelectedItem != null)
                {
                    exercise.DefaultVoice = new VoiceConfig
                    {
                        Age = cboDefaultVoiceAge.SelectedItem.ToString()!,
                        Gender = cboDefaultVoiceGender.SelectedItem.ToString()!,
                        LanguageCode = cboDefaultVoiceLanguageCode.SelectedItem.ToString()!,
                        Rate = (double)numRate.Value,
                        Pitch = (double)numPitch.Value
                    };
                }

                // Speaker Voices - chỉ import khi hasVoice được checked và có dữ liệu
                if (_speakerVoices.Count > 0)
                {
                    exercise.SpeakerVoices = new Dictionary<string, VoiceConfig>(_speakerVoices);
                }
            }
            // Nếu không checked, không import bất kỳ voice data nào (HasVoice, DefaultVoice, SpeakerVoices đều null)

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
