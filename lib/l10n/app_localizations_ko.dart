// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => '홈';

  @override
  String get practice => '연습';

  @override
  String get progress => '진도';

  @override
  String get settings => '설정';

  @override
  String get welcomeBack => '다시 오신 것을 환영합니다';

  @override
  String get welcome => 'Sarah Edu에 오신 것을 환영합니다';

  @override
  String get whatToLearnToday => '오늘 무엇을 배우고 싶으신가요?';

  @override
  String get daysStreak => '연속 일수';

  @override
  String get levels => '레벨';

  @override
  String get continueLearning => '학습 계속하기';

  @override
  String get loginToSync => '진도를 저장하고 데이터를 동기화하려면 로그인하세요';

  @override
  String get login => '로그인';

  @override
  String get register => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get registerNow => '지금 가입하기';

  @override
  String get name => '이름';

  @override
  String get accountInfo => '계정 정보';

  @override
  String get notifications => '알림';

  @override
  String get language => '언어';

  @override
  String get theme => '테마';

  @override
  String get help => '도움말';

  @override
  String get about => '정보';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirm => '로그아웃하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get stats => '통계';

  @override
  String get units => '단원';

  @override
  String get lessons => '수업';

  @override
  String get exercises => '연습문제';

  @override
  String get theory => '이론';

  @override
  String get examples => '예제';

  @override
  String get usage => '사용법';

  @override
  String get forms => '형태';

  @override
  String get affirmative => '긍정';

  @override
  String get negative => '부정';

  @override
  String get interrogative => '의문';

  @override
  String get minutes => '분';

  @override
  String get hours => '시간';

  @override
  String get submit => '제출';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => '정답입니다!';

  @override
  String get incorrect => '틀렸습니다!';

  @override
  String get explanation => '설명';

  @override
  String get points => '점수';

  @override
  String get youGot => '획득한 점수';

  @override
  String get back => '뒤로';

  @override
  String get selectOne => '답 하나 선택';

  @override
  String get selectMultiple => '모든 정답 선택';

  @override
  String get fillBlank => '빈칸 채우기';

  @override
  String get matching => '매칭';

  @override
  String get easy => '쉬움';

  @override
  String get medium => '보통';

  @override
  String get hard => '어려움';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get retry => '다시 시도';

  @override
  String get unlock => '잠금 해제';

  @override
  String get locked => '잠김';

  @override
  String get welcomeTitle1 => 'Sarah Edu에 오신 것을 환영합니다';

  @override
  String get welcomeDescription1 => '구조화된 수업과 대화형 연습으로 A1부터 C2까지 영어를 배우세요';

  @override
  String get welcomeTitle2 => '진도 추적';

  @override
  String get welcomeDescription2 => '학습 여정을 모니터링하고 강점과 약점을 파악하며 지속적으로 개선하세요';

  @override
  String get welcomeTitle3 => '언어 선택';

  @override
  String get welcomeDescription3 => '앱 인터페이스에 선호하는 언어를 선택하세요';

  @override
  String get next => '다음';

  @override
  String get previous => '이전';

  @override
  String get skip => '건너뛰기';

  @override
  String get getStarted => '시작하기';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get sentenceForms => '문장 형태';

  @override
  String get howToUse => '사용법';

  @override
  String get lessonsList => '수업 목록';

  @override
  String lessonNumber(int number) {
    return '수업 $number';
  }

  @override
  String get noLessons => '수업이 없습니다';

  @override
  String get noUnits => '단원이 없습니다';

  @override
  String get noExercises => '연습문제가 없습니다';

  @override
  String exercisesCount(int count) {
    return '$count개 연습문제';
  }

  @override
  String lessonsCount(int count) {
    return '$count개 수업';
  }

  @override
  String get errorLoadingExercises => '연습문제 로딩 오류';

  @override
  String get exerciseTypeNotSupported => '이 연습 유형은 아직 지원되지 않습니다';

  @override
  String get selectOneAnswer => '정답 하나 선택';

  @override
  String get selectAllCorrectAnswers => '모든 정답 선택';

  @override
  String youGotPoints(int points) {
    return '$points점을 받았습니다';
  }

  @override
  String get selectOneAnswerShort => '1개 선택';

  @override
  String get selectMultipleAnswersShort => '여러 개 선택';

  @override
  String get listening => '듣기';

  @override
  String get speaking => '말하기';

  @override
  String get progressTitle => '학습 진행 상황';

  @override
  String get featureInDevelopment => '개발 중인 기능';

  @override
  String get progressDescription => '통계, 약점 및\n차트가 곧 제공될 예정입니다';

  @override
  String get practiceDescription => 'AI 연습 및 맞춤 연습이\n곧 제공될 예정입니다';

  @override
  String get learningProgress => '학습 진행 상황';

  @override
  String get loginToSaveProgress => '로그인하여 학습 진행 상황을 저장하고\n여러 기기에서 동기화하세요';

  @override
  String get currentLevel => '현재 레벨';

  @override
  String get unitsCompleted => '완료된 단원';

  @override
  String get placementTest => '배치 테스트';

  @override
  String get placementTestResult => '테스트 결과';

  @override
  String get placementTestTitle => '레벨 평가 테스트 받기';

  @override
  String get placementTestDescription => '영어 실력을 확인하고 적절한 레벨 추천을 받으세요';

  @override
  String get vocabulary => '어휘';

  @override
  String get weakSkills => '약한 기술';

  @override
  String get overview => '개요';

  @override
  String get featureComingSoon => '기능이 곧 출시됩니다';

  @override
  String get all => '전체';
}
