namespace FirestoreImporter;

partial class CreateExerciseForm
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    private TextBox txtId;
    private TextBox txtLessonId;
    private TextBox txtUnitId;
    private TextBox txtLevelId;
    private ComboBox cmbType;
    private TextBox txtQuestion;
    private NumericUpDown numPoints;
    private NumericUpDown numTimeLimit;
    private ComboBox cmbDifficulty;
    private TextBox txtExplanation;
    private TextBox txtContent;
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
        this.txtLessonId = new TextBox();
        this.txtUnitId = new TextBox();
        this.txtLevelId = new TextBox();
        this.cmbType = new ComboBox();
        this.txtQuestion = new TextBox();
        this.numPoints = new NumericUpDown();
        this.numTimeLimit = new NumericUpDown();
        this.cmbDifficulty = new ComboBox();
        this.txtExplanation = new TextBox();
        this.txtContent = new TextBox();
        this.btnExportJson = new Button();
        this.btnCancel = new Button();
        this.rtbJsonPreview = new RichTextBox();
        ((System.ComponentModel.ISupportInitialize)(this.numPoints)).BeginInit();
        ((System.ComponentModel.ISupportInitialize)(this.numTimeLimit)).BeginInit();
        this.SuspendLayout();
        
        // Note: Complex UI setup is done in SetupUI() method called from constructor
        // This keeps InitializeComponent simple for the designer
        
        ((System.ComponentModel.ISupportInitialize)(this.numPoints)).EndInit();
        ((System.ComponentModel.ISupportInitialize)(this.numTimeLimit)).EndInit();
        this.ResumeLayout(false);
        this.PerformLayout();
    }

    #endregion
}
