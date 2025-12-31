namespace FirestoreImporter
{
    partial class ExerciseGroupForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            txtLessonId = new TextBox();
            label2 = new Label();
            txtId = new TextBox();
            label1 = new Label();
            label3 = new Label();
            txtUnitId = new TextBox();
            label4 = new Label();
            cbLevelId = new ComboBox();
            grvQuestion = new DataGridView();
            numPoints = new NumericUpDown();
            label11 = new Label();
            label8 = new Label();
            numTimeLimit = new NumericUpDown();
            cbDifficulty = new ComboBox();
            label9 = new Label();
            label13 = new Label();
            txtAudioUrl = new TextBox();
            label14 = new Label();
            txtImageUrl = new TextBox();
            btnExportJsonFireStore = new Button();
            btnExportJson = new Button();
            tabControl1 = new TabControl();
            tabPage2 = new TabPage();
            btnAddQuestion = new Button();
            groupBox1 = new GroupBox();
            grvTitle = new DataGridView();
            btnAddTitle = new Button();
            txtLanguageTitleValue = new TextBox();
            label6 = new Label();
            cbLanguageCodeTitle = new ComboBox();
            label7 = new Label();
            numLesson = new NumericUpDown();
            numUnit = new NumericUpDown();
            label19 = new Label();
            label18 = new Label();
            label5 = new Label();
            numExercise = new NumericUpDown();
            ((System.ComponentModel.ISupportInitialize)grvQuestion).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numPoints).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numTimeLimit).BeginInit();
            tabControl1.SuspendLayout();
            tabPage2.SuspendLayout();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)grvTitle).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numLesson).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numUnit).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numExercise).BeginInit();
            SuspendLayout();
            // 
            // txtLessonId
            // 
            txtLessonId.Location = new Point(530, 77);
            txtLessonId.Name = "txtLessonId";
            txtLessonId.Size = new Size(228, 23);
            txtLessonId.TabIndex = 4;
            txtLessonId.Text = "lesson_";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(447, 85);
            label2.Name = "label2";
            label2.Size = new Size(56, 15);
            label2.TabIndex = 2;
            label2.Text = "Lesson Id";
            // 
            // txtId
            // 
            txtId.Location = new Point(149, 136);
            txtId.Name = "txtId";
            txtId.Size = new Size(279, 23);
            txtId.TabIndex = 5;
            txtId.Text = "exercise_";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(66, 144);
            label1.Name = "label1";
            label1.Size = new Size(17, 15);
            label1.TabIndex = 3;
            label1.Text = "Id";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(447, 56);
            label3.Name = "label3";
            label3.Size = new Size(42, 15);
            label3.TabIndex = 2;
            label3.Text = "Unit Id";
            // 
            // txtUnitId
            // 
            txtUnitId.Location = new Point(530, 48);
            txtUnitId.Name = "txtUnitId";
            txtUnitId.Size = new Size(228, 23);
            txtUnitId.TabIndex = 4;
            txtUnitId.Text = "unit_";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Location = new Point(66, 28);
            label4.Name = "label4";
            label4.Size = new Size(34, 15);
            label4.TabIndex = 2;
            label4.Text = "Level";
            // 
            // cbLevelId
            // 
            cbLevelId.FormattingEnabled = true;
            cbLevelId.Items.AddRange(new object[] { "A1", "A2", "B1", "B2", "C1", "C2" });
            cbLevelId.Location = new Point(149, 20);
            cbLevelId.Name = "cbLevelId";
            cbLevelId.Size = new Size(279, 23);
            cbLevelId.TabIndex = 1;
            // 
            // grvQuestion
            // 
            grvQuestion.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvQuestion.Location = new Point(6, 35);
            grvQuestion.Name = "grvQuestion";
            grvQuestion.Size = new Size(705, 268);
            grvQuestion.TabIndex = 5;
            // 
            // numPoints
            // 
            numPoints.Location = new Point(143, 834);
            numPoints.Name = "numPoints";
            numPoints.Size = new Size(173, 23);
            numPoints.TabIndex = 11;
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Location = new Point(64, 842);
            label11.Name = "label11";
            label11.Size = new Size(35, 15);
            label11.TabIndex = 12;
            label11.Text = "Point";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Location = new Point(64, 871);
            label8.Name = "label8";
            label8.Size = new Size(61, 15);
            label8.TabIndex = 12;
            label8.Text = "Time limit";
            // 
            // numTimeLimit
            // 
            numTimeLimit.Location = new Point(143, 863);
            numTimeLimit.Name = "numTimeLimit";
            numTimeLimit.Size = new Size(173, 23);
            numTimeLimit.TabIndex = 12;
            // 
            // cbDifficulty
            // 
            cbDifficulty.FormattingEnabled = true;
            cbDifficulty.Items.AddRange(new object[] { "easy", "medium", "hard" });
            cbDifficulty.Location = new Point(143, 892);
            cbDifficulty.Name = "cbDifficulty";
            cbDifficulty.Size = new Size(121, 23);
            cbDifficulty.TabIndex = 13;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Location = new Point(66, 900);
            label9.Name = "label9";
            label9.Size = new Size(55, 15);
            label9.TabIndex = 6;
            label9.Text = "Difficulty";
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Location = new Point(66, 173);
            label13.Name = "label13";
            label13.Size = new Size(57, 15);
            label13.TabIndex = 2;
            label13.Text = "Audio Url";
            // 
            // txtAudioUrl
            // 
            txtAudioUrl.Location = new Point(149, 165);
            txtAudioUrl.Name = "txtAudioUrl";
            txtAudioUrl.Size = new Size(638, 23);
            txtAudioUrl.TabIndex = 5;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Location = new Point(66, 197);
            label14.Name = "label14";
            label14.Size = new Size(58, 15);
            label14.TabIndex = 2;
            label14.Text = "Image Url";
            // 
            // txtImageUrl
            // 
            txtImageUrl.Location = new Point(149, 194);
            txtImageUrl.Name = "txtImageUrl";
            txtImageUrl.Size = new Size(638, 23);
            txtImageUrl.TabIndex = 6;
            // 
            // btnExportJsonFireStore
            // 
            btnExportJsonFireStore.Location = new Point(649, 960);
            btnExportJsonFireStore.Name = "btnExportJsonFireStore";
            btnExportJsonFireStore.Size = new Size(134, 23);
            btnExportJsonFireStore.TabIndex = 15;
            btnExportJsonFireStore.Text = "Export Json FireStore";
            btnExportJsonFireStore.UseVisualStyleBackColor = true;
            btnExportJsonFireStore.Click += btnExportJsonFireStore_Click;
            // 
            // btnExportJson
            // 
            btnExportJson.Location = new Point(568, 960);
            btnExportJson.Name = "btnExportJson";
            btnExportJson.Size = new Size(75, 23);
            btnExportJson.TabIndex = 14;
            btnExportJson.Text = "Export Json";
            btnExportJson.UseVisualStyleBackColor = true;
            btnExportJson.Click += btnExportJson_Click;
            // 
            // tabControl1
            // 
            tabControl1.Controls.Add(tabPage2);
            tabControl1.Location = new Point(66, 476);
            tabControl1.Name = "tabControl1";
            tabControl1.SelectedIndex = 0;
            tabControl1.Size = new Size(725, 338);
            tabControl1.TabIndex = 16;
            // 
            // tabPage2
            // 
            tabPage2.Controls.Add(btnAddQuestion);
            tabPage2.Controls.Add(grvQuestion);
            tabPage2.Location = new Point(4, 24);
            tabPage2.Name = "tabPage2";
            tabPage2.Padding = new Padding(3);
            tabPage2.Size = new Size(717, 310);
            tabPage2.TabIndex = 1;
            tabPage2.Text = "Questions";
            tabPage2.UseVisualStyleBackColor = true;
            // 
            // btnAddQuestion
            // 
            btnAddQuestion.Location = new Point(6, 6);
            btnAddQuestion.Name = "btnAddQuestion";
            btnAddQuestion.Size = new Size(75, 23);
            btnAddQuestion.TabIndex = 10;
            btnAddQuestion.Text = "Add";
            btnAddQuestion.UseVisualStyleBackColor = true;
            btnAddQuestion.Click += btnAddQuestion_Click_1;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(grvTitle);
            groupBox1.Controls.Add(btnAddTitle);
            groupBox1.Controls.Add(txtLanguageTitleValue);
            groupBox1.Controls.Add(label6);
            groupBox1.Controls.Add(cbLanguageCodeTitle);
            groupBox1.Controls.Add(label7);
            groupBox1.Location = new Point(64, 234);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(723, 236);
            groupBox1.TabIndex = 17;
            groupBox1.TabStop = false;
            groupBox1.Text = "Title";
            // 
            // grvTitle
            // 
            grvTitle.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvTitle.Location = new Point(6, 47);
            grvTitle.Name = "grvTitle";
            grvTitle.Size = new Size(711, 186);
            grvTitle.TabIndex = 5;
            // 
            // btnAddTitle
            // 
            btnAddTitle.Location = new Point(553, 22);
            btnAddTitle.Name = "btnAddTitle";
            btnAddTitle.Size = new Size(75, 23);
            btnAddTitle.TabIndex = 9;
            btnAddTitle.Text = "Add";
            btnAddTitle.UseVisualStyleBackColor = true;
            btnAddTitle.Click += btnAddTitle_Click;
            // 
            // txtLanguageTitleValue
            // 
            txtLanguageTitleValue.Location = new Point(265, 21);
            txtLanguageTitleValue.Name = "txtLanguageTitleValue";
            txtLanguageTitleValue.Size = new Size(282, 23);
            txtLanguageTitleValue.TabIndex = 8;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Location = new Point(224, 29);
            label6.Name = "label6";
            label6.Size = new Size(35, 15);
            label6.TabIndex = 2;
            label6.Text = "value";
            // 
            // cbLanguageCodeTitle
            // 
            cbLanguageCodeTitle.FormattingEnabled = true;
            cbLanguageCodeTitle.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanguageCodeTitle.Location = new Point(97, 21);
            cbLanguageCodeTitle.Name = "cbLanguageCodeTitle";
            cbLanguageCodeTitle.Size = new Size(121, 23);
            cbLanguageCodeTitle.TabIndex = 7;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Location = new Point(6, 29);
            label7.Name = "label7";
            label7.Size = new Size(85, 15);
            label7.TabIndex = 0;
            label7.Text = "language code";
            // 
            // numLesson
            // 
            numLesson.Location = new Point(149, 78);
            numLesson.Name = "numLesson";
            numLesson.Size = new Size(279, 23);
            numLesson.TabIndex = 3;
            // 
            // numUnit
            // 
            numUnit.Location = new Point(149, 49);
            numUnit.Name = "numUnit";
            numUnit.Size = new Size(279, 23);
            numUnit.TabIndex = 2;
            // 
            // label19
            // 
            label19.AutoSize = true;
            label19.Location = new Point(66, 86);
            label19.Name = "label19";
            label19.Size = new Size(43, 15);
            label19.TabIndex = 19;
            label19.Text = "Lesson";
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Location = new Point(66, 57);
            label18.Name = "label18";
            label18.Size = new Size(29, 15);
            label18.TabIndex = 20;
            label18.Text = "Unit";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Location = new Point(66, 115);
            label5.Name = "label5";
            label5.Size = new Size(61, 15);
            label5.TabIndex = 19;
            label5.Text = "Exercise Id";
            // 
            // numExercise
            // 
            numExercise.Location = new Point(149, 107);
            numExercise.Name = "numExercise";
            numExercise.Size = new Size(279, 23);
            numExercise.TabIndex = 4;
            // 
            // ExerciseGroupForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(854, 990);
            Controls.Add(numExercise);
            Controls.Add(numLesson);
            Controls.Add(label5);
            Controls.Add(numUnit);
            Controls.Add(label19);
            Controls.Add(label18);
            Controls.Add(groupBox1);
            Controls.Add(tabControl1);
            Controls.Add(btnExportJsonFireStore);
            Controls.Add(btnExportJson);
            Controls.Add(cbDifficulty);
            Controls.Add(label9);
            Controls.Add(numTimeLimit);
            Controls.Add(label8);
            Controls.Add(numPoints);
            Controls.Add(label11);
            Controls.Add(cbLevelId);
            Controls.Add(label4);
            Controls.Add(txtUnitId);
            Controls.Add(label3);
            Controls.Add(txtImageUrl);
            Controls.Add(label14);
            Controls.Add(txtAudioUrl);
            Controls.Add(label13);
            Controls.Add(txtLessonId);
            Controls.Add(label2);
            Controls.Add(txtId);
            Controls.Add(label1);
            Name = "ExerciseGroupForm";
            Text = "Exercise Group Form";
            ((System.ComponentModel.ISupportInitialize)grvQuestion).EndInit();
            ((System.ComponentModel.ISupportInitialize)numPoints).EndInit();
            ((System.ComponentModel.ISupportInitialize)numTimeLimit).EndInit();
            tabControl1.ResumeLayout(false);
            tabPage2.ResumeLayout(false);
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)grvTitle).EndInit();
            ((System.ComponentModel.ISupportInitialize)numLesson).EndInit();
            ((System.ComponentModel.ISupportInitialize)numUnit).EndInit();
            ((System.ComponentModel.ISupportInitialize)numExercise).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox txtLessonId;
        private Label label2;
        private TextBox txtId;
        private Label label1;
        private Label label3;
        private TextBox txtUnitId;
        private Label label4;
        private ComboBox cbLevelId;
        private DataGridView grvQuestion;
        private NumericUpDown numPoints;
        private Label label11;
        private Label label8;
        private NumericUpDown numTimeLimit;
        private ComboBox cbDifficulty;
        private Label label9;
        private Label label13;
        private TextBox txtAudioUrl;
        private Label label14;
        private TextBox txtImageUrl;
        private Button btnExportJsonFireStore;
        private Button btnExportJson;
        private TabControl tabControl1;
        private TabPage tabPage2;
        private Button btnAddQuestion;
        private GroupBox groupBox1;
        private DataGridView grvTitle;
        private Button btnAddTitle;
        private TextBox txtLanguageTitleValue;
        private Label label6;
        private ComboBox cbLanguageCodeTitle;
        private Label label7;
        private NumericUpDown numLesson;
        private NumericUpDown numUnit;
        private Label label19;
        private Label label18;
        private Label label5;
        private NumericUpDown numExercise;
    }
}