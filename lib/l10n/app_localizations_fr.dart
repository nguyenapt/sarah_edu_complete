// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'Accueil';

  @override
  String get practice => 'Pratique';

  @override
  String get progress => 'Progrès';

  @override
  String get settings => 'Paramètres';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get welcome => 'Bienvenue sur Sarah Edu';

  @override
  String get whatToLearnToday => 'Que souhaitez-vous apprendre aujourd\'hui?';

  @override
  String get daysStreak => 'Jours consécutifs';

  @override
  String get levels => 'Niveaux';

  @override
  String get continueLearning => 'Continuer l\'apprentissage';

  @override
  String get loginToSync =>
      'Connectez-vous pour enregistrer les progrès et synchroniser les données';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get loginWithGoogle => 'Se connecter avec Google';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte?';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte?';

  @override
  String get registerNow => 'S\'inscrire maintenant';

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
  String get name => 'Nom';

  @override
  String get accountInfo => 'Informations du compte';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get help => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get cancel => 'Annuler';

  @override
  String get stats => 'Statistiques';

  @override
  String get units => 'Unités';

  @override
  String get lessons => 'Leçons';

  @override
  String get exercises => 'Exercices';

  @override
  String reviewExerciseWithIndex(int number) {
    return 'Exercice de révision $number';
  }

  @override
  String get exerciseDetails => 'Détails de l\'exercice';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String position(int number) {
    return 'Position $number';
  }

  @override
  String youChose(String answer) {
    return 'Vous avez choisi : $answer';
  }

  @override
  String get youHaventChosen => 'Vous n\'avez pas choisi';

  @override
  String correctAnswer(String answer) {
    return 'Bonne réponse : $answer';
  }

  @override
  String youFilled(String answer) {
    return 'Vous avez rempli : \"$answer\"';
  }

  @override
  String get youHaventFilled => 'Vous n\'avez pas rempli';

  @override
  String get theory => 'Théorie';

  @override
  String get examples => 'Exemples';

  @override
  String get usage => 'Utilisation';

  @override
  String get forms => 'Formes';

  @override
  String get affirmative => 'Affirmatif';

  @override
  String get negative => 'Négatif';

  @override
  String get interrogative => 'Interrogatif';

  @override
  String get grammarForm => 'Forme';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'heures';

  @override
  String get submit => 'Soumettre';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect!';

  @override
  String get perfect => 'Parfait!';

  @override
  String get goodJob => 'Bien joué!';

  @override
  String get needToTryHarder => 'Il faut faire plus d\'efforts!';

  @override
  String question(int number) {
    return 'Question $number';
  }

  @override
  String get explanation => 'Explication';

  @override
  String get points => 'points';

  @override
  String get youGot => 'Vous avez obtenu';

  @override
  String get back => 'Retour';

  @override
  String get selectOne => 'Sélectionner une réponse';

  @override
  String get selectMultiple => 'Sélectionner toutes les bonnes réponses';

  @override
  String get fillBlank => 'Remplir les blancs';

  @override
  String get matching => 'Correspondance';

  @override
  String get matchItems => 'Associez les éléments';

  @override
  String get crossword => 'Mots croisés';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get locked => 'Verrouillé';

  @override
  String get welcomeTitle1 => 'Bienvenue sur Sarah Edu';

  @override
  String get welcomeDescription1 =>
      'Apprenez l\'anglais de A1 à C2 avec des leçons structurées et des exercices interactifs';

  @override
  String get welcomeTitle2 => 'Suivez vos progrès';

  @override
  String get welcomeDescription2 =>
      'Surveillez votre parcours d\'apprentissage, identifiez vos forces et faiblesses, et améliorez-vous continuellement';

  @override
  String get welcomeTitle3 => 'Choisissez votre langue';

  @override
  String get welcomeDescription3 =>
      'Sélectionnez votre langue préférée pour l\'interface de l\'application';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get skip => 'Passer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get sentenceForms => 'Formes de phrases';

  @override
  String get howToUse => 'Comment utiliser';

  @override
  String get lessonsList => 'Liste des leçons';

  @override
  String lessonNumber(int number) {
    return 'Leçon $number';
  }

  @override
  String get noLessons => 'Aucune leçon disponible';

  @override
  String get noUnits => 'Aucune unité disponible';

  @override
  String get noExercises => 'Aucun exercice disponible';

  @override
  String exercisesCount(int count) {
    return '$count exercices';
  }

  @override
  String lessonsCount(int count) {
    return '$count leçons';
  }

  @override
  String get errorLoadingExercises => 'Erreur de chargement des exercices';

  @override
  String get exerciseTypeNotSupported =>
      'Ce type d\'exercice n\'est pas encore pris en charge';

  @override
  String get selectOneAnswer => 'Sélectionner une bonne réponse';

  @override
  String get selectAllCorrectAnswers =>
      'Sélectionner toutes les bonnes réponses';

  @override
  String youGotPoints(int points) {
    return 'Vous avez obtenu $points points';
  }

  @override
  String get selectOneAnswerShort => 'Sélectionner 1 réponse';

  @override
  String get selectMultipleAnswersShort => 'Sélectionner plusieurs réponses';

  @override
  String get listening => 'Écoute';

  @override
  String get grammar => 'Grammaire';

  @override
  String get reading => 'Lecture';

  @override
  String get speaking => 'Parole';

  @override
  String get progressTitle => 'Progrès d\'apprentissage';

  @override
  String get featureInDevelopment => 'Fonctionnalité en développement';

  @override
  String get progressDescription =>
      'Statistiques, faiblesses et\ngraphiques seront bientôt disponibles';

  @override
  String get practiceDescription =>
      'Pratique IA et Pratique personnalisée\nseront bientôt disponibles';

  @override
  String get learningProgress => 'Progrès d\'apprentissage';

  @override
  String get loginToSaveProgress =>
      'Connectez-vous pour enregistrer vos progrès et\nsynchroniser sur plusieurs appareils';

  @override
  String get currentLevel => 'Niveau actuel';

  @override
  String get unitsCompleted => 'Unités terminées';

  @override
  String get placementTest => 'Test de placement';

  @override
  String get placementTestResult => 'Résultat du test';

  @override
  String get placementTestTitle => 'Passer un test d\'évaluation de niveau';

  @override
  String get placementTestDescription =>
      'Vérifiez votre niveau d\'anglais et recevez des recommandations de niveau appropriées';

  @override
  String get vocabulary => 'Vocabulaire';

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
  String get vocabularyLoadMore => 'Charger plus';

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
  String get weakSkills => 'Compétences faibles';

  @override
  String get overview => 'Aperçu';

  @override
  String get featureComingSoon => 'Fonctionnalité à venir';

  @override
  String get all => 'Tous';

  @override
  String get review => 'Révision';

  @override
  String get continuePractice => 'Continuer à pratiquer';

  @override
  String get pleaseLoginToUseFeature =>
      'Veuillez vous connecter pour utiliser cette fonctionnalité';

  @override
  String get pleaseLogin => 'Veuillez vous connecter';

  @override
  String get loginToUseReviewFeature =>
      'Connectez-vous pour utiliser la fonctionnalité de révision';

  @override
  String reviewLevel(String level) {
    return 'Révision - $level';
  }

  @override
  String get congratulations => 'Félicitations !';

  @override
  String youReachedLevel(String level) {
    return 'Vous avez atteint le niveau $level !';
  }

  @override
  String get continueLearningToImprove =>
      'Continuez à apprendre pour améliorer votre niveau';

  @override
  String get currentLevelText => 'Niveau actuel';

  @override
  String get completed => 'Terminé';

  @override
  String get notUnlocked => 'Non déverrouillé';

  @override
  String get reviewLevelNotAvailable =>
      'This level is not available for review yet.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get xp => 'XP';

  @override
  String get levelLabel => 'Niveau';

  @override
  String get user => 'Utilisateur';

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
  String get levelSkipTest => 'Test de Saut de Niveau';

  @override
  String skipToLevel(String level) {
    return 'Passer à $level';
  }

  @override
  String get dailyLimitReached =>
      'Vous avez déjà passé le test aujourd\'hui. Veuillez réessayer demain.';

  @override
  String levelUnlocked(String level) {
    return 'Niveau $level déverrouillé !';
  }

  @override
  String get testFailed => 'Test échoué';

  @override
  String get testFailedMessage =>
      'Test échoué. Vous devez obtenir au moins 80% pour déverrouiller le niveau.';

  @override
  String get noQuestionsAvailable => 'Aucune question disponible';

  @override
  String questionNumber(int current, int total) {
    return 'Question $current / $total';
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
