namespace FirestoreImporter;

partial class CreateLessonForm
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    private TextBox txtId;
    private TextBox txtUnitId;
    private TextBox txtLevelId;
    private TextBox txtTitleEn;
    private TextBox txtTitleVi;
    private ComboBox cmbType;
    private NumericUpDown numOrder;
    private TextBox txtExercises;
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
        this.txtId = new TextBox();
        this.txtUnitId = new TextBox();
        this.txtLevelId = new TextBox();
        this.txtTitleEn = new TextBox();
        this.txtTitleVi = new TextBox();
        this.cmbType = new ComboBox();
        this.numOrder = new NumericUpDown();
        this.txtExercises = new TextBox();
        this.btnExportJson = new Button();
        this.btnCancel = new Button();
        this.rtbJsonPreview = new RichTextBox();
        ((System.ComponentModel.ISupportInitialize)(this.numOrder)).BeginInit();
        this.SuspendLayout();
        
        // Note: Complex UI setup is done in SetupUI() method called from constructor
        // This keeps InitializeComponent simple for the designer
        
        ((System.ComponentModel.ISupportInitialize)(this.numOrder)).EndInit();
        this.ResumeLayout(false);
        this.PerformLayout();
    }

    #endregion
}
