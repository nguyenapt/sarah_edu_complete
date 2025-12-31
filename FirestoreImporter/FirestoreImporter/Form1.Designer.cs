namespace FirestoreImporter;

partial class Form1
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

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
        lblProjectId = new Label();
        txtProjectId = new TextBox();
        lblCredentials = new Label();
        txtCredentials = new TextBox();
        btnBrowseCredentials = new Button();
        btnTestConnection = new Button();
        groupBoxConnection = new GroupBox();
        groupBoxImport = new GroupBox();
        btnCreateExercise = new Button();
        btnCreateLesson = new Button();
        btnCreateUnit = new Button();
        chkExercises = new CheckBox();
        chkLessons = new CheckBox();
        chkUnits = new CheckBox();
        chkLevels = new CheckBox();
        btnBrowseJson = new Button();
        txtJsonFile = new TextBox();
        lblJsonFile = new Label();
        btnImport = new Button();
        rtbLog = new RichTextBox();
        progressBar = new ProgressBar();
        lblStatus = new Label();
        button1 = new Button();
        button2 = new Button();
        button3 = new Button();
        btnCreateGroupExercise = new Button();
        groupBoxConnection.SuspendLayout();
        groupBoxImport.SuspendLayout();
        SuspendLayout();
        // 
        // lblProjectId
        // 
        lblProjectId.AutoSize = true;
        lblProjectId.Location = new Point(12, 25);
        lblProjectId.Name = "lblProjectId";
        lblProjectId.Size = new Size(61, 15);
        lblProjectId.TabIndex = 0;
        lblProjectId.Text = "Project ID:";
        // 
        // txtProjectId
        // 
        txtProjectId.Location = new Point(100, 22);
        txtProjectId.Name = "txtProjectId";
        txtProjectId.Size = new Size(300, 23);
        txtProjectId.TabIndex = 1;
        // 
        // lblCredentials
        // 
        lblCredentials.AutoSize = true;
        lblCredentials.Location = new Point(12, 60);
        lblCredentials.Name = "lblCredentials";
        lblCredentials.Size = new Size(69, 15);
        lblCredentials.TabIndex = 2;
        lblCredentials.Text = "Credentials:";
        // 
        // txtCredentials
        // 
        txtCredentials.Location = new Point(100, 57);
        txtCredentials.Name = "txtCredentials";
        txtCredentials.Size = new Size(250, 23);
        txtCredentials.TabIndex = 3;
        // 
        // btnBrowseCredentials
        // 
        btnBrowseCredentials.Location = new Point(356, 56);
        btnBrowseCredentials.Name = "btnBrowseCredentials";
        btnBrowseCredentials.Size = new Size(44, 25);
        btnBrowseCredentials.TabIndex = 4;
        btnBrowseCredentials.Text = "...";
        btnBrowseCredentials.UseVisualStyleBackColor = true;
        btnBrowseCredentials.Click += BtnBrowseCredentials_Click;
        // 
        // btnTestConnection
        // 
        btnTestConnection.Location = new Point(100, 95);
        btnTestConnection.Name = "btnTestConnection";
        btnTestConnection.Size = new Size(120, 30);
        btnTestConnection.TabIndex = 5;
        btnTestConnection.Text = "Test Connection";
        btnTestConnection.UseVisualStyleBackColor = true;
        btnTestConnection.Click += BtnTestConnection_Click;
        // 
        // groupBoxConnection
        // 
        groupBoxConnection.Controls.Add(lblProjectId);
        groupBoxConnection.Controls.Add(btnTestConnection);
        groupBoxConnection.Controls.Add(txtProjectId);
        groupBoxConnection.Controls.Add(btnBrowseCredentials);
        groupBoxConnection.Controls.Add(lblCredentials);
        groupBoxConnection.Controls.Add(txtCredentials);
        groupBoxConnection.Location = new Point(12, 12);
        groupBoxConnection.Name = "groupBoxConnection";
        groupBoxConnection.Size = new Size(420, 140);
        groupBoxConnection.TabIndex = 6;
        groupBoxConnection.TabStop = false;
        groupBoxConnection.Text = "Firestore Connection";
        // 
        // groupBoxImport
        // 
        groupBoxImport.Controls.Add(btnCreateExercise);
        groupBoxImport.Controls.Add(btnCreateLesson);
        groupBoxImport.Controls.Add(btnCreateUnit);
        groupBoxImport.Controls.Add(chkExercises);
        groupBoxImport.Controls.Add(chkLessons);
        groupBoxImport.Controls.Add(chkUnits);
        groupBoxImport.Controls.Add(chkLevels);
        groupBoxImport.Controls.Add(btnBrowseJson);
        groupBoxImport.Controls.Add(txtJsonFile);
        groupBoxImport.Controls.Add(lblJsonFile);
        groupBoxImport.Controls.Add(btnImport);
        groupBoxImport.Location = new Point(12, 165);
        groupBoxImport.Name = "groupBoxImport";
        groupBoxImport.Size = new Size(420, 200);
        groupBoxImport.TabIndex = 7;
        groupBoxImport.TabStop = false;
        groupBoxImport.Text = "Import Data";
        // 
        // btnCreateExercise
        // 
        btnCreateExercise.Location = new Point(288, 205);
        btnCreateExercise.Name = "btnCreateExercise";
        btnCreateExercise.Size = new Size(120, 30);
        btnCreateExercise.TabIndex = 10;
        btnCreateExercise.Text = "Tạo Exercise";
        btnCreateExercise.UseVisualStyleBackColor = true;
        btnCreateExercise.Click += BtnCreateExercise_Click;
        // 
        // btnCreateLesson
        // 
        btnCreateLesson.Location = new Point(150, 205);
        btnCreateLesson.Name = "btnCreateLesson";
        btnCreateLesson.Size = new Size(120, 30);
        btnCreateLesson.TabIndex = 9;
        btnCreateLesson.Text = "Tạo Lesson";
        btnCreateLesson.UseVisualStyleBackColor = true;
        btnCreateLesson.Click += BtnCreateLesson_Click;
        // 
        // btnCreateUnit
        // 
        btnCreateUnit.Location = new Point(12, 205);
        btnCreateUnit.Name = "btnCreateUnit";
        btnCreateUnit.Size = new Size(120, 30);
        btnCreateUnit.TabIndex = 8;
        btnCreateUnit.Text = "Tạo Unit";
        btnCreateUnit.UseVisualStyleBackColor = true;
        btnCreateUnit.Click += BtnCreateUnit_Click;
        // 
        // chkExercises
        // 
        chkExercises.AutoSize = true;
        chkExercises.Checked = true;
        chkExercises.CheckState = CheckState.Checked;
        chkExercises.Location = new Point(100, 135);
        chkExercises.Name = "chkExercises";
        chkExercises.Size = new Size(72, 19);
        chkExercises.TabIndex = 6;
        chkExercises.Text = "Exercises";
        chkExercises.UseVisualStyleBackColor = true;
        // 
        // chkLessons
        // 
        chkLessons.AutoSize = true;
        chkLessons.Checked = true;
        chkLessons.CheckState = CheckState.Checked;
        chkLessons.Location = new Point(100, 110);
        chkLessons.Name = "chkLessons";
        chkLessons.Size = new Size(67, 19);
        chkLessons.TabIndex = 5;
        chkLessons.Text = "Lessons";
        chkLessons.UseVisualStyleBackColor = true;
        // 
        // chkUnits
        // 
        chkUnits.AutoSize = true;
        chkUnits.Checked = true;
        chkUnits.CheckState = CheckState.Checked;
        chkUnits.Location = new Point(100, 85);
        chkUnits.Name = "chkUnits";
        chkUnits.Size = new Size(53, 19);
        chkUnits.TabIndex = 4;
        chkUnits.Text = "Units";
        chkUnits.UseVisualStyleBackColor = true;
        // 
        // chkLevels
        // 
        chkLevels.AutoSize = true;
        chkLevels.Checked = true;
        chkLevels.CheckState = CheckState.Checked;
        chkLevels.Location = new Point(100, 60);
        chkLevels.Name = "chkLevels";
        chkLevels.Size = new Size(58, 19);
        chkLevels.TabIndex = 3;
        chkLevels.Text = "Levels";
        chkLevels.UseVisualStyleBackColor = true;
        // 
        // btnBrowseJson
        // 
        btnBrowseJson.Location = new Point(356, 21);
        btnBrowseJson.Name = "btnBrowseJson";
        btnBrowseJson.Size = new Size(44, 25);
        btnBrowseJson.TabIndex = 2;
        btnBrowseJson.Text = "...";
        btnBrowseJson.UseVisualStyleBackColor = true;
        btnBrowseJson.Click += BtnBrowseJson_Click;
        // 
        // txtJsonFile
        // 
        txtJsonFile.Location = new Point(100, 22);
        txtJsonFile.Name = "txtJsonFile";
        txtJsonFile.Size = new Size(250, 23);
        txtJsonFile.TabIndex = 1;
        // 
        // lblJsonFile
        // 
        lblJsonFile.AutoSize = true;
        lblJsonFile.Location = new Point(12, 25);
        lblJsonFile.Name = "lblJsonFile";
        lblJsonFile.Size = new Size(59, 15);
        lblJsonFile.TabIndex = 0;
        lblJsonFile.Text = "JSON File:";
        // 
        // btnImport
        // 
        btnImport.Location = new Point(100, 165);
        btnImport.Name = "btnImport";
        btnImport.Size = new Size(120, 30);
        btnImport.TabIndex = 7;
        btnImport.Text = "Start Import";
        btnImport.UseVisualStyleBackColor = true;
        btnImport.Click += BtnImport_Click;
        // 
        // rtbLog
        // 
        rtbLog.Location = new Point(450, 12);
        rtbLog.Name = "rtbLog";
        rtbLog.Size = new Size(500, 400);
        rtbLog.TabIndex = 8;
        rtbLog.Text = "";
        // 
        // progressBar
        // 
        progressBar.Location = new Point(12, 440);
        progressBar.Name = "progressBar";
        progressBar.Size = new Size(420, 23);
        progressBar.TabIndex = 9;
        // 
        // lblStatus
        // 
        lblStatus.AutoSize = true;
        lblStatus.Location = new Point(12, 470);
        lblStatus.Name = "lblStatus";
        lblStatus.Size = new Size(39, 15);
        lblStatus.TabIndex = 10;
        lblStatus.Text = "Ready";
        // 
        // button1
        // 
        button1.Location = new Point(515, 440);
        button1.Name = "button1";
        button1.Size = new Size(75, 23);
        button1.TabIndex = 11;
        button1.Text = "Create Unit";
        button1.UseVisualStyleBackColor = true;
        button1.Click += BtnCreateUnit_Click;
        // 
        // button2
        // 
        button2.Location = new Point(596, 440);
        button2.Name = "button2";
        button2.Size = new Size(102, 23);
        button2.TabIndex = 12;
        button2.Text = "Create Lesson";
        button2.UseVisualStyleBackColor = true;
        button2.Click += BtnCreateLesson_Click;
        // 
        // button3
        // 
        button3.Location = new Point(704, 440);
        button3.Name = "button3";
        button3.Size = new Size(102, 23);
        button3.TabIndex = 13;
        button3.Text = "Create Exercise";
        button3.UseVisualStyleBackColor = true;
        button3.Click += BtnCreateExercise_Click;
        // 
        // btnCreateGroupExercise
        // 
        btnCreateGroupExercise.Location = new Point(812, 440);
        btnCreateGroupExercise.Name = "btnCreateGroupExercise";
        btnCreateGroupExercise.Size = new Size(138, 23);
        btnCreateGroupExercise.TabIndex = 13;
        btnCreateGroupExercise.Text = "Create Group Exercise";
        btnCreateGroupExercise.UseVisualStyleBackColor = true;
        btnCreateGroupExercise.Click += btnCreateGroupExercise_Click;
        // 
        // Form1
        // 
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(1011, 751);
        Controls.Add(btnCreateGroupExercise);
        Controls.Add(button3);
        Controls.Add(button2);
        Controls.Add(button1);
        Controls.Add(lblStatus);
        Controls.Add(progressBar);
        Controls.Add(rtbLog);
        Controls.Add(groupBoxImport);
        Controls.Add(groupBoxConnection);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox = false;
        Name = "Form1";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "Firestore Data Importer";
        groupBoxConnection.ResumeLayout(false);
        groupBoxConnection.PerformLayout();
        groupBoxImport.ResumeLayout(false);
        groupBoxImport.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }

    #endregion

    private Label lblProjectId;
    private TextBox txtProjectId;
    private Label lblCredentials;
    private TextBox txtCredentials;
    private Button btnBrowseCredentials;
    private Button btnTestConnection;
    private GroupBox groupBoxConnection;
    private GroupBox groupBoxImport;
    private Label lblJsonFile;
    private TextBox txtJsonFile;
    private Button btnBrowseJson;
    private CheckBox chkLevels;
    private CheckBox chkUnits;
    private CheckBox chkLessons;
    private CheckBox chkExercises;
    private Button btnImport;
    private RichTextBox rtbLog;
    private ProgressBar progressBar;
    private Label lblStatus;
    private Button btnCreateUnit;
    private Button btnCreateLesson;
    private Button btnCreateExercise;
    private Button button1;
    private Button button2;
    private Button button3;
    private Button btnCreateGroupExercise;
}
