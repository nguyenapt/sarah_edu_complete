// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'होम';

  @override
  String get practice => 'अभ्यास';

  @override
  String get progress => 'प्रगति';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get welcome => 'Sarah Edu में आपका स्वागत है';

  @override
  String get whatToLearnToday => 'आज आप क्या सीखना चाहेंगे?';

  @override
  String get daysStreak => 'लगातार दिन';

  @override
  String get levels => 'स्तर';

  @override
  String get continueLearning => 'सीखना जारी रखें';

  @override
  String get loginToSync => 'प्रगति सहेजने और डेटा सिंक करने के लिए लॉगिन करें';

  @override
  String get login => 'लॉगिन';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get loginWithGoogle => 'Google के साथ लॉगिन करें';

  @override
  String get dontHaveAccount => 'खाता नहीं है?';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है?';

  @override
  String get registerNow => 'अभी रजिस्टर करें';

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
  String get name => 'नाम';

  @override
  String get accountInfo => 'खाता जानकारी';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get language => 'भाषा';

  @override
  String get theme => 'थीम';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get help => 'मदद';

  @override
  String get about => 'के बारे में';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirm => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get stats => 'आंकड़े';

  @override
  String get units => 'इकाइयां';

  @override
  String get lessons => 'पाठ';

  @override
  String get exercises => 'अभ्यास';

  @override
  String get exerciseDetails => 'अभ्यास विवरण';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String position(int number) {
    return 'स्थिति $number';
  }

  @override
  String youChose(String answer) {
    return 'आपने चुना: $answer';
  }

  @override
  String get youHaventChosen => 'आपने चयन नहीं किया';

  @override
  String correctAnswer(String answer) {
    return 'सही उत्तर: $answer';
  }

  @override
  String youFilled(String answer) {
    return 'आपने भरा: \"$answer\"';
  }

  @override
  String get youHaventFilled => 'आपने नहीं भरा';

  @override
  String get theory => 'सिद्धांत';

  @override
  String get examples => 'उदाहरण';

  @override
  String get usage => 'उपयोग';

  @override
  String get forms => 'रूप';

  @override
  String get affirmative => 'सकारात्मक';

  @override
  String get negative => 'नकारात्मक';

  @override
  String get interrogative => 'प्रश्नवाचक';

  @override
  String get minutes => 'मिनट';

  @override
  String get hours => 'घंटे';

  @override
  String get submit => 'जमा करें';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => 'सही!';

  @override
  String get incorrect => 'गलत!';

  @override
  String get perfect => 'बिल्कुल सही!';

  @override
  String get goodJob => 'बहुत बढ़िया!';

  @override
  String get needToTryHarder => 'और मेहनत करनी होगी!';

  @override
  String question(int number) {
    return 'प्रश्न $number';
  }

  @override
  String get explanation => 'व्याख्या';

  @override
  String get points => 'अंक';

  @override
  String get youGot => 'आपको मिले';

  @override
  String get back => 'वापस';

  @override
  String get selectOne => 'एक उत्तर चुनें';

  @override
  String get selectMultiple => 'सभी सही उत्तर चुनें';

  @override
  String get fillBlank => 'रिक्त स्थान भरें';

  @override
  String get matching => 'मिलान';

  @override
  String get matchItems => 'वस्तुओं को मिलाएँ';

  @override
  String get crossword => 'क्रॉसवर्ड';

  @override
  String get easy => 'आसान';

  @override
  String get medium => 'मध्यम';

  @override
  String get hard => 'कठिन';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get unlock => 'अनलॉक करें';

  @override
  String get locked => 'लॉक किया गया';

  @override
  String get welcomeTitle1 => 'Sarah Edu में आपका स्वागत है';

  @override
  String get welcomeDescription1 =>
      'संरचित पाठ और इंटरैक्टिव अभ्यास के साथ A1 से C2 तक अंग्रेजी सीखें';

  @override
  String get welcomeTitle2 => 'अपनी प्रगति को ट्रैक करें';

  @override
  String get welcomeDescription2 =>
      'अपनी सीखने की यात्रा की निगरानी करें, ताकत और कमजोरियों की पहचान करें, और लगातार सुधार करें';

  @override
  String get welcomeTitle3 => 'अपनी भाषा चुनें';

  @override
  String get welcomeDescription3 => 'ऐप इंटरफेस के लिए अपनी पसंदीदा भाषा चुनें';

  @override
  String get next => 'अगला';

  @override
  String get previous => 'पिछला';

  @override
  String get skip => 'छोड़ें';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get sentenceForms => 'वाक्य रूप';

  @override
  String get howToUse => 'कैसे उपयोग करें';

  @override
  String get lessonsList => 'पाठ सूची';

  @override
  String lessonNumber(int number) {
    return 'पाठ $number';
  }

  @override
  String get noLessons => 'कोई पाठ उपलब्ध नहीं';

  @override
  String get noUnits => 'कोई इकाई उपलब्ध नहीं';

  @override
  String get noExercises => 'कोई अभ्यास उपलब्ध नहीं';

  @override
  String exercisesCount(int count) {
    return '$count अभ्यास';
  }

  @override
  String lessonsCount(int count) {
    return '$count पाठ';
  }

  @override
  String get errorLoadingExercises => 'अभ्यास लोड करने में त्रुटि';

  @override
  String get exerciseTypeNotSupported =>
      'इस प्रकार का अभ्यास अभी तक समर्थित नहीं है';

  @override
  String get selectOneAnswer => 'एक सही उत्तर चुनें';

  @override
  String get selectAllCorrectAnswers => 'सभी सही उत्तर चुनें';

  @override
  String youGotPoints(int points) {
    return 'आपको $points अंक मिले';
  }

  @override
  String get selectOneAnswerShort => '1 उत्तर चुनें';

  @override
  String get selectMultipleAnswersShort => 'कई उत्तर चुनें';

  @override
  String get listening => 'सुनना';

  @override
  String get grammar => 'व्याकरण';

  @override
  String get reading => 'पढ़ना';

  @override
  String get speaking => 'बोलना';

  @override
  String get progressTitle => 'सीखने की प्रगति';

  @override
  String get featureInDevelopment => 'विकास में सुविधा';

  @override
  String get progressDescription =>
      'आंकड़े, कमजोरियां और\nचार्ट जल्द ही उपलब्ध होंगे';

  @override
  String get practiceDescription =>
      'AI अभ्यास और कस्टम अभ्यास\nजल्द ही उपलब्ध होंगे';

  @override
  String get learningProgress => 'सीखने की प्रगति';

  @override
  String get loginToSaveProgress =>
      'अपनी प्रगति सहेजने और\nकई उपकरणों पर सिंक करने के लिए लॉगिन करें';

  @override
  String get currentLevel => 'वर्तमान स्तर';

  @override
  String get unitsCompleted => 'पूर्ण इकाइयाँ';

  @override
  String get placementTest => 'प्लेसमेंट टेस्ट';

  @override
  String get placementTestResult => 'टेस्ट परिणाम';

  @override
  String get placementTestTitle => 'स्तर मूल्यांकन परीक्षा लें';

  @override
  String get placementTestDescription =>
      'अपने अंग्रेजी स्तर की जांच करें और उपयुक्त स्तर की सिफारिशें प्राप्त करें';

  @override
  String get vocabulary => 'शब्दावली';

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
  String get flashcardTapShowWord => 'Tap to show word';

  @override
  String get flashcardTapShowDefinition => 'Tap to show definition';

  @override
  String get weakSkills => 'कमजोर कौशल';

  @override
  String get overview => 'अवलोकन';

  @override
  String get featureComingSoon => 'जल्द ही सुविधा आ रही है';

  @override
  String get all => 'सभी';

  @override
  String get review => 'समीक्षा';

  @override
  String get continuePractice => 'अभ्यास जारी रखें';

  @override
  String get pleaseLoginToUseFeature =>
      'कृपया इस सुविधा का उपयोग करने के लिए लॉगिन करें';

  @override
  String get pleaseLogin => 'कृपया लॉगिन करें';

  @override
  String get loginToUseReviewFeature =>
      'समीक्षा सुविधा का उपयोग करने के लिए लॉगिन करें';

  @override
  String reviewLevel(String level) {
    return 'समीक्षा - $level';
  }

  @override
  String get congratulations => 'बधाई हो!';

  @override
  String youReachedLevel(String level) {
    return 'आपने स्तर $level तक पहुंच गए हैं!';
  }

  @override
  String get continueLearningToImprove =>
      'अपने स्तर को सुधारने के लिए सीखना जारी रखें';

  @override
  String get currentLevelText => 'वर्तमान स्तर';

  @override
  String get completed => 'पूर्ण';

  @override
  String get notUnlocked => 'अनलॉक नहीं किया गया';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get xp => 'XP';

  @override
  String get levelLabel => 'स्तर';

  @override
  String get user => 'उपयोगकर्ता';

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
  String get levelSkipTest => 'स्तर छोड़ें परीक्षण';

  @override
  String skipToLevel(String level) {
    return '$level पर जाएं';
  }

  @override
  String get dailyLimitReached =>
      'आपने आज पहले से ही परीक्षण दिया है। कृपया कल पुनः प्रयास करें।';

  @override
  String levelUnlocked(String level) {
    return 'स्तर $level अनलॉक हो गया!';
  }

  @override
  String get testFailed => 'परीक्षण असफल';

  @override
  String get testFailedMessage =>
      'परीक्षण असफल। स्तर को अनलॉक करने के लिए आपको कम से कम 80% की आवश्यकता है।';

  @override
  String get noQuestionsAvailable => 'कोई प्रश्न उपलब्ध नहीं';

  @override
  String questionNumber(int current, int total) {
    return 'प्रश्न $current / $total';
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
  String get ok => 'ठीक';

  @override
  String get grammarNoteTitle => 'Grammar Note';

  @override
  String get buttonSingleChoiceTapHint => 'Tap a word...';

  @override
  String get fillBlankNeedHint => 'Need a hint?';
}
