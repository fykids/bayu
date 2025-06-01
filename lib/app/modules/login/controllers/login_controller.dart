import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan4/app/data/firebase_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive state
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var showEmailVerificationDialog = false.obs;
  var showForgotPasswordDialog = false.obs;
  var isSendingResetEmail = false.obs;
  var unverifiedUser = Rxn<User>();

  // Form field controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgotPasswordEmailController = TextEditingController();

  // Login logic
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan password wajib diisi';
      return;
    }

    // Validasi format email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      errorMessage.value = 'Format email tidak valid';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Login dengan Firebase Auth langsung
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // PENTING: Refresh user untuk mendapatkan status verifikasi terbaru
        await user.reload();
        final User? refreshedUser = _auth.currentUser;

        // Cek apakah email sudah diverifikasi setelah refresh
        if (refreshedUser != null && refreshedUser.emailVerified) {
          // Email sudah diverifikasi, login berhasil
          Get.snackbar(
            'Sukses',
            'Login berhasil!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Clear form setelah login berhasil
          _clearForm();

          // Navigasi ke halaman utama
          Get.offAllNamed('/home');
        } else {
          // Email belum diverifikasi
          await _auth.signOut(); // Sign out user yang belum terverifikasi

          unverifiedUser.value = user;
          showEmailVerificationDialog.value = true;
          errorMessage.value =
              'Email Anda belum diverifikasi. Silakan verifikasi email terlebih dahulu.';
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = _getFirebaseErrorMessage(e);
      errorMessage.value = errorMsg;

      Get.snackbar(
        'Login Gagal',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tidak diketahui';

      Get.snackbar(
        'Login Gagal',
        'Terjadi kesalahan tidak diketahui: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Alternatif login dengan pengecekan ulang status email
  Future<void> loginWithEmailCheck() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan password wajib diisi';
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      errorMessage.value = 'Format email tidak valid';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Step 1: Login terlebih dahulu
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Step 2: Reload user untuk mendapatkan status terbaru
        await user.reload();

        // Step 3: Dapatkan user yang sudah di-refresh
        final User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          print(
            'Email verified status: ${currentUser.emailVerified}',
          ); // Debug log

          if (currentUser.emailVerified) {
            // Email sudah diverifikasi - login berhasil
            Get.snackbar(
              'Sukses',
              'Login berhasil! Selamat datang.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );

            _clearForm();
            Get.offAllNamed('/home');
          } else {
            // Email belum diverifikasi
            await _auth.signOut(); // Logout user yang belum terverifikasi

            unverifiedUser.value = currentUser;
            showEmailVerificationDialog.value = true;
            errorMessage.value =
                'Email Anda belum diverifikasi. Silakan cek email dan klik link verifikasi.';

            Get.snackbar(
              'Email Belum Diverifikasi',
              'Silakan verifikasi email Anda terlebih dahulu',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = _getFirebaseErrorMessage(e);
      errorMessage.value = errorMsg;

      Get.snackbar(
        'Login Gagal',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';

      Get.snackbar(
        'Login Gagal',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk refresh status email verification
  Future<bool> checkEmailVerificationStatus() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        final User? refreshedUser = _auth.currentUser;
        return refreshedUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Forgot Password logic
  Future<void> sendPasswordResetEmail() async {
    final email = forgotPasswordEmailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSendingResetEmail.value = true;

    try {
      await _authRepository.sendPasswordResetEmail(email);

      Get.snackbar(
        'Email Terkirim',
        'Link reset password telah dikirim ke email Anda. Silakan cek inbox dan folder spam.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      closeForgotPasswordDialog();
    } on FirebaseAuthException catch (e) {
      String errorMsg = _getFirebaseErrorMessage(e);

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSendingResetEmail.value = false;
    }
  }

  // Show forgot password dialog
  void showForgotPasswordDialogMethod() {
    forgotPasswordEmailController.text = emailController.text.trim();
    showForgotPasswordDialog.value = true;
  }

  // Close forgot password dialog
  void closeForgotPasswordDialog() {
    showForgotPasswordDialog.value = false;
    forgotPasswordEmailController.clear();
  }

  // Kirim ulang email verifikasi
  Future<void> resendVerificationEmail() async {
    if (unverifiedUser.value == null) return;

    try {
      await unverifiedUser.value!.sendEmailVerification();

      Get.snackbar(
        'Email Terkirim',
        'Email verifikasi telah dikirim ulang. Silakan cek inbox dan folder spam Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal mengirim email verifikasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method untuk cek ulang verifikasi email dari dialog
  Future<void> recheckEmailVerification() async {
    if (unverifiedUser.value == null) return;

    try {
      // Sign in ulang untuk mendapatkan status terbaru
      await _auth.signInWithEmailAndPassword(
        email: unverifiedUser.value!.email!,
        password: passwordController.text,
      );

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        final User? refreshedUser = _auth.currentUser;

        if (refreshedUser != null && refreshedUser.emailVerified) {
          // Email sudah diverifikasi
          closeEmailVerificationDialog();

          Get.snackbar(
            'Verifikasi Berhasil',
            'Email Anda sudah diverifikasi. Login berhasil!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          _clearForm();
          Get.offAllNamed('/home');
        } else {
          Get.snackbar(
            'Belum Diverifikasi',
            'Email Anda masih belum diverifikasi. Silakan cek email Anda.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memeriksa status verifikasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Tutup dialog verifikasi email
  void closeEmailVerificationDialog() {
    showEmailVerificationDialog.value = false;
    unverifiedUser.value = null;
  }

  // Clear form fields
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }

  // Handle Firebase Auth errors
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'user-not-found':
        return 'Email tidak terdaftar dalam sistem';
      case 'wrong-password':
        return 'Password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'user-mismatch':
        return 'Kredensial tidak cocok dengan user yang sedang login';
      case 'requires-recent-login':
        return 'Operasi ini memerlukan login ulang';
      default:
        return e.message ?? 'Terjadi kesalahan pada autentikasi';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}
