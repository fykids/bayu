import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laporan4/app/data/firebase_repository.dart';

class SignupController extends GetxController {
  // Controller untuk form input
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State observables
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var acceptTerms = false.obs;

  final AuthRepository _authRepository = AuthRepository();

  // Toggle show/hide password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Toggle Terms agreement
  void toggleTerms(bool? value) {
    acceptTerms.value = value ?? false;
  }

  // Proses sign up
  Future<void> signUp() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validasi sederhana
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua field harus diisi.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!acceptTerms.value) {
      Get.snackbar(
        "Error",
        "Anda harus menyetujui syarat dan ketentuan.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Error",
        "Password dan konfirmasi tidak sama.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      User? user = await _authRepository.signUp(
        email: email,
        password: password,
      );
      if (user != null) {
        Get.snackbar(
          "Berhasil",
          "Akun berhasil dibuat!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login'); 
      }
    } catch (e) {
      Get.snackbar(
        "Gagal",
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Placeholder jika kamu ingin menambahkan Google Sign In nanti
  void signUpWithGoogle() {
    Get.snackbar(
      "Coming Soon",
      "Fitur Google Sign In belum tersedia.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
