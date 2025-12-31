namespace FirestoreImporter
{
    partial class UnitForm
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
            label1 = new Label();
            txtId = new TextBox();
            groupBox1 = new GroupBox();
            grvTitle = new DataGridView();
            btnAddTitle = new Button();
            txtLanguageValue = new TextBox();
            label4 = new Label();
            cbLanguageCodeTitle = new ComboBox();
            label3 = new Label();
            groupBox2 = new GroupBox();
            grvDescription = new DataGridView();
            btnAddDescription = new Button();
            txtDescriptionValue = new TextBox();
            label5 = new Label();
            cbLanguageCodeDescription = new ComboBox();
            label6 = new Label();
            label7 = new Label();
            txtLessons = new TextBox();
            txtPrerequisites = new TextBox();
            label8 = new Label();
            label9 = new Label();
            txtGroup = new TextBox();
            label11 = new Label();
            numEstimatedTime = new NumericUpDown();
            label10 = new Label();
            numOrder = new NumericUpDown();
            btnExportJson = new Button();
            btnExportJsonFireStore = new Button();
            numUnit = new NumericUpDown();
            label18 = new Label();
            cbLevelId = new ComboBox();
            label12 = new Label();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)grvTitle).BeginInit();
            groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)grvDescription).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numEstimatedTime).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numOrder).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numUnit).BeginInit();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(61, 71);
            label1.Name = "label1";
            label1.Size = new Size(17, 15);
            label1.TabIndex = 0;
            label1.Text = "Id";
            // 
            // txtId
            // 
            txtId.Location = new Point(125, 68);
            txtId.Name = "txtId";
            txtId.Size = new Size(279, 23);
            txtId.TabIndex = 3;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(grvTitle);
            groupBox1.Controls.Add(btnAddTitle);
            groupBox1.Controls.Add(txtLanguageValue);
            groupBox1.Controls.Add(label4);
            groupBox1.Controls.Add(cbLanguageCodeTitle);
            groupBox1.Controls.Add(label3);
            groupBox1.Location = new Point(55, 103);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(737, 242);
            groupBox1.TabIndex = 3;
            groupBox1.TabStop = false;
            groupBox1.Text = "Title";
            // 
            // grvTitle
            // 
            grvTitle.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvTitle.Location = new Point(6, 50);
            grvTitle.Name = "grvTitle";
            grvTitle.Size = new Size(725, 175);
            grvTitle.TabIndex = 5;
            // 
            // btnAddTitle
            // 
            btnAddTitle.Location = new Point(553, 22);
            btnAddTitle.Name = "btnAddTitle";
            btnAddTitle.Size = new Size(75, 23);
            btnAddTitle.TabIndex = 6;
            btnAddTitle.Text = "Add";
            btnAddTitle.UseVisualStyleBackColor = true;
            btnAddTitle.Click += btnAddTitle_Click;
            // 
            // txtLanguageValue
            // 
            txtLanguageValue.Location = new Point(265, 21);
            txtLanguageValue.Name = "txtLanguageValue";
            txtLanguageValue.Size = new Size(282, 23);
            txtLanguageValue.TabIndex = 5;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Location = new Point(224, 29);
            label4.Name = "label4";
            label4.Size = new Size(35, 15);
            label4.TabIndex = 2;
            label4.Text = "value";
            // 
            // cbLanguageCodeTitle
            // 
            cbLanguageCodeTitle.FormattingEnabled = true;
            cbLanguageCodeTitle.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanguageCodeTitle.Location = new Point(97, 21);
            cbLanguageCodeTitle.Name = "cbLanguageCodeTitle";
            cbLanguageCodeTitle.Size = new Size(121, 23);
            cbLanguageCodeTitle.TabIndex = 4;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(6, 29);
            label3.Name = "label3";
            label3.Size = new Size(85, 15);
            label3.TabIndex = 0;
            label3.Text = "language code";
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(grvDescription);
            groupBox2.Controls.Add(btnAddDescription);
            groupBox2.Controls.Add(txtDescriptionValue);
            groupBox2.Controls.Add(label5);
            groupBox2.Controls.Add(cbLanguageCodeDescription);
            groupBox2.Controls.Add(label6);
            groupBox2.Location = new Point(55, 365);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(737, 242);
            groupBox2.TabIndex = 6;
            groupBox2.TabStop = false;
            groupBox2.Text = "Description";
            // 
            // grvDescription
            // 
            grvDescription.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            grvDescription.Location = new Point(6, 50);
            grvDescription.Name = "grvDescription";
            grvDescription.Size = new Size(725, 175);
            grvDescription.TabIndex = 5;
            // 
            // btnAddDescription
            // 
            btnAddDescription.Location = new Point(553, 22);
            btnAddDescription.Name = "btnAddDescription";
            btnAddDescription.Size = new Size(75, 23);
            btnAddDescription.TabIndex = 9;
            btnAddDescription.Text = "Add";
            btnAddDescription.UseVisualStyleBackColor = true;
            btnAddDescription.Click += btnAddDescription_Click;
            // 
            // txtDescriptionValue
            // 
            txtDescriptionValue.Location = new Point(265, 21);
            txtDescriptionValue.Name = "txtDescriptionValue";
            txtDescriptionValue.Size = new Size(282, 23);
            txtDescriptionValue.TabIndex = 8;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Location = new Point(224, 29);
            label5.Name = "label5";
            label5.Size = new Size(35, 15);
            label5.TabIndex = 2;
            label5.Text = "value";
            // 
            // cbLanguageCodeDescription
            // 
            cbLanguageCodeDescription.FormattingEnabled = true;
            cbLanguageCodeDescription.Items.AddRange(new object[] { "en", "vi", "de", "es", "fr", "hi", "ja", "ko", "pt", "ru", "zh" });
            cbLanguageCodeDescription.Location = new Point(97, 21);
            cbLanguageCodeDescription.Name = "cbLanguageCodeDescription";
            cbLanguageCodeDescription.Size = new Size(121, 23);
            cbLanguageCodeDescription.TabIndex = 7;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Location = new Point(6, 29);
            label6.Name = "label6";
            label6.Size = new Size(85, 15);
            label6.TabIndex = 0;
            label6.Text = "language code";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Location = new Point(55, 621);
            label7.Name = "label7";
            label7.Size = new Size(43, 15);
            label7.TabIndex = 7;
            label7.Text = "Lesson";
            // 
            // txtLessons
            // 
            txtLessons.Location = new Point(104, 613);
            txtLessons.Name = "txtLessons";
            txtLessons.Size = new Size(237, 23);
            txtLessons.TabIndex = 10;
            // 
            // txtPrerequisites
            // 
            txtPrerequisites.Location = new Point(484, 613);
            txtPrerequisites.Name = "txtPrerequisites";
            txtPrerequisites.Size = new Size(302, 23);
            txtPrerequisites.TabIndex = 11;
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Location = new Point(367, 621);
            label8.Name = "label8";
            label8.Size = new Size(74, 15);
            label8.TabIndex = 9;
            label8.Text = "Prerequisites";
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Location = new Point(55, 650);
            label9.Name = "label9";
            label9.Size = new Size(40, 15);
            label9.TabIndex = 7;
            label9.Text = "Group";
            // 
            // txtGroup
            // 
            txtGroup.Location = new Point(104, 642);
            txtGroup.Name = "txtGroup";
            txtGroup.Size = new Size(237, 23);
            txtGroup.TabIndex = 12;
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Location = new Point(367, 650);
            label11.Name = "label11";
            label11.Size = new Size(92, 15);
            label11.TabIndex = 7;
            label11.Text = "Estimated Time:";
            // 
            // numEstimatedTime
            // 
            numEstimatedTime.Location = new Point(484, 642);
            numEstimatedTime.Name = "numEstimatedTime";
            numEstimatedTime.Size = new Size(302, 23);
            numEstimatedTime.TabIndex = 13;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Location = new Point(367, 679);
            label10.Name = "label10";
            label10.Size = new Size(37, 15);
            label10.TabIndex = 7;
            label10.Text = "Order";
            // 
            // numOrder
            // 
            numOrder.Location = new Point(484, 671);
            numOrder.Name = "numOrder";
            numOrder.Size = new Size(302, 23);
            numOrder.TabIndex = 14;
            // 
            // btnExportJson
            // 
            btnExportJson.Location = new Point(571, 700);
            btnExportJson.Name = "btnExportJson";
            btnExportJson.Size = new Size(75, 23);
            btnExportJson.TabIndex = 15;
            btnExportJson.Text = "Export Json";
            btnExportJson.UseVisualStyleBackColor = true;
            btnExportJson.Click += btnExportJson_Click;
            // 
            // btnExportJsonFireStore
            // 
            btnExportJsonFireStore.Location = new Point(652, 700);
            btnExportJsonFireStore.Name = "btnExportJsonFireStore";
            btnExportJsonFireStore.Size = new Size(134, 23);
            btnExportJsonFireStore.TabIndex = 16;
            btnExportJsonFireStore.Text = "Export Json FireStore";
            btnExportJsonFireStore.UseVisualStyleBackColor = true;
            btnExportJsonFireStore.Click += btnExportJsonFireStore_Click;
            // 
            // numUnit
            // 
            numUnit.Location = new Point(125, 39);
            numUnit.Name = "numUnit";
            numUnit.Size = new Size(279, 23);
            numUnit.TabIndex = 2;
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Location = new Point(61, 47);
            label18.Name = "label18";
            label18.Size = new Size(29, 15);
            label18.TabIndex = 24;
            label18.Text = "Unit";
            // 
            // cbLevelId
            // 
            cbLevelId.FormattingEnabled = true;
            cbLevelId.Items.AddRange(new object[] { "A1", "A2", "B1", "B2", "C1", "C2" });
            cbLevelId.Location = new Point(125, 10);
            cbLevelId.Name = "cbLevelId";
            cbLevelId.Size = new Size(279, 23);
            cbLevelId.TabIndex = 1;
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Location = new Point(61, 18);
            label12.Name = "label12";
            label12.Size = new Size(34, 15);
            label12.TabIndex = 23;
            label12.Text = "Level";
            // 
            // UnitForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(844, 774);
            Controls.Add(numUnit);
            Controls.Add(label18);
            Controls.Add(cbLevelId);
            Controls.Add(label12);
            Controls.Add(btnExportJsonFireStore);
            Controls.Add(btnExportJson);
            Controls.Add(numOrder);
            Controls.Add(numEstimatedTime);
            Controls.Add(txtPrerequisites);
            Controls.Add(label10);
            Controls.Add(label8);
            Controls.Add(label11);
            Controls.Add(txtGroup);
            Controls.Add(label9);
            Controls.Add(txtLessons);
            Controls.Add(label7);
            Controls.Add(groupBox2);
            Controls.Add(groupBox1);
            Controls.Add(txtId);
            Controls.Add(label1);
            Name = "UnitForm";
            Text = "UnitForm";
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)grvTitle).EndInit();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)grvDescription).EndInit();
            ((System.ComponentModel.ISupportInitialize)numEstimatedTime).EndInit();
            ((System.ComponentModel.ISupportInitialize)numOrder).EndInit();
            ((System.ComponentModel.ISupportInitialize)numUnit).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private TextBox txtId;
        private GroupBox groupBox1;
        private DataGridView grvTitle;
        private Button btnAddTitle;
        private TextBox txtLanguageValue;
        private Label label4;
        private ComboBox cbLanguageCodeTitle;
        private Label label3;
        private GroupBox groupBox2;
        private DataGridView grvDescription;
        private Button btnAddDescription;
        private TextBox txtDescriptionValue;
        private Label label5;
        private ComboBox cbLanguageCodeDescription;
        private Label label6;
        private Label label7;
        private TextBox txtLessons;
        private TextBox txtPrerequisites;
        private Label label8;
        private Label label9;
        private TextBox txtGroup;
        private Label label11;
        private NumericUpDown numEstimatedTime;
        private Label label10;
        private NumericUpDown numOrder;
        private Button btnExportJson;
        private Button btnExportJsonFireStore;
        private NumericUpDown numUnit;
        private Label label18;
        private ComboBox cbLevelId;
        private Label label12;
    }
}