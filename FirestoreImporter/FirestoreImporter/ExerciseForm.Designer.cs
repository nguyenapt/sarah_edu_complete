namespace FirestoreImporter
{
    partial class ExerciseForm
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
            label5 = new Label();
            cbType = new ComboBox();
            grvQuestion = new DataGridView();
            btnAddQuestion = new Button();
            txtLanguageQuestionValue = new TextBox();
            label6 = new Label();
            cbLanguageCodeQuestion = new ComboBox();
            label7 = new Label();
            numPoints = new NumericUpDown();
            label11 = new Label();
            label8 = new Label();
            numTimeLimit = new NumericUpDown();
            cbDifficulty = new ComboBox();
            label9 = new Label();
            grvExplanation = new DataGridView();
            button1 = new Button();
            txtLanguageExplanationValue = new TextBox();
            label10 = new Label();
            cbLanguageCodeExplanation = new ComboBox();
            label12 = new Label();
            label13 = new Label();
            txtAudioUrl = new TextBox();
            label14 = new Label();
            txtImageUrl = new TextBox();
            btnExportJsonFireStore = new Button();
            btnExportJson = new Button();
            cbPropertyType = new ComboBox();
            label17 = new Label();
            txtPropertyName = new TextBox();
            grvContent = new DataGridView();
            btnContentAdd = new Button();
            txtPropertyValue = new TextBox();
            label15 = new Label();
            label16 = new Label();
            tabControl1 = new TabControl();
            tabPage1 = new TabPage();
            tabPage2 = new TabPage();
            tabPage3 = new TabPage();
            btnSave = new Button();
            label18 = new Label();
            label19 = new Label();
            numUnit = new NumericUpDown();
            numLesson = new NumericUpDown();
            numExercise = new NumericUpDown();
            label20 = new Label();
            ((System.ComponentModel.ISupportInitialize)grvQuestion).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numPoints).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numTimeLimit).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvExplanation).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvContent).BeginInit();
            tabControl1.SuspendLayout();
            tabPage1.SuspendLayout();
            tabPage2.SuspendLayout();
            tabPage3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)numUnit).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numLesson).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numExercise).BeginInit();
            SuspendLayout();
            // 
            // txtLessonId
            // 
            txtLessonId.Location = new Point(563, 80);
            txtLessonId.Name = "txtLessonId";
            txtLessonId.Size = new Size(228, 23);
            txtLessonId.TabIndex = 4;
            txtLessonId.Text = "lesson_";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(480, 88);
            label2.Name = "label2";
            label2.Size = new Size(56, 15);
            label2.TabIndex = 2;
            label2.Text = "Lesson Id";
            // 
            // txtId
            // 
            txtId.Location = new Point(143, 141);
            txtId.Name = "txtId";
            txtId.Size = new Size(279, 23);
            txtId.TabIndex = 5;
            txtId.Text = "exercise_";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(60, 149);
            label1.Name = "label1";
            label1.Size = new Size(17, 15);
            label1.TabIndex = 3;
            label1.Text = "Id";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(480, 59);
            label3.Name = "label3";
            label3.Size = new Size(42, 15);
            label3.TabIndex = 2;
            label3.Text = "Unit Id";
            // 
            // txtUnitId
            // 
            txtUnitId.Location = new Point(563, 51);
            txtUnitId.Name = "txtUnitId";
            txtUnitId.Size = new Size(228, 23);
            txtUnitId.TabIndex = 4;
            txtUnitId.Text = "unit_";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Location = new Point(60, 30);
            label4.Name = "label4";
            label4.Size = new Size(34, 15);
            label4.TabIndex = 2;
            label4.Text = "Level";
            // 
            // cbLevelId
            // 
            cbLevelId.FormattingEnabled = true;
            cbLevelId.Items.AddRange(new object[] { "A1", "A2", "B1", "B2", "C1", "C2" });
            cbLevelId.Location = new Point(143, 22);
            cbLevelId.Name = "cbLevelId";
            cbLevelId.Size = new Size(279, 23);
            cbLevelId.TabIndex = 1;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Location = new Point(480, 149);
            label5.Name = "label5";
            label5.Size = new Size(32, 15);
            label5.TabIndex = 2;
            label5.Text = "Type";
            // 
            // cbType
            // 
            cbType.FormattingEnabled = true;
            cbType.Items.AddRange(new object[] { "single_choice", "multiple_choice", "fill_blank", "matching", "listening", "speaking", "button_single_choice" });
            cbType.Location = new Point(563, 141);
            cbType.Name = "cbType";
            cbType.Size = new Size(228, 23);
            cbType.TabIndex = 5;
            // 
            // grvQuestion
            // 
            grvQuestion.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvQuestion.Location = new Point(6, 36);
            grvQuestion.Name = "grvQuestion";
            grvQuestion.Size = new Size(711, 280);
            grvQuestion.TabIndex = 5;
            // 
            // btnAddQuestion
            // 
            btnAddQuestion.Location = new Point(553, 8);
            btnAddQuestion.Name = "btnAddQuestion";
            btnAddQuestion.Size = new Size(75, 23);
            btnAddQuestion.TabIndex = 10;
            btnAddQuestion.Text = "Add";
            btnAddQuestion.UseVisualStyleBackColor = true;
            btnAddQuestion.Click += btnAddQuestion_Click;
            // 
            // txtLanguageQuestionValue
            // 
            txtLanguageQuestionValue.Location = new Point(265, 7);
            txtLanguageQuestionValue.Name = "txtLanguageQuestionValue";
            txtLanguageQuestionValue.Size = new Size(282, 23);
            txtLanguageQuestionValue.TabIndex = 9;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Location = new Point(224, 15);
            label6.Name = "label6";
            label6.Size = new Size(35, 15);
            label6.TabIndex = 2;
            label6.Text = "value";
            // 
            // cbLanguageCodeQuestion
            // 
            cbLanguageCodeQuestion.FormattingEnabled = true;
            cbLanguageCodeQuestion.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanguageCodeQuestion.Location = new Point(97, 7);
            cbLanguageCodeQuestion.Name = "cbLanguageCodeQuestion";
            cbLanguageCodeQuestion.Size = new Size(121, 23);
            cbLanguageCodeQuestion.TabIndex = 8;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Location = new Point(6, 15);
            label7.Name = "label7";
            label7.Size = new Size(85, 15);
            label7.TabIndex = 0;
            label7.Text = "language code";
            // 
            // numPoints
            // 
            numPoints.Location = new Point(143, 593);
            numPoints.Name = "numPoints";
            numPoints.Size = new Size(173, 23);
            numPoints.TabIndex = 22;
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Location = new Point(64, 601);
            label11.Name = "label11";
            label11.Size = new Size(35, 15);
            label11.TabIndex = 12;
            label11.Text = "Point";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Location = new Point(64, 630);
            label8.Name = "label8";
            label8.Size = new Size(61, 15);
            label8.TabIndex = 12;
            label8.Text = "Time limit";
            // 
            // numTimeLimit
            // 
            numTimeLimit.Location = new Point(143, 622);
            numTimeLimit.Name = "numTimeLimit";
            numTimeLimit.Size = new Size(173, 23);
            numTimeLimit.TabIndex = 23;
            // 
            // cbDifficulty
            // 
            cbDifficulty.FormattingEnabled = true;
            cbDifficulty.Items.AddRange(new object[] { "easy", "medium", "hard" });
            cbDifficulty.Location = new Point(143, 651);
            cbDifficulty.Name = "cbDifficulty";
            cbDifficulty.Size = new Size(121, 23);
            cbDifficulty.TabIndex = 24;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Location = new Point(66, 659);
            label9.Name = "label9";
            label9.Size = new Size(55, 15);
            label9.TabIndex = 6;
            label9.Text = "Difficulty";
            // 
            // grvExplanation
            // 
            grvExplanation.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvExplanation.Location = new Point(6, 36);
            grvExplanation.Name = "grvExplanation";
            grvExplanation.Size = new Size(711, 280);
            grvExplanation.TabIndex = 5;
            // 
            // button1
            // 
            button1.Location = new Point(553, 8);
            button1.Name = "button1";
            button1.Size = new Size(75, 23);
            button1.TabIndex = 13;
            button1.Text = "Add";
            button1.UseVisualStyleBackColor = true;
            button1.Click += btnAddExplanation_Click;
            // 
            // txtLanguageExplanationValue
            // 
            txtLanguageExplanationValue.Location = new Point(265, 7);
            txtLanguageExplanationValue.Name = "txtLanguageExplanationValue";
            txtLanguageExplanationValue.Size = new Size(282, 23);
            txtLanguageExplanationValue.TabIndex = 12;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Location = new Point(224, 15);
            label10.Name = "label10";
            label10.Size = new Size(35, 15);
            label10.TabIndex = 2;
            label10.Text = "value";
            // 
            // cbLanguageCodeExplanation
            // 
            cbLanguageCodeExplanation.FormattingEnabled = true;
            cbLanguageCodeExplanation.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanguageCodeExplanation.Location = new Point(97, 7);
            cbLanguageCodeExplanation.Name = "cbLanguageCodeExplanation";
            cbLanguageCodeExplanation.Size = new Size(121, 23);
            cbLanguageCodeExplanation.TabIndex = 11;
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Location = new Point(6, 15);
            label12.Name = "label12";
            label12.Size = new Size(85, 15);
            label12.TabIndex = 0;
            label12.Text = "language code";
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Location = new Point(60, 178);
            label13.Name = "label13";
            label13.Size = new Size(57, 15);
            label13.TabIndex = 2;
            label13.Text = "Audio Url";
            // 
            // txtAudioUrl
            // 
            txtAudioUrl.Location = new Point(143, 170);
            txtAudioUrl.Name = "txtAudioUrl";
            txtAudioUrl.Size = new Size(648, 23);
            txtAudioUrl.TabIndex = 6;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Location = new Point(60, 207);
            label14.Name = "label14";
            label14.Size = new Size(58, 15);
            label14.TabIndex = 2;
            label14.Text = "Image Url";
            // 
            // txtImageUrl
            // 
            txtImageUrl.Location = new Point(143, 199);
            txtImageUrl.Name = "txtImageUrl";
            txtImageUrl.Size = new Size(648, 23);
            txtImageUrl.TabIndex = 7;
            // 
            // btnExportJsonFireStore
            // 
            btnExportJsonFireStore.Location = new Point(649, 719);
            btnExportJsonFireStore.Name = "btnExportJsonFireStore";
            btnExportJsonFireStore.Size = new Size(134, 23);
            btnExportJsonFireStore.TabIndex = 26;
            btnExportJsonFireStore.Text = "Export Json FireStore";
            btnExportJsonFireStore.UseVisualStyleBackColor = true;
            btnExportJsonFireStore.Click += btnExportJsonFireStore_Click;
            // 
            // btnExportJson
            // 
            btnExportJson.Location = new Point(568, 719);
            btnExportJson.Name = "btnExportJson";
            btnExportJson.Size = new Size(75, 23);
            btnExportJson.TabIndex = 25;
            btnExportJson.Text = "Export Json";
            btnExportJson.UseVisualStyleBackColor = true;
            btnExportJson.Click += btnExportJson_Click;
            // 
            // cbPropertyType
            // 
            cbPropertyType.FormattingEnabled = true;
            cbPropertyType.Items.AddRange(new object[] { "array", "string" });
            cbPropertyType.Location = new Point(533, 6);
            cbPropertyType.Name = "cbPropertyType";
            cbPropertyType.Size = new Size(97, 23);
            cbPropertyType.TabIndex = 16;
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Location = new Point(495, 14);
            label17.Name = "label17";
            label17.Size = new Size(32, 15);
            label17.TabIndex = 6;
            label17.Text = "Type";
            // 
            // txtPropertyName
            // 
            txtPropertyName.Location = new Point(83, 9);
            txtPropertyName.Name = "txtPropertyName";
            txtPropertyName.Size = new Size(124, 23);
            txtPropertyName.TabIndex = 14;
            // 
            // grvContent
            // 
            grvContent.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvContent.Location = new Point(6, 36);
            grvContent.Name = "grvContent";
            grvContent.Size = new Size(705, 280);
            grvContent.TabIndex = 5;
            // 
            // btnContentAdd
            // 
            btnContentAdd.Location = new Point(636, 6);
            btnContentAdd.Name = "btnContentAdd";
            btnContentAdd.Size = new Size(75, 23);
            btnContentAdd.TabIndex = 17;
            btnContentAdd.Text = "Add";
            btnContentAdd.UseVisualStyleBackColor = true;
            btnContentAdd.Click += btnContentAdd_Click;
            // 
            // txtPropertyValue
            // 
            txtPropertyValue.Location = new Point(265, 7);
            txtPropertyValue.Name = "txtPropertyValue";
            txtPropertyValue.Size = new Size(228, 23);
            txtPropertyValue.TabIndex = 15;
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Location = new Point(224, 15);
            label15.Name = "label15";
            label15.Size = new Size(35, 15);
            label15.TabIndex = 2;
            label15.Text = "value";
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Location = new Point(6, 15);
            label16.Name = "label16";
            label16.Size = new Size(58, 15);
            label16.TabIndex = 0;
            label16.Text = "pro name";
            // 
            // tabControl1
            // 
            tabControl1.Controls.Add(tabPage1);
            tabControl1.Controls.Add(tabPage2);
            tabControl1.Controls.Add(tabPage3);
            tabControl1.Location = new Point(60, 237);
            tabControl1.Name = "tabControl1";
            tabControl1.SelectedIndex = 0;
            tabControl1.Size = new Size(731, 350);
            tabControl1.TabIndex = 16;
            // 
            // tabPage1
            // 
            tabPage1.Controls.Add(grvQuestion);
            tabPage1.Controls.Add(label7);
            tabPage1.Controls.Add(btnAddQuestion);
            tabPage1.Controls.Add(cbLanguageCodeQuestion);
            tabPage1.Controls.Add(label6);
            tabPage1.Controls.Add(txtLanguageQuestionValue);
            tabPage1.Location = new Point(4, 24);
            tabPage1.Name = "tabPage1";
            tabPage1.Padding = new Padding(3);
            tabPage1.Size = new Size(723, 322);
            tabPage1.TabIndex = 0;
            tabPage1.Text = "Questions";
            tabPage1.UseVisualStyleBackColor = true;
            // 
            // tabPage2
            // 
            tabPage2.Controls.Add(grvExplanation);
            tabPage2.Controls.Add(button1);
            tabPage2.Controls.Add(label12);
            tabPage2.Controls.Add(cbLanguageCodeExplanation);
            tabPage2.Controls.Add(txtLanguageExplanationValue);
            tabPage2.Controls.Add(label10);
            tabPage2.Location = new Point(4, 24);
            tabPage2.Name = "tabPage2";
            tabPage2.Padding = new Padding(3);
            tabPage2.Size = new Size(723, 322);
            tabPage2.TabIndex = 1;
            tabPage2.Text = "Explanation";
            tabPage2.UseVisualStyleBackColor = true;
            // 
            // tabPage3
            // 
            tabPage3.Controls.Add(cbPropertyType);
            tabPage3.Controls.Add(grvContent);
            tabPage3.Controls.Add(label16);
            tabPage3.Controls.Add(label17);
            tabPage3.Controls.Add(label15);
            tabPage3.Controls.Add(txtPropertyValue);
            tabPage3.Controls.Add(txtPropertyName);
            tabPage3.Controls.Add(btnContentAdd);
            tabPage3.Location = new Point(4, 24);
            tabPage3.Name = "tabPage3";
            tabPage3.Padding = new Padding(3);
            tabPage3.Size = new Size(723, 322);
            tabPage3.TabIndex = 2;
            tabPage3.Text = "Content";
            tabPage3.UseVisualStyleBackColor = true;
            // 
            // btnSave
            // 
            btnSave.Location = new Point(568, 690);
            btnSave.Name = "btnSave";
            btnSave.Size = new Size(213, 23);
            btnSave.TabIndex = 27;
            btnSave.Text = "Save";
            btnSave.UseVisualStyleBackColor = true;
            btnSave.Visible = false;
            btnSave.Click += btnSave_Click;
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Location = new Point(60, 59);
            label18.Name = "label18";
            label18.Size = new Size(29, 15);
            label18.TabIndex = 2;
            label18.Text = "Unit";
            // 
            // label19
            // 
            label19.AutoSize = true;
            label19.Location = new Point(60, 88);
            label19.Name = "label19";
            label19.Size = new Size(43, 15);
            label19.TabIndex = 2;
            label19.Text = "Lesson";
            // 
            // numUnit
            // 
            numUnit.Location = new Point(143, 51);
            numUnit.Name = "numUnit";
            numUnit.Size = new Size(279, 23);
            numUnit.TabIndex = 2;
            // 
            // numLesson
            // 
            numLesson.Location = new Point(143, 80);
            numLesson.Name = "numLesson";
            numLesson.Size = new Size(279, 23);
            numLesson.TabIndex = 3;
            // 
            // numExercise
            // 
            numExercise.Location = new Point(143, 109);
            numExercise.Name = "numExercise";
            numExercise.Size = new Size(279, 23);
            numExercise.TabIndex = 4;
            // 
            // label20
            // 
            label20.AutoSize = true;
            label20.Location = new Point(60, 117);
            label20.Name = "label20";
            label20.Size = new Size(61, 15);
            label20.TabIndex = 22;
            label20.Text = "Exercise Id";
            // 
            // ExerciseForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(866, 860);
            Controls.Add(numExercise);
            Controls.Add(label20);
            Controls.Add(numLesson);
            Controls.Add(numUnit);
            Controls.Add(btnSave);
            Controls.Add(tabControl1);
            Controls.Add(btnExportJsonFireStore);
            Controls.Add(btnExportJson);
            Controls.Add(cbDifficulty);
            Controls.Add(label9);
            Controls.Add(numTimeLimit);
            Controls.Add(label8);
            Controls.Add(numPoints);
            Controls.Add(label11);
            Controls.Add(cbType);
            Controls.Add(label5);
            Controls.Add(label19);
            Controls.Add(label18);
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
            Name = "ExerciseForm";
            Text = "ExerciseForm";
            ((System.ComponentModel.ISupportInitialize)grvQuestion).EndInit();
            ((System.ComponentModel.ISupportInitialize)numPoints).EndInit();
            ((System.ComponentModel.ISupportInitialize)numTimeLimit).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvExplanation).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvContent).EndInit();
            tabControl1.ResumeLayout(false);
            tabPage1.ResumeLayout(false);
            tabPage1.PerformLayout();
            tabPage2.ResumeLayout(false);
            tabPage2.PerformLayout();
            tabPage3.ResumeLayout(false);
            tabPage3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)numUnit).EndInit();
            ((System.ComponentModel.ISupportInitialize)numLesson).EndInit();
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
        private Label label5;
        private ComboBox cbType;
        private DataGridView grvQuestion;
        private Button btnAddQuestion;
        private TextBox txtLanguageQuestionValue;
        private Label label6;
        private ComboBox cbLanguageCodeQuestion;
        private Label label7;
        private NumericUpDown numPoints;
        private Label label11;
        private Label label8;
        private NumericUpDown numTimeLimit;
        private ComboBox cbDifficulty;
        private Label label9;
        private DataGridView grvExplanation;
        private Button button1;
        private TextBox txtLanguageExplanationValue;
        private Label label10;
        private ComboBox cbLanguageCodeExplanation;
        private Label label12;
        private Label label13;
        private TextBox txtAudioUrl;
        private Label label14;
        private TextBox txtImageUrl;
        private Button btnExportJsonFireStore;
        private Button btnExportJson;
        private TextBox txtPropertyName;
        private DataGridView grvContent;
        private Button btnContentAdd;
        private TextBox txtPropertyValue;
        private Label label15;
        private Label label16;
        private ComboBox cbPropertyType;
        private Label label17;
        private TabControl tabControl1;
        private TabPage tabPage1;
        private TabPage tabPage2;
        private TabPage tabPage3;
        private Button btnSave;
        private Label label18;
        private Label label19;
        private NumericUpDown numUnit;
        private NumericUpDown numLesson;
        private NumericUpDown numExercise;
        private Label label20;
    }
}