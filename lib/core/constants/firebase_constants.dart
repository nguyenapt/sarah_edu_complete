class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String userProgressCollection = 'userProgress';
  static const String levelsCollection = 'levels';
  static const String unitsCollection = 'units';
  static const String lessonsCollection = 'lessons';
  static const String exercisesCollection = 'exercises';
  static const String aiPracticeCollection = 'aiPractice';
  static const String placementTestCollection = 'placementTest';
  static const String groupUnitsCollection = 'groupUnits';
  static const String levelSkipTestCollection = 'levelSkipTest';
  static const String levelSkipTestAttemptsCollection = 'levelSkipTestAttempts';

  // User fields
  static const String userEmail = 'email';
  static const String userDisplayName = 'displayName';
  static const String userPhotoUrl = 'photoUrl';
  static const String userCurrentLevel = 'currentLevel';
  static const String userTotalXP = 'totalXP';
  static const String userStreak = 'streak';

  // Progress fields
  static const String progressLevelProgress = 'levelProgress';
  static const String progressWeakPoints = 'weakPoints';
  static const String progressExerciseHistory = 'exerciseHistory';

  /// `users/{uid}/vocabularyWords/{wordDocId}`
  static const String userVocabularyWordsSubcollection = 'vocabularyWords';

  static const String vocabFieldFavorited = 'favorited';
  static const String vocabFieldLastOutcome = 'lastOutcome';
  static const String vocabFieldStillLearningCount = 'stillLearningCount';
  static const String vocabFieldGotItCount = 'gotItCount';
  static const String vocabFieldEaseFactor = 'easeFactor';
  static const String vocabFieldIntervalDays = 'intervalDays';
  static const String vocabFieldRepetitions = 'repetitions';
  static const String vocabFieldNextReviewAt = 'nextReviewAt';
  static const String vocabFieldLastReviewedAt = 'lastReviewedAt';
  static const String vocabFieldUpdatedAt = 'updatedAt';
}


