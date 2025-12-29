// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => '首页';

  @override
  String get practice => '练习';

  @override
  String get progress => '进度';

  @override
  String get settings => '设置';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get welcome => '欢迎使用 Sarah Edu';

  @override
  String get whatToLearnToday => '今天你想学什么？';

  @override
  String get daysStreak => '连续天数';

  @override
  String get levels => '级别';

  @override
  String get continueLearning => '继续学习';

  @override
  String get loginToSync => '登录以保存进度并同步数据';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get loginWithGoogle => '使用 Google 登录';

  @override
  String get dontHaveAccount => '还没有账户？';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get registerNow => '立即注册';

  @override
  String get name => '姓名';

  @override
  String get accountInfo => '账户信息';

  @override
  String get notifications => '通知';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get help => '帮助';

  @override
  String get about => '关于';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirm => '您确定要退出登录吗？';

  @override
  String get cancel => '取消';

  @override
  String get stats => '统计';

  @override
  String get units => '单元';

  @override
  String get lessons => '课程';

  @override
  String get exercises => '练习';

  @override
  String get theory => '理论';

  @override
  String get examples => '示例';

  @override
  String get usage => '用法';

  @override
  String get forms => '形式';

  @override
  String get affirmative => '肯定';

  @override
  String get negative => '否定';

  @override
  String get interrogative => '疑问';

  @override
  String get minutes => '分钟';

  @override
  String get hours => '小时';

  @override
  String get submit => '提交';

  @override
  String get continueText => 'Continue';

  @override
  String get correct => '正确！';

  @override
  String get incorrect => '错误！';

  @override
  String get explanation => '解释';

  @override
  String get points => '分数';

  @override
  String get youGot => '您获得了';

  @override
  String get back => '返回';

  @override
  String get selectOne => '选择一个答案';

  @override
  String get selectMultiple => '选择所有正确答案';

  @override
  String get fillBlank => '填空';

  @override
  String get matching => '匹配';

  @override
  String get easy => '简单';

  @override
  String get medium => '中等';

  @override
  String get hard => '困难';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get retry => '重试';

  @override
  String get unlock => '解锁';

  @override
  String get locked => '已锁定';

  @override
  String get welcomeTitle1 => '欢迎使用 Sarah Edu';

  @override
  String get welcomeDescription1 => '通过结构化课程和互动练习从 A1 到 C2 学习英语';

  @override
  String get welcomeTitle2 => '跟踪您的进度';

  @override
  String get welcomeDescription2 => '监控您的学习旅程，识别优势和劣势，并持续改进';

  @override
  String get welcomeTitle3 => '选择您的语言';

  @override
  String get welcomeDescription3 => '为应用程序界面选择您喜欢的语言';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get skip => '跳过';

  @override
  String get getStarted => '开始';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get sentenceForms => '句子形式';

  @override
  String get howToUse => '使用方法';

  @override
  String get lessonsList => '课程列表';

  @override
  String lessonNumber(int number) {
    return '课程 $number';
  }

  @override
  String get noLessons => '暂无课程';

  @override
  String get noUnits => '暂无单元';

  @override
  String get noExercises => '暂无练习';

  @override
  String exercisesCount(int count) {
    return '$count 个练习';
  }

  @override
  String lessonsCount(int count) {
    return '$count 个课程';
  }

  @override
  String get errorLoadingExercises => '加载练习时出错';

  @override
  String get exerciseTypeNotSupported => '此练习类型尚未支持';

  @override
  String get selectOneAnswer => '选择一个正确答案';

  @override
  String get selectAllCorrectAnswers => '选择所有正确答案';

  @override
  String youGotPoints(int points) {
    return '您获得了 $points 分';
  }

  @override
  String get selectOneAnswerShort => '选择 1 个答案';

  @override
  String get selectMultipleAnswersShort => '选择多个答案';

  @override
  String get listening => '听力';

  @override
  String get speaking => '口语';

  @override
  String get progressTitle => '学习进度';

  @override
  String get featureInDevelopment => '功能开发中';

  @override
  String get progressDescription => '统计、弱点和\n图表将很快推出';

  @override
  String get practiceDescription => 'AI练习和自定义练习\n将很快推出';

  @override
  String get learningProgress => '学习进度';

  @override
  String get loginToSaveProgress => '登录以保存学习进度并\n在多个设备上同步';

  @override
  String get currentLevel => '当前级别';

  @override
  String get unitsCompleted => '已完成的单元';

  @override
  String get placementTest => '分班测试';

  @override
  String get placementTestResult => '测试结果';

  @override
  String get placementTestTitle => '进行水平评估测试';

  @override
  String get placementTestDescription => '检查您的英语水平并获得合适的级别推荐';

  @override
  String get vocabulary => '词汇';

  @override
  String get weakSkills => '薄弱技能';

  @override
  String get overview => '概览';

  @override
  String get featureComingSoon => '功能即将推出';

  @override
  String get all => '全部';
}
