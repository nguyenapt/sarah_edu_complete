using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using FirestoreImporter.Models;
using FirestoreImporter.Services;
using Newtonsoft.Json;

namespace FirestoreImporter
{
    public partial class UnitForm : Form
    {
        private Dictionary<string, string> _titleDictionary;
        private Dictionary<string, string> _descriptionDictionary;

        public UnitForm()
        {
            InitializeComponent();
            _titleDictionary = new Dictionary<string, string>();
            _descriptionDictionary = new Dictionary<string, string>();
            SetupDataGridViews();
            SetupAutoBuildId();
        }

        private void SetupAutoBuildId()
        {
            cbLevelId.SelectedIndexChanged += OnIdControlsChanged;
            numUnit.ValueChanged += OnIdControlsChanged;
        }

        private void OnIdControlsChanged(object? sender, EventArgs e)
        {
            BuildId();
        }

        private void BuildId()
        {
            // Lấy level ID (lowercase)
            string levelId = cbLevelId.SelectedItem?.ToString()?.ToLower() ?? "";
            
            // Lấy giá trị numeric
            int unitValue = (int)numUnit.Value;

            // Build Unit ID: unit_{levelId}_{unitValue}
            if (!string.IsNullOrEmpty(levelId) && unitValue > 0)
            {
                txtId.Text = $"unit_{levelId}_{unitValue}";
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

            // Setup grvDescription
            grvDescription.AutoGenerateColumns = false;
            grvDescription.Columns.Clear();
            
            // Delete button column
            var deleteColumnDescription = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvDescription.Columns.Add(deleteColumnDescription);
            
            grvDescription.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            grvDescription.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 490,
                ReadOnly = true
            });
            grvDescription.AllowUserToAddRows = false;
            grvDescription.AllowUserToDeleteRows = false;
            grvDescription.ReadOnly = true;
            grvDescription.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvDescription.CellContentClick += GrvDescription_CellContentClick;
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

        private void GrvDescription_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvDescription.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _descriptionDictionary.Remove(kvp.Key);
                    RefreshDescriptionGrid();
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

        private void RefreshDescriptionGrid()
        {
            grvDescription.DataSource = null;
            if (_descriptionDictionary.Count > 0)
            {
                grvDescription.DataSource = _descriptionDictionary.ToList();
            }
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

                if (cbLevelId.SelectedItem == null)
                {
                    MessageBox.Show("Vui lòng chọn Level ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Get JSON string
                string jsonContent = ExportJson();

                // Get Desktop path
                string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                string filePath = Path.Combine(desktopPath, "unit.json");

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

                if (cbLevelId.SelectedItem == null)
                {
                    MessageBox.Show("Vui lòng chọn Level ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
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

                // Tạo UnitModel từ dữ liệu form
                var unit = new UnitModel
                {
                    Id = txtId.Text.Trim(),
                    LevelId = cbLevelId.SelectedItem?.ToString() ?? "",
                    Order = (int)numOrder.Value,
                    EstimatedTime = (int)numEstimatedTime.Value
                };

                // Title từ dictionary
                if (_titleDictionary.Count > 0)
                {
                    unit.Title = new Dictionary<string, string>(_titleDictionary);
                }

                // Description từ dictionary
                if (_descriptionDictionary.Count > 0)
                {
                    unit.Description = new Dictionary<string, string>(_descriptionDictionary);
                }

                // Lessons
                if (!string.IsNullOrWhiteSpace(txtLessons.Text))
                {
                    unit.Lessons = txtLessons.Text.Split(',')
                        .Select(s => s.Trim())
                        .Where(s => !string.IsNullOrEmpty(s))
                        .ToList();
                }

                // Prerequisites
                if (!string.IsNullOrWhiteSpace(txtPrerequisites.Text))
                {
                    unit.Prerequisites = txtPrerequisites.Text.Split(',')
                        .Select(s => s.Trim())
                        .Where(s => !string.IsNullOrEmpty(s))
                        .ToList();
                }

                // Group
                if (!string.IsNullOrWhiteSpace(txtGroup.Text))
                {
                    unit.Group = txtGroup.Text.Trim();
                }

                // Upload lên Firestore
                await firestoreService.ImportUnitAsync(unit);

                // Thông báo thành công
                MessageBox.Show($"Đã upload Unit lên Firestore thành công!\nUnit ID: {unit.Id}", 
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

        public string ExportJson()
        {
            var unit = new UnitModel
            {
                Id = txtId.Text.Trim(),
                LevelId = cbLevelId.SelectedItem?.ToString() ?? "",
                Order = (int)numOrder.Value,
                EstimatedTime = (int)numEstimatedTime.Value
            };

            // Title từ dictionary
            if (_titleDictionary.Count > 0)
            {
                unit.Title = new Dictionary<string, string>(_titleDictionary);
            }

            // Description từ dictionary
            if (_descriptionDictionary.Count > 0)
            {
                unit.Description = new Dictionary<string, string>(_descriptionDictionary);
            }

            // Lessons
            if (!string.IsNullOrWhiteSpace(txtLessons.Text))
            {
                unit.Lessons = txtLessons.Text.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }

            // Prerequisites
            if (!string.IsNullOrWhiteSpace(txtPrerequisites.Text))
            {
                unit.Prerequisites = txtPrerequisites.Text.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }

            // Group
            if (!string.IsNullOrWhiteSpace(txtGroup.Text))
            {
                unit.Group = txtGroup.Text.Trim();
            }

            var jsonData = new Dictionary<string, object>
            {
                { "units", new Dictionary<string, UnitModel> { { unit.Id, unit } } }
            };
            var _jsonResult = JsonConvert.SerializeObject(jsonData, Formatting.Indented);

            return _jsonResult.ToString();
        }

        private void btnAddTitle_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeTitle.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeTitle.SelectedItem.ToString()!;
            string value = txtLanguageValue.Text.Trim();

            // Update hoặc thêm mới
            _titleDictionary[languageCode] = value;
            
            // Refresh grid
            RefreshTitleGrid();
            
            // Clear input
            txtLanguageValue.Clear();
        }

        private void btnAddDescription_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeDescription.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtDescriptionValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Description!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeDescription.SelectedItem.ToString()!;
            string value = txtDescriptionValue.Text.Trim();

            // Update hoặc thêm mới
            _descriptionDictionary[languageCode] = value;
            
            // Refresh grid
            RefreshDescriptionGrid();
            
            // Clear input
            txtDescriptionValue.Clear();
        }
    }

      
}
