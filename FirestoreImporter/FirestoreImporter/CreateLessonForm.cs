using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter;

public partial class CreateLessonForm : Form
{
    private string _jsonResult = string.Empty;

    public CreateLessonForm()
    {
        InitializeComponent();
        SetupUI();
    }

    private void SetupUI()
    {
        this.Text = "Tạo Lesson";
        this.Size = new Size(800, 550);
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

        // Title EN
        var lblTitleEn = new Label { Text = "Title (EN):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtTitleEn.Location = new Point(140, yPos);
        this.txtTitleEn.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblTitleEn);
        this.Controls.Add(this.txtTitleEn);
        yPos += spacing;

        // Title VI
        var lblTitleVi = new Label { Text = "Title (VI):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtTitleVi.Location = new Point(140, yPos);
        this.txtTitleVi.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblTitleVi);
        this.Controls.Add(this.txtTitleVi);
        yPos += spacing;

        // Type
        var lblType = new Label { Text = "Type:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.cmbType.Location = new Point(140, yPos);
        this.cmbType.Size = new Size(textBoxWidth, 23);
        this.cmbType.DropDownStyle = ComboBoxStyle.DropDownList;
        this.cmbType.Items.AddRange(new[] { "grammar", "vocabulary", "listening", "speaking", "reading", "writing" });
        this.cmbType.SelectedIndex = 0;
        this.Controls.Add(lblType);
        this.Controls.Add(this.cmbType);
        yPos += spacing;

        // Order
        var lblOrder = new Label { Text = "Order:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.numOrder.Location = new Point(140, yPos);
        this.numOrder.Size = new Size(100, 23);
        this.numOrder.Minimum = 0;
        this.numOrder.Maximum = 1000;
        this.Controls.Add(lblOrder);
        this.Controls.Add(this.numOrder);
        yPos += spacing;

        // Exercises (comma separated)
        var lblExercises = new Label { Text = "Exercises (comma):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtExercises.Location = new Point(140, yPos);
        this.txtExercises.Size = new Size(textBoxWidth, 23);
        this.txtExercises.PlaceholderText = "exercise_a1_1_1_1, exercise_a1_1_1_2";
        this.Controls.Add(lblExercises);
        this.Controls.Add(this.txtExercises);
        yPos += spacing + 20;

        // JSON Preview
        var lblJsonPreview = new Label { Text = "JSON Preview:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.rtbJsonPreview.Location = new Point(15, yPos + 20);
        this.rtbJsonPreview.Size = new Size(750, 150);
        this.rtbJsonPreview.ReadOnly = true;
        this.Controls.Add(lblJsonPreview);
        this.Controls.Add(this.rtbJsonPreview);
        yPos += 190;

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
        this.txtUnitId.TextChanged += UpdateJsonPreview;
        this.txtLevelId.TextChanged += UpdateJsonPreview;
        this.txtTitleEn.TextChanged += UpdateJsonPreview;
        this.txtTitleVi.TextChanged += UpdateJsonPreview;
        this.cmbType.SelectedIndexChanged += UpdateJsonPreview;
        this.numOrder.ValueChanged += UpdateJsonPreview;
        this.txtExercises.TextChanged += UpdateJsonPreview;
    }

    private void UpdateJsonPreview(object? sender, EventArgs e)
    {
        try
        {
            var lesson = CreateLessonFromInputs();
            var json = JsonConvert.SerializeObject(new Dictionary<string, LessonModel> { { lesson.Id, lesson } }, Formatting.Indented);
            this.rtbJsonPreview.Text = json;
        }
        catch
        {
            this.rtbJsonPreview.Text = "Invalid input";
        }
    }

    private LessonModel CreateLessonFromInputs()
    {
        var lesson = new LessonModel
        {
            Id = txtId.Text.Trim(),
            UnitId = txtUnitId.Text.Trim(),
            LevelId = txtLevelId.Text.Trim(),
            Type = cmbType.SelectedItem?.ToString() ?? "grammar",
            Order = (int)numOrder.Value
        };

        // Title
        if (!string.IsNullOrWhiteSpace(txtTitleEn.Text) || !string.IsNullOrWhiteSpace(txtTitleVi.Text))
        {
            lesson.Title = new Dictionary<string, string>();
            if (!string.IsNullOrWhiteSpace(txtTitleEn.Text))
                lesson.Title["en"] = txtTitleEn.Text.Trim();
            if (!string.IsNullOrWhiteSpace(txtTitleVi.Text))
                lesson.Title["vi"] = txtTitleVi.Text.Trim();
        }

        // Content with exercises
        lesson.Content = new LessonContent();
        if (!string.IsNullOrWhiteSpace(txtExercises.Text))
        {
            lesson.Content.Exercises = txtExercises.Text.Split(',')
                .Select(s => s.Trim())
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();
        }

        return lesson;
    }

    private void BtnExportJson_Click(object? sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtId.Text))
        {
            MessageBox.Show("Vui lòng nhập ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        try
        {
            var lesson = CreateLessonFromInputs();
            var jsonData = new Dictionary<string, object>
            {
                { "lessons", new Dictionary<string, LessonModel> { { lesson.Id, lesson } } }
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
