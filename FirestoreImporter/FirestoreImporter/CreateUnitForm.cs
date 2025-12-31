using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter;

public partial class CreateUnitForm : Form
{
    private string _jsonResult = string.Empty;

    public CreateUnitForm()
    {
        InitializeComponent();
        SetupUI();
    }

    private void SetupUI()
    {
        this.Text = "Tạo Unit";
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

        // Description EN
        var lblDescEn = new Label { Text = "Description (EN):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtDescriptionEn.Location = new Point(140, yPos);
        this.txtDescriptionEn.Size = new Size(textBoxWidth, 60);
        this.txtDescriptionEn.Multiline = true;
        this.Controls.Add(lblDescEn);
        this.Controls.Add(this.txtDescriptionEn);
        yPos += 70;

        // Description VI
        var lblDescVi = new Label { Text = "Description (VI):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtDescriptionVi.Location = new Point(140, yPos);
        this.txtDescriptionVi.Size = new Size(textBoxWidth, 60);
        this.txtDescriptionVi.Multiline = true;
        this.Controls.Add(lblDescVi);
        this.Controls.Add(this.txtDescriptionVi);
        yPos += 70;

        // Order
        var lblOrder = new Label { Text = "Order:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.numOrder.Location = new Point(140, yPos);
        this.numOrder.Size = new Size(100, 23);
        this.numOrder.Minimum = 0;
        this.numOrder.Maximum = 1000;
        this.Controls.Add(lblOrder);
        this.Controls.Add(this.numOrder);
        yPos += spacing;

        // Estimated Time
        var lblEstimatedTime = new Label { Text = "Estimated Time:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.numEstimatedTime.Location = new Point(140, yPos);
        this.numEstimatedTime.Size = new Size(100, 23);
        this.numEstimatedTime.Minimum = 0;
        this.numEstimatedTime.Maximum = 10000;
        this.Controls.Add(lblEstimatedTime);
        this.Controls.Add(this.numEstimatedTime);
        yPos += spacing;

        // Lessons (comma separated)
        var lblLessons = new Label { Text = "Lessons (comma):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtLessons.Location = new Point(140, yPos);
        this.txtLessons.Size = new Size(textBoxWidth, 23);
        this.txtLessons.PlaceholderText = "lesson_a1_1_1, lesson_a1_1_2";
        this.Controls.Add(lblLessons);
        this.Controls.Add(this.txtLessons);
        yPos += spacing;

        // Prerequisites (comma separated)
        var lblPrerequisites = new Label { Text = "Prerequisites (comma):", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtPrerequisites.Location = new Point(140, yPos);
        this.txtPrerequisites.Size = new Size(textBoxWidth, 23);
        this.txtPrerequisites.PlaceholderText = "unit_a1_1, unit_a1_2";
        this.Controls.Add(lblPrerequisites);
        this.Controls.Add(this.txtPrerequisites);
        yPos += spacing;

        // Group
        var lblGroup = new Label { Text = "Group:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.txtGroup.Location = new Point(140, yPos);
        this.txtGroup.Size = new Size(textBoxWidth, 23);
        this.Controls.Add(lblGroup);
        this.Controls.Add(this.txtGroup);
        yPos += spacing + 20;

        // JSON Preview
        var lblJsonPreview = new Label { Text = "JSON Preview:", Location = new Point(15, yPos), Size = new Size(labelWidth, 20) };
        this.rtbJsonPreview.Location = new Point(15, yPos + 20);
        this.rtbJsonPreview.Size = new Size(750, 200);
        this.rtbJsonPreview.ReadOnly = true;
        this.Controls.Add(lblJsonPreview);
        this.Controls.Add(this.rtbJsonPreview);
        yPos += 240;

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

        // Update preview on text change
        this.txtId.TextChanged += UpdateJsonPreview;
        this.txtLevelId.TextChanged += UpdateJsonPreview;
        this.txtTitleEn.TextChanged += UpdateJsonPreview;
        this.txtTitleVi.TextChanged += UpdateJsonPreview;
        this.txtDescriptionEn.TextChanged += UpdateJsonPreview;
        this.txtDescriptionVi.TextChanged += UpdateJsonPreview;
        this.numOrder.ValueChanged += UpdateJsonPreview;
        this.numEstimatedTime.ValueChanged += UpdateJsonPreview;
        this.txtLessons.TextChanged += UpdateJsonPreview;
        this.txtPrerequisites.TextChanged += UpdateJsonPreview;
        this.txtGroup.TextChanged += UpdateJsonPreview;
    }

    private void UpdateJsonPreview(object? sender, EventArgs e)
    {
        try
        {
            var unit = CreateUnitFromInputs();
            var json = JsonConvert.SerializeObject(new Dictionary<string, UnitModel> { { unit.Id, unit } }, Formatting.Indented);
            this.rtbJsonPreview.Text = json;
        }
        catch
        {
            this.rtbJsonPreview.Text = "Invalid input";
        }
    }

    private UnitModel CreateUnitFromInputs()
    {
        var unit = new UnitModel
        {
            Id = txtId.Text.Trim(),
            LevelId = txtLevelId.Text.Trim(),
            Order = (int)numOrder.Value,
            EstimatedTime = (int)numEstimatedTime.Value
        };

        // Title
        if (!string.IsNullOrWhiteSpace(txtTitleEn.Text) || !string.IsNullOrWhiteSpace(txtTitleVi.Text))
        {
            unit.Title = new Dictionary<string, string>();
            if (!string.IsNullOrWhiteSpace(txtTitleEn.Text))
                unit.Title["en"] = txtTitleEn.Text.Trim();
            if (!string.IsNullOrWhiteSpace(txtTitleVi.Text))
                unit.Title["vi"] = txtTitleVi.Text.Trim();
        }

        // Description
        if (!string.IsNullOrWhiteSpace(txtDescriptionEn.Text) || !string.IsNullOrWhiteSpace(txtDescriptionVi.Text))
        {
            unit.Description = new Dictionary<string, string>();
            if (!string.IsNullOrWhiteSpace(txtDescriptionEn.Text))
                unit.Description["en"] = txtDescriptionEn.Text.Trim();
            if (!string.IsNullOrWhiteSpace(txtDescriptionVi.Text))
                unit.Description["vi"] = txtDescriptionVi.Text.Trim();
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

        return unit;
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
            var unit = CreateUnitFromInputs();
            var jsonData = new Dictionary<string, object>
            {
                { "units", new Dictionary<string, UnitModel> { { unit.Id, unit } } }
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
