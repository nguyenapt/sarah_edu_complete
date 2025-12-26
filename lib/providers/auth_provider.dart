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
        if (firebaseUser != null) {
          await _loadUserData(firebaseUser.uid);
        } else {
          _user = null;
        }
        _isLoading = false;
        notifyListeners();
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
        await _loadUserData(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
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
        await _loadUserData(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
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
        await _loadUserData(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
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
}

