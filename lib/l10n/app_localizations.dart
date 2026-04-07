import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sarah Edu'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sarah Edu'**
  String get welcome;

  /// No description provided for @whatToLearnToday.
  ///
  /// In en, this message translates to:
  /// **'What would you like to learn today?'**
  String get whatToLearnToday;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'Days streak'**
  String get daysStreak;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @loginToSync.
  ///
  /// In en, this message translates to:
  /// **'Login to save progress and sync data'**
  String get loginToSync;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to start learning'**
  String get createAccountSubtitle;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password (at least 6 characters)'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get validationNameRequired;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordMinLength;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @exerciseDetails.
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetails;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position {number}'**
  String position(int number);

  /// No description provided for @youChose.
  ///
  /// In en, this message translates to:
  /// **'You chose: {answer}'**
  String youChose(String answer);

  /// No description provided for @youHaventChosen.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t chosen'**
  String get youHaventChosen;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswer(String answer);

  /// No description provided for @youFilled.
  ///
  /// In en, this message translates to:
  /// **'You filled: \"{answer}\"'**
  String youFilled(String answer);

  /// No description provided for @youHaventFilled.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t filled'**
  String get youHaventFilled;

  /// No description provided for @theory.
  ///
  /// In en, this message translates to:
  /// **'Theory'**
  String get theory;

  /// No description provided for @examples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get examples;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @forms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get forms;

  /// No description provided for @affirmative.
  ///
  /// In en, this message translates to:
  /// **'Affirmative'**
  String get affirmative;

  /// No description provided for @negative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get negative;

  /// No description provided for @interrogative.
  ///
  /// In en, this message translates to:
  /// **'Interrogative'**
  String get interrogative;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrect;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get perfect;

  /// No description provided for @goodJob.
  ///
  /// In en, this message translates to:
  /// **'Good job!'**
  String get goodJob;

  /// No description provided for @needToTryHarder.
  ///
  /// In en, this message translates to:
  /// **'Need to try harder!'**
  String get needToTryHarder;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String question(int number);

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @youGot.
  ///
  /// In en, this message translates to:
  /// **'You got'**
  String get youGot;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @selectOne.
  ///
  /// In en, this message translates to:
  /// **'Select one answer'**
  String get selectOne;

  /// No description provided for @selectMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select all correct answers'**
  String get selectMultiple;

  /// No description provided for @fillBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blanks'**
  String get fillBlank;

  /// No description provided for @matching.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get matching;

  /// No description provided for @matchItems.
  ///
  /// In en, this message translates to:
  /// **'Match the items'**
  String get matchItems;

  /// No description provided for @crossword.
  ///
  /// In en, this message translates to:
  /// **'Crossword'**
  String get crossword;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @welcomeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sarah Edu'**
  String get welcomeTitle1;

  /// No description provided for @welcomeDescription1.
  ///
  /// In en, this message translates to:
  /// **'Learn English from A1 to C2 with structured lessons and interactive exercises'**
  String get welcomeDescription1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get welcomeTitle2;

  /// No description provided for @welcomeDescription2.
  ///
  /// In en, this message translates to:
  /// **'Monitor your learning journey, identify strengths and weaknesses, and improve continuously'**
  String get welcomeDescription2;

  /// No description provided for @welcomeTitle3.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get welcomeTitle3;

  /// No description provided for @welcomeDescription3.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app interface'**
  String get welcomeDescription3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @sentenceForms.
  ///
  /// In en, this message translates to:
  /// **'Sentence Forms'**
  String get sentenceForms;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @lessonsList.
  ///
  /// In en, this message translates to:
  /// **'Lessons List'**
  String get lessonsList;

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonNumber(int number);

  /// No description provided for @noLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons available'**
  String get noLessons;

  /// No description provided for @noUnits.
  ///
  /// In en, this message translates to:
  /// **'No units available'**
  String get noUnits;

  /// No description provided for @noExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises available'**
  String get noExercises;

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercisesCount(int count);

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String lessonsCount(int count);

  /// No description provided for @errorLoadingExercises.
  ///
  /// In en, this message translates to:
  /// **'Error loading exercises'**
  String get errorLoadingExercises;

  /// No description provided for @exerciseTypeNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This exercise type is not supported'**
  String get exerciseTypeNotSupported;

  /// No description provided for @selectOneAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select one correct answer'**
  String get selectOneAnswer;

  /// No description provided for @selectAllCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Select all correct answers'**
  String get selectAllCorrectAnswers;

  /// No description provided for @youGotPoints.
  ///
  /// In en, this message translates to:
  /// **'You got {points} points'**
  String youGotPoints(int points);

  /// No description provided for @selectOneAnswerShort.
  ///
  /// In en, this message translates to:
  /// **'Select 1 answer'**
  String get selectOneAnswerShort;

  /// No description provided for @selectMultipleAnswersShort.
  ///
  /// In en, this message translates to:
  /// **'Select multiple answers'**
  String get selectMultipleAnswersShort;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get listening;

  /// No description provided for @grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammar;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get speaking;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Progress'**
  String get progressTitle;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get featureInDevelopment;

  /// No description provided for @progressDescription.
  ///
  /// In en, this message translates to:
  /// **'Statistics, weaknesses and\ncharts will be available soon'**
  String get progressDescription;

  /// No description provided for @practiceDescription.
  ///
  /// In en, this message translates to:
  /// **'AI Practice and Custom Practice\nwill be available soon'**
  String get practiceDescription;

  /// No description provided for @learningProgress.
  ///
  /// In en, this message translates to:
  /// **'Learning Progress'**
  String get learningProgress;

  /// No description provided for @loginToSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Login to save learning progress and\nsync across multiple devices'**
  String get loginToSaveProgress;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @unitsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Units Completed'**
  String get unitsCompleted;

  /// No description provided for @placementTest.
  ///
  /// In en, this message translates to:
  /// **'Placement Test'**
  String get placementTest;

  /// No description provided for @placementTestResult.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get placementTestResult;

  /// No description provided for @placementTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a level assessment test'**
  String get placementTestTitle;

  /// No description provided for @placementTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your English level and receive appropriate level recommendations'**
  String get placementTestDescription;

  /// No description provided for @vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabulary;

  /// No description provided for @vocabularyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get vocabularyFilterLabel;

  /// No description provided for @vocabularySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search vocabulary/definition'**
  String get vocabularySearchHint;

  /// No description provided for @vocabularyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching vocabulary'**
  String get vocabularyNoMatch;

  /// No description provided for @vocabularySortWordAsc.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get vocabularySortWordAsc;

  /// No description provided for @vocabularySortWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get vocabularySortWordDesc;

  /// No description provided for @vocabularySortDefinitionAsc.
  ///
  /// In en, this message translates to:
  /// **'Def A-Z'**
  String get vocabularySortDefinitionAsc;

  /// No description provided for @vocabularySortDefinitionDesc.
  ///
  /// In en, this message translates to:
  /// **'Def Z-A'**
  String get vocabularySortDefinitionDesc;

  /// No description provided for @practiceVocabularyTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Vocabulary'**
  String get practiceVocabularyTitle;

  /// No description provided for @practiceVocabularyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary to practice'**
  String get practiceVocabularyEmpty;

  /// No description provided for @flashcardTapShowWord.
  ///
  /// In en, this message translates to:
  /// **'Tap to show word'**
  String get flashcardTapShowWord;

  /// No description provided for @flashcardTapShowDefinition.
  ///
  /// In en, this message translates to:
  /// **'Tap to show definition'**
  String get flashcardTapShowDefinition;

  /// No description provided for @weakSkills.
  ///
  /// In en, this message translates to:
  /// **'Weak Skills'**
  String get weakSkills;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @continuePractice.
  ///
  /// In en, this message translates to:
  /// **'Continue Practice'**
  String get continuePractice;

  /// No description provided for @pleaseLoginToUseFeature.
  ///
  /// In en, this message translates to:
  /// **'Please login to use this feature'**
  String get pleaseLoginToUseFeature;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaseLogin;

  /// No description provided for @loginToUseReviewFeature.
  ///
  /// In en, this message translates to:
  /// **'Login to use review feature'**
  String get loginToUseReviewFeature;

  /// No description provided for @reviewLevel.
  ///
  /// In en, this message translates to:
  /// **'Review - {level}'**
  String reviewLevel(String level);

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @youReachedLevel.
  ///
  /// In en, this message translates to:
  /// **'You reached level {level}!'**
  String youReachedLevel(String level);

  /// No description provided for @continueLearningToImprove.
  ///
  /// In en, this message translates to:
  /// **'Continue learning to improve your level'**
  String get continueLearningToImprove;

  /// No description provided for @currentLevelText.
  ///
  /// In en, this message translates to:
  /// **'Current level'**
  String get currentLevelText;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @notUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Not unlocked'**
  String get notUnlocked;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @completedExercises.
  ///
  /// In en, this message translates to:
  /// **'Completed: {completed}/{total} exercises'**
  String completedExercises(int completed, int total);

  /// No description provided for @progressSaved.
  ///
  /// In en, this message translates to:
  /// **'Learning progress saved'**
  String get progressSaved;

  /// No description provided for @errorSavingProgress.
  ///
  /// In en, this message translates to:
  /// **'Error saving progress: {error}'**
  String errorSavingProgress(String error);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @allLessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'You have completed all lessons!'**
  String get allLessonsCompleted;

  /// No description provided for @noProgressData.
  ///
  /// In en, this message translates to:
  /// **'No progress data available.'**
  String get noProgressData;

  /// No description provided for @noWeakSkillsData.
  ///
  /// In en, this message translates to:
  /// **'No weak skills data available.'**
  String get noWeakSkillsData;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noData;

  /// No description provided for @correctPercent.
  ///
  /// In en, this message translates to:
  /// **'Correct {percent}% • {attempts} attempts'**
  String correctPercent(int percent, int attempts);

  /// No description provided for @practiceSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Practice Suggestions'**
  String get practiceSuggestions;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions available.'**
  String get noSuggestions;

  /// No description provided for @loginToSaveResult.
  ///
  /// In en, this message translates to:
  /// **'Login to save result'**
  String get loginToSaveResult;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive password reset link'**
  String get enterEmailForReset;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent!'**
  String get emailSent;

  /// No description provided for @checkEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and follow the instructions in the email.'**
  String get checkEmailInstructions;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @sendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send password reset email'**
  String get sendPasswordResetEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @selectCorrectForm.
  ///
  /// In en, this message translates to:
  /// **'Select the correct form'**
  String get selectCorrectForm;

  /// No description provided for @completeSentenceWithForm.
  ///
  /// In en, this message translates to:
  /// **'Complete the sentence with the correct form of \"{word}\"'**
  String completeSentenceWithForm(String word);

  /// No description provided for @levelSkipTest.
  ///
  /// In en, this message translates to:
  /// **'Level Skip Test'**
  String get levelSkipTest;

  /// No description provided for @skipToLevel.
  ///
  /// In en, this message translates to:
  /// **'Skip to {level}'**
  String skipToLevel(String level);

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have already taken the test today. Please try again tomorrow.'**
  String get dailyLimitReached;

  /// No description provided for @levelUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Level {level} unlocked!'**
  String levelUnlocked(String level);

  /// No description provided for @testFailed.
  ///
  /// In en, this message translates to:
  /// **'Test Failed'**
  String get testFailed;

  /// No description provided for @testFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Test failed. You need at least 80% to unlock the level.'**
  String get testFailedMessage;

  /// No description provided for @noQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get noQuestionsAvailable;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String questionNumber(int current, int total);

  /// No description provided for @practiceSessionHeading.
  ///
  /// In en, this message translates to:
  /// **'Practice Session'**
  String get practiceSessionHeading;

  /// No description provided for @sessionProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Progress'**
  String sessionProgressPercent(int percent);

  /// No description provided for @newSkillBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW SKILL'**
  String get newSkillBadge;

  /// No description provided for @lessonCapsLabel.
  ///
  /// In en, this message translates to:
  /// **'LESSON'**
  String get lessonCapsLabel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @grammarNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Note'**
  String get grammarNoteTitle;

  /// No description provided for @buttonSingleChoiceTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a word...'**
  String get buttonSingleChoiceTapHint;

  /// No description provided for @fillBlankNeedHint.
  ///
  /// In en, this message translates to:
  /// **'Need a hint?'**
  String get fillBlankNeedHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'ko',
    'pt',
    'ru',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
