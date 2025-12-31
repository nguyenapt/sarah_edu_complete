using FirestoreImporter.Services;
using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter;

public partial class Form1 : Form
{
    private FirestoreService? _firestoreService;
    private ImportData? _importData;

    public Form1()
    {
        InitializeComponent();
        _firestoreService = new FirestoreService();
    }

    private void BtnBrowseCredentials_Click(object? sender, EventArgs e)
    {
        using var openFileDialog = new OpenFileDialog
        {
            Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*",
            Title = "Chọn Firebase Credentials File"
        };

        if (openFileDialog.ShowDialog() == DialogResult.OK)
        {
            txtCredentials.Text = openFileDialog.FileName;
        }
    }

    private void BtnBrowseJson_Click(object? sender, EventArgs e)
    {
        using var openFileDialog = new OpenFileDialog
        {
            Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*",
            Title = "Chọn JSON Data File"
        };

        if (openFileDialog.ShowDialog() == DialogResult.OK)
        {
            txtJsonFile.Text = openFileDialog.FileName;
        }
    }

    private async void BtnTestConnection_Click(object? sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtProjectId.Text))
        {
            MessageBox.Show("Vui lòng nhập Project ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        btnTestConnection.Enabled = false;
        btnTestConnection.Text = "Đang kiểm tra...";
        rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Đang kiểm tra kết nối Firestore...\n");

        try
        {
            await _firestoreService!.InitializeAsync(txtProjectId.Text, txtCredentials.Text);
            var isConnected = await _firestoreService.TestConnectionAsync();

            if (isConnected)
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Kết nối thành công!\n");
                MessageBox.Show("Kết nối Firestore thành công!", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✗ Kết nối thất bại!\n");
                MessageBox.Show("Không thể kết nối đến Firestore. Vui lòng kiểm tra Project ID và Credentials.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        catch (Exception ex)
        {
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✗ Lỗi: {ex.Message}\n");
            MessageBox.Show($"Lỗi: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            btnTestConnection.Enabled = true;
            btnTestConnection.Text = "Test Connection";
        }
    }

    private void BtnImport_Click(object? sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtJsonFile.Text) || !File.Exists(txtJsonFile.Text))
        {
            MessageBox.Show("Vui lòng chọn file JSON hợp lệ!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        if (string.IsNullOrWhiteSpace(txtProjectId.Text))
        {
            MessageBox.Show("Vui lòng nhập Project ID và test connection trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        if (!chkLevels.Checked && !chkUnits.Checked && !chkLessons.Checked && !chkExercises.Checked)
        {
            MessageBox.Show("Vui lòng chọn ít nhất một loại dữ liệu để import!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        // Parse JSON
        try
        {
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Đang đọc file JSON...\n");
            _importData = JsonParser.ParseJsonFile(txtJsonFile.Text);
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã đọc file JSON thành công!\n");
        }
        catch (Exception ex)
        {
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✗ Lỗi khi đọc JSON: {ex.Message}\n");
            MessageBox.Show($"Lỗi khi đọc file JSON: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        // Start import
        _ = ImportDataAsync();
    }

    private async Task ImportDataAsync()
    {
        btnImport.Enabled = false;
        progressBar.Style = ProgressBarStyle.Marquee;
        lblStatus.Text = "Đang import...";
        rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Bắt đầu import dữ liệu...\n");

        try
        {
            // Initialize Firestore if not already done
            if (_firestoreService == null)
            {
                _firestoreService = new FirestoreService();
            }
            await _firestoreService.InitializeAsync(txtProjectId.Text, txtCredentials.Text);

            int totalImported = 0;
            var progress = new Progress<string>(message =>
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}\n");
                rtbLog.ScrollToCaret();
            });

            // Import Levels
            if (chkLevels.Checked && _importData!.Levels != null && _importData.Levels.Count > 0)
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Đang import {_importData.Levels.Count} Levels...\n");
                var count = await _firestoreService.ImportLevelsAsync(_importData.Levels, progress);
                totalImported += count;
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã import {count}/{_importData.Levels.Count} Levels\n");
            }

            // Import Units
            if (chkUnits.Checked && _importData!.Units != null && _importData.Units.Count > 0)
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Đang import {_importData.Units.Count} Units...\n");
                var unitsList = _importData.Units.Values.ToList();
                var count = await _firestoreService.ImportUnitsAsync(unitsList, progress);
                totalImported += count;
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã import {count}/{_importData.Units.Count} Units\n");
            }

            // Import Lessons
            if (chkLessons.Checked && _importData!.Lessons != null && _importData.Lessons.Count > 0)
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Đang import {_importData.Lessons.Count} Lessons...\n");
                var lessonsList = _importData.Lessons.Values.ToList();
                var count = await _firestoreService.ImportLessonsAsync(lessonsList, progress);
                totalImported += count;
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã import {count}/{_importData.Lessons.Count} Lessons\n");
            }

            // Import Exercises
            if (chkExercises.Checked && _importData!.Exercises != null && _importData.Exercises.Count > 0)
            {
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] Đang import {_importData.Exercises.Count} Exercises...\n");
                var exercisesList = _importData.Exercises.Values.ToList();
                var count = await _firestoreService.ImportExercisesAsync(exercisesList, progress);
                totalImported += count;
                rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã import {count}/{_importData.Exercises.Count} Exercises\n");
            }

            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Hoàn thành! Đã import tổng cộng {totalImported} items.\n");
            MessageBox.Show($"Import hoàn thành! Đã import {totalImported} items.", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        catch (Exception ex)
        {
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✗ Lỗi khi import: {ex.Message}\n");
            MessageBox.Show($"Lỗi khi import: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            btnImport.Enabled = true;
            progressBar.Style = ProgressBarStyle.Continuous;
            progressBar.Value = 0;
            lblStatus.Text = "Ready";
        }
    }

    public void SetJsonContent(string jsonContent)
    {
        try
        {
            Dictionary<string, object>? existingData = null;

            // Nếu đã có file JSON, đọc và merge
            if (!string.IsNullOrWhiteSpace(txtJsonFile.Text) && File.Exists(txtJsonFile.Text))
            {
                try
                {
                    var existingJson = File.ReadAllText(txtJsonFile.Text);
                    existingData = JsonConvert.DeserializeObject<Dictionary<string, object>>(existingJson);
                }
                catch
                {
                    // Nếu không parse được, tạo mới
                    existingData = null;
                }
            }

            // Parse JSON mới
            var newData = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonContent);

            if (existingData != null && newData != null)
            {
                // Merge: thêm dữ liệu mới vào existing data
                foreach (var kvp in newData)
                {
                    if (existingData.ContainsKey(kvp.Key))
                    {
                        // Merge dictionaries nếu cùng key (units, lessons, exercises)
                        if (kvp.Value is Dictionary<string, object> newDict &&
                            existingData[kvp.Key] is Dictionary<string, object> existingDict)
                        {
                            foreach (var item in newDict)
                            {
                                existingDict[item.Key] = item.Value;
                            }
                        }
                    }
                    else
                    {
                        existingData[kvp.Key] = kvp.Value;
                    }
                }
            }
            else if (newData != null)
            {
                existingData = newData;
            }

            // Lưu vào file tạm hoặc file hiện có
            var outputFile = !string.IsNullOrWhiteSpace(txtJsonFile.Text) && File.Exists(txtJsonFile.Text)
                ? txtJsonFile.Text
                : Path.Combine(Path.GetTempPath(), $"firestore_import_{DateTime.Now:yyyyMMddHHmmss}.json");

            var mergedJson = JsonConvert.SerializeObject(existingData, Formatting.Indented);
            File.WriteAllText(outputFile, mergedJson);
            txtJsonFile.Text = outputFile;
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã nhận và merge JSON từ form tạo mới\n");
        }
        catch (Exception ex)
        {
            // Nếu merge thất bại, lưu JSON mới vào file tạm
            var tempFile = Path.Combine(Path.GetTempPath(), $"firestore_import_{DateTime.Now:yyyyMMddHHmmss}.json");
            File.WriteAllText(tempFile, jsonContent);
            txtJsonFile.Text = tempFile;
            rtbLog.AppendText($"[{DateTime.Now:HH:mm:ss}] ✓ Đã nhận JSON từ form tạo mới (không merge được: {ex.Message})\n");
        }
    }

    private void BtnCreateUnit_Click(object? sender, EventArgs e)
    {
        using var form = new UnitForm();
        if (form.ShowDialog() == DialogResult.OK)
        {
            //var json = form.GetJson();
            //if (!string.IsNullOrEmpty(json))
            //{
            //    SetJsonContent(json);
            //}
        }
    }

    private void BtnCreateLesson_Click(object? sender, EventArgs e)
    {
        using var form = new LessonForm();
        if (form.ShowDialog() == DialogResult.OK)
        {
            //var json = form.GetJson();
            //if (!string.IsNullOrEmpty(json))
            //{
            //    SetJsonContent(json);
            //}
        }
    }

    private void BtnCreateExercise_Click(object? sender, EventArgs e)
    {
        using var form = new ExerciseForm();
        if (form.ShowDialog() == DialogResult.OK)
        {
            //if (!string.IsNullOrEmpty(json))
            //{
            //    SetJsonContent(json);
            //}
        }
    }

    private void btnCreateGroupExercise_Click(object sender, EventArgs e)
    {
        using var form = new ExerciseGroupForm();
        if (form.ShowDialog() == DialogResult.OK)
        {
            //if (!string.IsNullOrEmpty(json))
            //{
            //    SetJsonContent(json);
            //}
        }
    }
}
