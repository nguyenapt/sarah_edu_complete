// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'Inicio';

  @override
  String get practice => 'Práctica';

  @override
  String get progress => 'Progreso';

  @override
  String get settings => 'Configuración';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get welcome => 'Bienvenido a Sarah Edu';

  @override
  String get whatToLearnToday => '¿Qué te gustaría aprender hoy?';

  @override
  String get daysStreak => 'Días consecutivos';

  @override
  String get levels => 'Niveles';

  @override
  String get continueLearning => 'Continuar aprendiendo';

  @override
  String get loginToSync =>
      'Inicia sesión para guardar el progreso y sincronizar datos';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginWithGoogle => 'Iniciar sesión con Google';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get registerNow => 'Regístrate ahora';

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
  String get name => 'Nombre';

  @override
  String get accountInfo => 'Información de la cuenta';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get stats => 'Estadísticas';

  @override
  String get units => 'Unidades';

  @override
  String get lessons => 'Lecciones';

  @override
  String get exercises => 'Ejercicios';

  @override
  String reviewExerciseWithIndex(int number) {
    return 'Ejercicio de repaso $number';
  }

  @override
  String get exerciseDetails => 'Detalles del ejercicio';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String position(int number) {
    return 'Posición $number';
  }

  @override
  String youChose(String answer) {
    return 'Elegiste: $answer';
  }

  @override
  String get youHaventChosen => 'No has elegido';

  @override
  String correctAnswer(String answer) {
    return 'Respuesta correcta: $answer';
  }

  @override
  String youFilled(String answer) {
    return 'Completaste: \"$answer\"';
  }

  @override
  String get youHaventFilled => 'No has completado';

  @override
  String get theory => 'Teoría';

  @override
  String get examples => 'Ejemplos';

  @override
  String get usage => 'Uso';

  @override
  String get forms => 'Formas';

  @override
  String get affirmative => 'Afirmativo';

  @override
  String get negative => 'Negativo';

  @override
  String get interrogative => 'Interrogativo';

  @override
  String get grammarForm => 'Forma';

  @override
  String get minutes => 'minutos';

  @override
  String get hours => 'horas';

  @override
  String get submit => 'Enviar';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => '¡Correcto!';

  @override
  String get incorrect => '¡Incorrecto!';

  @override
  String get perfect => '¡Perfecto!';

  @override
  String get goodJob => '¡Bien hecho!';

  @override
  String get needToTryHarder => '¡Necesitas esforzarte más!';

  @override
  String question(int number) {
    return 'Pregunta $number';
  }

  @override
  String get explanation => 'Explicación';

  @override
  String get points => 'puntos';

  @override
  String get youGot => 'Obtuviste';

  @override
  String get back => 'Volver';

  @override
  String get selectOne => 'Selecciona una respuesta';

  @override
  String get selectMultiple => 'Selecciona todas las respuestas correctas';

  @override
  String get fillBlank => 'Completar espacios';

  @override
  String get matching => 'Emparejar';

  @override
  String get matchItems => 'Empareja los elementos';

  @override
  String get crossword => 'Crucigrama';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get locked => 'Bloqueado';

  @override
  String get welcomeTitle1 => 'Bienvenido a Sarah Edu';

  @override
  String get welcomeDescription1 =>
      'Aprende inglés de A1 a C2 con lecciones estructuradas y ejercicios interactivos';

  @override
  String get welcomeTitle2 => 'Rastrea tu progreso';

  @override
  String get welcomeDescription2 =>
      'Monitorea tu viaje de aprendizaje, identifica fortalezas y debilidades, y mejora continuamente';

  @override
  String get welcomeTitle3 => 'Elige tu idioma';

  @override
  String get welcomeDescription3 =>
      'Selecciona tu idioma preferido para la interfaz de la aplicación';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get skip => 'Omitir';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get sentenceForms => 'Formas de oraciones';

  @override
  String get howToUse => 'Cómo usar';

  @override
  String get lessonsList => 'Lista de lecciones';

  @override
  String lessonNumber(int number) {
    return 'Lección $number';
  }

  @override
  String get noLessons => 'No hay lecciones disponibles';

  @override
  String get noUnits => 'No hay unidades disponibles';

  @override
  String get noExercises => 'No hay ejercicios disponibles';

  @override
  String exercisesCount(int count) {
    return '$count ejercicios';
  }

  @override
  String lessonsCount(int count) {
    return '$count lecciones';
  }

  @override
  String get errorLoadingExercises => 'Error al cargar ejercicios';

  @override
  String get exerciseTypeNotSupported =>
      'Este tipo de ejercicio aún no está soportado';

  @override
  String get selectOneAnswer => 'Selecciona una respuesta correcta';

  @override
  String get selectAllCorrectAnswers =>
      'Selecciona todas las respuestas correctas';

  @override
  String youGotPoints(int points) {
    return 'Obtuviste $points puntos';
  }

  @override
  String get selectOneAnswerShort => 'Seleccionar 1 respuesta';

  @override
  String get selectMultipleAnswersShort => 'Seleccionar múltiples respuestas';

  @override
  String get listening => 'Escucha';

  @override
  String get grammar => 'Gramática';

  @override
  String get reading => 'Lectura';

  @override
  String get speaking => 'Habla';

  @override
  String get progressTitle => 'Progreso de aprendizaje';

  @override
  String get featureInDevelopment => 'Función en desarrollo';

  @override
  String get progressDescription =>
      'Estadísticas, debilidades y\ngráficos estarán disponibles pronto';

  @override
  String get practiceDescription =>
      'Práctica de IA y Práctica personalizada\nestarán disponibles pronto';

  @override
  String get learningProgress => 'Progreso de aprendizaje';

  @override
  String get loginToSaveProgress =>
      'Inicia sesión para guardar tu progreso y\nsincronizar en múltiples dispositivos';

  @override
  String get currentLevel => 'Nivel actual';

  @override
  String get unitsCompleted => 'Unidades completadas';

  @override
  String get placementTest => 'Prueba de nivelación';

  @override
  String get placementTestResult => 'Resultado de la prueba';

  @override
  String get placementTestTitle => 'Realizar prueba de evaluación de nivel';

  @override
  String get placementTestDescription =>
      'Verifica tu nivel de inglés y recibe recomendaciones de nivel apropiadas';

  @override
  String get vocabulary => 'Vocabulario';

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
  String get vocabularyLoadMore => 'Cargar más';

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
  String get weakSkills => 'Habilidades débiles';

  @override
  String get overview => 'Resumen';

  @override
  String get featureComingSoon => 'Función próximamente';

  @override
  String get all => 'Todos';

  @override
  String get review => 'Revisar';

  @override
  String get continuePractice => 'Continuar practicando';

  @override
  String get pleaseLoginToUseFeature =>
      'Por favor, inicia sesión para usar esta función';

  @override
  String get pleaseLogin => 'Por favor inicia sesión';

  @override
  String get loginToUseReviewFeature =>
      'Inicia sesión para usar la función de revisión';

  @override
  String reviewLevel(String level) {
    return 'Revisar - $level';
  }

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String youReachedLevel(String level) {
    return '¡Has alcanzado el nivel $level!';
  }

  @override
  String get continueLearningToImprove =>
      'Continúa aprendiendo para mejorar tu nivel';

  @override
  String get currentLevelText => 'Nivel actual';

  @override
  String get completed => 'Completado';

  @override
  String get notUnlocked => 'No desbloqueado';

  @override
  String get reviewLevelNotAvailable =>
      'This level is not available for review yet.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get xp => 'XP';

  @override
  String get levelLabel => 'Nivel';

  @override
  String get user => 'Usuario';

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
  String get levelSkipTest => 'Prueba de Salto de Nivel';

  @override
  String skipToLevel(String level) {
    return 'Saltar a $level';
  }

  @override
  String get dailyLimitReached =>
      'Ya has realizado la prueba hoy. Por favor, inténtalo de nuevo mañana.';

  @override
  String levelUnlocked(String level) {
    return '¡Nivel $level desbloqueado!';
  }

  @override
  String get testFailed => 'Prueba fallida';

  @override
  String get testFailedMessage =>
      'Prueba fallida. Necesitas al menos 80% para desbloquear el nivel.';

  @override
  String get noQuestionsAvailable => 'No hay preguntas disponibles';

  @override
  String questionNumber(int current, int total) {
    return 'Pregunta $current / $total';
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
