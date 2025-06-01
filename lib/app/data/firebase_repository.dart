import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Sign up with email & password
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kirim email verifikasi
      await result.user?.sendEmailVerification();

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak dikenal');
    }
  }

  // Sign in with email & password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cek apakah email sudah diverifikasi
      if (result.user != null && !result.user!.emailVerified) {
        await _firebaseAuth.signOut(); // Logout langsung
        throw EmailNotVerifiedException(
          'Email belum diverifikasi. Silakan cek inbox atau folder spam Anda.',
          result.user!,
        );
      }

      return result.user;
    } on EmailNotVerifiedException {
      rethrow; // Lempar ulang exception EmailNotVerifiedException
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak dikenal');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e),
      );
    }
  }

  // Kirim ulang email verifikasi
  Future<void> resendEmailVerification(User user) async {
    try {
      // Refresh user untuk mendapatkan status terbaru
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;
      
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await refreshedUser.sendEmailVerification();
      } else {
        throw Exception('Email sudah terverifikasi');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Gagal logout');
    }
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Listen to auth changes
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  // Check if current user's email is verified
  bool get isEmailVerified => 
      _firebaseAuth.currentUser?.emailVerified ?? false;

  // Custom error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'user-not-found':
        return 'Email tidak terdaftar dalam sistem';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'requires-recent-login':
        return 'Silakan login ulang untuk melanjutkan';
      default:
        return e.message ?? 'Terjadi kesalahan pada autentikasi';
    }
  }
}

// Custom exception untuk email yang belum diverifikasi
class EmailNotVerifiedException implements Exception {
  final String message;
  final User user;

  EmailNotVerifiedException(this.message, this.user);

  @override
  String toString() => message;
}