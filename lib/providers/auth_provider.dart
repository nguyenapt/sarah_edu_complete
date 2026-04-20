import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Set initial loading state
    _isLoading = true;
    notifyListeners();

    // Kiểm tra currentUser ngay lập tức để tự động đăng nhập nhanh hơn
    // Điều này quan trọng cho việc khôi phục session trên Android
    _checkCurrentUser();

    // Listen to auth state changes (sẽ trigger khi có thay đổi auth state)
    _authService.authStateChanges.listen((User? firebaseUser) async {
      try {
        // Nếu đã có user từ _checkCurrentUser, không cần setup lại
        if (_user != null && firebaseUser?.uid == _user?.id) {
          debugPrint('✅ User already loaded, skipping duplicate setup');
          return;
        }

        // Cancel previous subscription if exists
        await _userSubscription?.cancel();
        _userSubscription = null;

        if (firebaseUser != null) {
          debugPrint('🔄 Auth state changed: User ${firebaseUser.uid}');
          await _setupUserListener(firebaseUser);
        } else {
          debugPrint('ℹ️ Auth state changed: No user');
          _user = null;
          _isLoading = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('❌ Error in auth state listener: $e');
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint('❌ Error in auth state stream: $error');
      _user = null;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Kiểm tra currentUser ngay lập tức để tự động đăng nhập
  /// Đây là bước quan trọng để khôi phục session đã lưu trên Android
  Future<void> _checkCurrentUser() async {
    try {
      // Firebase Auth tự động lưu session vào local storage trên Android
      // currentUser sẽ trả về user nếu session còn hợp lệ
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        // authStateChanges có thể đã hydrate trước — tránh hủy listener / ghi đè
        if (_user != null && _user!.id == currentUser.uid) {
          debugPrint(
            '✅ Session already hydrated from auth stream, skipping _checkCurrentUser',
          );
          return;
        }

        debugPrint('✅ Found existing user session: ${currentUser.uid}');
        debugPrint('   Email: ${currentUser.email}');
        debugPrint('   Display Name: ${currentUser.displayName}');

        // Dùng token cache khi có; không force refresh — getIdToken(true) cần mạng và
        // nếu lỗi sẽ không được coi là hết session (Firebase vẫn giữ currentUser).
        try {
          await currentUser.getIdToken();
          debugPrint('✅ ID token available (cached or refreshed)');
        } catch (tokenError) {
          debugPrint('⚠️ getIdToken failed (offline or transient): $tokenError');
        }

        await _setupUserListener(currentUser);
      } else {
        debugPrint('ℹ️ No existing user session found - user needs to login');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error checking current user: $e');
      _isLoading = false;
      // Không clear _user: authStateChanges có thể đã set song song
      notifyListeners();
    }
  }

  /// Setup Firestore snapshot listener cho user data (realtime updates)
  Future<void> _setupUserListener(User firebaseUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Cancel previous subscription if exists
      await _userSubscription?.cancel();

      // Optimistic user so UI (Home, Practice) does not flash guest before first snapshot.
      _user = _buildFallbackUser(firebaseUser);
      notifyListeners();

      // Setup snapshot listener để tự động cập nhật khi có thay đổi trên Firestore
      _userSubscription = FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .snapshots()
          .listen(
        (DocumentSnapshot doc) async {
          if (doc.exists) {
            _user = UserModel.fromFirestore(doc);
            _isLoading = false;
            notifyListeners();
            debugPrint('✅ User data updated: streak=${_user?.streak}, XP=${_user?.totalXP}');
          } else {
            _user = _buildFallbackUser(firebaseUser);
            _isLoading = false;
            notifyListeners();
            await _authService.ensureUserDocument(firebaseUser);
          }
        },
        onError: (error) {
          debugPrint('Error in user data listener: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error setting up user listener: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  UserModel _buildFallbackUser(User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final displayName =
        firebaseUser.displayName ?? (email.isNotEmpty ? email.split('@').first : '');

    return UserModel(
      id: firebaseUser.uid,
      email: email,
      displayName: displayName.isNotEmpty ? displayName : null,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      currentLevel: 'A1',
      totalXP: 0,
      streak: 0,
      lastActiveDate: DateTime.now(),
    );
  }

  /// Load user data một lần (dùng khi cần force refresh)
  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (credential.user != null) {
        // Listener sẽ tự động được setup trong authStateChanges listener
        // Nhưng chúng ta vẫn setup ngay để đảm bảo data được load
        await _setupUserListener(credential.user!);
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );

      if (credential.user != null) {
        // Listener sẽ tự động được setup trong authStateChanges listener
        // Nhưng chúng ta vẫn setup ngay để đảm bảo data được load
        await _setupUserListener(credential.user!);
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithGoogle();

      if (credential.user != null) {
        // Listener sẽ tự động được setup trong authStateChanges listener
        // Nhưng chúng ta vẫn setup ngay để đảm bảo data được load
        await _setupUserListener(credential.user!);
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Cancel user subscription
      await _userSubscription?.cancel();
      _userSubscription = null;

      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh user data từ Firestore (dùng khi level-up hoặc data thay đổi)
  /// Lưu ý: Với snapshot listener, data sẽ tự động cập nhật, nhưng method này
  /// vẫn hữu ích khi cần force refresh ngay lập tức
  Future<void> refreshUser() async {
    if (_user != null) {
      await _loadUserData(_user!.id);
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

