using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using FirestoreImporter.Models;
using FirestoreImporter.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FirestoreImporter
{
    public partial class LessonForm : Form
    {
        // Lesson Title
        private Dictionary<string, string> _titleDictionary;

        // Theory Content
        private Dictionary<string, string> _theoryDescriptionDictionary;
        private Dictionary<string, string> _currentExampleExplanationDictionary;
        private List<Example> _examples;
        private Dictionary<string, List<string>> _hintsDictionary; // language code -> list of hints
        private List<Dictionary<string, object>> _usageItems; // List of usage items with language keys

        // Vocabulary Content
        private List<TopicVocabularyItem> _topicVocabularyItems;
        private List<PhrasalVerbItem> _phrasalVerbItems;
        private List<PrepositionalPhraseItem> _prepositionalPhraseItems;

        // Current vocabulary item being edited (for multi-language definitions)
        private TopicVocabularyItem? _currentTopicVocabularyItem;
        private PhrasalVerbItem? _currentPhrasalVerbItem;
        private PrepositionalPhraseItem? _currentPrepositionalPhraseItem;

        public LessonForm()
        {
            InitializeComponent();
            _titleDictionary = new Dictionary<string, string>();
            _theoryDescriptionDictionary = new Dictionary<string, string>();
            _currentExampleExplanationDictionary = new Dictionary<string, string>();
            _examples = new List<Example>();
            _hintsDictionary = new Dictionary<string, List<string>>();
            _usageItems = new List<Dictionary<string, object>>();
            _topicVocabularyItems = new List<TopicVocabularyItem>();
            _phrasalVerbItems = new List<PhrasalVerbItem>();
            _prepositionalPhraseItems = new List<PrepositionalPhraseItem>();
            SetupDataGridViews();
            SetupAutoBuildIds();
        }

        private void SetupAutoBuildIds()
        {
            cbLevelId.SelectedIndexChanged += OnIdControlsChanged;
            numUnit.ValueChanged += OnIdControlsChanged;
            numLesson.ValueChanged += OnIdControlsChanged;
        }

        private void OnIdControlsChanged(object? sender, EventArgs e)
        {
            BuildIds();
        }

        private void BuildIds()
        {
            // Lấy level ID (lowercase)
            string levelId = cbLevelId.SelectedItem?.ToString()?.ToLower() ?? "";

            // Lấy các giá trị numeric
            int unitValue = (int)numUnit.Value;
            int lessonValue = (int)numLesson.Value;

            // Build Unit ID: unit_{levelId}_{unitValue}
            if (!string.IsNullOrEmpty(levelId) && unitValue > 0)
            {
                txtUnitId.Text = $"unit_{levelId}_{unitValue}";
            }

            // Build Lesson ID: lesson_{levelId}_{unitValue}_{lessonValue}
            if (!string.IsNullOrEmpty(levelId) && unitValue > 0 && lessonValue > 0)
            {
                txtLessonId.Text = $"lesson_{levelId}_{unitValue}_{lessonValue}";
            }
        }

        private void SetupDataGridViews()
        {
            // Setup grvTitle (Lesson Title)
            SetupTitleGrid();

            // Setup dataGridView1 (Theory Description)
            SetupDescriptionGrid();

            // Setup grvExplanation (Example Explanation)
            SetupExplanationGrid();

            // Setup grvExample (Examples)
            SetupExampleGrid();

            // Setup grvHint (Hints)
            SetupHintGrid();

            // Setup grvUsageLanguage (Usage Language)
            SetupUsageLanguageGrid();

            // Setup grvUsage (Usage Items)
            SetupUsageGrid();

            // Setup Vocabulary Grids
            SetupTopicVocabularyGrid();
            SetupTopicVocabularyLanguageGrid();
            SetupPhrasalVerbsGrid();
            SetupPhrasalVerbLanguageGrid();
            SetupPrepositionalPhrasesGrid();
            SetupPrepositionalPhraseLanguageGrid();
        }

        private void SetupTitleGrid()
        {
            grvTitle.AutoGenerateColumns = false;
            grvTitle.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvTitle.Columns.Add(deleteColumn);

            grvTitle.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            grvTitle.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 490,
                ReadOnly = true
            });
            grvTitle.AllowUserToAddRows = false;
            grvTitle.AllowUserToDeleteRows = false;
            grvTitle.ReadOnly = true;
            grvTitle.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvTitle.CellContentClick += GrvTitle_CellContentClick;
        }

        private void SetupDescriptionGrid()
        {
            dataGridView1.AutoGenerateColumns = false;
            dataGridView1.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            dataGridView1.Columns.Add(deleteColumn);

            dataGridView1.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            dataGridView1.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 490,
                ReadOnly = true
            });
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.AllowUserToDeleteRows = false;
            dataGridView1.ReadOnly = true;
            dataGridView1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dataGridView1.CellContentClick += GrvDescription_CellContentClick;
        }

        private void SetupExplanationGrid()
        {
            grvExplanation.AutoGenerateColumns = false;
            grvExplanation.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvExplanation.Columns.Add(deleteColumn);

            grvExplanation.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "Key",
                Width = 150,
                ReadOnly = true
            });
            grvExplanation.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colValue",
                HeaderText = "Value",
                DataPropertyName = "Value",
                Width = 440,
                ReadOnly = true
            });
            grvExplanation.AllowUserToAddRows = false;
            grvExplanation.AllowUserToDeleteRows = false;
            grvExplanation.ReadOnly = true;
            grvExplanation.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvExplanation.CellContentClick += GrvExplanation_CellContentClick;
        }

        private void SetupExampleGrid()
        {
            grvExample.AutoGenerateColumns = false;
            grvExample.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvExample.Columns.Add(deleteColumn);

            grvExample.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colIndex",
                HeaderText = "#",
                DataPropertyName = "Index",
                Width = 50,
                ReadOnly = true
            });
            grvExample.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colSentence",
                HeaderText = "Sentence",
                DataPropertyName = "Sentence",
                Width = 350,
                ReadOnly = true
            });
            grvExample.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colExplanation",
                HeaderText = "Explanation",
                DataPropertyName = "Explanation",
                Width = 250,
                ReadOnly = true
            });
            grvExample.AllowUserToAddRows = false;
            grvExample.AllowUserToDeleteRows = false;
            grvExample.ReadOnly = true;
            grvExample.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvExample.CellContentClick += GrvExample_CellContentClick;
        }

        private void SetupHintGrid()
        {
            grvHint.AutoGenerateColumns = false;
            grvHint.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvHint.Columns.Add(deleteColumn);

            grvHint.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvHint.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colHints",
                HeaderText = "Hints",
                DataPropertyName = "Hints",
                Width = 490,
                ReadOnly = true
            });
            grvHint.AllowUserToAddRows = false;
            grvHint.AllowUserToDeleteRows = false;
            grvHint.ReadOnly = true;
            grvHint.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvHint.CellContentClick += GrvHint_CellContentClick;
        }

        private void SetupUsageLanguageGrid()
        {
            grvUsageLanguage.AutoGenerateColumns = false;
            grvUsageLanguage.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvUsageLanguage.Columns.Add(deleteColumn);

            grvUsageLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvUsageLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colTitle",
                HeaderText = "Title",
                DataPropertyName = "Title",
                Width = 200,
                ReadOnly = true
            });
            grvUsageLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colExample",
                HeaderText = "Example",
                DataPropertyName = "Example",
                Width = 290,
                ReadOnly = true
            });
            grvUsageLanguage.AllowUserToAddRows = false;
            grvUsageLanguage.AllowUserToDeleteRows = false;
            grvUsageLanguage.ReadOnly = true;
            grvUsageLanguage.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvUsageLanguage.CellContentClick += GrvUsageLanguage_CellContentClick;
        }

        private void SetupUsageGrid()
        {
            grvUsage.AutoGenerateColumns = false;
            grvUsage.Columns.Clear();

            // Delete button column
            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvUsage.Columns.Add(deleteColumn);

            grvUsage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colIndex",
                HeaderText = "#",
                DataPropertyName = "Index",
                Width = 50,
                ReadOnly = true
            });
            grvUsage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colUsage",
                HeaderText = "Usage",
                DataPropertyName = "Usage",
                Width = 590,
                ReadOnly = true
            });
            grvUsage.AllowUserToAddRows = false;
            grvUsage.AllowUserToDeleteRows = false;
            grvUsage.ReadOnly = true;
            grvUsage.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvUsage.CellContentClick += GrvUsage_CellContentClick;
        }

        // Helper classes để bind vào DataGridView
        private class ExampleGridItem
        {
            public int Index { get; set; }
            public string Sentence { get; set; } = string.Empty;
            public string Explanation { get; set; } = string.Empty;
        }

        private class HintGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Hints { get; set; } = string.Empty;
        }

        private class UsageLanguageGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Title { get; set; } = string.Empty;
            public string Example { get; set; } = string.Empty;
        }

        private class UsageGridItem
        {
            public int Index { get; set; }
            public string Usage { get; set; } = string.Empty;
        }

        private class TopicVocabularyGridItem
        {
            public int Index { get; set; }
            public string Word { get; set; } = string.Empty;
            public string PartOfSpeech { get; set; } = string.Empty;
            public string Definition { get; set; } = string.Empty;
        }

        private class PhrasalVerbGridItem
        {
            public int Index { get; set; }
            public string Verb { get; set; } = string.Empty;
            public string Definition { get; set; } = string.Empty;
        }

        private class PrepositionalPhraseGridItem
        {
            public int Index { get; set; }
            public string Phrase { get; set; } = string.Empty;
            public string Definition { get; set; } = string.Empty;
        }

        private class TopicVocabularyLanguageGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Definition { get; set; } = string.Empty;
        }

        private class PhrasalVerbLanguageGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Definition { get; set; } = string.Empty;
        }

        private class PrepositionalPhraseLanguageGridItem
        {
            public string LanguageCode { get; set; } = string.Empty;
            public string Definition { get; set; } = string.Empty;
        }

        private void GrvTitle_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvTitle.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _titleDictionary.Remove(kvp.Key);
                    RefreshTitleGrid();
                }
            }
        }

        private void RefreshTitleGrid()
        {
            grvTitle.DataSource = null;
            if (_titleDictionary.Count > 0)
            {
                grvTitle.DataSource = _titleDictionary.ToList();
            }
        }

        private void RefreshDescriptionGrid()
        {
            dataGridView1.DataSource = null;
            if (_theoryDescriptionDictionary.Count > 0)
            {
                dataGridView1.DataSource = _theoryDescriptionDictionary.ToList();
            }
        }

        private void GrvDescription_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (dataGridView1.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _theoryDescriptionDictionary.Remove(kvp.Key);
                    RefreshDescriptionGrid();
                }
            }
        }

        private void RefreshExplanationGrid()
        {
            grvExplanation.DataSource = null;
            if (_currentExampleExplanationDictionary.Count > 0)
            {
                grvExplanation.DataSource = _currentExampleExplanationDictionary.ToList();
            }
        }

        private void GrvExplanation_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvExplanation.Rows[e.RowIndex].DataBoundItem is KeyValuePair<string, string> kvp)
                {
                    _currentExampleExplanationDictionary.Remove(kvp.Key);
                    RefreshExplanationGrid();
                }
            }
        }

        private void RefreshExampleGrid()
        {
            grvExample.DataSource = null;
            if (_examples.Count > 0)
            {
                var dataSource = _examples.Select((ex, index) => new ExampleGridItem
                {
                    Index = index + 1,
                    Sentence = ex.Sentence,
                    Explanation = ex.Explanation != null && ex.Explanation.Count > 0
                        ? (ex.Explanation.ContainsKey("en") ? ex.Explanation["en"] : ex.Explanation.Values.FirstOrDefault() ?? "")
                        : ""
                }).ToList();
                grvExample.DataSource = dataSource;
            }
        }

        private void GrvExample_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvExample.Rows[e.RowIndex].DataBoundItem is ExampleGridItem item)
                {
                    int index = item.Index - 1;
                    if (index >= 0 && index < _examples.Count)
                    {
                        _examples.RemoveAt(index);
                        RefreshExampleGrid();
                    }
                }
            }
        }

        private void RefreshHintGrid()
        {
            grvHint.DataSource = null;
            if (_hintsDictionary.Count > 0)
            {
                var dataSource = _hintsDictionary.Select(kvp => new HintGridItem
                {
                    LanguageCode = kvp.Key,
                    Hints = string.Join("\n", kvp.Value)
                }).ToList();
                grvHint.DataSource = dataSource;
            }
        }

        private void GrvHint_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvHint.Rows[e.RowIndex].DataBoundItem is HintGridItem item)
                {
                    _hintsDictionary.Remove(item.LanguageCode);
                    RefreshHintGrid();
                }
            }
        }

        private void RefreshUsageLanguageGrid()
        {
            grvUsageLanguage.DataSource = null;
            // Usage language grid sẽ được refresh khi add language usage
        }

        private Dictionary<string, object>? _currentUsageLanguageData;

        private void GrvUsageLanguage_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvUsageLanguage.Rows[e.RowIndex].DataBoundItem is UsageLanguageGridItem item)
                {
                    if (_currentUsageLanguageData != null)
                    {
                        _currentUsageLanguageData.Remove(item.LanguageCode);
                        RefreshUsageLanguageGrid();
                        if (_currentUsageLanguageData.Count > 0)
                        {
                            var dataSource = _currentUsageLanguageData.Select(kvp =>
                            {
                                var langData = kvp.Value as Dictionary<string, string>;
                                return new UsageLanguageGridItem
                                {
                                    LanguageCode = kvp.Key,
                                    Title = langData?.GetValueOrDefault("title") ?? "",
                                    Example = langData?.GetValueOrDefault("example") ?? ""
                                };
                            }).ToList();
                            grvUsageLanguage.DataSource = dataSource;
                        }
                        else
                        {
                            grvUsageLanguage.DataSource = null;
                        }
                    }
                }
            }
        }

        private void RefreshUsageGrid()
        {
            grvUsage.DataSource = null;
            if (_usageItems.Count > 0)
            {
                var dataSource = _usageItems.Select((usage, index) => new UsageGridItem
                {
                    Index = index + 1,
                    Usage = JsonConvert.SerializeObject(usage, Formatting.None)
                }).ToList();
                grvUsage.DataSource = dataSource;
            }
        }

        private void SetupTopicVocabularyGrid()
        {
            grvTopicVocabulary.AutoGenerateColumns = false;
            grvTopicVocabulary.Columns.Clear();

            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvTopicVocabulary.Columns.Add(deleteColumn);

            grvTopicVocabulary.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colWord",
                HeaderText = "Word",
                DataPropertyName = "Word",
                Width = 150,
                ReadOnly = true
            });
            grvTopicVocabulary.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPartOfSpeech",
                HeaderText = "Part of Speech",
                DataPropertyName = "PartOfSpeech",
                Width = 100,
                ReadOnly = true
            });
            grvTopicVocabulary.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDefinition",
                HeaderText = "Definition",
                DataPropertyName = "Definition",
                Width = 300,
                ReadOnly = true
            });
            grvTopicVocabulary.AllowUserToAddRows = false;
            grvTopicVocabulary.AllowUserToDeleteRows = false;
            grvTopicVocabulary.ReadOnly = true;
            grvTopicVocabulary.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvTopicVocabulary.CellContentClick += GrvTopicVocabulary_CellContentClick;
        }

        private void SetupPhrasalVerbsGrid()
        {
            grvPhrasalVerbs.AutoGenerateColumns = false;
            grvPhrasalVerbs.Columns.Clear();

            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvPhrasalVerbs.Columns.Add(deleteColumn);

            grvPhrasalVerbs.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colVerb",
                HeaderText = "Phrasal Verb",
                DataPropertyName = "Verb",
                Width = 200,
                ReadOnly = true
            });
            grvPhrasalVerbs.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDefinition",
                HeaderText = "Definition",
                DataPropertyName = "Definition",
                Width = 400,
                ReadOnly = true
            });
            grvPhrasalVerbs.AllowUserToAddRows = false;
            grvPhrasalVerbs.AllowUserToDeleteRows = false;
            grvPhrasalVerbs.ReadOnly = true;
            grvPhrasalVerbs.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvPhrasalVerbs.CellContentClick += GrvPhrasalVerbs_CellContentClick;
        }

        private void SetupPrepositionalPhrasesGrid()
        {
            grvPrepositionalPhrases.AutoGenerateColumns = false;
            grvPrepositionalPhrases.Columns.Clear();

            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvPrepositionalPhrases.Columns.Add(deleteColumn);

            grvPrepositionalPhrases.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colPhrase",
                HeaderText = "Phrase",
                DataPropertyName = "Phrase",
                Width = 200,
                ReadOnly = true
            });
            grvPrepositionalPhrases.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDefinition",
                HeaderText = "Definition",
                DataPropertyName = "Definition",
                Width = 400,
                ReadOnly = true
            });
            grvPrepositionalPhrases.AllowUserToAddRows = false;
            grvPrepositionalPhrases.AllowUserToDeleteRows = false;
            grvPrepositionalPhrases.ReadOnly = true;
            grvPrepositionalPhrases.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvPrepositionalPhrases.CellContentClick += GrvPrepositionalPhrases_CellContentClick;
        }

        private void SetupPrepositionalPhraseLanguageGrid()
        {
            grvPrepositionalPhrase.AutoGenerateColumns = false;
            grvPrepositionalPhrase.Columns.Clear();

            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvPrepositionalPhrase.Columns.Add(deleteColumn);

            grvPrepositionalPhrase.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvPrepositionalPhrase.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDefinition",
                HeaderText = "Definition",
                DataPropertyName = "Definition",
                Width = 500,
                ReadOnly = true
            });
            grvPrepositionalPhrase.AllowUserToAddRows = false;
            grvPrepositionalPhrase.AllowUserToDeleteRows = false;
            grvPrepositionalPhrase.ReadOnly = true;
            grvPrepositionalPhrase.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvPrepositionalPhrase.CellContentClick += GrvPrepositionalPhrase_CellContentClick;
        }

        private void SetupTopicVocabularyLanguageGrid()
        {
            grvTopicVocabularyLanguage.AutoGenerateColumns = false;
            grvTopicVocabularyLanguage.Columns.Clear();

            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvTopicVocabularyLanguage.Columns.Add(deleteColumn);

            grvTopicVocabularyLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvTopicVocabularyLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDefinition",
                HeaderText = "Definition",
                DataPropertyName = "Definition",
                Width = 500,
                ReadOnly = true
            });
            grvTopicVocabularyLanguage.AllowUserToAddRows = false;
            grvTopicVocabularyLanguage.AllowUserToDeleteRows = false;
            grvTopicVocabularyLanguage.ReadOnly = true;
            grvTopicVocabularyLanguage.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvTopicVocabularyLanguage.CellContentClick += GrvTopicVocabularyLanguage_CellContentClick;
        }

        private void SetupPhrasalVerbLanguageGrid()
        {
            grvPhrasalVerbLanguage.AutoGenerateColumns = false;
            grvPhrasalVerbLanguage.Columns.Clear();

            var deleteColumn = new DataGridViewButtonColumn
            {
                Name = "colDelete",
                HeaderText = "",
                Text = "Delete",
                UseColumnTextForButtonValue = true,
                Width = 60,
                ReadOnly = true
            };
            grvPhrasalVerbLanguage.Columns.Add(deleteColumn);

            grvPhrasalVerbLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colLanguageCode",
                HeaderText = "Language Code",
                DataPropertyName = "LanguageCode",
                Width = 150,
                ReadOnly = true
            });
            grvPhrasalVerbLanguage.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "colDefinition",
                HeaderText = "Definition",
                DataPropertyName = "Definition",
                Width = 500,
                ReadOnly = true
            });
            grvPhrasalVerbLanguage.AllowUserToAddRows = false;
            grvPhrasalVerbLanguage.AllowUserToDeleteRows = false;
            grvPhrasalVerbLanguage.ReadOnly = true;
            grvPhrasalVerbLanguage.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grvPhrasalVerbLanguage.CellContentClick += GrvPhrasalVerbLanguage_CellContentClick;
        }

        private void RefreshTopicVocabularyGrid()
        {
            grvTopicVocabulary.DataSource = null;
            if (_topicVocabularyItems.Count > 0)
            {
                var dataSource = _topicVocabularyItems.Select((item, index) => new TopicVocabularyGridItem
                {
                    Index = index + 1,
                    Word = item.Word,
                    PartOfSpeech = item.PartOfSpeech,
                    Definition = item.Definitions != null && item.Definitions.ContainsKey("en")
                        ? item.Definitions["en"]
                        : (item.Definitions?.Values.FirstOrDefault() ?? "")
                }).ToList();
                grvTopicVocabulary.DataSource = dataSource;
            }
        }

        private void RefreshPhrasalVerbsGrid()
        {
            grvPhrasalVerbs.DataSource = null;
            if (_phrasalVerbItems.Count > 0)
            {
                var dataSource = _phrasalVerbItems.Select((item, index) => new PhrasalVerbGridItem
                {
                    Index = index + 1,
                    Verb = item.Verb,
                    Definition = item.Definition != null && item.Definition.ContainsKey("en")
                        ? item.Definition["en"]
                        : (item.Definition?.Values.FirstOrDefault() ?? "")
                }).ToList();
                grvPhrasalVerbs.DataSource = dataSource;
            }
        }

        private void RefreshPrepositionalPhrasesGrid()
        {
            grvPrepositionalPhrases.DataSource = null;
            if (_prepositionalPhraseItems.Count > 0)
            {
                var dataSource = _prepositionalPhraseItems.Select((item, index) => new PrepositionalPhraseGridItem
                {
                    Index = index + 1,
                    Phrase = item.Phrase,
                    Definition = item.Definition != null && item.Definition.ContainsKey("en")
                        ? item.Definition["en"]
                        : (item.Definition?.Values.FirstOrDefault() ?? "")
                }).ToList();
                grvPrepositionalPhrases.DataSource = dataSource;
            }
        }

        private void RefreshPrepositionalPhraseLanguageGrid()
        {
            grvPrepositionalPhrase.DataSource = null;
            if (_currentPrepositionalPhraseItem != null && _currentPrepositionalPhraseItem.Definition != null)
            {
                var dataSource = _currentPrepositionalPhraseItem.Definition.Select(kvp => new PrepositionalPhraseLanguageGridItem
                {
                    LanguageCode = kvp.Key,
                    Definition = kvp.Value
                }).ToList();
                grvPrepositionalPhrase.DataSource = dataSource;
            }
        }

        private void GrvPrepositionalPhrase_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (grvPrepositionalPhrase.Rows[e.RowIndex].DataBoundItem is PrepositionalPhraseLanguageGridItem item)
                {
                    if (_currentPrepositionalPhraseItem != null && _currentPrepositionalPhraseItem.Definition != null)
                    {
                        _currentPrepositionalPhraseItem.Definition.Remove(item.LanguageCode);
                        RefreshPrepositionalPhraseLanguageGrid();
                    }
                }
            }
        }

        private void RefreshTopicVocabularyLanguageGrid()
        {
            grvTopicVocabularyLanguage.DataSource = null;
            if (_currentTopicVocabularyItem != null && _currentTopicVocabularyItem.Definitions != null)
            {
                var dataSource = _currentTopicVocabularyItem.Definitions.Select(kvp => new TopicVocabularyLanguageGridItem
                {
                    LanguageCode = kvp.Key,
                    Definition = kvp.Value
                }).ToList();
                grvTopicVocabularyLanguage.DataSource = dataSource;
            }
        }

        private void RefreshPhrasalVerbLanguageGrid()
        {
            grvPhrasalVerbLanguage.DataSource = null;
            if (_currentPhrasalVerbItem != null && _currentPhrasalVerbItem.Definition != null)
            {
                var dataSource = _currentPhrasalVerbItem.Definition.Select(kvp => new PhrasalVerbLanguageGridItem
                {
                    LanguageCode = kvp.Key,
                    Definition = kvp.Value
                }).ToList();
                grvPhrasalVerbLanguage.DataSource = dataSource;
            }
        }

        private void GrvTopicVocabularyLanguage_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (grvTopicVocabularyLanguage.Rows[e.RowIndex].DataBoundItem is TopicVocabularyLanguageGridItem item)
                {
                    if (_currentTopicVocabularyItem != null && _currentTopicVocabularyItem.Definitions != null)
                    {
                        _currentTopicVocabularyItem.Definitions.Remove(item.LanguageCode);
                        RefreshTopicVocabularyLanguageGrid();
                    }
                }
            }
        }

        private void GrvPhrasalVerbLanguage_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (grvPhrasalVerbLanguage.Rows[e.RowIndex].DataBoundItem is PhrasalVerbLanguageGridItem item)
                {
                    if (_currentPhrasalVerbItem != null && _currentPhrasalVerbItem.Definition != null)
                    {
                        _currentPhrasalVerbItem.Definition.Remove(item.LanguageCode);
                        RefreshPhrasalVerbLanguageGrid();
                    }
                }
            }
        }



        private void GrvTopicVocabulary_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (grvTopicVocabulary.Rows[e.RowIndex].DataBoundItem is TopicVocabularyGridItem item)
                {
                    int index = item.Index - 1;
                    if (index >= 0 && index < _topicVocabularyItems.Count)
                    {
                        _topicVocabularyItems.RemoveAt(index);
                        RefreshTopicVocabularyGrid();
                    }
                }
            }
        }

        private void GrvPhrasalVerbs_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (grvPhrasalVerbs.Rows[e.RowIndex].DataBoundItem is PhrasalVerbGridItem item)
                {
                    int index = item.Index - 1;
                    if (index >= 0 && index < _phrasalVerbItems.Count)
                    {
                        _phrasalVerbItems.RemoveAt(index);
                        RefreshPhrasalVerbsGrid();
                    }
                }
            }
        }

        private void GrvPrepositionalPhrases_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0)
            {
                if (grvPrepositionalPhrases.Rows[e.RowIndex].DataBoundItem is PrepositionalPhraseGridItem item)
                {
                    int index = item.Index - 1;
                    if (index >= 0 && index < _prepositionalPhraseItems.Count)
                    {
                        _prepositionalPhraseItems.RemoveAt(index);
                        RefreshPrepositionalPhrasesGrid();
                    }
                }
            }
        }



        private void GrvUsage_CellContentClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0 && e.RowIndex >= 0) // Delete button column
            {
                if (grvUsage.Rows[e.RowIndex].DataBoundItem is UsageGridItem item)
                {
                    int index = item.Index - 1;
                    if (index >= 0 && index < _usageItems.Count)
                    {
                        _usageItems.RemoveAt(index);
                        RefreshUsageGrid();
                    }
                }
            }
        }

        private void btnExportJson_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtUnitId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Unit ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Get JSON string
                string jsonContent = ExportJson();

                // Get Desktop path
                string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                string filePath = Path.Combine(desktopPath, "lesson.json");

                // Write file
                File.WriteAllText(filePath, jsonContent, Encoding.UTF8);

                // Show success message
                MessageBox.Show($"Đã export JSON thành công!\nFile đã được lưu tại: {filePath}",
                    "Thành công",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi export JSON: {ex.Message}",
                    "Lỗi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        private async void btnExportJsonFireStore_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtLessonId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Lesson ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtUnitId.Text))
                {
                    MessageBox.Show("Vui lòng nhập Unit ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Kiểm tra xem có file serviceAccountKey.json trong thư mục ứng dụng không
                string credentialsPath = string.Empty;
                string appDirectory = AppDomain.CurrentDomain.BaseDirectory;
                string defaultCredentialsPath = Path.Combine(appDirectory, "serviceAccountKey.json");

                if (File.Exists(defaultCredentialsPath))
                {
                    // Sử dụng file có sẵn trong thư mục ứng dụng
                    credentialsPath = defaultCredentialsPath;
                }
                else
                {
                    // Mở dialog để chọn file
                    using var openFileDialog = new OpenFileDialog
                    {
                        Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*",
                        Title = "Chọn Firebase Service Account Key File",
                        FileName = "serviceAccountKey.json"
                    };

                    if (openFileDialog.ShowDialog() != DialogResult.OK)
                    {
                        return; // User đã hủy
                    }

                    credentialsPath = openFileDialog.FileName;
                }

                // Đọc project_id từ file JSON
                string projectId = string.Empty;
                try
                {
                    string jsonContent = File.ReadAllText(credentialsPath);
                    dynamic? jsonObj = JsonConvert.DeserializeObject(jsonContent);
                    projectId = jsonObj?.project_id?.ToString() ?? string.Empty;
                }
                catch
                {
                    // Nếu không đọc được từ file, yêu cầu user nhập
                }

                // Nếu không có project_id từ file, yêu cầu user nhập
                if (string.IsNullOrWhiteSpace(projectId))
                {
                    using var inputDialog = new Form
                    {
                        Text = "Nhập Project ID",
                        Size = new Size(400, 150),
                        StartPosition = FormStartPosition.CenterParent,
                        FormBorderStyle = FormBorderStyle.FixedDialog,
                        MaximizeBox = false,
                        MinimizeBox = false
                    };

                    var lblProjectId = new Label
                    {
                        Text = "Project ID:",
                        Location = new Point(20, 25),
                        Size = new Size(80, 20)
                    };

                    var txtProjectId = new TextBox
                    {
                        Location = new Point(100, 22),
                        Size = new Size(250, 23)
                    };

                    var btnOk = new Button
                    {
                        Text = "OK",
                        DialogResult = DialogResult.OK,
                        Location = new Point(200, 60),
                        Size = new Size(75, 30)
                    };

                    var btnCancel = new Button
                    {
                        Text = "Cancel",
                        DialogResult = DialogResult.Cancel,
                        Location = new Point(285, 60),
                        Size = new Size(75, 30)
                    };

                    inputDialog.Controls.AddRange(new Control[] { lblProjectId, txtProjectId, btnOk, btnCancel });
                    inputDialog.AcceptButton = btnOk;
                    inputDialog.CancelButton = btnCancel;

                    if (inputDialog.ShowDialog() != DialogResult.OK)
                    {
                        return; // User đã hủy
                    }

                    projectId = txtProjectId.Text.Trim();
                    if (string.IsNullOrWhiteSpace(projectId))
                    {
                        MessageBox.Show("Vui lòng nhập Project ID!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }
                }

                // Disable button để tránh click nhiều lần
                btnExportJsonFireStore.Enabled = false;
                btnExportJsonFireStore.Text = "Đang upload...";

                // Khởi tạo FirestoreService
                var firestoreService = new FirestoreService();
                await firestoreService.InitializeAsync(projectId, credentialsPath);

                // Test connection
                bool isConnected = await firestoreService.TestConnectionAsync();
                if (!isConnected)
                {
                    MessageBox.Show("Không thể kết nối đến Firestore. Vui lòng kiểm tra Project ID và Credentials.",
                        "Lỗi",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return;
                }

                // Tạo LessonModel từ dữ liệu form
                var lesson = CreateLessonFromInputs();

                // Upload lên Firestore
                await firestoreService.ImportLessonAsync(lesson);

                // Thông báo thành công
                MessageBox.Show($"Đã upload Lesson lên Firestore thành công!\nLesson ID: {lesson.Id}",
                    "Thành công",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi upload lên Firestore: {ex.Message}",
                    "Lỗi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                // Restore button
                btnExportJsonFireStore.Enabled = true;
                btnExportJsonFireStore.Text = "Export Json FireStore";
            }
        }

        private LessonModel CreateLessonFromInputs()
        {
            var lesson = new LessonModel
            {
                Id = txtLessonId.Text.Trim(),
                UnitId = txtUnitId.Text.Trim(),
                LevelId = cbLevelId.SelectedItem?.ToString() ?? string.Empty,
                Type = cbType.SelectedItem?.ToString() ?? "grammar",
                Order = (int)numOrder.Value
            };

            // Title từ dictionary
            if (_titleDictionary.Count > 0)
            {
                lesson.Title = new Dictionary<string, string>(_titleDictionary);
            }

            // Content
            var content = new LessonContent();

            // Exercises: split theo dấu phẩy
            if (!string.IsNullOrWhiteSpace(txtExercises.Text))
            {
                content.Exercises = txtExercises.Text.Split(',')
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }

            // Theory Content
            var theory = new TheoryContent();

            // Description từ dictionary
            if (_theoryDescriptionDictionary.Count > 0)
            {
                theory.Description = new Dictionary<string, string>(_theoryDescriptionDictionary);
            }

            // Examples
            if (_examples.Count > 0)
            {
                theory.Examples = _examples;
            }

            // Forms: split theo newline
            var forms = new GrammarForms();
            if (!string.IsNullOrWhiteSpace(txtStatement.Text))
            {
                forms.Statement = txtStatement.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (!string.IsNullOrWhiteSpace(txtNegative.Text))
            {
                forms.Negative = txtNegative.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (!string.IsNullOrWhiteSpace(txtQuestion.Text))
            {
                forms.Question = txtQuestion.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (!string.IsNullOrWhiteSpace(txtForm.Text))
            {
                forms.Form = txtForm.Text.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrEmpty(s))
                    .ToList();
            }
            if (forms.Statement != null || forms.Negative != null || forms.Question != null || forms.Form != null)
            {
                theory.Forms = forms;
            }

            // Hints: convert từ dictionary sang object
            if (_hintsDictionary.Count > 0)
            {
                // Hints được lưu dưới dạng Dictionary<string, List<string>>
                var hintsObject = new Dictionary<string, object>();
                foreach (var kvp in _hintsDictionary)
                {
                    hintsObject[kvp.Key] = kvp.Value; // List<string>
                }
                theory.Hints = hintsObject;
            }

            // Usage: convert từ list sang object
            if (_usageItems.Count > 0)
            {
                // Usage là List<Dictionary<string, object>>
                theory.Usage = _usageItems;
            }

            // Vocabulary Content: ưu tiên JSON trong txtJsonText (tab Json), không thì dùng nhập tay
            var vocabulary = BuildVocabularyContentForExport();
            if (vocabulary != null)
            {
                theory.Vocabulary = vocabulary;
            }

            // Chỉ thêm theory nếu có ít nhất một field
            if (theory.Description != null || theory.Examples.Count > 0 || theory.Forms != null ||
                theory.Usage != null || theory.Hints.Count > 0 || theory.Vocabulary != null)
            {
                content.Theory = theory;
            }

            lesson.Content = content;

            return lesson;
        }

        public string ExportJson()
        {
            var lesson = CreateLessonFromInputs();

            var jsonData = new Dictionary<string, object>
            {
                { "lessons", new Dictionary<string, LessonModel> { { lesson.Id, lesson } } }
            };
            var jsonResult = JsonConvert.SerializeObject(jsonData, Formatting.Indented);

            return jsonResult;
        }

        private void btnAddTitle_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeTitle.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageTitleValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeTitle.SelectedItem.ToString()!;
            string value = txtLanguageTitleValue.Text.Trim();

            // Update hoặc thêm mới
            _titleDictionary[languageCode] = value;

            // Refresh grid
            RefreshTitleGrid();

            // Clear input
            txtLanguageTitleValue.Clear();
        }

        private void btnAddDescription_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeDescription.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageDescriptionValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Description!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeDescription.SelectedItem.ToString()!;
            string value = txtLanguageDescriptionValue.Text.Trim();

            // Update hoặc thêm mới
            _theoryDescriptionDictionary[languageCode] = value;

            // Refresh grid
            RefreshDescriptionGrid();

            // Clear input
            txtLanguageDescriptionValue.Clear();
        }

        private void btnAddExplanation_Click(object sender, EventArgs e)
        {
            if (cbLanuageCodeExplanation.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageValueExplanation.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Explanation!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanuageCodeExplanation.SelectedItem.ToString()!;
            string value = txtLanguageValueExplanation.Text.Trim();

            // Update hoặc thêm mới vào current example explanation
            _currentExampleExplanationDictionary[languageCode] = value;

            // Refresh grid
            RefreshExplanationGrid();

            // Clear input
            txtLanguageValueExplanation.Clear();
        }

        private void btnAddExample_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSentence.Text))
            {
                MessageBox.Show("Vui lòng nhập Sentence!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var example = new Example
            {
                Sentence = txtSentence.Text.Trim()
            };

            // Thêm explanation nếu có
            if (_currentExampleExplanationDictionary.Count > 0)
            {
                example.Explanation = new Dictionary<string, string>(_currentExampleExplanationDictionary);
            }

            // Thêm vào list
            _examples.Add(example);

            // Refresh grid
            RefreshExampleGrid();

            // Clear inputs
            txtSentence.Clear();
            _currentExampleExplanationDictionary.Clear();
            RefreshExplanationGrid();
        }

        private void btnAddHint_Click(object sender, EventArgs e)
        {
            if (cbHintLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtHintVaue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Hint!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbHintLanguageCode.SelectedItem.ToString()!;
            string value = txtHintVaue.Text.Trim();

            // Split theo newline và tạo list
            var hints = value.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                .Select(s => s.Trim())
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();

            // Update hoặc thêm mới
            _hintsDictionary[languageCode] = hints;

            // Refresh grid
            RefreshHintGrid();

            // Clear input
            txtHintVaue.Clear();
        }

        private void btnAddLanguageUsage_Click(object sender, EventArgs e)
        {
            if (cbUsageLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtUsageTitle.Text))
            {
                MessageBox.Show("Vui lòng nhập Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtUsageExample.Text))
            {
                MessageBox.Show("Vui lòng nhập Example!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbUsageLanguageCode.SelectedItem.ToString()!;
            string title = txtUsageTitle.Text.Trim();
            string example = txtUsageExample.Text.Trim();

            // Khởi tạo _currentUsageLanguageData nếu chưa có
            if (_currentUsageLanguageData == null)
            {
                _currentUsageLanguageData = new Dictionary<string, object>();
            }

            // Thêm/update language data
            _currentUsageLanguageData[languageCode] = new Dictionary<string, string>
            {
                { "title", title },
                { "example", example }
            };

            // Refresh usage language grid
            RefreshUsageLanguageGrid();
            if (_currentUsageLanguageData.Count > 0)
            {
                var dataSource = _currentUsageLanguageData.Select(kvp =>
                {
                    var langData = kvp.Value as Dictionary<string, string>;
                    return new UsageLanguageGridItem
                    {
                        LanguageCode = kvp.Key,
                        Title = langData?.GetValueOrDefault("title") ?? "",
                        Example = langData?.GetValueOrDefault("example") ?? ""
                    };
                }).ToList();
                grvUsageLanguage.DataSource = dataSource;
            }

            // Clear inputs
            txtUsageTitle.Clear();
            txtUsageExample.Clear();
        }

        private void btnAddToUsage_Click(object sender, EventArgs e)
        {
            if (_currentUsageLanguageData == null || _currentUsageLanguageData.Count == 0)
            {
                MessageBox.Show("Vui lòng thêm ít nhất một Language Usage trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Thêm usage item vào list
            _usageItems.Add(new Dictionary<string, object>(_currentUsageLanguageData));

            // Refresh usage grid
            RefreshUsageGrid();

            // Clear current usage language data
            _currentUsageLanguageData = null;
            grvUsageLanguage.DataSource = null;
        }

        private void btnReadFromJsonToUsage_Click(object sender, EventArgs e)
        {
            using var dlg = new Form
            {
                Text = "Import Usage từ JSON",
                Size = new Size(640, 480),
                StartPosition = FormStartPosition.CenterParent,
                MinimizeBox = false,
                MaximizeBox = false,
                ShowInTaskbar = false,
                FormBorderStyle = FormBorderStyle.Sizable
            };
            var txtJson = new TextBox
            {
                Multiline = true,
                ScrollBars = ScrollBars.Both,
                Dock = DockStyle.Fill,
                AcceptsReturn = true,
                AcceptsTab = true,
                Font = new Font(FontFamily.GenericMonospace, 9f),
                WordWrap = false
            };
            var bottom = new FlowLayoutPanel
            {
                Dock = DockStyle.Bottom,
                Height = 44,
                FlowDirection = FlowDirection.RightToLeft,
                Padding = new Padding(8)
            };
            var btnOk = new Button { Text = "OK", DialogResult = DialogResult.OK, Width = 88 };
            var btnCancel = new Button { Text = "Hủy", DialogResult = DialogResult.Cancel, Width = 88 };
            bottom.Controls.Add(btnOk);
            bottom.Controls.Add(btnCancel);
            dlg.Controls.Add(bottom);
            dlg.Controls.Add(txtJson);
            dlg.AcceptButton = btnOk;
            dlg.CancelButton = btnCancel;

            if (dlg.ShowDialog(this) != DialogResult.OK)
                return;

            var raw = txtJson.Text.Trim();
            if (string.IsNullOrEmpty(raw))
            {
                MessageBox.Show("Chưa nhập JSON.", "Import Usage", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                var parsed = ParseUsageItemsFromJsonText(raw);
                _usageItems = parsed;
                RefreshUsageGrid();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"JSON không hợp lệ: {ex.Message}", "Import Usage", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        /// <summary>
        /// Parse JSON thành danh sách usage: một object (một dòng usage) hoặc mảng các object.
        /// Mỗi object: các key là mã ngôn ngữ, giá trị là object có title/example (giống khi nhập tay).
        /// </summary>
        private static List<Dictionary<string, object>> ParseUsageItemsFromJsonText(string json)
        {
            var token = JToken.Parse(json);
            var list = new List<Dictionary<string, object>>();

            switch (token)
            {
                case JArray arr:
                    foreach (var item in arr)
                    {
                        if (item is not JObject obj)
                            throw new JsonException("Mỗi phần tử trong mảng phải là object.");
                        list.Add(JObjectToUsageDictionary(obj));
                    }
                    break;
                case JObject jobj:
                    list.Add(JObjectToUsageDictionary(jobj));
                    break;
                default:
                    throw new JsonException("JSON phải là object hoặc mảng các object.");
            }

            return list;
        }

        private static Dictionary<string, object> JObjectToUsageDictionary(JObject obj)
        {
            var result = new Dictionary<string, object>();
            foreach (var prop in obj.Properties())
            {
                if (prop.Value == null || prop.Value.Type == JTokenType.Null)
                    continue;

                if (prop.Value is JObject langObj)
                {
                    var inner = new Dictionary<string, string>();
                    foreach (var p in langObj.Properties())
                        inner[p.Name] = p.Value?.ToString() ?? "";
                    result[prop.Name] = inner;
                }
                else
                {
                    result[prop.Name] = prop.Value.ToString() ?? "";
                }
            }

            if (result.Count == 0)
                throw new JsonException("Một usage item phải có ít nhất một khóa ngôn ngữ.");

            return result;
        }

        private void btnTitleAddAndNext_Click(object sender, EventArgs e)
        {
            //cbLanguageCodeTitle select to next option
            if (cbLanguageCodeTitle.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageTitleValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeTitle.SelectedItem.ToString()!;
            string value = txtLanguageTitleValue.Text.Trim();

            // Update hoặc thêm mới
            _titleDictionary[languageCode] = value;

            // Refresh grid
            RefreshTitleGrid();

            // Clear input
            if (cbLanguageCodeTitle.SelectedIndex != cbLanguageCodeTitle.Items.Count - 1)
            {
                cbLanguageCodeTitle.SelectedIndex += 1;
            }
            txtLanguageTitleValue.Clear();
        }

        private void btnDescriptionAddAndNext_Click(object sender, EventArgs e)
        {
            if (cbLanguageCodeDescription.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageDescriptionValue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Description!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanguageCodeDescription.SelectedItem.ToString()!;
            string value = txtLanguageDescriptionValue.Text.Trim();

            // Update hoặc thêm mới
            _theoryDescriptionDictionary[languageCode] = value;

            // Refresh grid
            RefreshDescriptionGrid();

            if (cbLanguageCodeDescription.SelectedIndex != cbLanguageCodeDescription.Items.Count - 1)
            {
                cbLanguageCodeDescription.SelectedIndex += 1;
            }

            // Clear input
            txtLanguageDescriptionValue.Clear();

        }

        private void btnSentenceAddAndNext_Click(object sender, EventArgs e)
        {
            if (cbLanuageCodeExplanation.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageValueExplanation.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Explanation!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbLanuageCodeExplanation.SelectedItem.ToString()!;
            string value = txtLanguageValueExplanation.Text.Trim();

            // Update hoặc thêm mới vào current example explanation
            _currentExampleExplanationDictionary[languageCode] = value;

            if (cbLanuageCodeExplanation.SelectedIndex != cbLanuageCodeExplanation.Items.Count - 1)
            {
                cbLanuageCodeExplanation.SelectedIndex += 1;
            }

            // Refresh grid
            RefreshExplanationGrid();

            // Clear input
            txtLanguageValueExplanation.Clear();
        }

        private void btnHintAddAndNext_Click(object sender, EventArgs e)
        {
            if (cbHintLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtHintVaue.Text))
            {
                MessageBox.Show("Vui lòng nhập giá trị Hint!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbHintLanguageCode.SelectedItem.ToString()!;
            string value = txtHintVaue.Text.Trim();

            // Split theo newline và tạo list
            var hints = value.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries)
                .Select(s => s.Trim())
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();

            // Update hoặc thêm mới
            _hintsDictionary[languageCode] = hints;

            if (cbHintLanguageCode.SelectedIndex != cbHintLanguageCode.Items.Count - 1)
            {
                cbHintLanguageCode.SelectedIndex += 1;
            }

            // Refresh grid
            RefreshHintGrid();

            // Clear input
            txtHintVaue.Clear();
        }

        private void btnUsageAddAndNext_Click(object sender, EventArgs e)
        {
            if (cbUsageLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtUsageTitle.Text))
            {
                MessageBox.Show("Vui lòng nhập Title!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtUsageExample.Text))
            {
                MessageBox.Show("Vui lòng nhập Example!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string languageCode = cbUsageLanguageCode.SelectedItem.ToString()!;
            string title = txtUsageTitle.Text.Trim();
            string example = txtUsageExample.Text.Trim();

            // Khởi tạo _currentUsageLanguageData nếu chưa có
            if (_currentUsageLanguageData == null)
            {
                _currentUsageLanguageData = new Dictionary<string, object>();
            }

            // Thêm/update language data
            _currentUsageLanguageData[languageCode] = new Dictionary<string, string>
            {
                { "title", title },
                { "example", example }
            };

            // Refresh usage language grid
            RefreshUsageLanguageGrid();
            if (_currentUsageLanguageData.Count > 0)
            {
                var dataSource = _currentUsageLanguageData.Select(kvp =>
                {
                    var langData = kvp.Value as Dictionary<string, string>;
                    return new UsageLanguageGridItem
                    {
                        LanguageCode = kvp.Key,
                        Title = langData?.GetValueOrDefault("title") ?? "",
                        Example = langData?.GetValueOrDefault("example") ?? ""
                    };
                }).ToList();
                grvUsageLanguage.DataSource = dataSource;
            }

            if (cbUsageLanguageCode.SelectedIndex != cbUsageLanguageCode.Items.Count - 1)
            {
                cbUsageLanguageCode.SelectedIndex += 1;
            }

            // Clear inputs
            txtUsageTitle.Clear();
            //txtUsageExample.Clear();
        }

        private void btnAddTopicVocabulary_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTopicVocabularyWord.Text))
            {
                MessageBox.Show("Vui lòng nhập Word!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (cbTopicVocabularyPartOfSpeech.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Part of Speech!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (_currentTopicVocabularyItem == null || _currentTopicVocabularyItem.Definitions == null || _currentTopicVocabularyItem.Definitions.Count == 0)
            {
                MessageBox.Show("Vui lòng thêm ít nhất một Definition trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Đảm bảo Word và PartOfSpeech được cập nhật
            _currentTopicVocabularyItem.Word = txtTopicVocabularyWord.Text.Trim();
            _currentTopicVocabularyItem.PartOfSpeech = cbTopicVocabularyPartOfSpeech.SelectedItem.ToString()!;

            // Thêm item vào list
            _topicVocabularyItems.Add(_currentTopicVocabularyItem);

            // Refresh grid
            RefreshTopicVocabularyGrid();

            // Clear current item và inputs
            _currentTopicVocabularyItem = null;
            grvTopicVocabularyLanguage.DataSource = null;
            txtTopicVocabularyWord.Clear();
            cbTopicVocabularyPartOfSpeech.SelectedIndex = -1;
        }

        private void btnAddPhrasalVerb_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPhrasalVerb.Text))
            {
                MessageBox.Show("Vui lòng nhập Phrasal Verb!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (_currentPhrasalVerbItem == null || _currentPhrasalVerbItem.Definition == null || _currentPhrasalVerbItem.Definition.Count == 0)
            {
                MessageBox.Show("Vui lòng thêm ít nhất một Definition trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Đảm bảo Verb được cập nhật
            _currentPhrasalVerbItem.Verb = txtPhrasalVerb.Text.Trim();

            // Thêm item vào list
            _phrasalVerbItems.Add(_currentPhrasalVerbItem);

            // Refresh grid
            RefreshPhrasalVerbsGrid();

            // Clear current item và inputs
            _currentPhrasalVerbItem = null;
            grvPhrasalVerbLanguage.DataSource = null;
            txtPhrasalVerb.Clear();
        }

        private void btnAddPrepositionalPhraseDefinition_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPrepositionalPhrase.Text))
            {
                MessageBox.Show("Vui lòng nhập Prepositional Phrase trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (cbPrepositionalPhraseLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtPrepositionalPhraseDefinition.Text))
            {
                MessageBox.Show("Vui lòng nhập Definition!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Tạo hoặc cập nhật current item
            if (_currentPrepositionalPhraseItem == null)
            {
                _currentPrepositionalPhraseItem = new PrepositionalPhraseItem
                {
                    Phrase = txtPrepositionalPhrase.Text.Trim(),
                    Definition = new Dictionary<string, string>(),
                    Examples = new List<string>()
                };
            }
            else
            {
                // Đảm bảo Phrase được cập nhật
                _currentPrepositionalPhraseItem.Phrase = txtPrepositionalPhrase.Text.Trim();
            }

            // Thêm definition
            string languageCode = cbPrepositionalPhraseLanguageCode.SelectedItem.ToString()!;
            _currentPrepositionalPhraseItem.Definition[languageCode] = txtPrepositionalPhraseDefinition.Text.Trim();

            // Refresh language grid
            RefreshPrepositionalPhraseLanguageGrid();

            // Clear input và chuyển sang language tiếp theo
            txtPrepositionalPhraseDefinition.Clear();
            if (cbPrepositionalPhraseLanguageCode.SelectedIndex != cbPrepositionalPhraseLanguageCode.Items.Count - 1)
            {
                cbPrepositionalPhraseLanguageCode.SelectedIndex += 1;
            }
        }

        private void btnAddPrepositionalPhrase_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPrepositionalPhrase.Text))
            {
                MessageBox.Show("Vui lòng nhập Prepositional Phrase!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (_currentPrepositionalPhraseItem == null || _currentPrepositionalPhraseItem.Definition == null || _currentPrepositionalPhraseItem.Definition.Count == 0)
            {
                MessageBox.Show("Vui lòng thêm ít nhất một Definition trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Đảm bảo Phrase được cập nhật
            _currentPrepositionalPhraseItem.Phrase = txtPrepositionalPhrase.Text.Trim();

            // Thêm item vào list
            _prepositionalPhraseItems.Add(_currentPrepositionalPhraseItem);

            // Refresh grid
            RefreshPrepositionalPhrasesGrid();

            // Clear current item và inputs
            _currentPrepositionalPhraseItem = null;
            grvPrepositionalPhrase.DataSource = null;
            txtPrepositionalPhrase.Clear();
            txtPrepositionalPhraseDefinition.Clear();
            cbPrepositionalPhraseLanguageCode.SelectedIndex = -1;
        }

        private void btnAddLanguageWordDefinition_Click(object sender, EventArgs e)
        {
            if (cbWordLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtTopicVocabularyDefinition.Text))
            {
                MessageBox.Show("Vui lòng nhập Definition!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Tạo hoặc cập nhật current item
            if (_currentTopicVocabularyItem == null)
            {
                if (string.IsNullOrWhiteSpace(txtTopicVocabularyWord.Text))
                {
                    MessageBox.Show("Vui lòng nhập Word trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (cbTopicVocabularyPartOfSpeech.SelectedItem == null)
                {
                    MessageBox.Show("Vui lòng chọn Part of Speech trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                _currentTopicVocabularyItem = new TopicVocabularyItem
                {
                    Word = txtTopicVocabularyWord.Text.Trim(),
                    PartOfSpeech = cbTopicVocabularyPartOfSpeech.SelectedItem.ToString()!,
                    Definitions = new Dictionary<string, string>(),
                    Examples = new List<string>(),
                    AudioUrl = null,
                    ImageUrl = null
                };
            }

            // Thêm definition
            string languageCode = cbWordLanguageCode.SelectedItem.ToString()!;
            _currentTopicVocabularyItem.Definitions[languageCode] = txtTopicVocabularyDefinition.Text.Trim();

            // Refresh language grid
            RefreshTopicVocabularyLanguageGrid();

            // Clear input và chuyển sang language tiếp theo
            txtTopicVocabularyDefinition.Clear();
            if (cbWordLanguageCode.SelectedIndex != cbWordLanguageCode.Items.Count - 1)
            {
                cbWordLanguageCode.SelectedIndex += 1;
            }
        }

        private void btnAddPhrasaVerbLanguageDefinition_Click(object sender, EventArgs e)
        {
            if (cbPhrasalVerbLanguageCode.SelectedItem == null)
            {
                MessageBox.Show("Vui lòng chọn Language Code!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtPhrasalVerbDefinition.Text))
            {
                MessageBox.Show("Vui lòng nhập Definition!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Tạo hoặc cập nhật current item
            if (_currentPhrasalVerbItem == null)
            {
                if (string.IsNullOrWhiteSpace(txtPhrasalVerb.Text))
                {
                    MessageBox.Show("Vui lòng nhập Phrasal Verb trước!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                _currentPhrasalVerbItem = new PhrasalVerbItem
                {
                    Verb = txtPhrasalVerb.Text.Trim(),
                    Definition = new Dictionary<string, string>(),
                    Examples = new List<string>()
                };
            }

            // Thêm definition
            string languageCode = cbPhrasalVerbLanguageCode.SelectedItem.ToString()!;
            _currentPhrasalVerbItem.Definition[languageCode] = txtPhrasalVerbDefinition.Text.Trim();

            // Refresh language grid
            RefreshPhrasalVerbLanguageGrid();

            // Clear input và chuyển sang language tiếp theo
            txtPhrasalVerbDefinition.Clear();
            if (cbPhrasalVerbLanguageCode.SelectedIndex != cbPhrasalVerbLanguageCode.Items.Count - 1)
            {
                cbPhrasalVerbLanguageCode.SelectedIndex += 1;
            }
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            openFileDialog1.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*";
            openFileDialog1.Title = "Chọn file vocabulary JSON";
            openFileDialog1.FileName = "";
            if (openFileDialog1.ShowDialog() != DialogResult.OK)
                return;

            try
            {
                string path = openFileDialog1.FileName;
                txtFileJson.Text = path;
                string raw = File.ReadAllText(path, Encoding.UTF8);
                var token = JToken.Parse(raw);
                txtJsonText.Text = token.ToString(Formatting.Indented);
                _ = ParseVocabularyFromText(txtJsonText.Text);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Không đọc hoặc không hợp lệ JSON vocabulary: {ex.Message}",
                    "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        /// <summary>
        /// Nội dung vocabulary đưa vào lesson khi export: có txtJsonText thì parse từ đó, ngược lại dùng grid.
        /// </summary>
        private VocabularyContent? BuildVocabularyContentForExport()
        {
            if (!string.IsNullOrWhiteSpace(txtJsonText.Text))
            {
                var fromJson = ParseVocabularyFromText(txtJsonText.Text);
                return HasAnyVocabularySection(fromJson) ? fromJson : null;
            }

            var vocabulary = new VocabularyContent();
            if (_topicVocabularyItems.Count > 0)
                vocabulary.TopicVocabulary = _topicVocabularyItems;
            if (_phrasalVerbItems.Count > 0)
                vocabulary.PhrasalVerbs = _phrasalVerbItems;
            if (_prepositionalPhraseItems.Count > 0)
                vocabulary.PrepositionalPhrases = _prepositionalPhraseItems;

            return HasAnyVocabularySection(vocabulary) ? vocabulary : null;
        }

        private static bool HasAnyVocabularySection(VocabularyContent v)
        {
            return (v.TopicVocabulary?.Count > 0) == true
                || (v.PhrasalVerbs?.Count > 0) == true
                || (v.PrepositionalPhrases?.Count > 0) == true
                || (v.WordFormation?.Count > 0) == true
                || (v.WordPatterns?.Count > 0) == true;
        }

        /// <summary>
        /// Hỗ trợ file dạng vocabulary_full.json (root "vocabulary") hoặc object vocabulary trần.
        /// Phrasal verb trong file có thể để "verb" bên trong "definition" — chuẩn hóa về PhrasalVerbItem.
        /// </summary>
        private static VocabularyContent ParseVocabularyFromText(string text)
        {
            var root = JToken.Parse(text);
            JToken? vocabNode = root["vocabulary"];
            if (vocabNode == null &&
                (root["topicVocabulary"] != null || root["phrasalVerbs"] != null ||
                 root["prepositionalPhrases"] != null || root["wordFormation"] != null ||
                 root["wordPatterns"] != null))
            {
                vocabNode = root;
            }

            if (vocabNode == null || vocabNode.Type == JTokenType.Null)
                throw new InvalidOperationException("Thiếu khóa \"vocabulary\" hoặc không nhận dạng được cấu trúc vocabulary.");

            var content = vocabNode.ToObject<VocabularyContent>()
                ?? throw new InvalidOperationException("Không deserialize được VocabularyContent.");
            NormalizePhrasalVerbsFromDefinitionVerb(content);
            return content;
        }

        private static void NormalizePhrasalVerbsFromDefinitionVerb(VocabularyContent content)
        {
            if (content.PhrasalVerbs == null)
                return;

            foreach (var item in content.PhrasalVerbs)
            {
                if (item.Definition == null)
                    continue;
                if (item.Definition.TryGetValue("verb", out string? verbInDef) && !string.IsNullOrWhiteSpace(verbInDef))
                {
                    if (string.IsNullOrWhiteSpace(item.Verb))
                        item.Verb = verbInDef.Trim();
                    item.Definition.Remove("verb");
                }
            }
        }
    }
}
