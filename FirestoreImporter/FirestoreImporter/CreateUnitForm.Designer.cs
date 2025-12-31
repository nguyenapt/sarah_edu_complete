namespace FirestoreImporter;

partial class CreateUnitForm
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    private TextBox txtId;
    private TextBox txtLevelId;
    private TextBox txtTitleEn;
    private TextBox txtTitleVi;
    private TextBox txtDescriptionEn;
    private TextBox txtDescriptionVi;
    private NumericUpDown numOrder;
    private NumericUpDown numEstimatedTime;
    private TextBox txtLessons;
    private TextBox txtPrerequisites;
    private TextBox txtGroup;
    private Button btnExportJson;
    private Button btnCancel;
    private RichTextBox rtbJsonPreview;

    /// <summary>
    ///  Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    ///  Required method for Designer support - do not modify
    ///  the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        txtId = new TextBox();
        txtLevelId = new TextBox();
        txtTitleEn = new TextBox();
        txtTitleVi = new TextBox();
        txtDescriptionEn = new TextBox();
        txtDescriptionVi = new TextBox();
        numOrder = new NumericUpDown();
        numEstimatedTime = new NumericUpDown();
        txtLessons = new TextBox();
        txtPrerequisites = new TextBox();
        txtGroup = new TextBox();
        btnExportJson = new Button();
        btnCancel = new Button();
        rtbJsonPreview = new RichTextBox();
        ((System.ComponentModel.ISupportInitialize)numOrder).BeginInit();
        ((System.ComponentModel.ISupportInitialize)numEstimatedTime).BeginInit();
        SuspendLayout();
        // 
        // txtId
        // 
        txtId.Location = new Point(0, 0);
        txtId.Name = "txtId";
        txtId.Size = new Size(100, 23);
        txtId.TabIndex = 0;
        // 
        // txtLevelId
        // 
        txtLevelId.Location = new Point(0, 0);
        txtLevelId.Name = "txtLevelId";
        txtLevelId.Size = new Size(100, 23);
        txtLevelId.TabIndex = 0;
        // 
        // txtTitleEn
        // 
        txtTitleEn.Location = new Point(0, 0);
        txtTitleEn.Name = "txtTitleEn";
        txtTitleEn.Size = new Size(100, 23);
        txtTitleEn.TabIndex = 0;
        // 
        // txtTitleVi
        // 
        txtTitleVi.Location = new Point(0, 0);
        txtTitleVi.Name = "txtTitleVi";
        txtTitleVi.Size = new Size(100, 23);
        txtTitleVi.TabIndex = 0;
        // 
        // txtDescriptionEn
        // 
        txtDescriptionEn.Location = new Point(0, 0);
        txtDescriptionEn.Name = "txtDescriptionEn";
        txtDescriptionEn.Size = new Size(100, 23);
        txtDescriptionEn.TabIndex = 0;
        // 
        // txtDescriptionVi
        // 
        txtDescriptionVi.Location = new Point(0, 0);
        txtDescriptionVi.Name = "txtDescriptionVi";
        txtDescriptionVi.Size = new Size(100, 23);
        txtDescriptionVi.TabIndex = 0;
        // 
        // numOrder
        // 
        numOrder.Location = new Point(0, 0);
        numOrder.Name = "numOrder";
        numOrder.Size = new Size(120, 23);
        numOrder.TabIndex = 0;
        // 
        // numEstimatedTime
        // 
        numEstimatedTime.Location = new Point(0, 0);
        numEstimatedTime.Name = "numEstimatedTime";
        numEstimatedTime.Size = new Size(120, 23);
        numEstimatedTime.TabIndex = 0;
        // 
        // txtLessons
        // 
        txtLessons.Location = new Point(0, 0);
        txtLessons.Name = "txtLessons";
        txtLessons.Size = new Size(100, 23);
        txtLessons.TabIndex = 0;
        // 
        // txtPrerequisites
        // 
        txtPrerequisites.Location = new Point(0, 0);
        txtPrerequisites.Name = "txtPrerequisites";
        txtPrerequisites.Size = new Size(100, 23);
        txtPrerequisites.TabIndex = 0;
        // 
        // txtGroup
        // 
        txtGroup.Location = new Point(0, 0);
        txtGroup.Name = "txtGroup";
        txtGroup.Size = new Size(100, 23);
        txtGroup.TabIndex = 0;
        // 
        // btnExportJson
        // 
        btnExportJson.Location = new Point(0, 0);
        btnExportJson.Name = "btnExportJson";
        btnExportJson.Size = new Size(75, 23);
        btnExportJson.TabIndex = 0;
        // 
        // btnCancel
        // 
        btnCancel.Location = new Point(0, 0);
        btnCancel.Name = "btnCancel";
        btnCancel.Size = new Size(75, 23);
        btnCancel.TabIndex = 0;
        // 
        // rtbJsonPreview
        // 
        rtbJsonPreview.Location = new Point(0, 0);
        rtbJsonPreview.Name = "rtbJsonPreview";
        rtbJsonPreview.Size = new Size(100, 96);
        rtbJsonPreview.TabIndex = 0;
        rtbJsonPreview.Text = "";
        // 
        // CreateUnitForm
        // 
        ClientSize = new Size(585, 422);
        Name = "CreateUnitForm";
        ((System.ComponentModel.ISupportInitialize)numOrder).EndInit();
        ((System.ComponentModel.ISupportInitialize)numEstimatedTime).EndInit();
        ResumeLayout(false);
    }

    #endregion
}
