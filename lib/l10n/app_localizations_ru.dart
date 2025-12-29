// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'Главная';

  @override
  String get practice => 'Практика';

  @override
  String get progress => 'Прогресс';

  @override
  String get settings => 'Настройки';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get welcome => 'Добро пожаловать в Sarah Edu';

  @override
  String get whatToLearnToday => 'Что вы хотите изучить сегодня?';

  @override
  String get daysStreak => 'Дней подряд';

  @override
  String get levels => 'Уровни';

  @override
  String get continueLearning => 'Продолжить обучение';

  @override
  String get loginToSync =>
      'Войдите, чтобы сохранить прогресс и синхронизировать данные';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginWithGoogle => 'Войти через Google';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get registerNow => 'Зарегистрироваться';

  @override
  String get name => 'Имя';

  @override
  String get accountInfo => 'Информация об аккаунте';

  @override
  String get notifications => 'Уведомления';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get help => 'Помощь';

  @override
  String get about => 'О приложении';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get cancel => 'Отмена';

  @override
  String get stats => 'Статистика';

  @override
  String get units => 'Единицы';

  @override
  String get lessons => 'Уроки';

  @override
  String get exercises => 'Упражнения';

  @override
  String get theory => 'Теория';

  @override
  String get examples => 'Примеры';

  @override
  String get usage => 'Использование';

  @override
  String get forms => 'Формы';

  @override
  String get affirmative => 'Утвердительное';

  @override
  String get negative => 'Отрицательное';

  @override
  String get interrogative => 'Вопросительное';

  @override
  String get minutes => 'минут';

  @override
  String get hours => 'часов';

  @override
  String get submit => 'Отправить';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => 'Правильно!';

  @override
  String get incorrect => 'Неправильно!';

  @override
  String get explanation => 'Объяснение';

  @override
  String get points => 'баллов';

  @override
  String get youGot => 'Вы получили';

  @override
  String get back => 'Назад';

  @override
  String get selectOne => 'Выберите один ответ';

  @override
  String get selectMultiple => 'Выберите все правильные ответы';

  @override
  String get fillBlank => 'Заполните пропуски';

  @override
  String get matching => 'Сопоставление';

  @override
  String get easy => 'Легко';

  @override
  String get medium => 'Средне';

  @override
  String get hard => 'Сложно';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get locked => 'Заблокировано';

  @override
  String get welcomeTitle1 => 'Добро пожаловать в Sarah Edu';

  @override
  String get welcomeDescription1 =>
      'Изучайте английский от A1 до C2 с структурированными уроками и интерактивными упражнениями';

  @override
  String get welcomeTitle2 => 'Отслеживайте свой прогресс';

  @override
  String get welcomeDescription2 =>
      'Следите за своим учебным путешествием, определяйте сильные и слабые стороны и постоянно улучшайтесь';

  @override
  String get welcomeTitle3 => 'Выберите язык';

  @override
  String get welcomeDescription3 =>
      'Выберите предпочитаемый язык для интерфейса приложения';

  @override
  String get next => 'Далее';

  @override
  String get previous => 'Назад';

  @override
  String get skip => 'Пропустить';

  @override
  String get getStarted => 'Начать';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get sentenceForms => 'Формы предложений';

  @override
  String get howToUse => 'Как использовать';

  @override
  String get lessonsList => 'Список уроков';

  @override
  String lessonNumber(int number) {
    return 'Урок $number';
  }

  @override
  String get noLessons => 'Уроков нет';

  @override
  String get noUnits => 'Единиц нет';

  @override
  String get noExercises => 'Упражнений нет';

  @override
  String exercisesCount(int count) {
    return '$count упражнений';
  }

  @override
  String lessonsCount(int count) {
    return '$count уроков';
  }

  @override
  String get errorLoadingExercises => 'Ошибка загрузки упражнений';

  @override
  String get exerciseTypeNotSupported =>
      'Этот тип упражнения еще не поддерживается';

  @override
  String get selectOneAnswer => 'Выберите один правильный ответ';

  @override
  String get selectAllCorrectAnswers => 'Выберите все правильные ответы';

  @override
  String youGotPoints(int points) {
    return 'Вы получили $points баллов';
  }

  @override
  String get selectOneAnswerShort => 'Выбрать 1 ответ';

  @override
  String get selectMultipleAnswersShort => 'Выбрать несколько ответов';

  @override
  String get listening => 'Аудирование';

  @override
  String get speaking => 'Говорение';

  @override
  String get progressTitle => 'Прогресс обучения';

  @override
  String get featureInDevelopment => 'Функция в разработке';

  @override
  String get progressDescription =>
      'Статистика, слабые стороны и\nграфики скоро появятся';

  @override
  String get practiceDescription =>
      'ИИ-практика и пользовательская практика\nскоро появятся';

  @override
  String get learningProgress => 'Прогресс обучения';

  @override
  String get loginToSaveProgress =>
      'Войдите, чтобы сохранить прогресс обучения и\nсинхронизировать на нескольких устройствах';

  @override
  String get currentLevel => 'Текущий уровень';

  @override
  String get unitsCompleted => 'Завершенные единицы';

  @override
  String get placementTest => 'Тест на определение уровня';

  @override
  String get placementTestResult => 'Результат теста';

  @override
  String get placementTestTitle => 'Пройти тест на оценку уровня';

  @override
  String get placementTestDescription =>
      'Проверьте свой уровень английского и получите подходящие рекомендации по уровню';

  @override
  String get vocabulary => 'Словарь';

  @override
  String get weakSkills => 'Слабые навыки';

  @override
  String get overview => 'Обзор';

  @override
  String get featureComingSoon => 'Функция скоро появится';

  @override
  String get all => 'Все';
}
