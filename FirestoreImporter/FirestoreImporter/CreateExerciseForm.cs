using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter;

public partial class CreateExerciseForm : Form
{
    private string _jsonResult = string.Empty;

    public CreateExerciseForm()
    {
        InitializeComponent();
        SetupUI();
    }

    private void SetupUI()
    {
        this.Text = "Tạo Exercise";
        this.Size = new Size(800, 600);
        this.StartPosition = FormStartPosition.CenterParent;
        this.FormBorderStyle = FormBorderStyle.FixedDialog;
        this.MaximizeBox = false;

        int yPos = 15;
        int labelWidth = 120;
        int textBoxWidth = 200;
        int spacing = 30;

        // ID
        var lblId = new Label { Text = "ID:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtId.Location = new Point(140, yPos);
        this.txtId.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblId);
        this.Controls.Add(this.txtId);
        yPos += spacing;

        // Lesson ID
        var lblLessonId = new Label { Text = "Lesson ID:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtLessonId.Location = new Point(140, yPos);
        this.txtLessonId.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblLessonId);
        this.Controls.Add(this.txtLessonId);
        yPos += spacing;

        // Unit ID
        var lblUnitId = new Label { Text = "Unit ID:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtUnitId.Location = new Point(140, yPos);
        this.txtUnitId.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblUnitId);
        this.Controls.Add(this.txtUnitId);
        yPos += spacing;

        // Level ID
        var lblLevelId = new Label { Text = "Level ID:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtLevelId.Location = new Point(140, yPos);
        this.txtLevelId.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblLevelId);
        this.Controls.Add(this.txtLevelId);
        yPos += spacing;

        // Type
        var lblType = new Label { Text = "Type:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.cmbType.Location = new Point(140, yPos);
        this.cmbType.Size = new Size(textBoxWidth, 23);
        this.cmbType.DropDownStyle = ComboBoxStyle.DropDownList;
        this.cmbType.Items.AddRange(new[] { "single_choice", "multiple_choice", "fill_blank", "matching", "listening", "speaking", "button_single_choice" });
        this.cmbType.SelectedIndex = 0;
        this.Controls.Add(lblType);
        this.Controls.Add(this.cmbType);
        yPos += spacing;

        // Question
        var lblQuestion = new Label { Text = "Question:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtQuestion.Location = new Point(140, yPos);
        this.txtQuestion.Size = new Size(textBoxWidth, 60);
        this.txtQuestion.Multiline = true;
        this.Controls.Add(lblQuestion);
        this.Controls.Add(this.txtQuestion);
        yPos += 70;

        // Points
        var lblPoints = new Label { Text = "Points:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.numPoints.Location = new Point(140, yPos);
        this.numPoints.Size = new Size(100, 23);
        this.numPoints.Minimum = 0;
        this.numPoints.Maximum = 1000;
        this.numPoints.Value = 10;
        this.Controls.Add(lblPoints);
        this.Controls.Add(this.numPoints);
        yPos += spacing;

        // Time Limit
        var lblTimeLimit = new Label { Text = "Time Limit (s):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.numTimeLimit.Location = new Point(140, yPos);
        this.numTimeLimit.Size = new Size(100, 23);
        this.numTimeLimit.Minimum = 0;
        this.numTimeLimit.Maximum = 3600;
        this.Controls.Add(lblTimeLimit);
        this.Controls.Add(this.numTimeLimit);
        yPos += spacing;

        // Difficulty
        var lblDifficulty = new Label { Text = "Difficulty:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.cmbDifficulty.Location = new Point(140, yPos);
        this.cmbDifficulty.Size = new Size(textBoxWidth, 23);
        this.cmbDifficulty.DropDownStyle = ComboBoxStyle.DropDownList;
        this.cmbDifficulty.Items.AddRange(new[] { "easy", "medium", "hard" });
        this.cmbDifficulty.SelectedIndex = 0;
        this.Controls.Add(lblDifficulty);
        this.Controls.Add(this.cmbDifficulty);
        yPos += spacing;

        // Explanation
        var lblExplanation = new Label { Text = "Explanation:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtExplanation.Location = new Point(140, yPos);
        this.txtExplanation.Size = new Size(textBoxWidth, 60);
        this.txtExplanation.Multiline = true;
        this.Controls.Add(lblExplanation);
        this.Controls.Add(this.txtExplanation);
        yPos += 70;

        // Content (JSON format)
        var lblContent = new Label { Text = "Content (JSON):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        var lblContentHint = new Label 
        { 
            Text = "VD: {\"options\":[\"A\",\"B\",\"C\"],\"correctAnswers\":[\"A\"]}", 
            Location = new Point(140, yPos - 15), 
            Size = new Size(400, 15),
            ForeColor = Color.Gray,
            Font = new Font("Arial", 8)
        };
        this.txtContent.Location = new Point(140, yPos);
        this.txtContent.Size = new Size(textBoxWidth, 60);
        this.txtContent.Multiline = true;
        this.txtContent.PlaceholderText = "{\"options\":[\"A\",\"B\"],\"correctAnswers\":[\"A\"]}";
        this.Controls.Add(lblContent);
        this.Controls.Add(lblContentHint);
        this.Controls.Add(this.txtContent);
        yPos += 70;

        // JSON Preview
        var lblJsonPreview = new Label { Text = "JSON Preview:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.rtbJsonPreview.Location = new Point(15, yPos + 20);
        this.rtbJsonPreview.Size = new Size(750, 100);
        this.rtbJsonPreview.ReadOnly = true;
        this.Controls.Add(lblJsonPreview);
        this.Controls.Add(this.rtbJsonPreview);
        yPos += 140;

        // Buttons
        this.btnExportJson = new Button
        {
            Text = "Export JSON",
            Location = new Point(500, yPos),
            Size = new Size(120, 35),
            DialogResult = DialogResult.OK
        };
        this.btnExportJson.Click += BtnExportJson_Click;

        this.btnCancel = new Button
        {
            Text = "Cancel",
            Location = new Point(630, yPos),
            Size = new Size(120, 35),
            DialogResult = DialogResult.Cancel
        };

        this.Controls.Add(this.btnExportJson);
        this.Controls.Add(this.btnCancel);

        // Update preview on change
        this.txtId.TextChanged += UpdateJsonPreview;
        this.txtLessonId.TextChanged += UpdateJsonPreview;
        this.txtUnitId.TextChanged += UpdateJsonPreview;
        this.txtLevelId.TextChanged += UpdateJsonPreview;
        this.cmbType.SelectedIndexChanged += UpdateJsonPreview;
        this.txtQuestion.TextChanged += UpdateJsonPreview;
        this.numPoints.ValueChanged += UpdateJsonPreview;
        this.numTimeLimit.ValueChanged += UpdateJsonPreview;
        this.cmbDifficulty.SelectedIndexChanged += UpdateJsonPreview;
        this.txtExplanation.TextChanged += UpdateJsonPreview;
        this.txtContent.TextChanged += UpdateJsonPreview;
    }

    private void UpdateJsonPreview(object? sender, EventArgs e)
    {
        try
        {
            var exercise = CreateExerciseFromInputs();
            var json = JsonConvert.SerializeObject(new Dictionary<string, ExerciseModel> { { exercise.Id, exercise } }, Formatting.Indented);
            this.rtbJsonPreview.Text = json;
        }
        catch
        {
            this.rtbJsonPreview.Text = "Invalid input";
        }
    }

    private ExerciseModel CreateExerciseFromInputs()
    {
        var exercise = new ExerciseModel
        {
            Id = txtId.Text.Trim(),
            LessonId = txtLessonId.Text.Trim(),
            UnitId = txtUnitId.Text.Trim(),
            LevelId = txtLevelId.Text.Trim(),
            Type = cmbType.SelectedItem?.ToString() ?? "single_choice",
            Question = txtQuestion.Text.Trim(),
            Points = (int)numPoints.Value,
            Difficulty = cmbDifficulty.SelectedItem?.ToString() ?? "easy"
        };

        if (numTimeLimit.Value > 0)
        {
            exercise.TimeLimit = (int)numTimeLimit.Value;
        }

        if (!string.IsNullOrWhiteSpace(txtExplanation.Text))
        {
            exercise.Explanation = txtExplanation.Text.Trim();
        }

        // Parse Content JSON
        if (!string.IsNullOrWhiteSpace(txtContent.Text))
        {
            try
            {
                exercise.Content = JsonConvert.DeserializeObject<Dictionary<string, object>>(txtContent.Text);
            }
            catch
            {
                // Invalid JSON, will be handled in validation
            }
        }

        return exercise;
    }

    private void BtnExportJson_Click(object? sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtId.Text))
        {
            MessageBox.Show("Vui lòng nhập ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        if (!string.IsNullOrWhiteSpace(txtContent.Text))
        {
            try
            {
                JsonConvert.DeserializeObject<Dictionary<string, object>>(txtContent.Text);
            }
            catch
            {
                MessageBox.Show("Content phải là JSON hợp lệ!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
        }

        try
        {
            var exercise = CreateExerciseFromInputs();
            var jsonData = new Dictionary<string, object>
            {
                { "exercises", new Dictionary<string, ExerciseModel> { { exercise.Id, exercise } } }
            };
            _jsonResult = JsonConvert.SerializeObject(jsonData, Formatting.Indented);
            this.DialogResult = DialogResult.OK;
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi khi tạo JSON: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    public string GetJson()
    {
        return _jsonResult;
    }
}
