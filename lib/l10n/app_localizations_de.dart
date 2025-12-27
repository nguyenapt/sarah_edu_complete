// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'Startseite';

  @override
  String get practice => 'Übung';

  @override
  String get progress => 'Fortschritt';

  @override
  String get settings => 'Einstellungen';

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get welcome => 'Willkommen bei Sarah Edu';

  @override
  String get whatToLearnToday => 'Was möchten Sie heute lernen?';

  @override
  String get daysStreak => 'Tage in Folge';

  @override
  String get levels => 'Ebenen';

  @override
  String get continueLearning => 'Lernen fortsetzen';

  @override
  String get loginToSync =>
      'Melden Sie sich an, um den Fortschritt zu speichern und Daten zu synchronisieren';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get dontHaveAccount => 'Haben Sie kein Konto?';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get registerNow => 'Jetzt registrieren';

  @override
  String get name => 'Name';

  @override
  String get accountInfo => 'Kontoinformationen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Thema';

  @override
  String get help => 'Hilfe';

  @override
  String get about => 'Über';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirm => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get stats => 'Statistiken';

  @override
  String get units => 'Einheiten';

  @override
  String get lessons => 'Lektionen';

  @override
  String get exercises => 'Übungen';

  @override
  String get theory => 'Theorie';

  @override
  String get examples => 'Beispiele';

  @override
  String get usage => 'Verwendung';

  @override
  String get forms => 'Formen';

  @override
  String get affirmative => 'Bejahend';

  @override
  String get negative => 'Verneinend';

  @override
  String get interrogative => 'Fragend';

  @override
  String get minutes => 'Minuten';

  @override
  String get hours => 'Stunden';

  @override
  String get submit => 'Einreichen';

  @override
  String get correct => 'Richtig!';

  @override
  String get incorrect => 'Falsch!';

  @override
  String get explanation => 'Erklärung';

  @override
  String get points => 'Punkte';

  @override
  String get youGot => 'Sie haben erhalten';

  @override
  String get back => 'Zurück';

  @override
  String get selectOne => 'Eine Antwort auswählen';

  @override
  String get selectMultiple => 'Alle richtigen Antworten auswählen';

  @override
  String get fillBlank => 'Lücken ausfüllen';

  @override
  String get matching => 'Zuordnung';

  @override
  String get easy => 'Einfach';

  @override
  String get medium => 'Mittel';

  @override
  String get hard => 'Schwer';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fehler';

  @override
  String get retry => 'Wiederholen';

  @override
  String get unlock => 'Entsperren';

  @override
  String get locked => 'Gesperrt';

  @override
  String get welcomeTitle1 => 'Willkommen bei Sarah Edu';

  @override
  String get welcomeDescription1 =>
      'Lernen Sie Englisch von A1 bis C2 mit strukturierten Lektionen und interaktiven Übungen';

  @override
  String get welcomeTitle2 => 'Verfolgen Sie Ihren Fortschritt';

  @override
  String get welcomeDescription2 =>
      'Überwachen Sie Ihre Lernreise, identifizieren Sie Stärken und Schwächen und verbessern Sie sich kontinuierlich';

  @override
  String get welcomeTitle3 => 'Wählen Sie Ihre Sprache';

  @override
  String get welcomeDescription3 =>
      'Wählen Sie Ihre bevorzugte Sprache für die App-Oberfläche';

  @override
  String get next => 'Weiter';

  @override
  String get previous => 'Zurück';

  @override
  String get skip => 'Überspringen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get sentenceForms => 'Satzformen';

  @override
  String get howToUse => 'Verwendung';

  @override
  String get lessonsList => 'Lektionenliste';

  @override
  String lessonNumber(int number) {
    return 'Lektion $number';
  }

  @override
  String get noLessons => 'Keine Lektionen verfügbar';

  @override
  String get noUnits => 'Keine Einheiten verfügbar';

  @override
  String get noExercises => 'Keine Übungen verfügbar';

  @override
  String exercisesCount(int count) {
    return '$count Übungen';
  }

  @override
  String lessonsCount(int count) {
    return '$count Lektionen';
  }

  @override
  String get errorLoadingExercises => 'Fehler beim Laden der Übungen';

  @override
  String get exerciseTypeNotSupported =>
      'Dieser Übungstyp wird noch nicht unterstützt';

  @override
  String get selectOneAnswer => 'Eine richtige Antwort auswählen';

  @override
  String get selectAllCorrectAnswers => 'Alle richtigen Antworten auswählen';

  @override
  String youGotPoints(int points) {
    return 'Sie haben $points Punkte erhalten';
  }

  @override
  String get selectOneAnswerShort => '1 Antwort auswählen';

  @override
  String get selectMultipleAnswersShort => 'Mehrere Antworten auswählen';

  @override
  String get listening => 'Hören';

  @override
  String get speaking => 'Sprechen';

  @override
  String get progressTitle => 'Lernfortschritt';

  @override
  String get featureInDevelopment => 'Funktion in Entwicklung';

  @override
  String get progressDescription =>
      'Statistiken, Schwächen und\nDiagramme werden bald verfügbar sein';

  @override
  String get practiceDescription =>
      'KI-Übung und benutzerdefinierte Übung\nwerden bald verfügbar sein';

  @override
  String get learningProgress => 'Lernfortschritt';

  @override
  String get loginToSaveProgress =>
      'Melden Sie sich an, um Ihren Fortschritt zu speichern und\nauf mehreren Geräten zu synchronisieren';

  @override
  String get currentLevel => 'Aktuelles Level';

  @override
  String get unitsCompleted => 'Abgeschlossene Einheiten';
}
