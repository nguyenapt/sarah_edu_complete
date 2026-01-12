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

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? firebaseUser) async {
      try {
        // Cancel previous subscription if exists
        await _userSubscription?.cancel();
        _userSubscription = null;

        if (firebaseUser != null) {
          await _setupUserListener(firebaseUser.uid);
        } else {
          _user = null;
          _isLoading = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error in auth state listener: $e');
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint('Error in auth state stream: $error');
      _user = null;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Setup Firestore snapshot listener cho user data (realtime updates)
  Future<void> _setupUserListener(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Cancel previous subscription if exists
      await _userSubscription?.cancel();

      // Setup snapshot listener để tự động cập nhật khi có thay đổi trên Firestore
      _userSubscription = FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .snapshots()
          .listen(
        (DocumentSnapshot doc) {
          if (doc.exists) {
            _user = UserModel.fromFirestore(doc);
            _isLoading = false;
            notifyListeners();
            debugPrint('✅ User data updated: streak=${_user?.streak}, XP=${_user?.totalXP}');
          } else {
            _user = null;
            _isLoading = false;
            notifyListeners();
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
        await _setupUserListener(credential.user!.uid);
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
        await _setupUserListener(credential.user!.uid);
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
        await _setupUserListener(credential.user!.uid);
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

