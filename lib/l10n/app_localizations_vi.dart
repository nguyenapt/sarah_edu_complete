// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Sarah Edu';

  @override
  String get home => 'Trang chủ';

  @override
  String get practice => 'Luyện tập';

  @override
  String get progress => 'Tiến độ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get welcomeBack => 'Chào mừng trở lại';

  @override
  String get welcome => 'Chào mừng đến với Sarah Edu';

  @override
  String get whatToLearnToday => 'Hôm nay bạn muốn học gì?';

  @override
  String get daysStreak => 'Ngày liên tiếp';

  @override
  String get levels => 'Các cấp độ';

  @override
  String get continueLearning => 'Tiếp tục học';

  @override
  String get loginToSync => 'Đăng nhập để lưu tiến độ và đồng bộ dữ liệu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginWithGoogle => 'Đăng nhập với Google';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản?';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản?';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get createAccountTitle => 'Tạo tài khoản mới';

  @override
  String get createAccountSubtitle => 'Điền thông tin để bắt đầu học';

  @override
  String get nameHint => 'Nhập họ và tên của bạn';

  @override
  String get emailHint => 'Nhập email của bạn';

  @override
  String get passwordHint => 'Nhập mật khẩu (ít nhất 6 ký tự)';

  @override
  String get confirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get validationNameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get validationEmailRequired => 'Vui lòng nhập email';

  @override
  String get validationEmailInvalid => 'Email không hợp lệ';

  @override
  String get validationPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get validationPasswordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get validationConfirmPasswordRequired => 'Vui lòng xác nhận mật khẩu';

  @override
  String get validationPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get name => 'Họ và tên';

  @override
  String get accountInfo => 'Thông tin tài khoản';

  @override
  String get notifications => 'Thông báo';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get help => 'Trợ giúp';

  @override
  String get about => 'Về ứng dụng';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get cancel => 'Hủy';

  @override
  String get stats => 'Thống kê';

  @override
  String get units => 'Units';

  @override
  String get lessons => 'Bài học';

  @override
  String get exercises => 'Bài tập';

  @override
  String get exerciseDetails => 'Chi tiết bài tập';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String position(int number) {
    return 'Vị trí $number';
  }

  @override
  String youChose(String answer) {
    return 'Bạn chọn: $answer';
  }

  @override
  String get youHaventChosen => 'Bạn chưa chọn';

  @override
  String correctAnswer(String answer) {
    return 'Đáp án đúng: $answer';
  }

  @override
  String youFilled(String answer) {
    return 'Bạn điền: \"$answer\"';
  }

  @override
  String get youHaventFilled => 'Bạn chưa điền';

  @override
  String get theory => 'Lý thuyết';

  @override
  String get examples => 'Ví dụ';

  @override
  String get usage => 'Cách dùng';

  @override
  String get forms => 'Các dạng câu';

  @override
  String get affirmative => 'Khẳng định';

  @override
  String get negative => 'Phủ định';

  @override
  String get interrogative => 'Nghi vấn';

  @override
  String get minutes => 'phút';

  @override
  String get hours => 'giờ';

  @override
  String get submit => 'Nộp bài';

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get correct => 'Chính xác!';

  @override
  String get incorrect => 'Sai rồi!';

  @override
  String get perfect => 'Chính xác!';

  @override
  String get goodJob => 'Tốt lắm!';

  @override
  String get needToTryHarder => 'Cần cố gắng thêm!';

  @override
  String question(int number) {
    return 'Câu $number';
  }

  @override
  String get explanation => 'Giải thích';

  @override
  String get points => 'điểm';

  @override
  String get youGot => 'Bạn nhận được';

  @override
  String get back => 'Quay lại';

  @override
  String get selectOne => 'Chọn một đáp án';

  @override
  String get selectMultiple => 'Chọn tất cả đáp án đúng';

  @override
  String get fillBlank => 'Điền từ';

  @override
  String get matching => 'Nối';

  @override
  String get matchItems => 'Ghép các mục';

  @override
  String get crossword => 'Ô chữ';

  @override
  String get easy => 'Dễ';

  @override
  String get medium => 'Trung bình';

  @override
  String get hard => 'Khó';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get retry => 'Thử lại';

  @override
  String get unlock => 'Mở khóa';

  @override
  String get locked => 'Đã khóa';

  @override
  String get welcomeTitle1 => 'Chào mừng đến với Sarah Edu';

  @override
  String get welcomeDescription1 =>
      'Học tiếng Anh từ A1 đến C2 với các bài học có cấu trúc và bài tập tương tác';

  @override
  String get welcomeTitle2 => 'Theo dõi tiến độ';

  @override
  String get welcomeDescription2 =>
      'Theo dõi hành trình học tập, xác định điểm mạnh và điểm yếu, cải thiện liên tục';

  @override
  String get welcomeTitle3 => 'Chọn ngôn ngữ';

  @override
  String get welcomeDescription3 =>
      'Chọn ngôn ngữ ưa thích cho giao diện ứng dụng';

  @override
  String get next => 'Tiếp theo';

  @override
  String get previous => 'Trước';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get sentenceForms => 'Các dạng câu';

  @override
  String get howToUse => 'Cách dùng';

  @override
  String get lessonsList => 'Danh sách bài học';

  @override
  String lessonNumber(int number) {
    return 'Bài $number';
  }

  @override
  String get noLessons => 'Chưa có bài học nào';

  @override
  String get noUnits => 'Chưa có unit nào';

  @override
  String get noExercises => 'Chưa có bài tập nào';

  @override
  String exercisesCount(int count) {
    return '$count bài tập';
  }

  @override
  String lessonsCount(int count) {
    return '$count bài học';
  }

  @override
  String get errorLoadingExercises => 'Lỗi tải bài tập';

  @override
  String get exerciseTypeNotSupported => 'Loại bài tập này chưa được hỗ trợ';

  @override
  String get selectOneAnswer => 'Chọn một đáp án đúng';

  @override
  String get selectAllCorrectAnswers => 'Chọn tất cả đáp án đúng';

  @override
  String youGotPoints(int points) {
    return 'Bạn nhận được $points điểm';
  }

  @override
  String get selectOneAnswerShort => 'Chọn 1 đáp án';

  @override
  String get selectMultipleAnswersShort => 'Chọn nhiều đáp án';

  @override
  String get listening => 'Nghe';

  @override
  String get speaking => 'Nói';

  @override
  String get progressTitle => 'Tiến Độ Học Tập';

  @override
  String get featureInDevelopment => 'Tính năng đang phát triển';

  @override
  String get progressDescription =>
      'Thống kê tiến độ, điểm yếu và\nbiểu đồ sẽ sớm có mặt tại đây';

  @override
  String get practiceDescription =>
      'AI Practice và Custom Practice\nsẽ sớm có mặt tại đây';

  @override
  String get learningProgress => 'Tiến độ học tập';

  @override
  String get loginToSaveProgress =>
      'Đăng nhập để lưu tiến độ học tập và\nđồng bộ trên nhiều thiết bị';

  @override
  String get currentLevel => 'Level hiện tại';

  @override
  String get unitsCompleted => 'Units đã hoàn thành';

  @override
  String get placementTest => 'Bài kiểm tra xếp lớp';

  @override
  String get placementTestResult => 'Kết quả kiểm tra';

  @override
  String get placementTestTitle => 'Làm bài test đánh giá cấp độ';

  @override
  String get placementTestDescription =>
      'Kiểm tra trình độ tiếng Anh của bạn và nhận đề xuất cấp độ phù hợp';

  @override
  String get vocabulary => 'Từ vựng';

  @override
  String get vocabularyFilterLabel => 'Lọc:';

  @override
  String get vocabularySearchHint => 'Tìm từ/định nghĩa';

  @override
  String get vocabularyNoMatch => 'Không tìm thấy từ vựng phù hợp';

  @override
  String get vocabularySortWordAsc => 'A-Z';

  @override
  String get vocabularySortWordDesc => 'Z-A';

  @override
  String get vocabularySortDefinitionAsc => 'ĐN A-Z';

  @override
  String get vocabularySortDefinitionDesc => 'ĐN Z-A';

  @override
  String get practiceVocabularyTitle => 'Luyện tập từ vựng';

  @override
  String get practiceVocabularyEmpty => 'Không có từ vựng để luyện tập';

  @override
  String get flashcardTapShowWord => 'Chạm để xem từ';

  @override
  String get flashcardTapShowDefinition => 'Chạm để xem định nghĩa';

  @override
  String get weakSkills => 'Kỹ năng yếu';

  @override
  String get overview => 'Tổng quan';

  @override
  String get featureComingSoon => 'Tính năng sắp ra mắt';

  @override
  String get all => 'Tất cả';

  @override
  String get review => 'Ôn Tập';

  @override
  String get continuePractice => 'Tiếp tục luyện tập';

  @override
  String get pleaseLoginToUseFeature =>
      'Vui lòng đăng nhập để sử dụng tính năng này';

  @override
  String get pleaseLogin => 'Vui lòng đăng nhập';

  @override
  String get loginToUseReviewFeature => 'Đăng nhập để sử dụng tính năng ôn tập';

  @override
  String reviewLevel(String level) {
    return 'Ôn Tập - $level';
  }

  @override
  String get congratulations => 'Chúc mừng!';

  @override
  String youReachedLevel(String level) {
    return 'Bạn đã lên cấp độ $level!';
  }

  @override
  String get continueLearningToImprove =>
      'Tiếp tục học tập để nâng cao trình độ';

  @override
  String get currentLevelText => 'Cấp độ hiện tại';

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String get notUnlocked => 'Chưa mở khóa';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String get xp => 'XP';

  @override
  String get levelLabel => 'Level';

  @override
  String get user => 'User';

  @override
  String completedExercises(int completed, int total) {
    return 'Đã hoàn thành: $completed/$total bài tập';
  }

  @override
  String get progressSaved => 'Đã lưu tiến trình học tập';

  @override
  String errorSavingProgress(String error) {
    return 'Lỗi khi lưu tiến trình: $error';
  }

  @override
  String errorLoadingData(String error) {
    return 'Lỗi tải dữ liệu: $error';
  }

  @override
  String get allLessonsCompleted => 'Bạn đã hoàn thành tất cả bài học!';

  @override
  String get noProgressData => 'Chưa có dữ liệu tiến độ.';

  @override
  String get noWeakSkillsData => 'Chưa có dữ liệu kỹ năng yếu.';

  @override
  String get skills => 'Kỹ năng';

  @override
  String get topics => 'Chủ đề';

  @override
  String get noData => 'Chưa có dữ liệu.';

  @override
  String correctPercent(int percent, int attempts) {
    return 'Đúng $percent% • $attempts lượt';
  }

  @override
  String get practiceSuggestions => 'Gợi ý bài luyện';

  @override
  String get noSuggestions => 'Chưa có gợi ý.';

  @override
  String get loginToSaveResult => 'Đăng nhập để lưu kết quả';

  @override
  String get backToHome => 'Quay lại Home';

  @override
  String get enterEmailForReset =>
      'Nhập email của bạn để nhận link đặt lại mật khẩu';

  @override
  String get emailSent => 'Đã gửi email!';

  @override
  String get checkEmailInstructions =>
      'Vui lòng kiểm tra hộp thư và làm theo hướng dẫn trong email.';

  @override
  String get enterYourEmail => 'Nhập email của bạn';

  @override
  String get pleaseEnterEmail => 'Vui lòng nhập email';

  @override
  String get sendPasswordResetEmail => 'Gửi email đặt lại mật khẩu';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get selectCorrectForm => 'Chọn dạng đúng';

  @override
  String completeSentenceWithForm(String word) {
    return 'Hoàn thành câu với dạng đúng của \"$word\"';
  }
}
