// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'ホーム';

  @override
  String get practice => '練習';

  @override
  String get progress => '進捗';

  @override
  String get settings => '設定';

  @override
  String get welcomeBack => 'おかえりなさい';

  @override
  String get welcome => 'Sarah Eduへようこそ';

  @override
  String get whatToLearnToday => '今日は何を学びたいですか？';

  @override
  String get daysStreak => '連続日数';

  @override
  String get levels => 'レベル';

  @override
  String get continueLearning => '学習を続ける';

  @override
  String get loginToSync => '進捗を保存してデータを同期するにはログインしてください';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get loginWithGoogle => 'Googleでログイン';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get registerNow => '今すぐ登録';

  @override
  String get createAccountTitle => 'Create a new account';

  @override
  String get createAccountSubtitle => 'Fill in your details to start learning';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter password (at least 6 characters)';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get validationNameRequired => 'Please enter your name';

  @override
  String get validationEmailRequired => 'Please enter your email';

  @override
  String get validationEmailInvalid => 'Invalid email';

  @override
  String get validationPasswordRequired => 'Please enter your password';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 6 characters';

  @override
  String get validationConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get name => '名前';

  @override
  String get accountInfo => 'アカウント情報';

  @override
  String get notifications => '通知';

  @override
  String get language => '言語';

  @override
  String get theme => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get help => 'ヘルプ';

  @override
  String get about => 'について';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => 'ログアウトしますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get stats => '統計';

  @override
  String get units => 'ユニット';

  @override
  String get lessons => 'レッスン';

  @override
  String get exercises => '練習問題';

  @override
  String reviewExerciseWithIndex(int number) {
    return '復習 $number';
  }

  @override
  String get exerciseDetails => '練習問題の詳細';

  @override
  String get viewDetails => '詳細を見る';

  @override
  String position(int number) {
    return '位置 $number';
  }

  @override
  String youChose(String answer) {
    return '選択した答え: $answer';
  }

  @override
  String get youHaventChosen => '選択していません';

  @override
  String correctAnswer(String answer) {
    return '正解: $answer';
  }

  @override
  String youFilled(String answer) {
    return '入力した答え: \"$answer\"';
  }

  @override
  String get youHaventFilled => '入力していません';

  @override
  String get theory => '理論';

  @override
  String get examples => '例';

  @override
  String get usage => '使い方';

  @override
  String get forms => '形式';

  @override
  String get affirmative => '肯定';

  @override
  String get negative => '否定';

  @override
  String get interrogative => '疑問';

  @override
  String get grammarForm => '形式';

  @override
  String get minutes => '分';

  @override
  String get hours => '時間';

  @override
  String get submit => '提出';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => '正解です！';

  @override
  String get incorrect => '不正解です！';

  @override
  String get perfect => '完璧!';

  @override
  String get goodJob => 'よくできました!';

  @override
  String get needToTryHarder => 'もっと頑張りましょう!';

  @override
  String question(int number) {
    return '問題 $number';
  }

  @override
  String get explanation => '説明';

  @override
  String get points => 'ポイント';

  @override
  String get youGot => '獲得ポイント';

  @override
  String get back => '戻る';

  @override
  String get selectOne => '1つ選択';

  @override
  String get selectMultiple => 'すべての正解を選択';

  @override
  String get fillBlank => '空欄を埋める';

  @override
  String get matching => 'マッチング';

  @override
  String get matchItems => '項目を一致させてください';

  @override
  String get crossword => 'クロスワード';

  @override
  String get easy => '簡単';

  @override
  String get medium => '普通';

  @override
  String get hard => '難しい';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String get unlock => 'ロック解除';

  @override
  String get locked => 'ロック済み';

  @override
  String get welcomeTitle1 => 'Sarah Eduへようこそ';

  @override
  String get welcomeDescription1 => '構造化されたレッスンとインタラクティブな練習でA1からC2まで英語を学びましょう';

  @override
  String get welcomeTitle2 => '進捗を追跡';

  @override
  String get welcomeDescription2 => '学習の旅を監視し、強みと弱みを特定し、継続的に改善しましょう';

  @override
  String get welcomeTitle3 => '言語を選択';

  @override
  String get welcomeDescription3 => 'アプリインターフェースに希望する言語を選択してください';

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get skip => 'スキップ';

  @override
  String get getStarted => '始める';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get sentenceForms => '文の形式';

  @override
  String get howToUse => '使い方';

  @override
  String get lessonsList => 'レッスン';

  @override
  String lessonNumber(int number) {
    return 'レッスン $number';
  }

  @override
  String get noLessons => 'レッスンがありません';

  @override
  String get noUnits => 'ユニットがありません';

  @override
  String get noExercises => '練習問題がありません';

  @override
  String exercisesCount(int count) {
    return '$count個の練習問題';
  }

  @override
  String lessonsCount(int count) {
    return '$count個のレッスン';
  }

  @override
  String get errorLoadingExercises => '練習問題の読み込みエラー';

  @override
  String get exerciseTypeNotSupported => 'この練習タイプはまだサポートされていません';

  @override
  String get selectOneAnswer => '正解を1つ選択';

  @override
  String get selectAllCorrectAnswers => 'すべての正解を選択';

  @override
  String youGotPoints(int points) {
    return '$pointsポイントを獲得しました';
  }

  @override
  String get selectOneAnswerShort => '1つ選択';

  @override
  String get selectMultipleAnswersShort => '複数選択';

  @override
  String get listening => 'リスニング';

  @override
  String get grammar => '文法';

  @override
  String get reading => 'リーディング';

  @override
  String get speaking => 'スピーキング';

  @override
  String get progressTitle => '学習進捗';

  @override
  String get featureInDevelopment => '開発中の機能';

  @override
  String get progressDescription => '統計、弱点、\nチャートがまもなく利用可能になります';

  @override
  String get practiceDescription => 'AI練習とカスタム練習が\nまもなく利用可能になります';

  @override
  String get learningProgress => '学習進捗';

  @override
  String get loginToSaveProgress => 'ログインして学習進捗を保存し\n複数のデバイスで同期します';

  @override
  String get currentLevel => '現在のレベル';

  @override
  String get unitsCompleted => '完了したユニット';

  @override
  String get placementTest => 'プレースメントテスト';

  @override
  String get placementTestResult => 'テスト結果';

  @override
  String get placementTestTitle => 'レベル評価テストを受ける';

  @override
  String get placementTestDescription => '英語レベルを確認し、適切なレベルの推奨を受け取る';

  @override
  String get vocabulary => '語彙';

  @override
  String get vocabularyFilterLabel => 'Filter:';

  @override
  String get vocabularySearchHint => 'Search vocabulary/definition';

  @override
  String get vocabularyNoMatch => 'No matching vocabulary';

  @override
  String get vocabularySortWordAsc => 'A-Z';

  @override
  String get vocabularySortWordDesc => 'Z-A';

  @override
  String get vocabularySortDefinitionAsc => 'Def A-Z';

  @override
  String get vocabularySortDefinitionDesc => 'Def Z-A';

  @override
  String get practiceVocabularyTitle => 'Practice Vocabulary';

  @override
  String get practiceVocabularyEmpty => 'No vocabulary to practice';

  @override
  String get vocabularySearchDictionaryHint => 'Search your dictionary...';

  @override
  String get vocabularyRecentMasteries => 'RECENT MASTERIES';

  @override
  String get vocabularyChipVerbs => 'Verbs';

  @override
  String get vocabularyChipNouns => 'Nouns';

  @override
  String get vocabularyChipIdioms => 'Idioms';

  @override
  String get vocabularyChipWeakWords => 'Weak Words';

  @override
  String get vocabularyWeakWordsEmpty => 'No weak words yet. Keep practicing!';

  @override
  String get vocabularyWordOfTheDay => 'Word of the Day';

  @override
  String vocabularyWordOfTheDayBody(String word) {
    return 'Master \"$word\" and earn triple points in today\'s challenge.';
  }

  @override
  String get vocabularyExplore => 'EXPLORE';

  @override
  String get vocabularyLoadMore => 'さらに表示';

  @override
  String get vocabularyReviewSoon => 'REVIEW SOON';

  @override
  String get vocabularySort => 'Sort';

  @override
  String get vocabularyFlashcardCurrentSession => 'CURRENT SESSION';

  @override
  String get vocabularyFlashcardWordOfTheMoment => 'WORD OF THE MOMENT';

  @override
  String get vocabularyFlashcardTapToFlip => 'Tap to flip definition';

  @override
  String get vocabularyFlashcardStillLearning => 'STILL LEARNING';

  @override
  String get vocabularyFlashcardGotIt => 'GOT IT';

  @override
  String get vocabularyFlashcardSyncing => 'Syncing vocabulary…';

  @override
  String get vocabularyFlashcardSyncFailed =>
      'Could not sync vocabulary. Will retry later.';

  @override
  String get flashcardTapShowWord => 'Tap to show word';

  @override
  String get flashcardTapShowDefinition => 'Tap to show definition';

  @override
  String get weakSkills => '苦手なスキル';

  @override
  String get overview => '概要';

  @override
  String get featureComingSoon => '機能は間もなく公開されます';

  @override
  String get all => 'すべて';

  @override
  String get review => '復習';

  @override
  String get continuePractice => '練習を続ける';

  @override
  String get pleaseLoginToUseFeature => 'この機能を使用するにはログインしてください';

  @override
  String get pleaseLogin => 'ログインしてください';

  @override
  String get loginToUseReviewFeature => '復習機能を使用するにはログインしてください';

  @override
  String reviewLevel(String level) {
    return '復習 - $level';
  }

  @override
  String get congratulations => 'おめでとうございます！';

  @override
  String youReachedLevel(String level) {
    return 'レベル $level に到達しました！';
  }

  @override
  String get continueLearningToImprove => 'レベルを向上させるために学習を続けましょう';

  @override
  String get currentLevelText => '現在のレベル';

  @override
  String get completed => '完了';

  @override
  String get notUnlocked => 'ロック解除されていません';

  @override
  String get reviewLevelNotAvailable =>
      'This level is not available for review yet.';

  @override
  String get continueButton => '続ける';

  @override
  String get xp => 'XP';

  @override
  String get levelLabel => 'レベル';

  @override
  String get user => 'ユーザー';

  @override
  String completedExercises(int completed, int total) {
    return 'Completed: $completed/$total exercises';
  }

  @override
  String get progressSaved => 'Learning progress saved';

  @override
  String errorSavingProgress(String error) {
    return 'Error saving progress: $error';
  }

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get allLessonsCompleted => 'You have completed all lessons!';

  @override
  String get noProgressData => 'No progress data available.';

  @override
  String get noWeakSkillsData => 'No weak skills data available.';

  @override
  String get skills => 'Skills';

  @override
  String get topics => 'Topics';

  @override
  String get noData => 'No data available.';

  @override
  String correctPercent(int percent, int attempts) {
    return 'Correct $percent% • $attempts attempts';
  }

  @override
  String get practiceSuggestions => 'Practice Suggestions';

  @override
  String get noSuggestions => 'No suggestions available.';

  @override
  String get loginToSaveResult => 'Login to save result';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get enterEmailForReset =>
      'Enter your email to receive password reset link';

  @override
  String get emailSent => 'Email sent!';

  @override
  String get checkEmailInstructions =>
      'Please check your inbox and follow the instructions in the email.';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get sendPasswordResetEmail => 'Send password reset email';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get selectCorrectForm => 'Select the correct form';

  @override
  String completeSentenceWithForm(String word) {
    return 'Complete the sentence with the correct form of \"$word\"';
  }

  @override
  String get levelSkipTest => 'レベルスキップテスト';

  @override
  String skipToLevel(String level) {
    return '$levelにスキップ';
  }

  @override
  String get dailyLimitReached => '本日はすでにテストを受けています。明日再度お試しください。';

  @override
  String levelUnlocked(String level) {
    return 'レベル$levelがロック解除されました！';
  }

  @override
  String get testFailed => 'テスト失敗';

  @override
  String get testFailedMessage => 'テスト失敗。レベルをロック解除するには、少なくとも80%が必要です。';

  @override
  String get noQuestionsAvailable => '質問がありません';

  @override
  String questionNumber(int current, int total) {
    return '質問 $current / $total';
  }

  @override
  String get practiceSessionHeading => 'Practice Session';

  @override
  String sessionProgressPercent(int percent) {
    return '$percent% Progress';
  }

  @override
  String get newSkillBadge => 'NEW SKILL';

  @override
  String get lessonCapsLabel => 'LESSON';

  @override
  String get ok => 'OK';

  @override
  String get grammarNoteTitle => 'Grammar Note';

  @override
  String get buttonSingleChoiceTapHint => 'Tap a word...';

  @override
  String get fillBlankNeedHint => 'Need a hint?';
}
