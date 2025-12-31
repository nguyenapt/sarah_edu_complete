namespace FirestoreImporter
{
    partial class LessonForm
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
            label3 = new Label();
            txtUnitId = new TextBox();
            label4 = new Label();
            cbLevelId = new ComboBox();
            numOrder = new NumericUpDown();
            label11 = new Label();
            btnExportJsonFireStore = new Button();
            btnExportJson = new Button();
            tabControl1 = new TabControl();
            tabPage2 = new TabPage();
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
            label1 = new Label();
            cbType = new ComboBox();
            tabPage1 = new TabPage();
            tabPage3 = new TabPage();
            tabPage4 = new TabPage();
            tabPage5 = new TabPage();
            txtExercises = new TextBox();
            label5 = new Label();
            dataGridView1 = new DataGridView();
            btnAddDescription = new Button();
            txtLanguageDescriptionValue = new TextBox();
            label8 = new Label();
            cbLanguageCodeDescription = new ComboBox();
            label9 = new Label();
            grvExplanation = new DataGridView();
            btnAddExplanation = new Button();
            txtLanguageValueExplanation = new TextBox();
            label10 = new Label();
            cbLanuageCodeExplanation = new ComboBox();
            label12 = new Label();
            txtSentence = new TextBox();
            label13 = new Label();
            btnAddExample = new Button();
            grvExample = new DataGridView();
            txtStatement = new TextBox();
            label14 = new Label();
            label15 = new Label();
            txtNegative = new TextBox();
            label16 = new Label();
            txtQuestion = new TextBox();
            grvHint = new DataGridView();
            btnAddHint = new Button();
            txtHintVaue = new TextBox();
            label17 = new Label();
            cbHintLanguageCode = new ComboBox();
            label20 = new Label();
            grvUsage = new DataGridView();
            btnAddToUsage = new Button();
            grvUsageLanguage = new DataGridView();
            btnAddLanguageUsage = new Button();
            txtUsageExample = new TextBox();
            label22 = new Label();
            cbUsageLanguageCode = new ComboBox();
            label23 = new Label();
            txtUsageTitle = new TextBox();
            label21 = new Label();
            groupBox2 = new GroupBox();
            ((System.ComponentModel.ISupportInitialize)numOrder).BeginInit();
            tabControl1.SuspendLayout();
            tabPage2.SuspendLayout();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)grvTitle).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numLesson).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numUnit).BeginInit();
            tabPage1.SuspendLayout();
            tabPage3.SuspendLayout();
            tabPage4.SuspendLayout();
            tabPage5.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dataGridView1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvExplanation).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvExample).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvHint).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvUsage).BeginInit();
            ((System.ComponentModel.ISupportInitialize)grvUsageLanguage).BeginInit();
            groupBox2.SuspendLayout();
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
            // numOrder
            // 
            numOrder.Location = new Point(149, 849);
            numOrder.Name = "numOrder";
            numOrder.Size = new Size(173, 23);
            numOrder.TabIndex = 11;
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Location = new Point(66, 857);
            label11.Name = "label11";
            label11.Size = new Size(37, 15);
            label11.TabIndex = 12;
            label11.Text = "Order";
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
            tabControl1.Controls.Add(tabPage1);
            tabControl1.Controls.Add(tabPage3);
            tabControl1.Controls.Add(tabPage4);
            tabControl1.Controls.Add(tabPage5);
            tabControl1.Location = new Point(66, 349);
            tabControl1.Name = "tabControl1";
            tabControl1.SelectedIndex = 0;
            tabControl1.Size = new Size(725, 465);
            tabControl1.TabIndex = 16;
            // 
            // tabPage2
            // 
            tabPage2.Controls.Add(dataGridView1);
            tabPage2.Controls.Add(btnAddDescription);
            tabPage2.Controls.Add(txtLanguageDescriptionValue);
            tabPage2.Controls.Add(label8);
            tabPage2.Controls.Add(cbLanguageCodeDescription);
            tabPage2.Controls.Add(label9);
            tabPage2.Location = new Point(4, 24);
            tabPage2.Name = "tabPage2";
            tabPage2.Padding = new Padding(3);
            tabPage2.Size = new Size(717, 437);
            tabPage2.TabIndex = 1;
            tabPage2.Text = "Description";
            tabPage2.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(grvTitle);
            groupBox1.Controls.Add(btnAddTitle);
            groupBox1.Controls.Add(txtLanguageTitleValue);
            groupBox1.Controls.Add(label6);
            groupBox1.Controls.Add(cbLanguageCodeTitle);
            groupBox1.Controls.Add(label7);
            groupBox1.Location = new Point(66, 107);
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
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(66, 886);
            label1.Name = "label1";
            label1.Size = new Size(32, 15);
            label1.TabIndex = 12;
            label1.Text = "Type";
            // 
            // cbType
            // 
            cbType.FormattingEnabled = true;
            cbType.Items.AddRange(new object[] { "grammar", "vocabulary", "listening", "speaking", "reading", "writing" });
            cbType.Location = new Point(149, 878);
            cbType.Name = "cbType";
            cbType.Size = new Size(173, 23);
            cbType.TabIndex = 21;
            // 
            // tabPage1
            // 
            tabPage1.Controls.Add(groupBox2);
            tabPage1.Controls.Add(grvExample);
            tabPage1.Controls.Add(btnAddExample);
            tabPage1.Controls.Add(txtSentence);
            tabPage1.Controls.Add(label13);
            tabPage1.Location = new Point(4, 24);
            tabPage1.Name = "tabPage1";
            tabPage1.Padding = new Padding(3);
            tabPage1.Size = new Size(717, 437);
            tabPage1.TabIndex = 2;
            tabPage1.Text = "Example";
            tabPage1.UseVisualStyleBackColor = true;
            // 
            // tabPage3
            // 
            tabPage3.Controls.Add(txtQuestion);
            tabPage3.Controls.Add(label16);
            tabPage3.Controls.Add(txtNegative);
            tabPage3.Controls.Add(label15);
            tabPage3.Controls.Add(txtStatement);
            tabPage3.Controls.Add(label14);
            tabPage3.Location = new Point(4, 24);
            tabPage3.Name = "tabPage3";
            tabPage3.Padding = new Padding(3);
            tabPage3.Size = new Size(717, 437);
            tabPage3.TabIndex = 3;
            tabPage3.Text = "Form";
            tabPage3.UseVisualStyleBackColor = true;
            // 
            // tabPage4
            // 
            tabPage4.Controls.Add(grvHint);
            tabPage4.Controls.Add(btnAddHint);
            tabPage4.Controls.Add(txtHintVaue);
            tabPage4.Controls.Add(label17);
            tabPage4.Controls.Add(cbHintLanguageCode);
            tabPage4.Controls.Add(label20);
            tabPage4.Location = new Point(4, 24);
            tabPage4.Name = "tabPage4";
            tabPage4.Padding = new Padding(3);
            tabPage4.Size = new Size(717, 437);
            tabPage4.TabIndex = 4;
            tabPage4.Text = "Hint";
            tabPage4.UseVisualStyleBackColor = true;
            // 
            // tabPage5
            // 
            tabPage5.Controls.Add(txtUsageTitle);
            tabPage5.Controls.Add(label21);
            tabPage5.Controls.Add(grvUsage);
            tabPage5.Controls.Add(btnAddToUsage);
            tabPage5.Controls.Add(grvUsageLanguage);
            tabPage5.Controls.Add(btnAddLanguageUsage);
            tabPage5.Controls.Add(txtUsageExample);
            tabPage5.Controls.Add(label22);
            tabPage5.Controls.Add(cbUsageLanguageCode);
            tabPage5.Controls.Add(label23);
            tabPage5.Location = new Point(4, 24);
            tabPage5.Name = "tabPage5";
            tabPage5.Padding = new Padding(3);
            tabPage5.Size = new Size(717, 437);
            tabPage5.TabIndex = 5;
            tabPage5.Text = "Usage";
            tabPage5.UseVisualStyleBackColor = true;
            // 
            // txtExercises
            // 
            txtExercises.Location = new Point(149, 820);
            txtExercises.Name = "txtExercises";
            txtExercises.Size = new Size(634, 23);
            txtExercises.TabIndex = 23;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Location = new Point(66, 828);
            label5.Name = "label5";
            label5.Size = new Size(53, 15);
            label5.TabIndex = 22;
            label5.Text = "Exercises";
            // 
            // dataGridView1
            // 
            dataGridView1.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataGridView1.Location = new Point(8, 36);
            dataGridView1.Name = "dataGridView1";
            dataGridView1.Size = new Size(703, 378);
            dataGridView1.TabIndex = 12;
            // 
            // btnAddDescription
            // 
            btnAddDescription.Location = new Point(555, 11);
            btnAddDescription.Name = "btnAddDescription";
            btnAddDescription.Size = new Size(75, 23);
            btnAddDescription.TabIndex = 15;
            btnAddDescription.Text = "Add";
            btnAddDescription.UseVisualStyleBackColor = true;
            btnAddDescription.Click += btnAddDescription_Click;
            // 
            // txtLanguageDescriptionValue
            // 
            txtLanguageDescriptionValue.Location = new Point(267, 10);
            txtLanguageDescriptionValue.Name = "txtLanguageDescriptionValue";
            txtLanguageDescriptionValue.Size = new Size(282, 23);
            txtLanguageDescriptionValue.TabIndex = 14;
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Location = new Point(226, 18);
            label8.Name = "label8";
            label8.Size = new Size(35, 15);
            label8.TabIndex = 11;
            label8.Text = "value";
            // 
            // cbLanguageCodeDescription
            // 
            cbLanguageCodeDescription.FormattingEnabled = true;
            cbLanguageCodeDescription.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanguageCodeDescription.Location = new Point(99, 10);
            cbLanguageCodeDescription.Name = "cbLanguageCodeDescription";
            cbLanguageCodeDescription.Size = new Size(121, 23);
            cbLanguageCodeDescription.TabIndex = 13;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Location = new Point(8, 18);
            label9.Name = "label9";
            label9.Size = new Size(85, 15);
            label9.TabIndex = 10;
            label9.Text = "language code";
            // 
            // grvExplanation
            // 
            grvExplanation.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvExplanation.Location = new Point(6, 42);
            grvExplanation.Name = "grvExplanation";
            grvExplanation.Size = new Size(685, 108);
            grvExplanation.TabIndex = 12;
            // 
            // btnAddExplanation
            // 
            btnAddExplanation.Location = new Point(571, 17);
            btnAddExplanation.Name = "btnAddExplanation";
            btnAddExplanation.Size = new Size(75, 23);
            btnAddExplanation.TabIndex = 15;
            btnAddExplanation.Text = "Add";
            btnAddExplanation.UseVisualStyleBackColor = true;
            btnAddExplanation.Click += btnAddExplanation_Click;
            // 
            // txtLanguageValueExplanation
            // 
            txtLanguageValueExplanation.Location = new Point(283, 16);
            txtLanguageValueExplanation.Name = "txtLanguageValueExplanation";
            txtLanguageValueExplanation.Size = new Size(282, 23);
            txtLanguageValueExplanation.TabIndex = 14;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Location = new Point(242, 24);
            label10.Name = "label10";
            label10.Size = new Size(35, 15);
            label10.TabIndex = 11;
            label10.Text = "value";
            // 
            // cbLanuageCodeExplanation
            // 
            cbLanuageCodeExplanation.FormattingEnabled = true;
            cbLanuageCodeExplanation.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanuageCodeExplanation.Location = new Point(115, 16);
            cbLanuageCodeExplanation.Name = "cbLanuageCodeExplanation";
            cbLanuageCodeExplanation.Size = new Size(121, 23);
            cbLanuageCodeExplanation.TabIndex = 13;
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Location = new Point(24, 24);
            label12.Name = "label12";
            label12.Size = new Size(85, 15);
            label12.TabIndex = 10;
            label12.Text = "language code";
            // 
            // txtSentence
            // 
            txtSentence.Location = new Point(79, 6);
            txtSentence.Name = "txtSentence";
            txtSentence.Size = new Size(626, 23);
            txtSentence.TabIndex = 17;
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Location = new Point(18, 9);
            label13.Name = "label13";
            label13.Size = new Size(55, 15);
            label13.TabIndex = 16;
            label13.Text = "Sentence";
            // 
            // btnAddExample
            // 
            btnAddExample.Location = new Point(585, 209);
            btnAddExample.Name = "btnAddExample";
            btnAddExample.Size = new Size(75, 23);
            btnAddExample.TabIndex = 18;
            btnAddExample.Text = "Add";
            btnAddExample.UseVisualStyleBackColor = true;
            btnAddExample.Click += btnAddExample_Click;
            // 
            // grvExample
            // 
            grvExample.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvExample.Location = new Point(10, 238);
            grvExample.Name = "grvExample";
            grvExample.Size = new Size(703, 193);
            grvExample.TabIndex = 19;
            // 
            // txtStatement
            // 
            txtStatement.Location = new Point(122, 29);
            txtStatement.Multiline = true;
            txtStatement.Name = "txtStatement";
            txtStatement.Size = new Size(589, 71);
            txtStatement.TabIndex = 25;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Location = new Point(19, 29);
            label14.Name = "label14";
            label14.Size = new Size(61, 15);
            label14.TabIndex = 24;
            label14.Text = "Statement";
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Location = new Point(19, 106);
            label15.Name = "label15";
            label15.Size = new Size(54, 15);
            label15.TabIndex = 24;
            label15.Text = "Negative";
            // 
            // txtNegative
            // 
            txtNegative.Location = new Point(122, 106);
            txtNegative.Multiline = true;
            txtNegative.Name = "txtNegative";
            txtNegative.Size = new Size(589, 71);
            txtNegative.TabIndex = 25;
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Location = new Point(19, 183);
            label16.Name = "label16";
            label16.Size = new Size(55, 15);
            label16.TabIndex = 24;
            label16.Text = "Question";
            // 
            // txtQuestion
            // 
            txtQuestion.Location = new Point(121, 183);
            txtQuestion.Multiline = true;
            txtQuestion.Name = "txtQuestion";
            txtQuestion.Size = new Size(589, 71);
            txtQuestion.TabIndex = 25;
            // 
            // grvHint
            // 
            grvHint.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvHint.Location = new Point(8, 152);
            grvHint.Name = "grvHint";
            grvHint.Size = new Size(703, 279);
            grvHint.TabIndex = 18;
            // 
            // btnAddHint
            // 
            btnAddHint.Location = new Point(636, 123);
            btnAddHint.Name = "btnAddHint";
            btnAddHint.Size = new Size(75, 23);
            btnAddHint.TabIndex = 21;
            btnAddHint.Text = "Add";
            btnAddHint.UseVisualStyleBackColor = true;
            btnAddHint.Click += btnAddHint_Click;
            // 
            // txtHintVaue
            // 
            txtHintVaue.Location = new Point(99, 43);
            txtHintVaue.Multiline = true;
            txtHintVaue.Name = "txtHintVaue";
            txtHintVaue.Size = new Size(612, 74);
            txtHintVaue.TabIndex = 20;
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Location = new Point(58, 51);
            label17.Name = "label17";
            label17.Size = new Size(35, 15);
            label17.TabIndex = 17;
            label17.Text = "value";
            // 
            // cbHintLanguageCode
            // 
            cbHintLanguageCode.FormattingEnabled = true;
            cbHintLanguageCode.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbHintLanguageCode.Location = new Point(99, 14);
            cbHintLanguageCode.Name = "cbHintLanguageCode";
            cbHintLanguageCode.Size = new Size(121, 23);
            cbHintLanguageCode.TabIndex = 19;
            // 
            // label20
            // 
            label20.AutoSize = true;
            label20.Location = new Point(8, 22);
            label20.Name = "label20";
            label20.Size = new Size(85, 15);
            label20.TabIndex = 16;
            label20.Text = "language code";
            // 
            // grvUsage
            // 
            grvUsage.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvUsage.Location = new Point(8, 266);
            grvUsage.Name = "grvUsage";
            grvUsage.Size = new Size(703, 165);
            grvUsage.TabIndex = 29;
            // 
            // btnAddToUsage
            // 
            btnAddToUsage.Location = new Point(634, 237);
            btnAddToUsage.Name = "btnAddToUsage";
            btnAddToUsage.Size = new Size(75, 23);
            btnAddToUsage.TabIndex = 28;
            btnAddToUsage.Text = "Add";
            btnAddToUsage.UseVisualStyleBackColor = true;
            btnAddToUsage.Click += btnAddToUsage_Click;
            // 
            // grvUsageLanguage
            // 
            grvUsageLanguage.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvUsageLanguage.Location = new Point(6, 90);
            grvUsageLanguage.Name = "grvUsageLanguage";
            grvUsageLanguage.Size = new Size(703, 141);
            grvUsageLanguage.TabIndex = 22;
            // 
            // btnAddLanguageUsage
            // 
            btnAddLanguageUsage.Location = new Point(634, 60);
            btnAddLanguageUsage.Name = "btnAddLanguageUsage";
            btnAddLanguageUsage.Size = new Size(75, 23);
            btnAddLanguageUsage.TabIndex = 25;
            btnAddLanguageUsage.Text = "Add";
            btnAddLanguageUsage.UseVisualStyleBackColor = true;
            btnAddLanguageUsage.Click += btnAddLanguageUsage_Click;
            // 
            // txtUsageExample
            // 
            txtUsageExample.Location = new Point(109, 32);
            txtUsageExample.Name = "txtUsageExample";
            txtUsageExample.Size = new Size(282, 23);
            txtUsageExample.TabIndex = 24;
            // 
            // label22
            // 
            label22.AutoSize = true;
            label22.Location = new Point(36, 35);
            label22.Name = "label22";
            label22.Size = new Size(51, 15);
            label22.TabIndex = 21;
            label22.Text = "Example";
            // 
            // cbUsageLanguageCode
            // 
            cbUsageLanguageCode.FormattingEnabled = true;
            cbUsageLanguageCode.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbUsageLanguageCode.Location = new Point(109, 3);
            cbUsageLanguageCode.Name = "cbUsageLanguageCode";
            cbUsageLanguageCode.Size = new Size(121, 23);
            cbUsageLanguageCode.TabIndex = 23;
            // 
            // label23
            // 
            label23.AutoSize = true;
            label23.Location = new Point(2, 14);
            label23.Name = "label23";
            label23.Size = new Size(85, 15);
            label23.TabIndex = 20;
            label23.Text = "language code";
            // 
            // txtUsageTitle
            // 
            txtUsageTitle.Location = new Point(109, 61);
            txtUsageTitle.Name = "txtUsageTitle";
            txtUsageTitle.Size = new Size(282, 23);
            txtUsageTitle.TabIndex = 31;
            // 
            // label21
            // 
            label21.AutoSize = true;
            label21.Location = new Point(57, 64);
            label21.Name = "label21";
            label21.Size = new Size(30, 15);
            label21.TabIndex = 30;
            label21.Text = "Title";
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(grvExplanation);
            groupBox2.Controls.Add(label12);
            groupBox2.Controls.Add(cbLanuageCodeExplanation);
            groupBox2.Controls.Add(label10);
            groupBox2.Controls.Add(txtLanguageValueExplanation);
            groupBox2.Controls.Add(btnAddExplanation);
            groupBox2.Location = new Point(14, 35);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(697, 156);
            groupBox2.TabIndex = 20;
            groupBox2.TabStop = false;
            groupBox2.Text = "Sentence Explanation";
            // 
            // LessonForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(862, 1038);
            Controls.Add(txtExercises);
            Controls.Add(label5);
            Controls.Add(cbType);
            Controls.Add(numLesson);
            Controls.Add(numUnit);
            Controls.Add(label19);
            Controls.Add(label18);
            Controls.Add(groupBox1);
            Controls.Add(tabControl1);
            Controls.Add(btnExportJsonFireStore);
            Controls.Add(btnExportJson);
            Controls.Add(numOrder);
            Controls.Add(label1);
            Controls.Add(label11);
            Controls.Add(cbLevelId);
            Controls.Add(label4);
            Controls.Add(txtUnitId);
            Controls.Add(label3);
            Controls.Add(txtLessonId);
            Controls.Add(label2);
            Name = "LessonForm";
            Text = "lesson Form";
            ((System.ComponentModel.ISupportInitialize)numOrder).EndInit();
            tabControl1.ResumeLayout(false);
            tabPage2.ResumeLayout(false);
            tabPage2.PerformLayout();
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)grvTitle).EndInit();
            ((System.ComponentModel.ISupportInitialize)numLesson).EndInit();
            ((System.ComponentModel.ISupportInitialize)numUnit).EndInit();
            tabPage1.ResumeLayout(false);
            tabPage1.PerformLayout();
            tabPage3.ResumeLayout(false);
            tabPage3.PerformLayout();
            tabPage4.ResumeLayout(false);
            tabPage4.PerformLayout();
            tabPage5.ResumeLayout(false);
            tabPage5.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)dataGridView1).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvExplanation).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvExample).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvHint).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvUsage).EndInit();
            ((System.ComponentModel.ISupportInitialize)grvUsageLanguage).EndInit();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox txtLessonId;
        private Label label2;
        private Label label3;
        private TextBox txtUnitId;
        private Label label4;
        private ComboBox cbLevelId;
        private NumericUpDown numOrder;
        private Label label11;
        private Button btnExportJsonFireStore;
        private Button btnExportJson;
        private TabControl tabControl1;
        private TabPage tabPage2;
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
        private Label label1;
        private ComboBox cbType;
        private TabPage tabPage1;
        private TabPage tabPage3;
        private TabPage tabPage4;
        private TabPage tabPage5;
        private TextBox txtExercises;
        private Label label5;
        private DataGridView dataGridView1;
        private Button btnAddDescription;
        private TextBox txtLanguageDescriptionValue;
        private Label label8;
        private ComboBox cbLanguageCodeDescription;
        private Label label9;
        private DataGridView grvExample;
        private Button btnAddExample;
        private TextBox txtSentence;
        private Label label13;
        private DataGridView grvExplanation;
        private Button btnAddExplanation;
        private TextBox txtLanguageValueExplanation;
        private Label label10;
        private ComboBox cbLanuageCodeExplanation;
        private Label label12;
        private TextBox txtStatement;
        private Label label14;
        private TextBox txtQuestion;
        private Label label16;
        private TextBox txtNegative;
        private Label label15;
        private DataGridView grvHint;
        private Button btnAddHint;
        private TextBox txtHintVaue;
        private Label label17;
        private ComboBox cbHintLanguageCode;
        private Label label20;
        private TextBox txtUsageTitle;
        private Label label21;
        private DataGridView grvUsage;
        private Button btnAddToUsage;
        private DataGridView grvUsageLanguage;
        private Button btnAddLanguageUsage;
        private TextBox txtUsageExample;
        private Label label22;
        private ComboBox cbUsageLanguageCode;
        private Label label23;
        private GroupBox groupBox2;
    }
}