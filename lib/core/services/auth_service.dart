import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/placement_test_model.dart';
import '../../core/constants/firebase_constants.dart';
import 'firestore_service.dart';
import 'placement_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Google Sign-In với clientId cho web platform
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '595631319099-bmkhfmrtfsqueanp0ku245iulrjn6v2e.apps.googleusercontent.com',
  );
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last active date
      await _updateLastActiveDate(credential.user!.uid);
      
      // Sync placement test result if exists
      await _syncPlacementTestResult(credential.user!.uid);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      // Kiểm tra placement test result trước để lấy level
      final placementResult = await PlacementStorageService.loadPlacementTestResult();
      final initialLevel = placementResult?.assessedLevel.toString();

      // Create user document in Firestore với level từ placement test nếu có
      await _createUserDocument(
        credential.user!,
        displayName,
        initialLevel: initialLevel,
      );

      // Sync placement test result if exists
      await _syncPlacementTestResult(credential.user!.uid);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user document
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Kiểm tra placement test result trước để lấy level
        final placementResult = await PlacementStorageService.loadPlacementTestResult();
        final initialLevel = placementResult?.assessedLevel.toString();

        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName ?? '',
          initialLevel: initialLevel,
        );
      } else {
        // Cập nhật thông tin user nếu có thay đổi (displayName, photoUrl)
        await _updateUserProfile(
          userCredential.user!.uid,
          userCredential.user!.displayName,
          userCredential.user!.photoURL,
        );
        await _updateLastActiveDate(userCredential.user!.uid);
      }

      // Sync placement test result if exists
      await _syncPlacementTestResult(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName, {String? initialLevel}) async {
    // Kiểm tra placement test result để lấy level nếu có
    String level = initialLevel ?? 'A1';
    if (initialLevel == null) {
      final result = await PlacementStorageService.loadPlacementTestResult();
      if (result != null) {
        level = result.assessedLevel.toString();
      }
    }

    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      currentLevel: level,
      totalXP: 0,
      streak: 0,
      lastActiveDate: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  // Update user profile (displayName, photoUrl)
  Future<void> _updateUserProfile(
    String userId,
    String? displayName,
    String? photoUrl,
  ) async {
    final updateData = <String, dynamic>{
      'lastActiveDate': Timestamp.fromDate(DateTime.now()),
    };

    if (displayName != null) {
      updateData['displayName'] = displayName;
    }
    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
    }

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update(updateData);
  }

  // Update last active date
  Future<void> _updateLastActiveDate(String userId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update({
      'lastActiveDate': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Sync placement test result from local storage to Firestore
  Future<void> _syncPlacementTestResult(String userId) async {
    try {
      // Load result from local storage
      final result = await PlacementStorageService.loadPlacementTestResult();
      
      if (result != null) {
        // Update result with userId
        final updatedResult = PlacementTestResult(
          userId: userId,
          assessedLevel: result.assessedLevel,
          totalQuestions: result.totalQuestions,
          correctAnswers: result.correctAnswers,
          scorePercentage: result.scorePercentage,
          categoryScores: result.categoryScores,
          categoryTotals: result.categoryTotals,
          completedAt: result.completedAt,
          timeSpentSeconds: result.timeSpentSeconds,
        );

        // Save to Firestore
        await _firestoreService.savePlacementTestResult(userId, updatedResult);

        // Update user's currentLevel
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.usersCollection)
            .doc(userId)
            .update({
          'currentLevel': result.assessedLevel.toString(),
        });

        // Clear local storage
        await PlacementStorageService.clearPlacementTestResult();
      }
    } catch (e) {
      // Ignore errors during sync - don't block login
      print('Error syncing placement test result: $e');
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng đăng nhập hoặc dùng email khác.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}

