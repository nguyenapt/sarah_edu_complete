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
  String get minutes => '分';

  @override
  String get hours => '時間';

  @override
  String get submit => '提出';

  @override
  String get correct => '正解です！';

  @override
  String get incorrect => '不正解です！';

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
  String get lessonsList => 'レッスン一覧';

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
  String get weakSkills => '苦手なスキル';

  @override
  String get overview => '概要';

  @override
  String get featureComingSoon => '機能は間もなく公開されます';

  @override
  String get all => 'すべて';
}
